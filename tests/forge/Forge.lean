/-
tests/forge/Forge.lean: the rules of the Omega forge as a Lean 4 model, and the properties the forge
depends on, proved over that model.

The model follows the forge's interface contract (tools/FORGE.md):
  * the HTML escaping table every text byte goes through in tools/forge.om;
  * the ledger merge of tools/tally.om: for every (repository, day) seen in the logs, the logs'
    counts replace the ledger's row; every other ledger row is kept unchanged;
  * the distinct counts of tools/tally.om (hosts per HTTPS fetches, peers per Radicle fetches);
  * the spool bound of tools/intake.om: no new record once the spool holds 4096.
Bytes are Nat; a (repository, day) key, a host and a peer are opaque Nat.

Proved, for every input:
  escape_append         escaping distributes over concatenation, so emitting a text in chunks
                        gives the same bytes as escaping it whole
  escape_safe           escaped output holds no < > " ' and no control byte other than LF and TAB
  escape_tokens         escaped output is a concatenation of tokens, each one of the six entities
                        or a single byte that is not & < > " ' or a control byte: every & in the
                        output begins an entity
  unescape_escape       decoding the six entities (&#xFFFD; as U+FFFD) gives back the original
                        text when it has no control bytes other than LF and TAB, so escaping loses
                        nothing a reader sees
  merge_seen, merge_unseen  a key the logs saw gets the logs' row; any other key keeps its row
  merge_idem            merging the same logs twice gives what merging them once gives
  tally_idem            re-running tally on the same logs changes nothing (no double counting)
  merge_keys_nodup      each key appears once in the output when it did in the ledger
  distinct_le, distinct_nodup, mem_distinct  the distinct count is a count of distinct values,
                        never more than the number of lines
  summarize_bounded     every row tally makes has hosts <= https and peers <= rad
  run_bound             the intake spool never holds more than 4096 records

What this does not prove: that tools/forge.om, tools/tally.om or tools/intake.om implement this
model (the fixtures in tests/forge test that, they do not prove it), nor anything about nginx,
Radicle, browsers or the log formats.

Check: lean tests/forge/Forge.lean (core Lean 4, no Mathlib; checked with leanprover/lean4:v4.15.0),
or sh tests/forge/lean.sh, which also checks the axioms and that a mutated escape table fails.
-/
namespace Forge

/-! ## HTML escaping -/

/-- A control byte other than LF (10) and TAB (9): 0x00..0x08, 0x0B..0x1F and 0x7F. -/
def isCtl (b : Nat) : Bool := (b < 32 && b != 10 && b != 9) || b == 127

def eAmp : List Nat := [38, 97, 109, 112, 59]           -- &amp;
def eLt : List Nat := [38, 108, 116, 59]                -- &lt;
def eGt : List Nat := [38, 103, 116, 59]                -- &gt;
def eQuot : List Nat := [38, 113, 117, 111, 116, 59]    -- &quot;
def eApos : List Nat := [38, 35, 51, 57, 59]            -- &#39;
def eRepl : List Nat := [38, 35, 120, 70, 70, 70, 68, 59] -- &#xFFFD;

/-- The escaping table of one byte. -/
def esc1 (b : Nat) : List Nat :=
  if b = 38 then eAmp
  else if b = 60 then eLt
  else if b = 62 then eGt
  else if b = 34 then eQuot
  else if b = 39 then eApos
  else if isCtl b then eRepl
  else [b]

def escape : List Nat → List Nat
  | [] => []
  | b :: s => esc1 b ++ escape s

theorem escape_append (a b : List Nat) : escape (a ++ b) = escape a ++ escape b := by
  induction a with
  | nil => rfl
  | cons x xs ih => simp [escape, ih, List.append_assoc]

/-- A byte that may appear in escaped output. -/
abbrev safe (c : Nat) : Prop := c ≠ 60 ∧ c ≠ 62 ∧ c ≠ 34 ∧ c ≠ 39 ∧ isCtl c = false

theorem esc1_safe (b c : Nat) (h : c ∈ esc1 b) : safe c := by
  unfold esc1 at h
  split at h
  · simp [eAmp] at h; rcases h with rfl | rfl | rfl | rfl | rfl <;> decide
  · split at h
    · simp [eLt] at h; rcases h with rfl | rfl | rfl | rfl <;> decide
    · split at h
      · simp [eGt] at h; rcases h with rfl | rfl | rfl | rfl <;> decide
      · split at h
        · simp [eQuot] at h; rcases h with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
        · split at h
          · simp [eApos] at h; rcases h with rfl | rfl | rfl | rfl | rfl <;> decide
          · split at h
            · simp [eRepl] at h; rcases h with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> decide
            · simp at h; subst h
              refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> simp_all

/-- Escaped output holds no < > " ' and no control byte other than LF and TAB. -/
theorem escape_safe (s : List Nat) : ∀ c ∈ escape s, safe c := by
  induction s with
  | nil => intro c h; simp [escape] at h
  | cons b s ih =>
    intro c h
    simp only [escape, List.mem_append] at h
    rcases h with h | h
    · exact esc1_safe b c h
    · exact ih c h

/-- The tokens escaped output is made of. -/
def token (t : List Nat) : Prop :=
  t = eAmp ∨ t = eLt ∨ t = eGt ∨ t = eQuot ∨ t = eApos ∨ t = eRepl ∨
  ∃ c, t = [c] ∧ c ≠ 38 ∧ safe c

def concat : List (List Nat) → List Nat
  | [] => []
  | t :: ts => t ++ concat ts

theorem esc1_token (b : Nat) : token (esc1 b) := by
  unfold esc1 token
  split
  · simp
  · split
    · simp
    · split
      · simp
      · split
        · simp
        · split
          · simp
          · split
            · simp
            · rename_i h1 h2 h3 h4 h5 h6
              refine Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr ⟨b, rfl, h1, ?_⟩)))))
              refine ⟨h2, h3, h4, h5, ?_⟩
              simp_all

