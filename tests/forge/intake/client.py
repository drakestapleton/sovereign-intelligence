"""tests/forge/intake/client.py: the HTTP client of tests/forge/intake.sh (a test oracle, not product code).

    python3 -I client.py PORT RESPONSE [expect] < REQUEST

Sends the bytes of REQUEST to 127.0.0.1:PORT and reads the reply until the server closes the
connection. Writes the reply to RESPONSE and prints its status code, or 000 when there is none.
After the code it prints BADLEN when Content-Length disagrees with the body and NOCLOSE when the
reply has no "Connection: close". With "expect" it sends only the header, waits for the server's
"HTTP/1.1 100 Continue", then sends the body; NO100 when that interim reply does not come. With
"half" it shuts down its sending side after the request, so the server sees the request end.
"""
import socket
import sys

port = int(sys.argv[1])
out = sys.argv[2]
mode = sys.argv[3] if len(sys.argv) > 3 else ""
req = sys.stdin.buffer.read()
notes = []
resp = b""
s = socket.create_connection(("127.0.0.1", port), timeout=30)
try:
    if mode == "expect":
        h = req.index(b"\r\n\r\n") + 4
        s.sendall(req[:h])
        while b"\r\n\r\n" not in resp:
            b = s.recv(4096)
            if not b:
                break
            resp += b
        if not resp.startswith(b"HTTP/1.1 100 "):
            notes.append("NO100")
        else:
            resp = resp.split(b"\r\n\r\n", 1)[1]
        s.sendall(req[h:])
    else:
        s.sendall(req)
        if mode == "half":
            s.shutdown(socket.SHUT_WR)
except (OSError, ValueError) as e:
    notes.append(type(e).__name__)
try:
    while True:
        b = s.recv(65536)
        if not b:
            break
        resp += b
except OSError as e:
    notes.append(type(e).__name__)
s.close()
with open(out, "wb") as f:
    f.write(resp)
code = "000"
if resp.startswith(b"HTTP/1.1 ") and len(resp) >= 12:
    code = resp[9:12].decode("ascii", "replace")
    head, sep, body = resp.partition(b"\r\n\r\n")
    lines = head.split(b"\r\n")[1:]
    fields = {}
    for ln in lines:
        k, _, v = ln.partition(b":")
        fields[k.strip().lower()] = v.strip()
    if fields.get(b"content-length") != str(len(body)).encode():
        notes.append("BADLEN")
    if fields.get(b"connection") != b"close":
        notes.append("NOCLOSE")
print(" ".join([code] + notes))
