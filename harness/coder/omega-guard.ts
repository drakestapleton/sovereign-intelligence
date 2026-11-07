// omega-guard: omp extension for `aien --omega`. Harness configuration, not product code: omp
// extensions are TypeScript, so this file is the smallest shim between the omp tool loop and the
// pinned seeded Omega compiler. All checking of programs is done by Omega itself: `omc` compiles,
// and the OM-2 qualification conductor `seed/qualification/om2/gate.om` (built by the pinned omc)
// runs and compares task cases. This file only routes paths, starts those two binaries and sandboxes
// model-written programs with bubblewrap.
//
// Policy
// - write/edit may touch only `*.om` files (plus NOTES.md) inside the session directory; every other
//   path, an `MV` to a non-.om name, and archive/URL targets are refused before the tool runs.
// - read/grep/glob are confined to the session directory and the Omega context pack.
// - Every tool other than read, grep, glob, edit, write and omega_run is refused (no shell).
// - After a successful write/edit of a `.om` file the pinned omc compiles it; the result (rc, the
//   `omc: line N: error K` line, the offending source line and the error's meaning) is appended to
//   the tool result the model sees.
// - omega_run compiles a `.om` file and runs it in a bubblewrap sandbox: read-only root, private
//   /tmp, no network, own pid namespace, 10 s wall limit.
// - The session cannot end while any touched `.om` file fails to compile, or, when OMEGA_CASES names a
//   gate case list, until the gate prints `OM2GATE PASS`.
//
// Environment: OMEGA_HOME (default ~/.local/share/aien-omega: omc, gate, gate fixtures, context/),
// OMEGA_CASES (optional case list for the stop check; keep it outside the session directory).
import { spawnSync } from 'node:child_process'
import { createHash } from 'node:crypto'
import { appendFileSync, chmodSync, existsSync, mkdtempSync, readFileSync, realpathSync } from 'node:fs'
import { homedir, tmpdir } from 'node:os'
import { basename, isAbsolute, join, resolve, sep } from 'node:path'

const OMEGA_HOME = process.env.OMEGA_HOME || join(homedir(), '.local/share/aien-omega')
const OMC = join(OMEGA_HOME, 'omc')
const GATE = join(OMEGA_HOME, 'gate')
// Readable Omega reference. The eval control arm points this at an empty directory.
const CONTEXT = process.env.OMEGA_CONTEXT || join(OMEGA_HOME, 'context')
// Stop refusals before the session may end anyway (eval runs set it; unset means no limit).
const STOP_LIMIT = Number(process.env.OMEGA_STOP_LIMIT || 0)
// omega-mv f1b9ecb5d13f3b7303c055a187fff06e802eb952, seed/out/omc (commit 82a399b9f "batch 2 pin 2c824805").
const OMC_SHA256 = '2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f'
const LOG = process.env.OMEGA_LOG

function note(line: string): void {
  if (LOG) appendFileSync(LOG, `${new Date().toISOString()} ${line}\n`)
}
const ALLOWED_TOOLS = new Set(['read', 'grep', 'glob', 'edit', 'write', 'omega_run'])
const BUILD = mkdtempSync(join(tmpdir(), 'aien-omega-'))

const ERRORS: Record<number, string> = {
  1: 'compiler I/O', 2: 'compiler I/O', 3: 'unknown name or field', 4: 'line ends too early (missing value)',
  5: 'extra words on the line', 6: 'malformed number', 7: 'type mismatch (no implicit conversion)',
  8: 'number out of range', 9: 'word in a disallowed place', 10: 'duplicate name', 11: 'ambiguous bare number (give it a type: uint 5)',
  12: 'register pool exhausted (fewer live names or split the function)', 13: 'name too long (non-function names at most 8 characters)',
  14: 'capacity', 15: 'missing end', 16: 'syntax error or unknown word', 17: 'line after ret/break/continue/trap/exit',
  18: 'missing ret (end of a value-returning function is reachable)', 19: 'global passed as argument, or same array twice in one call',
  20: 'write to a view or text', 21: 'constant index out of range', 22: 'bad text literal', 23: 'size capacity',
}

type Ctx = { cwd?: string }
type Content = { type: string; text?: string }
type Pi = {
  on(name: string, handler: (event: any, ctx: Ctx) => unknown): void
  registerTool(def: any): void
  zod: any
}