/-- Escaped output is a concatenation of entities and single safe bytes other than &: every & in
it begins one of the six entities. -/
theorem escape_tokens (s : List Nat) :
    ∃ ts : List (List Nat), escape s = concat ts ∧ ∀ t ∈ ts, token t := by
  induction s with
  | nil => exact ⟨[], rfl, by simp⟩
  | cons b s ih =>
    obtain ⟨ts, h, ht⟩ := ih
    refine ⟨esc1 b :: ts, by simp [escape, concat, h], ?_⟩
    intro t hm
    rcases List.mem_cons.mp hm with rfl | hm
    · exact esc1_token b
    · exact ht t hm

/-- `strip p r`: the rest of r after the prefix p, if r begins with p. -/
def strip : List Nat → List Nat → Option (List Nat)
  | [], r => some r
  | _ :: _, [] => none
  | p :: ps, x :: xs => if p = x then strip ps xs else none

theorem strip_append (p r : List Nat) : strip p (p ++ r) = some r := by
  induction p with
  | nil => rfl
  | cons x xs ih => simp [strip, ih]

theorem strip_length (p r t : List Nat) (h : strip p r = some t) : t.length ≤ r.length := by
  induction p generalizing r with
  | nil => simp [strip] at h; subst h; exact Nat.le_refl _
  | cons x xs ih =>
    cases r with
    | nil => simp [strip] at h
    | cons y ys =>
      simp only [strip] at h
      split at h
      · have := ih ys h; simp; omega
      · cases h

/-- The six entities after their &, each with the byte it stands for, in the order tried. -/
def ents : List (List Nat × Nat) :=
  [([97, 109, 112, 59], 38), ([108, 116, 59], 60), ([103, 116, 59], 62),
   ([113, 117, 111, 116, 59], 34), ([35, 51, 57, 59], 39), ([35, 120, 70, 70, 70, 68, 59], 65533)]

/-- The first entity r begins with: its byte and the rest of r. -/
def firstEnt : List (List Nat × Nat) → List Nat → Option (Nat × List Nat)
  | [], _ => none
  | (p, c) :: es, r =>
    match strip p r with
    | some t => some (c, t)
    | none => firstEnt es r

theorem firstEnt_length (es : List (List Nat × Nat)) (r t : List Nat) (c : Nat)
    (h : firstEnt es r = some (c, t)) : t.length ≤ r.length := by
  induction es with
  | nil => simp [firstEnt] at h
  | cons e es ih =>
    obtain ⟨p, c'⟩ := e
    simp only [firstEnt] at h
    split at h
    · rename_i t' ht
      simp at h
      obtain ⟨_, rfl⟩ := h
      exact strip_length p r t' ht
    · exact ih h

