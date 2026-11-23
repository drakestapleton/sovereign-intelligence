"""tests/forge/oracle.py: an independent check of the pages tools/forge.om writes.

    python3 -I tests/forge/oracle.py FACTS LEDGER DAY OUT

A verification oracle only, never part of the forge. It decodes FACTS with Python's own JSON
reader, recomputes every count from LEDGER, parses every page with Python's HTML parser and
checks: the page set; that no page has a script, an event attribute or an element outside the
small set the forge emits; every title, label and comment body as text (so escaping and JSON
decoding are both checked); every date against Python's calendar; the index's ranking; stats.tsv;
each project's 14 days of pulls. Prints one line per failed check and "ORACLE PASS pages=N
checks=M", or "ORACLE FAIL ..." with exit 1.
"""
import datetime
import html.parser
import json
import os
import sys

ALLOWED = {"html", "head", "meta", "title", "style", "body", "header", "main", "footer", "a",
           "span", "p", "h1", "h2", "h3", "div", "table", "thead", "tbody", "tr", "th", "td",
           "code", "pre", "br", "form", "input", "label", "textarea", "button"}
fails = []
checks = 0


def check(ok, what):
    global checks
    checks += 1
    if not ok:
        fails.append(what)


def clean(s):
    """the text a reader sees for a decoded JSON string: lone surrogates and control characters
    other than LF and TAB become U+FFFD (the forge's escape writes them as &#xFFFD;)"""
    out = []
    for ch in s:
        o = ord(ch)
        if 0xD800 <= o <= 0xDFFF or (o < 32 and ch not in "\n\t") or o == 127:
            out.append("�")
        else:
            out.append(ch)
    return "".join(out)