function omcVerified(): string | undefined {
  try {
    const sha = createHash('sha256').update(readFileSync(OMC)).digest('hex')
    return sha === OMC_SHA256 ? undefined : `pinned omc mismatch: ${OMC} sha256 ${sha}, expected ${OMC_SHA256}`
  } catch (e) {
    return `pinned omc unreadable: ${OMC}: ${e}`
  }
}

function root(ctx: Ctx): string {
  return realpathSync(ctx.cwd || process.cwd())
}

// Resolve a model-supplied path the way the file tools do (relative to the session directory).
// Symlinks are resolved for the existing prefix so a link cannot carry a write outside the root.
function resolvePath(p: string, base: string): string {
  let abs = resolve(base, p)
  let probe = abs
  const tail: string[] = []
  while (!existsSync(probe) && probe !== sep) {
    tail.unshift(basename(probe))
    probe = resolve(probe, '..')
  }
  try {
    abs = join(realpathSync(probe), ...tail)
  } catch {}
  return abs
}

function inside(abs: string, dir: string): boolean {
  return abs === dir || abs.startsWith(dir.endsWith(sep) ? dir : dir + sep)
}

function writePaths(tool: string, input: any): string[] {
  const out: string[] = []
  // The edit tool takes `path` as `FILE#TAG` (TAG = snapshot hash from the last read); the tag is not part of the
  // path. Anything else after a `#` is kept, and checkWrite refuses every path that still contains `#`.
  for (const k of ['path', 'file_path', 'file', 'target']) {
    const p = input?.[k]
    if (typeof p !== 'string') continue
    const h = p.lastIndexOf('#')
    out.push(h >= 0 && /^[0-9A-Za-z]+$/.test(p.slice(h + 1)) ? p.slice(0, h) : p)
  }
  if (typeof input?.input === 'string') {
    for (const m of input.input.matchAll(/^\[([^\]#\n]+)#/gm)) out.push(m[1])
    for (const m of input.input.matchAll(/^\s*MV\s+("([^"]+)"|(\S+))/gm)) out.push(m[2] ?? m[3])
  }
  if (Array.isArray(input?.edits)) for (const e of input.edits) if (typeof e?.path === 'string') out.push(e.path)
  if (tool === 'write' && out.length === 0) out.push('')
  return out
}

function readPaths(input: any): string[] {
  const out: string[] = []
  for (const k of ['path', 'paths', 'file_path']) {
    const v = input?.[k]
    if (typeof v === 'string') out.push(...v.split(';').map((s: string) => s.trim()).filter(Boolean))
    if (Array.isArray(v)) out.push(...v.filter((s: unknown) => typeof s === 'string'))
  }
  return out
}

function stripSelector(p: string): string {
  // read accepts `file.om:10-20`; the selector is not part of the path.
  return p.replace(/:(raw|conflicts|img|[-+0-9,]+[-+0-9,:raw]*)$/, '')
}

function checkWrite(p: string, base: string): string | undefined {
  if (!p) return 'write needs a path ending in .om'
  if (p.includes('://') || p.includes(':') || p.includes('#')) return `refused: ${p}: only plain paths to .om files may be written`
  const abs = resolvePath(p, base)
  if (!inside(abs, base)) return `refused: ${p} is outside the session directory ${base}`
  if (abs.endsWith('.om') || basename(abs) === 'NOTES.md') return undefined
  return `refused: ${p}: this session writes Omega only; edit or create .om files (or NOTES.md for notes)`
}

function checkRead(p: string, base: string): string | undefined {
  if (p.startsWith('artifact://')) return undefined
  if (p.includes('://')) return `refused: ${p}: read only files in ${base} or the Omega reference`
  const abs = resolvePath(stripSelector(p).replace(/[*?{[].*$/, '') || '.', base)
  let pack = CONTEXT
  try {
    pack = realpathSync(CONTEXT)
  } catch {}
  if (inside(abs, base) || inside(abs, pack)) return undefined
  return `refused: ${p} is outside ${base} and the Omega reference ${pack}`
}

type Compile = { rc: number; elf: string; report: string }

function compile(file: string): Compile {
  const bad = omcVerified()
  if (bad) return { rc: -1, elf: '', report: `OMC REFUSED: ${bad}` }
  const src = readFileSync(file)
  const elf = join(BUILD, createHash('sha256').update(file).digest('hex').slice(0, 16))
  const r = spawnSync('sh', ['-c', '"$1" < "$2" > "$3" 2> "$3.err"', 'omc', OMC, file, elf])
  const rc = r.status ?? -1
  let err = ''
  try {
    err = readFileSync(`${elf}.err`, 'utf8').trim()
  } catch {}
  if (rc === 0) {
    chmodSync(elf, 0o755)
    return { rc, elf, report: `omc: compile rc=0 (${basename(file)}, pinned omc ${OMC_SHA256.slice(0, 8)})` }
  }
  const m = err.match(/line (\d+): error (\d+)/)
  let detail = err || '(no diagnostic)'
  if (m) {
    const line = src.toString('utf8').split('\n')[Number(m[1]) - 1] ?? ''
    detail = `${err}\n  error ${m[2]} = ${ERRORS[Number(m[2])] ?? 'see the error table'}\n  line ${m[1]}: ${line}`
  }
  return { rc, elf: '', report: `omc: compile FAILED rc=${rc} (${basename(file)})\n${detail}\nFix the .om source; never run output from a failed compile.` }
}

function sandboxRun(elf: string, base: string, args: string[], stdin: string): { rc: number; out: string; err: string } {
  const r = spawnSync(
    'bwrap',
    ['--ro-bind', '/', '/', '--dev', '/dev', '--proc', '/proc', '--tmpfs', '/tmp', '--ro-bind', base, base, '--ro-bind', elf, '/tmp/prog',
      '--unshare-net', '--unshare-pid', '--die-with-parent', '--chdir', base, '--', '/tmp/prog', ...args],
    { input: stdin, timeout: 10_000, maxBuffer: 1 << 22 },
  )
  const cut = (b: Buffer | null) => {
    const s = (b ?? Buffer.alloc(0)).toString('utf8')
    return s.length > 8192 ? `${s.slice(0, 8192)}\n[... ${s.length - 8192} more bytes cut]` : s
  }
  return { rc: r.error ? -1 : (r.status ?? (r.signal ? 128 : -1)), out: cut(r.stdout), err: r.error ? String(r.error) : cut(r.stderr) }
}

function trapNote(rc: number): string {
  const traps: Record<number, string> = {
    101: 'trap 1 signed overflow', 102: 'trap 2 divide by zero', 103: 'trap 3 index or slice out of bounds', 104: 'trap 4 loop bound exceeded',
    105: 'trap 5 conversion does not fit', 106: 'trap 6 stack exhausted', 107: 'trap 7 shift amount out of range',
  }
  if (rc < 0) return ' (did not finish: timeout or sandbox failure)'
  if (traps[rc]) return ` (${traps[rc]})`
  if (rc > 100 && rc <= 114) return ` (trap ${rc - 100})`
  return ''
}

export default function (pi: Pi) {
  const touched = new Map<string, number>()
  const z = pi.zod

  const block = (tool: string, reason: string) => {
    note(`tool ${tool} refused: ${reason}`)
    return { block: true, reason }
  }

  pi.on('tool_call', async (event: any, ctx: Ctx) => {
    const base = root(ctx)
    const tool = String(event.toolName)
    if (!ALLOWED_TOOLS.has(tool)) return block(tool, `refused: ${tool} is not available in Omega mode; use omega_run to run .om programs`)
    if (tool === 'edit' || tool === 'write') {
      for (const p of writePaths(tool, event.input)) {
        const why = checkWrite(p, base)
        if (why) return block(tool, why)
      }
    }
    if (tool === 'read' || tool === 'grep' || tool === 'glob') {
      for (const p of readPaths(event.input)) {
        const why = checkRead(p, base)
        if (why) return block(tool, why)
      }
    }
    note(`tool ${tool} allowed`)
    return undefined
  })

  pi.on('tool_result', async (event: any, ctx: Ctx) => {
    const tool = String(event.toolName)
    if ((tool !== 'edit' && tool !== 'write') || event.isError) return undefined
    const base = root(ctx)
    const reports: string[] = []
    for (const p of writePaths(tool, event.input)) {
      const abs = resolvePath(p, base)
      if (!abs.endsWith('.om') || !existsSync(abs)) continue
      const c = compile(abs)
      touched.set(abs, c.rc)
      reports.push(c.report)
      note(`${tool} ${basename(abs)}: ${c.report.split('\n').slice(0, 2).join(' | ')}`)
    }
    if (reports.length === 0) return undefined
    const content: Content[] = [...(event.content ?? []), { type: 'text', text: `\n${reports.join('\n')}` }]
    return { content }
  })

  pi.registerTool({
    name: 'omega_run',
    label: 'Omega run',
    description:
      'Compile a .om file with the pinned seeded Omega compiler and, if it compiles, run it in a sandbox (read-only files, no network, 10 s). Returns the compiler diagnostic or the exit status, stdout and stderr. Exit status 101..114 is a runtime trap (100 + trap code).',
    parameters: z.object({
      path: z.string().describe('the .om file to compile and run'),
      stdin: z.string().optional().describe('bytes given to the program on standard input'),
      args: z.array(z.string()).optional().describe('command-line arguments after the program name'),
    }),
    loadMode: 'essential',
    async execute(_id: string, params: { path: string; stdin?: string; args?: string[] }, _signal: unknown, _onUpdate: unknown, ctx: Ctx) {
      const base = root(ctx)
      const abs = resolvePath(params.path, base)
      const text = (t: string) => ({ content: [{ type: 'text', text: t }] })
      if (!abs.endsWith('.om') || !inside(abs, base) || !existsSync(abs)) return text(`omega_run: ${params.path} is not a .om file in ${base}`)
      const c = compile(abs)
      touched.set(abs, c.rc)
      if (c.rc !== 0) {
        note(`omega_run ${basename(abs)}: compile FAILED rc=${c.rc}`)
        return text(c.report)
      }
      const r = sandboxRun(c.elf, base, params.args ?? [], params.stdin ?? '')
      note(`omega_run ${basename(abs)}: run exit=${r.rc} stdout_bytes=${Buffer.byteLength(r.out)}`)
      return text(`${c.report}\nrun exit status=${r.rc}${trapNote(r.rc)}\n--- stdout ---\n${r.out}\n--- stderr ---\n${r.err}`)
    },
  })

  let refusals = 0
  const refuse = (reason: string) => {
    refusals += 1
    if (STOP_LIMIT > 0 && refusals > STOP_LIMIT) {
      note(`stop allowed after ${STOP_LIMIT} refusals (OMEGA_STOP_LIMIT); last: ${reason.split('\n')[0]}`)
      return undefined
    }
    note(`stop refused #${refusals}: ${reason.split('\n')[0]}`)
    return { decision: 'block', reason }
  }

  pi.on('session_stop', async (_event: unknown, ctx: Ctx) => {
    const failing = [...touched].filter(([f, rc]) => rc !== 0 && existsSync(f)).map(([f]) => f)
    for (const f of failing) {
      const c = compile(f)
      touched.set(f, c.rc)
      if (c.rc !== 0) return refuse(`Not done: ${basename(f)} does not compile.\n${c.report}`)
    }
    const cases = process.env.OMEGA_CASES
    if (!cases) {
      note('stop allowed: every touched .om compiles; no OMEGA_CASES')
      return undefined
    }
    const base = root(ctx)
    const scratchParent = mkdtempSync(join(tmpdir(), 'aien-omega-gate-'))
    const r = spawnSync(
      'bwrap',
      ['--ro-bind', '/', '/', '--dev', '/dev', '--proc', '/proc', '--bind', scratchParent, scratchParent, '--unshare-net', '--unshare-pid',
        '--die-with-parent', '--chdir', OMEGA_HOME, '--', GATE, OMC, OMC_SHA256, cases, join(scratchParent, 's')],
      { cwd: base, timeout: 120_000, maxBuffer: 1 << 22 },
    )
    const out = (r.stdout ?? Buffer.alloc(0)).toString('utf8')
    if (/^OM2GATE PASS /m.test(out)) {
      note('stop allowed: OM2GATE PASS')
      return undefined
    }
    const verdicts = out.split('\n').filter(l => l.startsWith('VERDICT') || l.startsWith('OM2GATE')).join('\n')
    return refuse(`Not done: the task check did not pass.\n${verdicts || `gate exit ${r.status}`}\nRead the task again, fix the program, check it with omega_run, then finish.`)
  })
}

export { checkRead, checkWrite, writePaths }
