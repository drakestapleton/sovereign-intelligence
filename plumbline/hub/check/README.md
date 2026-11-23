# hubcheck: an independent verifier of the built site

`hubcheck DIR` reads a directory that some program wrote as a static site and judges it. It
knows nothing about that program: its only input is the bytes under `DIR`. It is one Omega unit,
[`check.om`](check.om), compiled by the seed-grown `omc`. Its tests are data plus two more Omega
units in [`tests/`](tests/). Nothing here is written in another language.

Status: IMPLEMENTED and EXERCISED on a host (see "Observed" at the end). The AArch64 build ran
under `qemu-aarch64-static`, which is emulation, not AArch64 hardware.

## Build and run

`omc` is the AArch64 compiler and `omc-x86` the x86-64 one; a unit is read on stdin and the
program is written to stdout. From the repository root:

```sh
omc < plumbline/hub/check/check.om > hubcheck && chmod +x hubcheck
{ printf 'target x86linux\n'; cat plumbline/hub/check/check.om; } | omc-x86 > hubcheck && chmod +x hubcheck
./hubcheck path/to/site
```

A compile exit status other than 0 is an Omega error number; never run that output. On an
x86-64 machine the AArch64 compiler and program run as `qemu-aarch64-static omc` and
`qemu-aarch64-static ./hubcheck DIR`.

Output on stdout:

- every rule holds: one line `HUBCHECK PASS files=N html=H links=L fragments=F`, exit 0.
  `N` regular files, `H` `.html` files, `L` `href`/`src` values that start with `/`, `F`
  fragments looked up.
- otherwise one line per violation, `HUBCHECK FAIL Rnn <path relative to DIR>: <detail>`, at most
  50 of them, then `HUBCHECK FAIL violations=V` with the full count, exit 1.
- exit 2 and a line on stderr: wrong usage, or `DIR` cannot be read as a directory.

The lines do not depend on the order in which a directory is listed: all paths are collected and
sorted in byte order first. R00 for an over-long path and R11 come first, then each file in path
order with its rules in number order. Control bytes in a printed path or value show as `?`, and a
value is cut at 80 bytes.

## Bounds (reported as R00)

Exceeding a bound is a failure, never a skip.

| Bound | Report |
|---|---|
| more than 2000 files (every entry that is not an entered directory counts), or more than 2000 directories below `DIR` | `R00 .: more than 2000 files or more than 2000 directories`, and nothing else is printed |
| a directory at level 9 or deeper (`DIR` is level 0) | `R00 <dir>: directory nested deeper than 8 levels`; it is not entered |
| a file over 4194304 bytes | `R00 <file>: file over 4 MiB`; its content is not checked |
| a path over 1000 bytes relative to `DIR` | `R00 .: a path under DIR is over 1000 bytes`; it is not listed or entered |
| an unreadable file or sub-directory | `R00 <path>: cannot read the file` / `cannot read the directory` |

`DIR` itself may be at most 3000 bytes.

## Rules

Tag and attribute names are matched without regard to ASCII case. Attribute values may be in
single quotes, in double quotes, or bare. "Page" below means a `.html` or `.svg` file.

