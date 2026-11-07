import http.client
import json
import sqlite3
import tempfile
import threading
import unittest
from pathlib import Path
from http.server import ThreadingHTTPServer

from server.waitlist_api import (
    CONSENT_VERSION,
    RateLimiter,
    WaitlistStore,
    build_handler,
    normalize_email,
)


class WaitlistApiTests(unittest.TestCase):
    def test_normalizes_email(self):
        self.assertEqual(normalize_email("  Drake@Example.COM "), "drake@example.com")

    def test_rejects_invalid_email(self):
        for value in ("", "drake", "@example.com", "drake@example"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                normalize_email(value)

    def test_store_is_insert_only_and_deduplicates(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            database = str(Path(temp_dir) / "waitlist.sqlite3")
            store = WaitlistStore(database)
            self.assertTrue(store.add("drake@example.com", CONSENT_VERSION))
            self.assertFalse(store.add("drake@example.com", CONSENT_VERSION))
            with sqlite3.connect(database) as connection:
                row = connection.execute(
                    "select email, consent_version from waitlist_signups"
                ).fetchone()
            self.assertEqual(row, ("drake@example.com", CONSENT_VERSION))

    def test_rate_limiter_closes_after_limit(self):
        limiter = RateLimiter(limit=2, window_seconds=60)
        self.assertTrue(limiter.allow("test"))
        self.assertTrue(limiter.allow("test"))
        self.assertFalse(limiter.allow("test"))


class WaitlistHttpTests(unittest.TestCase):
    origin = "https://www.drakestapleton.com"

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.store = WaitlistStore(str(Path(self.temp_dir.name) / "waitlist.sqlite3"))
        handler = build_handler(self.store, "test-release", {self.origin})
        self.server = ThreadingHTTPServer(("127.0.0.1", 0), handler)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)
        self.temp_dir.cleanup()

    def request(self, method, path, payload=None, origin=None):
        connection = http.client.HTTPConnection("127.0.0.1", self.server.server_port)
        body = json.dumps(payload) if payload is not None else None
        headers = {}
        if payload is not None:
            headers["Content-Type"] = "application/json"
        if origin:
            headers["Origin"] = origin
        connection.request(method, path, body=body, headers=headers)
        response = connection.getresponse()
        data = json.loads(response.read()) if response.length else None
        result = response.status, dict(response.getheaders()), data
        connection.close()
        return result

    def signup(self, **overrides):
        payload = {
            "email": "drake@example.com",
            "consent": True,
            "consentVersion": CONSENT_VERSION,
            "website": "",
            "elapsedMs": 1500,
        }
        payload.update(overrides)
        return self.request("POST", "/api/signup", payload, self.origin)

    def stored_count(self):
        with sqlite3.connect(self.store.path) as connection:
            return connection.execute("select count(*) from waitlist_signups").fetchone()[0]

    def test_health_reports_release_and_security_headers(self):
        status, headers, payload = self.request("GET", "/healthz")
        self.assertEqual(status, 200)
        self.assertEqual(payload, {"ok": True, "release": "test-release"})
        self.assertEqual(headers["Cache-Control"], "no-store")
        self.assertEqual(headers["X-Content-Type-Options"], "nosniff")
        self.assertEqual(headers["Strict-Transport-Security"], "max-age=31536000")

    def test_valid_signup_is_stored_with_allowlisted_cors(self):
        status, headers, payload = self.signup()
        self.assertEqual(status, 201)
        self.assertEqual(payload, {"ok": True})
        self.assertEqual(headers["Access-Control-Allow-Origin"], self.origin)
        self.assertEqual(self.stored_count(), 1)

    def test_disallowed_origin_fails_closed(self):
        status, headers, payload = self.request(
            "POST",
            "/api/signup",
            {
                "email": "drake@example.com",
                "consent": True,
                "consentVersion": CONSENT_VERSION,
                "website": "",
                "elapsedMs": 1500,
            },
            "https://example.com",
        )
        self.assertEqual(status, 403)
        self.assertEqual(payload["ok"], False)
        self.assertNotIn("Access-Control-Allow-Origin", headers)
        self.assertEqual(self.stored_count(), 0)

    def test_honeypot_and_fast_submit_leave_database_unchanged(self):
        self.assertEqual(self.signup(website="bot.example")[0], 202)
        self.assertEqual(self.signup(email="second@example.com", elapsedMs=250)[0], 202)
        self.assertEqual(self.stored_count(), 0)


if __name__ == "__main__":
    unittest.main()