/-- Decoding exactly the six entities the forge writes, left to right; every other byte is
itself. -/
def unescape (s : List Nat) : List Nat :=
  match s with
  | [] => []
  | b :: r =>
    if b = 38 then
      match h : firstEnt ents r with
      | some (c, t) =>
        have : t.length ≤ r.length := firstEnt_length ents r t c h
        c :: unescape t
      | none => 38 :: unescape r
    else b :: unescape r
termination_by s.length

theorem unescape_plain (b : Nat) (r : List Nat) (h : b ≠ 38) :
    unescape (b :: r) = b :: unescape r := by
  rw [unescape]
  simp [h]

theorem unescape_ent (r : List Nat) (c : Nat) (t : List Nat) (hf : firstEnt ents r = some (c, t)) :
    unescape (38 :: r) = c :: unescape t := by
  rw [unescape]
  simp only [if_pos]
  split
  · rename_i c' t' heq
    rw [hf] at heq
    simp at heq
    obtain ⟨rfl, rfl⟩ := heq
    rfl
  · rename_i heq
    rw [hf] at heq
    cases heq

theorem unescape_esc1 (b : Nat) (r : List Nat) (h : isCtl b = false) :
    unescape (esc1 b ++ r) = b :: unescape r := by
  unfold esc1
  split
  · subst_vars
    exact unescape_ent _ 38 r (by simp [ents, firstEnt, strip])
  · split
    · subst_vars
      exact unescape_ent _ 60 r (by simp [ents, firstEnt, strip])
    · split
      · subst_vars
        exact unescape_ent _ 62 r (by simp [ents, firstEnt, strip])
      · split
        · subst_vars
          exact unescape_ent _ 34 r (by simp [ents, firstEnt, strip])
        · split
          · subst_vars
            exact unescape_ent _ 39 r (by simp [ents, firstEnt, strip])
          · split
            · simp_all
            · rename_i h1 _ _ _ _ _
              simp only [List.singleton_append]
              exact unescape_plain b r h1

/-- Escaping loses nothing a reader sees: decoding gives the text back when it has no control
bytes other than LF and TAB. -/
theorem unescape_escape (s : List Nat) (h : ∀ b ∈ s, isCtl b = false) :
    unescape (escape s) = s := by
  induction s with
  | nil => simp [escape, unescape]
  | cons b s ih =>
    simp only [escape]
    rw [unescape_esc1 b _ (h b (List.mem_cons_self _ _))]
    rw [ih (fun c hc => h c (List.mem_cons_of_mem _ hc))]

/-- The fixture: what tools/forge.om must write for the title  Tab\t<b>"x" & 'y'\x01. -/
theorem escape_fixture :
    escape [84, 97, 98, 9, 60, 98, 62, 34, 120, 34, 32, 38, 32, 39, 121, 39, 1] =
      [84, 97, 98, 9] ++ eLt ++ [98] ++ eGt ++ eQuot ++ [120] ++ eQuot ++ [32] ++ eAmp ++ [32] ++
      eApos ++ [121] ++ eApos ++ eRepl := by
  decide

/-! ## The tally ledger -/

structure Counts where
  https : Nat
  hosts : Nat
  rad : Nat
  peers : Nat
  deriving DecidableEq

/-- A ledger: rows of (key, counts), the key standing for a (repository, day). -/
abbrev Ledger := List (Nat × Counts)

def keys (L : Ledger) : List Nat := L.map Prod.fst

/-- tally's merge: the logs' rows X, and every ledger row whose key the logs did not see. (The
Omega program writes the rows sorted by key; the order does not change what each key holds.) -/
def merge (L X : Ledger) : Ledger := L.filter (fun p => !decide (p.1 ∈ keys X)) ++ X

def lookup (k : Nat) : Ledger → Option Counts
  | [] => none
  | p :: r => if p.1 = k then some p.2 else lookup k r

theorem lookup_none (k : Nat) (L : Ledger) (h : k ∉ keys L) : lookup k L = none := by
  induction L with
  | nil => rfl
  | cons p r ih =>
    simp only [keys, List.map_cons, List.mem_cons, not_or] at h
    simp only [lookup]
    rw [if_neg (fun e => h.1 e.symm)]
    exact ih h.2

theorem lookup_append_right (k : Nat) (A B : Ledger) (h : k ∉ keys A) :
    lookup k (A ++ B) = lookup k B := by
  induction A with
  | nil => rfl
  | cons p r ih =>
    simp only [keys, List.map_cons, List.mem_cons, not_or] at h
    simp only [List.cons_append, lookup]
    rw [if_neg (fun e => h.1 e.symm)]
    exact ih h.2