| Rule | What fails |
|---|---|
| R01 script | In a page, any `<script` (any case, anywhere in the file) that is not byte for byte `<script type='application/ld+json'>` or the same with double quotes; a second one; a block whose first `<` is not `</script>`. |
| R02 handlers | In a page, an attribute whose name starts with `on` and is at least 3 bytes; an attribute value that spells `javascript:` once leading bytes up to space are dropped, with TAB, LF and CR ignored between its letters; an `&` before the first `:`, `/` or `?` of an `href`, `src` or `xlink:href` value (a character reference there could spell a scheme). |
| R03 embeds | In a page, a tag named `iframe`, `object`, `embed`, `form` or `base`; a `meta` whose `http-equiv` is `refresh` in any case. |
| R04 outside requests | In a page: a `src`, `poster`, `ping` or `background` value, a `srcset` candidate, or an `href` of a `link` whose `rel` holds `stylesheet`, `icon`, `preload`, `preconnect`, `dns-prefetch` or `manifest`, that is neither a `data:` URL nor a local path; an `href` or `xlink:href` of an svg `image`, `use` or `feimage` that is none of those and not a fragment; `@import` or a `url(` with such a target in a `style` attribute or a `<style>` block. In a `.css` file: `@import`, and `url(` with such a target. A local path starts with `/`, does not go on with `/` or `\`, and holds no byte up to space, no `\` and no `&`. |
| R05 http | `http://` (any case) in a `.html`, `.css`, `.txt`, `.xml`, `.json` or `.svg` file, unless it is exactly `http://www.w3.org/2000/svg`, `http://www.w3.org/1999/xlink` or `http://www.sitemaps.org/schemas/sitemap/0.9` and ends there (end of file, a quote, white space, `<`, `>`, `%22` or `%27`). |
| R06 trackers | In any file, in any case: `fonts.googleapis`, `fonts.gstatic`, `googletagmanager`, `google-analytics`, `plausible.io`, `cloudflareinsights`, `umami`, `doubleclick`, `static.ads-twitter`. |
| R07 local links | In a page, an `href` or `src` value that starts with `/` (after leading bytes up to space) and whose path, up to the first `?` or `#`, does not name a regular file under `DIR`; a path ending in `/` names that directory's `index.html`. A path with `..`, `//`, `\`, `&`, a byte up to space, or over 1000 bytes is refused. A fragment, on such a link or bare (`#frag`), must be the exact value of an `id` attribute in the target, which must be a page. |
| R08 page basics | A `.html` file that does not start with `<!doctype html>` (any case); has no `html` tag with `lang` exactly `en`; does not have exactly one `title` tag without attributes, whose text starts with `INTERPLANE`; does not have exactly one `h1` tag; has no `meta` with `name` `viewport`; none with `name` `description` and a non-empty `content`; none with `charset` exactly `utf-8`. |
| R09 dashes | The bytes E2 80 93 (U+2013) or E2 80 94 (U+2014) in a `.html` or `.css` file. |
| R10 css | In a `.css` file, a `}` with no open `{`, or a `{` left open. Every brace counts, also inside a string or comment. |
| R11 required files | `index.html`, `style.css`, `robots.txt`, `sitemap.xml` or `llms.txt` missing from `DIR`, not a regular file, or empty. |
| R12 bytes | A `.html`, `.css`, `.txt`, `.xml`, `.json` or `.svg` file that is not well-formed UTF-8 (overlong forms, surrogates and values above U+10FFFF are refused) or holds a byte below 32 other than LF and TAB, or 127. The first offence of a file is reported. |
| R13 file kinds | A file whose extension is not one of `html css txt xml json svg webp png ico` in lower case; anything that is neither a regular file nor a directory (a symbolic link is not followed). |

### How a page is read

A tag starts at every `<` that a letter follows, wherever it stands: inside a comment, inside a
quoted value of another tag, inside a `<style>`, `<title>` or `<textarea>`. Nothing is skipped.
The scanner therefore sees every tag a browser sees, and some that a browser would treat as text;
those must pass the rules too. Attributes are split as HTML splits them: a name runs to white
space, `/`, `>` or `=`; a value is quoted or runs to white space or `>`. When an attribute is
repeated, every occurrence is checked.

### Where this differs from the rule list it was written from

- Bounds are reported under the number R00, which the list did not have.
- `.svg` files are treated as pages for R01 to R05 and R07.
- R02: `javascript:` is looked for in attribute values only, not in prose, and is found behind
  leading white space, mixed case and TAB/LF/CR; the `&` check is an addition.
- R04 adds `ping`, `background`, `style` attributes, `<style>` blocks and svg `image`/`use`/`feimage`
  references; a local path may not hold white space, `\` or `&`.
- R05 and R06 ignore case. A namespace string must end where it is written.
- R07 ignores a `?query`, refuses `\` and `&` beside `..` and `//`, and wants a fragment's target
  to be a page.