def day(ms):
    if not ms:
        return "-"
    return datetime.datetime.fromtimestamp(ms // 1000, datetime.timezone.utc).strftime("%Y-%m-%d")


class Page(html.parser.HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.tags, self.stack, self.bad = [], [], []
        self.h1 = None
        self.h1lead = ""
        self.inh1 = False
        self.h1depth = 0
        self.bodies = []
        self.cdepth = None
        self.cur = None
        self.links = []
        self.cells = []
        self.row = None
        self.cell = None

    def handle_starttag(self, tag, attrs):
        self.tags.append(tag)
        if tag not in ALLOWED:
            self.bad.append("element " + tag)
        for k, v in attrs:
            if k.lower().startswith("on"):
                self.bad.append("attribute " + k)
            if k == "href" and v and not (v.startswith("./") or v.startswith("../") or
                                          v == "stats.tsv" or v == "https://radicle.xyz" or
                                          v.endswith(".html") or v.endswith("/")):
                self.bad.append("href " + v)
            if k == "href":
                self.links.append(v)
        if tag == "h1":
            self.inh1 = True
            self.h1 = ""
            self.h1depth = 0
        elif self.inh1:
            self.h1depth += 1
        if tag == "div" and dict(attrs).get("class") is None and self.stack and self.stack[-1] == "div.c":
            self.cur = ""
        self.stack.append("div.c" if tag == "div" and dict(attrs).get("class") == "c" else tag)
        if tag == "tr":
            self.row = []
        if tag in ("td", "th") and self.row is not None:
            self.cell = ""

    def handle_endtag(self, tag):
        if self.stack:
            self.stack.pop()
        if tag == "h1":
            self.inh1 = False
        elif self.inh1:
            self.h1depth -= 1
        if tag == "div" and self.cur is not None and (not self.stack or self.stack[-1] == "div.c"):
            self.bodies.append(self.cur)
            self.cur = None
        if tag in ("td", "th") and self.cell is not None:
            self.row.append(self.cell)
            self.cell = None
        if tag == "tr" and self.row is not None:
            self.cells.append(self.row)
            self.row = None

    def handle_data(self, data):
        if self.inh1 and self.h1depth == 0:
            self.h1 += data
        if self.cur is not None:
            self.cur += data
        if self.cell is not None:
            self.cell += data


def parse(path):
    p = Page()
    with open(path, encoding="utf-8") as f:
        p.feed(f.read())
    p.close()
    check(not p.bad, "%s: %s" % (path, ", ".join(p.bad)))
    check("script" not in p.tags, "%s: has a script" % path)
    return p


def main():
    if len(sys.argv) != 5:
        print("usage: oracle.py FACTS LEDGER DAY OUT", file=sys.stderr)
        return 2
    facts, ledger, today, out = sys.argv[1:]
    projects, order_in, cobs, seeders = {}, [], [], {}
    seed = None
    with open(facts, encoding="utf-8") as f:
        lines = f.read().split("\n")[:-1]
    for ln in lines[1:]:
        k = ln.split("\t", 1)[0]
        if k == "seed":
            seed = ln.split("\t")[1]
        elif k == "project":
            _, rid, head, js = ln.split("\t", 3)
            projects[rid] = {"head": head, "p": json.loads(js)["xyz.radicle.project"],
                             "days": {}, "all": 0, "w": 0}
            order_in.append(rid)
        elif k == "seeder":
            _, rid, nid = ln.split("\t")
            seeders.setdefault(rid, set()).add(nid)
        elif k in ("issue", "patch"):
            _, rid, oid, js = ln.split("\t", 3)
            cobs.append((k, rid, oid, json.loads(js)))
    t = datetime.date.fromisoformat(today)
    first = t - datetime.timedelta(days=13)
    with open(ledger) as f:
        rows = f.read().split("\n")[1:-1]
    for r in rows:
        rid, d, h, ho, ra, pe = r.split("\t")
        if rid not in projects:
            continue
        p = projects[rid]
        n = int(h) + int(ra)
        p["all"] += n
        dd = datetime.date.fromisoformat(d)
        if first <= dd <= t:
            p["w"] += n
            p["days"][d] = (int(h), int(ho), int(ra), int(pe))

    def opened(k, j):
        if k == "issue":
            c = j["thread"]["comments"][j["thread"]["timeline"][0]]
            return c["edits"][0]["timestamp"]
        r = j["revisions"].get(j["timeline"][0])
        return r["timestamp"] if r else 0

    # the page set
    want = {"index.html", "stats.tsv"}
    for rid in projects:
        z = rid[4:]
        want.add(z + "/index.html")
    for k, rid, oid, j in cobs:
        want.add("%s/%s-%s.html" % (rid[4:], k, oid))
    have = set()
    for dp, dn, fn in os.walk(out):
        for x in fn:
            have.add(os.path.relpath(os.path.join(dp, x), out))
    check(have == want, "page set: missing %s, extra %s" % (sorted(want - have), sorted(have - want)))

    # stats.tsv and the ranking
    rank = sorted(projects, key=lambda r: (-projects[r]["w"], -projects[r]["all"], r))
    exp = ["rid\tpulls14\thttps14\trad14\tpulls\tseeders\tissues_open\tissues\tpatches_open\tpatches"]
    for rid in rank:
        p = projects[rid]
        mine = [c for c in cobs if c[1] == rid]
        iss = [c for c in mine if c[0] == "issue"]
        pat = [c for c in mine if c[0] == "patch"]
        io = sum(1 for c in iss if c[3]["state"]["status"] == "open")
        po = sum(1 for c in pat if c[3]["state"]["status"] in ("open", "draft"))
        hs = sum(v[0] for v in p["days"].values())
        rs = sum(v[2] for v in p["days"].values())
        exp.append("\t".join(str(x) for x in [rid, p["w"], hs, rs, p["all"], len(seeders.get(rid, ())),
                                                 io, len(iss), po, len(pat)]))
    with open(os.path.join(out, "stats.tsv")) as f:
        got = f.read()
    check(got == "\n".join(exp) + "\n", "stats.tsv differs:\n" + "\n".join(exp))

    pages = 0
    ix = parse(os.path.join(out, "index.html"))
    pages += 1
    links = [l for l in ix.links if l.endswith("/") and l not in ("./", "../")]
    check(links == [r[4:] + "/" for r in rank], "index ranking %s" % links)

    for rid in projects:
        z, p = rid[4:], projects[rid]
        pg = parse(os.path.join(out, z, "index.html"))
        pages += 1
        name = clean(p["p"].get("name", rid))
        check(pg.h1 == name, "%s: h1 %r, not %r" % (z, pg.h1, name))
        days = [r for r in pg.cells if len(r) >= 5 and len(r[0]) == 10 and r[0][4] == "-"]
        check(len(days) == 14, "%s: %d day rows" % (z, len(days)))
        for i, r in enumerate(days):
            d = (t - datetime.timedelta(days=i)).isoformat()
            v = p["days"].get(d, (0, 0, 0, 0))
            check(r[0] == d and [int(x) for x in r[1:5]] == list(v), "%s: pulls row %r, want %s %s" % (z, r[:5], d, v))
        check(seed + z + ".git" in open(os.path.join(out, z, "index.html"), encoding="utf-8").read(),
              "%s: no clone URL" % z)

    for k, rid, oid, j in cobs:
        path = os.path.join(out, rid[4:], "%s-%s.html" % (k, oid))
        pg = parse(path)
        pages += 1
        title = clean(j["title"])
        lab = "".join(" " for _ in j.get("labels", []))
        check(pg.h1 == title + lab, "%s: h1 %r, not %r" % (path, pg.h1, title + lab))
        src = open(path, encoding="utf-8").read()
        check(" on %s " % day(opened(k, j)) in src, "%s: opened date not %s" % (path, day(opened(k, j))))
        for l in j.get("labels", []):
            check(">" + html_text(clean(l)) + "</span>" in src, "%s: label %r" % (path, l))
        if k == "issue":
            th = j["thread"]
            want_b = [clean(th["comments"][c]["body"]) for c in th["timeline"]]
        else:
            want_b = []
            for e in j["timeline"]:
                r = j["revisions"].get(e)
                if r is None:
                    continue
                d = r["description"][-1]["body"]
                if d:
                    want_b.append(clean(d))
                disc = r["discussion"]
                want_b += [clean(disc["comments"][c]["body"]) for c in disc["timeline"]]
        check(pg.bodies == want_b, "%s: bodies %r, want %r" % (path, pg.bodies, want_b))

    if fails:
        for x in fails:
            print("FAIL " + x)
        print("ORACLE FAIL pages=%d checks=%d failed=%d" % (pages, checks, len(fails)))
        return 1
    print("ORACLE PASS pages=%d checks=%d" % (pages, checks))
    return 0


def html_text(s):
    return (s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
             .replace('"', "&quot;").replace("'", "&#39;").replace("�", "&#xFFFD;"))


if __name__ == "__main__":
    sys.exit(main())