theorem lookup_append_left (k : Nat) (A B : Ledger) (h : k ∉ keys B) :
    lookup k (A ++ B) = lookup k A := by
  induction A with
  | nil => exact lookup_none k B h
  | cons p r ih =>
    simp only [List.cons_append, lookup]
    split
    · rfl
    · exact ih

theorem keys_filter_not (L X : Ledger) (k : Nat)
    (h : k ∈ keys (L.filter (fun p => !decide (p.1 ∈ keys X)))) : k ∉ keys X := by
  simp only [keys, List.mem_map, List.mem_filter] at h
  obtain ⟨p, ⟨_, hp⟩, rfl⟩ := h
  simpa [keys] using hp

theorem lookup_filter (k : Nat) (L X : Ledger) (h : k ∉ keys X) :
    lookup k (L.filter (fun p => !decide (p.1 ∈ keys X))) = lookup k L := by
  induction L with
  | nil => rfl
  | cons p r ih =>
    by_cases hp : p.1 ∈ keys X
    · have hne : p.1 ≠ k := fun e => h (e ▸ hp)
      simp [List.filter, hp, lookup, hne, ih]
    · simp [List.filter, hp, lookup, ih]

/-- A key the logs saw gets the logs' row. -/
theorem merge_seen (L X : Ledger) (k : Nat) (h : k ∈ keys X) :
    lookup k (merge L X) = lookup k X := by
  unfold merge
  apply lookup_append_right
  intro hk
  exact keys_filter_not L X k hk h

/-- Any other key keeps its ledger row. -/
theorem merge_unseen (L X : Ledger) (k : Nat) (h : k ∉ keys X) :
    lookup k (merge L X) = lookup k L := by
  unfold merge
  rw [lookup_append_left k _ X h]
  exact lookup_filter k L X h

theorem filter_own (X : Ledger) : X.filter (fun p => !decide (p.1 ∈ keys X)) = [] := by
  rw [List.filter_eq_nil_iff]
  intro p hp
  have : p.1 ∈ keys X := List.mem_map_of_mem Prod.fst hp
  simp [this]

/-- Merging the same logs twice gives what merging them once gives. -/
theorem merge_idem (L X : Ledger) : merge (merge L X) X = merge L X := by
  unfold merge
  rw [List.filter_append, filter_own, List.append_nil, List.filter_filter]
  congr 1
  apply List.filter_congr
  intro p _
  cases decide (p.1 ∈ keys X) <;> rfl

/-- tally with any summary S of the logs: re-running it on the same logs changes nothing. -/
def tally (S : List α → Ledger) (L : Ledger) (log : List α) : Ledger := merge L (S log)

theorem tally_idem (S : List α → Ledger) (L : Ledger) (log : List α) :
    tally S (tally S L log) log = tally S L log :=
  merge_idem L (S log)

/-- Each key appears once in the output when it does in the ledger and in the logs' rows. -/
theorem merge_keys_nodup (L X : Ledger) (hL : (keys L).Nodup) (hX : (keys X).Nodup) :
    (keys (merge L X)).Nodup := by
  unfold merge
  simp only [keys, List.map_append]
  show List.Pairwise (· ≠ ·) _
  apply List.pairwise_append.mpr
  refine ⟨?_, hX, ?_⟩
  · exact List.Nodup.sublist (List.Sublist.map _ (List.filter_sublist _)) hL
  · intro a ha b hb e
    subst e
    exact keys_filter_not L X a ha hb

/-! ## Distinct counts -/