- R08 counts a `title` tag only when it has no attribute, as the list writes it (`<title>`). An
  inline svg `<title id='...'>` is therefore not counted. Attribute values are compared exactly.
- R12 also refuses byte 127. R13 accepts lower-case extensions only.

## What it does not check

- That a page renders, that the HTML is valid, or that JSON, XML or the JSON-LD block parse.
- Links that do not start with `/` or `#`: relative links are not resolved, and `https:`, `mailto:`
  or any other scheme passes when it is not `javascript:` or plain `http://`.
- The content of `data:` URLs (a `data:` stylesheet could itself import something).
- CSS escapes that spell `url` or `import` (`\75rl(`), `image-set()` with a bare string, and
  whether a local `url()` target in CSS exists.
- `link` relations outside the six named ones (`prefetch`, `modulepreload`, `apple-touch-icon`),
  `<?xml-stylesheet?>` in XML files, tags named `frame` or `applet`.
- Percent-encoding and character references in paths and fragments: they are compared as
  written, so `/a%20b.html` does not find `a b.html`, and a file with a space in its name cannot
  be linked.
- `name=` anchors: only `id` counts for a fragment.
- Image files: `.webp`, `.png` and `.ico` are only searched for tracker strings.
- Files whose directory entry has no type (`DT_UNKNOWN`, on some file systems) are reported as
  not regular rather than examined.
- Anything a server adds: headers, redirects, a content security policy.

## Tests

| File | What it is |
|---|---|
| [`tests/good/`](tests/good/) | A valid site of 3 pages and 13 files: single and double quotes, a bare value, upper-case names, fragment links to the same page and to another page, a `data:` favicon and a `data:` CSS image, the allowed JSON-LD block in both quote styles, inline svg with the w3 namespaces and an attributed `<title>`, a `style` attribute, a `srcset`, a file eight directories deep. |
| [`tests/cases.tsv`](tests/cases.tsv) | One case per line: the one change to make to a copy of `good/`, and what `hubcheck` must then say. |
| [`tests/run.om`](tests/run.om) | The driver: builds each case in a scratch directory, runs `hubcheck` on it as a child process, compares, cleans up. |
| [`tests/subst.om`](tests/subst.om) | Replaces exactly one occurrence of a text in a file; used to build mutants of `check.om`. |

### cases.tsv

Seven fields with a TAB between them; lines that are empty or start with `#` are skipped.

```
VERB  NAME  FILE  FROM  TO  STATUS  FIRST-LINE
```

| Verb | Change to the copy of `good/` | FILE | FROM | TO |
|---|---|---|---|---|
| `none` | nothing | `-` | `-` | `-` |
| `edit` | in FILE, replace the one occurrence of FROM by TO; zero or several occurrences fail the case (overlapping ones count separately) | path | text, not empty | text, may be empty |
| `add` | create FILE with the content TO; it must not exist; missing directories are made | path | `-` | text, may be empty |
| `del` | delete FILE; it must exist | path | `-` | `-` |
| `trunc` | make FILE empty; it must exist | path | `-` | `-` |
| `symlink` | create FILE as a symbolic link to TO | path | `-` | text |

NAME is 1 to 100 of `A-Z a-z 0-9 . _ -`, not starting with `.`; keep names unique. FILE is
relative to the copy, with no empty, `.` or `..` part. FROM and TO take the escapes `\n`, `\t`,
`\r`, `\\` and `\xHH` (two hex digits); any other backslash makes the line malformed. A field
that is only `-` means "not used"; write `\x2d` for a text that is one hyphen. STATUS is the
expected exit status and FIRST-LINE the expected first line of stdout, byte for byte. A malformed
line is itself a failure.

The table holds 90 cases: `good` unchanged, 81 that must fail (at least two for every rule R01
to R13, one for the depth bound) and 8 changed copies that must still pass (near misses on the
passing side, names `ok-*`). The bounds on file count, file size and path length are not in the
table; "Observed" records them.

