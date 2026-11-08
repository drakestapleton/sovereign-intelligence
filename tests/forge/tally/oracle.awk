# oracle.awk: an independent model of tools/tally.om for its gate, written from the contract in
# tools/tally.om's header, not from its code. POSIX awk (mawk works): no interval expressions.
#   awk -f oracle.awk LEDGER - < LOGS
# prints the rows of the new ledger, unsorted and without the header (sort with LC_ALL=C), and
# then one line "#sum lines L https H rad R ignored I days D rows N".
function b58(s,   i) {
  for (i = 1; i <= length(s); i++)
    if (index("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz", substr(s, i, 1)) == 0) return 0
  return 1
}
# zrun(s): the length of the leading z-run of base58 characters of s when it is 21..61 long, else 0
function zrun(s,   n) {
  if (substr(s, 1, 1) != "z") return 0
  n = 0
  while (n < length(s) && index("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz", substr(s, n + 1, 1)) > 0) n++
  return (n >= 21 && n <= 61) ? n : 0
}
function dig(s) { return s != "" && s !~ /[^0-9]/ }
function leap(y) { return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 }
function mdays(y, m) {
  if (m == 2) return leap(y) ? 29 : 28
  if (m == 4 || m == 6 || m == 9 || m == 11) return 30
  return 31
}
function day(y, m, d) { return sprintf("%04d-%02d-%02d", y, m, d) }
# isoday(s): s (10 bytes) as YYYY-MM-DD from 1970 to 9999, or ""
function isoday(s,   y, m, d) {
  if (length(s) != 10 || substr(s, 5, 1) != "-" || substr(s, 8, 1) != "-") return ""
  y = substr(s, 1, 4); m = substr(s, 6, 2); d = substr(s, 9, 2)
  if (!dig(y) || !dig(m) || !dig(d)) return ""
  y += 0; m += 0; d += 0
  if (y < 1970 || y > 9999 || m < 1 || m > 12 || d < 1 || d > mdays(y, m)) return ""
  return s
}
# https(line): the key "rid TAB day" of an HTTPS pull, with the host in H; or ""
function https(l,   i, r, x, y, m, d, hh, mi, ss, oh, om, u, z, t) {
  i = index(l, " "); if (i < 2 || i > 65) return ""
  H = substr(l, 1, i - 1); r = substr(l, i + 1)
  i = index(r, " "); if (i < 2) return ""; r = substr(r, i + 1)
  i = index(r, " "); if (i < 2) return ""; r = substr(r, i + 1)
  if (length(r) < 29) return ""
  x = substr(r, 1, 28)
  if (substr(x, 1, 1) != "[" || substr(x, 4, 1) != "/" || substr(x, 8, 1) != "/" || substr(x, 13, 1) != ":") return ""
  if (substr(x, 16, 1) != ":" || substr(x, 19, 1) != ":" || substr(x, 22, 1) != " " || substr(x, 28, 1) != "]") return ""
  m = index("JanFebMarAprMayJunJulAugSepOctNovDec", substr(x, 5, 3)); if (m == 0 || (m - 1) % 3 != 0) return ""
  m = (m - 1) / 3 + 1
  d = substr(x, 2, 2); y = substr(x, 9, 4); hh = substr(x, 14, 2); mi = substr(x, 17, 2); ss = substr(x, 20, 2)
  oh = substr(x, 24, 2); om = substr(x, 26, 2)
  if (!dig(d) || !dig(y) || !dig(hh) || !dig(mi) || !dig(ss) || !dig(oh) || !dig(om)) return ""
  d += 0; y += 0; hh += 0; mi += 0; ss += 0; oh += 0; om += 0
  if (d < 1 || d > mdays(y, m) || hh > 23 || mi > 59 || ss > 59 || oh > 23 || om > 59) return ""
  t = substr(x, 23, 1)
  if (t == "+") u = hh * 60 + mi - (oh * 60 + om); else if (t == "-") u = hh * 60 + mi + oh * 60 + om; else return ""
  if (u < 0) { d--; if (d < 1) { m--; if (m < 1) { m = 12; y-- }; d = mdays(y, m) } }
  if (u >= 1440) { d++; if (d > mdays(y, m)) { d = 1; m++; if (m > 12) { m = 1; y++ } } }
  if (y < 1970 || y > 9999) return ""
  r = substr(r, 29)
  if (substr(r, 1, 11) != " \"GET /rad/") return ""
  r = substr(r, 12); z = zrun(r); if (z == 0) return ""
  t = substr(r, 1, z); r = substr(r, z + 1)
  if (substr(r, 1, 44) != ".git/info/refs?service=git-upload-pack HTTP/") return ""
  r = substr(r, 45)
  if (length(r) < 9 || !dig(substr(r, 1, 1)) || substr(r, 2, 1) != "." || !dig(substr(r, 3, 1))) return ""
  if (substr(r, 4, 6) != "\" 200 ") return ""
  return "rad:" t "\t" day(y, m, d)
}
# radp(line): the key of a Radicle pull, with the node id in H; or ""
function radp(l,   dd, x, hh, mi, ss, r, n, z, t) {
  if (length(l) < 20) return ""
  dd = isoday(substr(l, 1, 10)); if (dd == "") return ""
  if (substr(l, 11, 1) != "T" || substr(l, 14, 1) != ":" || substr(l, 17, 1) != ":") return ""
  hh = substr(l, 12, 2); mi = substr(l, 15, 2); ss = substr(l, 18, 2)
  if (!dig(hh) || !dig(mi) || !dig(ss) || hh + 0 > 23 || mi + 0 > 59 || ss + 0 > 59) return ""
  r = substr(l, 20)
  if (substr(r, 1, 1) == ".") {
    r = substr(r, 2); n = 0
    while (n < length(r) && dig(substr(r, n + 1, 1))) n++
    if (n < 1 || n > 9) return ""
    r = substr(r, n + 1)
  }
  if (substr(r, 1, 1) != "Z") return ""
  r = substr(r, 2)
  if (r !~ /^ +INFO +wire +Peer /) return ""
  sub(/^ +INFO +wire +Peer /, "", r)
  n = zrun(r); if (n == 0) return ""
  H = substr(r, 1, n); r = substr(r, n + 1)
  if (substr(r, 1, 13) != " fetched rad:") return ""
  r = substr(r, 14); z = zrun(r); if (z == 0) return ""
  t = substr(r, 1, z)
  if (substr(r, z + 1) != " from us successfully") return ""
  return "rad:" t "\t" dd
}
FILENAME != "-" { if (FNR > 1) { k = $1 "\t" $2; L[k] = $0; nl++ }; next }
{
  lines++
  if (length($0) > 16384) next
  k = radp($0)
  if (k != "") { rad++; R[k]++; if (!((k, H) in P)) { P[k, H] = 1; PE[k]++ }; K[k] = 1; next }
  k = https($0)
  if (k != "") { hits++; S[k]++; if (!((k, H) in Q)) { Q[k, H] = 1; QE[k]++ }; K[k] = 1 }
}
END {
  rows = 0; days = 0
  for (k in K) { days++; rows++; print k "\t" (S[k] + 0) "\t" (QE[k] + 0) "\t" (R[k] + 0) "\t" (PE[k] + 0) }
  for (k in L) if (!(k in K)) { rows++; print L[k] }
  print "#sum lines " lines " https " (hits + 0) " rad " (rad + 0) " ignored " (lines - hits - rad) " days " days " rows " rows
}