/-- The distinct values of a list (each value's last occurrence kept). -/
def distinct : List Nat → List Nat
  | [] => []
  | x :: xs => if x ∈ xs then distinct xs else x :: distinct xs

theorem mem_distinct (l : List Nat) (x : Nat) : x ∈ distinct l ↔ x ∈ l := by
  induction l with
  | nil => simp [distinct]
  | cons y ys ih =>
    unfold distinct
    split
    · rename_i hy
      rw [ih]
      constructor
      · exact List.mem_cons_of_mem _
      · intro h
        rcases List.mem_cons.mp h with rfl | h
        · exact hy
        · exact h
    · simp [ih]

theorem distinct_nodup (l : List Nat) : (distinct l).Nodup := by
  induction l with
  | nil => exact List.nodup_nil
  | cons y ys ih =>
    unfold distinct
    split
    · exact ih
    · rename_i hy
      exact List.nodup_cons.mpr ⟨fun h => hy ((mem_distinct ys y).mp h), ih⟩

/-- The distinct count is never more than the number of lines. -/
theorem distinct_le (l : List Nat) : (distinct l).length ≤ l.length := by
  induction l with
  | nil => simp [distinct]
  | cons y ys ih =>
    unfold distinct
    split
    · simp; omega
    · simp; omega

/-- One counted log line: an HTTPS fetch of key k by host h, or a Radicle fetch by peer n. -/
inductive Line
  | https (k h : Nat)
  | rad (k n : Nat)

def Line.key : Line → Nat
  | .https k _ => k
  | .rad k _ => k

def httpsHosts (k : Nat) : List Line → List Nat
  | [] => []
  | .https k' h :: r => if k' = k then h :: httpsHosts k r else httpsHosts k r
  | .rad _ _ :: r => httpsHosts k r

def radPeers (k : Nat) : List Line → List Nat
  | [] => []
  | .rad k' n :: r => if k' = k then n :: radPeers k r else radPeers k r
  | .https _ _ :: r => radPeers k r

/-- The counts tally makes for key k: lines, and distinct hosts and peers among them. -/
def countKey (log : List Line) (k : Nat) : Counts :=
  { https := (httpsHosts k log).length, hosts := (distinct (httpsHosts k log)).length,
    rad := (radPeers k log).length, peers := (distinct (radPeers k log)).length }

/-- The logs' rows: one per distinct key seen. -/
def summarize (log : List Line) : Ledger :=
  (distinct (log.map Line.key)).map (fun k => (k, countKey log k))

/-- Every row tally makes has hosts <= https and peers <= rad. -/
theorem summarize_bounded (log : List Line) :
    ∀ p ∈ summarize log, p.2.hosts ≤ p.2.https ∧ p.2.peers ≤ p.2.rad := by
  intro p hp
  simp only [summarize, List.mem_map] at hp
  obtain ⟨k, _, rfl⟩ := hp
  exact ⟨distinct_le _, distinct_le _⟩

theorem summarize_keys_nodup (log : List Line) : (keys (summarize log)).Nodup := by
  have : keys (summarize log) = distinct (log.map Line.key) := by
    simp [keys, summarize, List.map_map, Function.comp_def]
  rw [this]
  exact distinct_nodup _

/-- The whole tally: its output has each key once, and re-running it changes nothing. -/
theorem tally_sound (L : Ledger) (log : List Line) (hL : (keys L).Nodup) :
    (keys (tally summarize L log)).Nodup ∧
    tally summarize (tally summarize L log) log = tally summarize L log :=
  ⟨merge_keys_nodup L _ hL (summarize_keys_nodup log), tally_idem summarize L log⟩

/-! ## The intake spool bound -/

def cap : Nat := 4096

/-- One request: a valid one is admitted when the spool has room; anything else changes nothing.
A publish removes a record. -/
inductive Req
  | valid
  | invalid
  | publish

def step (n : Nat) : Req → Nat
  | .valid => if n < cap then n + 1 else n
  | .invalid => n
  | .publish => n - 1

def run (n : Nat) : List Req → Nat
  | [] => n
  | r :: rs => run (step n r) rs

theorem step_bound (n : Nat) (r : Req) (h : n ≤ cap) : step n r ≤ cap := by
  cases r <;> simp only [step] <;> (try split) <;> omega

/-- The spool never holds more than 4096 records. -/
theorem run_bound (n : Nat) (rs : List Req) (h : n ≤ cap) : run n rs ≤ cap := by
  induction rs generalizing n with
  | nil => exact h
  | cons r rs ih => exact ih (step n r) (step_bound n r h)

end Forge

#print axioms Forge.escape_append
#print axioms Forge.escape_safe
#print axioms Forge.escape_tokens
#print axioms Forge.unescape_escape
#print axioms Forge.escape_fixture
#print axioms Forge.merge_seen
#print axioms Forge.merge_unseen
#print axioms Forge.merge_idem
#print axioms Forge.tally_idem
#print axioms Forge.merge_keys_nodup
#print axioms Forge.distinct_le
#print axioms Forge.distinct_nodup
#print axioms Forge.mem_distinct
#print axioms Forge.summarize_bounded
#print axioms Forge.tally_sound
#print axioms Forge.run_bound