### Running the tests

```sh
omc < plumbline/hub/check/tests/run.om > hubcheck-run && chmod +x hubcheck-run
mkdir work
./hubcheck-run ./hubcheck plumbline/hub/check/tests work
qemu-aarch64-static ./hubcheck-run ./hubcheck plumbline/hub/check/tests work /usr/bin/qemu-aarch64-static
```

`run HUBCHECK TESTS WORK [RUNNER]`: WORK is an existing scratch directory. For each case the
driver creates `WORK/NAME` (if it exists already the case fails and nothing is touched), copies
`TESTS/good` into it, applies the change, runs `HUBCHECK WORK/NAME` with a pipe on its stdout,
and then removes exactly the files and directories it created, `WORK/NAME` last. It removes
nothing else. RUNNER is a path (it is not searched in `PATH`) of a program to run HUBCHECK with;
the last line above is how the AArch64 build is tested on an x86-64 machine. The driver prints a
block per failing case (`wrongly passes`, `wrongly fails`, `wrong exit status or first line`, or
why the case could not be built) and ends with `HUBCHECK-TESTS PASS cases=N` (exit 0) or
`HUBCHECK-TESTS FAIL cases=N failed=F` (exit 1). Exit 2: usage, or `cases.tsv` unreadable.

### The negative control of the verifier

A test table proves little unless a broken verifier fails it. `subst` builds a mutant with one
rule's call removed, and the driver must then name that rule's cases:

```sh
omc < plumbline/hub/check/tests/subst.om > subst && chmod +x subst
./subst plumbline/hub/check/check.om mutant.om '\nr09 n\n' '\n'
omc < mutant.om > hubcheck-mutant && chmod +x hubcheck-mutant
./hubcheck-run ./hubcheck-mutant plumbline/hub/check/tests work
```

`'\nscan 0 n 3\n'` removes R03 the same way; the other calls are in `fn judge` of `check.om`.
Write the mutant outside this directory. `subst IN OUT FROM TO` takes the escapes of `cases.tsv`,
refuses zero or several occurrences of FROM (exit 1, OUT not written) and exits 2 on usage or a
file error.

## Observed

2026-11-09, x86-64 Linux host; `omc` sha256 `45442c7d...6080d`, `omc-x86` sha256 `5e1f6e1f...3f19`;
AArch64 programs under `qemu-aarch64-static` 8.2.2 (emulated). Every command below was run with
both builds and the outputs compared byte for byte; they were identical each time.

| Command | Output | Exit |
|---|---|---|
| `hubcheck tests/good` | `HUBCHECK PASS files=13 html=3 links=23 fragments=10` | 0 |
| `run hubcheck tests work` | `HUBCHECK-TESTS PASS cases=90` | 0 |
| the same with the R09 mutant | 2 blocks, `R09-em-dash-css` and `R09-en-dash-html`, each `wrongly passes`; `HUBCHECK-TESTS FAIL cases=90 failed=2` | 1 |
| the same with the R03 mutant | 6 blocks, the six `R03-*` cases, each `wrongly passes`; `HUBCHECK-TESTS FAIL cases=90 failed=6` | 1 |
| `hubcheck` with no argument, a missing directory, a file as DIR | `usage: hubcheck DIR` / `hubcheck: cannot read the directory` on stderr | 2 |

Checked by hand in a scratch directory, not kept as fixtures: a copy of `good/` grown to 2000
files passed and to 2001 failed with the R00 line above; 2000 directories passed, 2001 failed; a
`.txt` file of 4194304 bytes passed and of 4194305 failed with `file over 4 MiB`; a path of over
1000 bytes gave its R00 line; 60 planted violations printed 50 lines and `violations=60`; two
trees with the same files created in opposite orders on tmpfs (where the listing order follows
creation) gave the same output. Not run: an unreadable file or sub-directory (the host ran as
root, which can read everything), a file system that reports no entry type, and AArch64 hardware.
