#!/usr/bin/env python3
"""Minimal TLS waitlist API with insert-only public behavior."""

from __future__ import annotations

import json
import os
import re
import sqlite3
import ssl
import threading
import time
import uuid
from collections import defaultdict, deque
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

EMAIL_RE = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
MAX_BODY_BYTES = 8192
CONSENT_VERSION = "2026-08-13-v1"
DEFAULT_ORIGINS = {
    "https://www.drakestapleton.com",
    "https://drakestapleton.com",
}


def normalize_email(value: object) -> str:
    email = str(value or "").strip().lower()
    if len(email) > 254 or not EMAIL_RE.fullmatch(email):
        raise ValueError("invalid email")
    return email


class WaitlistStore:
    def __init__(self, path: str):
        self.path = path
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        with self.connect() as connection:
            connection.execute(
                """
                create table if not exists waitlist_signups (
                  id text primary key,
                  email text not null unique,
                  consent_version text not null,
                  created_at text not null
                )
                """
            )
            connection.commit()

    def connect(self) -> sqlite3.Connection:
        connection = sqlite3.connect(self.path, timeout=5)
        connection.execute("pragma journal_mode = wal")
        connection.execute("pragma foreign_keys = on")
        return connection

    def add(self, email: str, consent_version: str) -> bool:
        try:
            with self.connect() as connection:
                connection.execute(
                    "insert into waitlist_signups (id, email, consent_version, created_at) values (?, ?, ?, ?)",
                    (
                        str(uuid.uuid4()),
                        email,
                        consent_version,
                        datetime.now(timezone.utc).isoformat(),
                    ),
                )
                connection.commit()
            return True
        except sqlite3.IntegrityError:
            return False


class RateLimiter:
    def __init__(self, limit: int = 8, window_seconds: int = 3600):
        self.limit = limit
        self.window_seconds = window_seconds
        self.events: dict[str, deque[float]] = defaultdict(deque)
        self.lock = threading.Lock()

    def allow(self, key: str) -> bool:
        now = time.monotonic()
        with self.lock:
            events = self.events[key]
            while events and now - events[0] > self.window_seconds:
                events.popleft()
            if len(events) >= self.limit:
                return False
            events.append(now)
            return True


def build_handler(store: WaitlistStore, release_marker: str, allowed_origins: set[str]):
    limiter = RateLimiter()

    class WaitlistHandler(BaseHTTPRequestHandler):
        server_version = "DrakeWaitlist/1"

        def log_message(self, format_string: str, *args: object) -> None:
            # Do not log request bodies or email addresses.
            super().log_message(format_string, *args)

        def origin(self) -> str | None:
            origin = self.headers.get("Origin")
            return origin if origin in allowed_origins else None

        def security_headers(self) -> None:
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Security-Policy", "default-src 'none'; frame-ancestors 'none'")
            self.send_header("Referrer-Policy", "no-referrer")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("X-Frame-Options", "DENY")
            self.send_header("Strict-Transport-Security", "max-age=31536000")
            origin = self.origin()
            if origin:
                self.send_header("Access-Control-Allow-Origin", origin)
                self.send_header("Vary", "Origin")

        def respond(self, status: int, payload: dict[str, object]) -> None:
            body = json.dumps(payload, separators=(",", ":")).encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.security_headers()
            self.end_headers()
            self.wfile.write(body)

        def do_OPTIONS(self) -> None:
            if self.path != "/api/signup" or not self.origin():
                self.respond(403, {"ok": False})
                return
            self.send_response(204)
            self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
            self.send_header("Access-Control-Max-Age", "600")
            self.security_headers()
            self.end_headers()

        def do_GET(self) -> None:
            if self.path == "/healthz":
                self.respond(200, {"ok": True, "release": release_marker})
                return
            self.respond(404, {"ok": False})

        def do_POST(self) -> None:
            if self.path != "/api/signup":
                self.respond(404, {"ok": False})
                return
            if not self.origin():
                self.respond(403, {"ok": False, "message": "origin not allowed"})
                return
            if not limiter.allow(self.client_address[0]):
                self.respond(429, {"ok": False, "message": "try again later"})
                return
            if self.headers.get_content_type() != "application/json":
                self.respond(415, {"ok": False, "message": "json required"})
                return

            try:
                length = int(self.headers.get("Content-Length", "0"))
            except ValueError:
                length = 0
            if length <= 0 or length > MAX_BODY_BYTES:
                self.respond(413, {"ok": False, "message": "invalid request size"})
                return

            try:
                payload = json.loads(self.rfile.read(length))
                email = normalize_email(payload.get("email"))
                if payload.get("consent") is not True:
                    raise ValueError("consent required")
                if payload.get("consentVersion") != CONSENT_VERSION:
                    raise ValueError("consent version mismatch")
                if str(payload.get("website") or ""):
                    self.respond(202, {"ok": True})
                    return
                elapsed_ms = int(payload.get("elapsedMs") or 0)
                if elapsed_ms < 1200:
                    self.respond(202, {"ok": True})
                    return
            except (ValueError, TypeError, json.JSONDecodeError):
                self.respond(400, {"ok": False, "message": "invalid signup"})
                return

            store.add(email, CONSENT_VERSION)
            # Duplicate and new signups intentionally return the same response.
            self.respond(201, {"ok": True})

    return WaitlistHandler


def main() -> None:
    host = os.environ.get("WAITLIST_HOST", "0.0.0.0")
    port = int(os.environ.get("WAITLIST_PORT", "8443"))
    database_path = os.environ.get(
        "WAITLIST_DB_PATH", "/var/lib/drake-waitlist/waitlist.sqlite3"
    )
    release_marker = os.environ.get("WAITLIST_RELEASE", "development")
    origins = {
        item.strip()
        for item in os.environ.get("WAITLIST_ALLOWED_ORIGINS", "").split(",")
        if item.strip()
    } or DEFAULT_ORIGINS

    server = ThreadingHTTPServer(
        (host, port), build_handler(WaitlistStore(database_path), release_marker, origins)
    )
    cert_path = os.environ.get("WAITLIST_CERT_PATH")
    key_path = os.environ.get("WAITLIST_KEY_PATH")
    if cert_path and key_path:
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.minimum_version = ssl.TLSVersion.TLSv1_2
        context.load_cert_chain(certfile=cert_path, keyfile=key_path)
        server.socket = context.wrap_socket(server.socket, server_side=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
