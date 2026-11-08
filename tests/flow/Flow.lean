/-
tests/flow/Flow.lean: the decision rules of tools/flow.om, the Omega merge queue's planner, as a
Lean 4 model, and the safety properties the queue depends on, proved over that model.

The model is the "Decision for each STATE row" section of tools/flow.om's header. Commits and
trees are opaque (Nat stands for a 40-hex object id). `Receipts` is the receipt ledger already
restricted to the plan's gate: what the gate said about a tree, if anything.

Proved, for every input:
  plan_length        every patch gets exactly one action
  merge_safe         a merge is planned only for a fast-forward whose exact tree has a pass
                     receipt from the default branch's gate
  merge_at_most_one  a plan holds at most one merge
  gate_needs_none    a tree is gated only when it has no receipt for this gate
  gate_once          no tree is gated twice in one plan
  fail_never_merges  a tree with a fail receipt is never merged
Together with flow.sh's checks (rad/DEFAULT is still the planned branch, HEAD's tree is the
planned tree, the push is a fast-forward), merge_safe gives the queue's invariant: the default
branch only ever moves to a tree that passed the gate guarding it.

What this does not prove: that tools/flow.om implements this model (the fixtures in tests/flow
and the end-to-end run in tests/flow/e2e.sh test that, they do not prove it), nor anything
about git, Radicle or the gate itself.

Check: lean tests/flow/Flow.lean (core Lean 4, no Mathlib). Checked 2026-11-08 with Lean 4.15.0
(x86_64-unknown-linux-gnu, commit 11651562caae): exit 0, and the only output is the
#print axioms lines at the end, [propext, Quot.sound] for every theorem, the six safety theorems
and fixture_plan included. build.sh step 12c repeats this check whenever lean is installed.
-/
namespace Flow

inductive Rel | ff | div | inB
  deriving DecidableEq, Repr

inductive Verdict | pass | fail
  deriving DecidableEq, Repr

inductive Action | merged | merge | queued | rebase | fail | gate | same
  deriving DecidableEq, Repr

structure Row where
  patch : Nat
  head : Nat
  tree : Nat
  rel : Rel

/-- The receipt ledger, restricted to the plan's gate. -/
abbrev Receipts := Nat → Option Verdict

/-- One row's action. `m`: an earlier row was given merge. `seen`: the trees of earlier rows. -/
def decide1 (r : Receipts) (m : Bool) (seen : List Nat) (x : Row) : Action :=
  match x.rel, r x.tree with
  | .inB, _ => .merged
  | .ff, some .pass => if m then .queued else .merge
  | .div, some .pass => .rebase
  | .ff, some .fail => .fail
  | .div, some .fail => .fail
  | .ff, none => if x.tree ∈ seen then .same else .gate
  | .div, none => if x.tree ∈ seen then .same else .gate

/-- The plan: rows in input order, each decided with what the rows before it were given. -/
def plan (r : Receipts) : Bool → List Nat → List Row → List Action
  | _, _, [] => []
  | m, seen, x :: xs =>
    let a := decide1 r m seen x
    a :: plan r (m || decide (a = .merge)) (x.tree :: seen) xs

/-- The plan flow.om makes from a STATE: nothing merged yet, no tree seen yet. -/
def flow (r : Receipts) (xs : List Row) : List Action := plan r false [] xs

theorem decide1_merge {r : Receipts} {m : Bool} {seen : List Nat} {x : Row}
    (h : decide1 r m seen x = .merge) : r x.tree = some .pass ∧ x.rel = .ff ∧ m = false := by
  unfold decide1 at h
  split at h <;> (try split at h) <;> simp_all

theorem decide1_gate {r : Receipts} {m : Bool} {seen : List Nat} {x : Row}
    (h : decide1 r m seen x = .gate) : r x.tree = none ∧ x.tree ∉ seen := by
  unfold decide1 at h
  split at h <;> (try split at h) <;> simp_all

theorem plan_length (r : Receipts) :
    ∀ (xs : List Row) (m : Bool) (seen : List Nat), (plan r m seen xs).length = xs.length := by
  intro xs
  induction xs with
  | nil => intro m seen; rfl
  | cons y ys ih => intro m seen; simp [plan, ih]

theorem merge_safe_gen (r : Receipts) :
    ∀ (xs : List Row) (m : Bool) (seen : List Nat) (x : Row),
      (x, Action.merge) ∈ xs.zip (plan r m seen xs) → r x.tree = some .pass ∧ x.rel = .ff := by
  intro xs
  induction xs with
  | nil => intro m seen x h; simp [plan] at h
  | cons y ys ih =>
    intro m seen x h
    simp only [plan, List.zip_cons_cons, List.mem_cons] at h
    rcases h with h | h
    · have hx : x = y := (Prod.mk.inj h).1
      have ha : decide1 r m seen y = .merge := (Prod.mk.inj h).2.symm
      subst hx
      exact ⟨(decide1_merge ha).1, (decide1_merge ha).2.1⟩
    · exact ih _ _ x h

/-- A merge is planned only for a fast-forward whose exact tree passed this gate. -/
theorem merge_safe (r : Receipts) (xs : List Row) (x : Row)
    (h : (x, Action.merge) ∈ xs.zip (flow r xs)) : r x.tree = some .pass ∧ x.rel = .ff :=
  merge_safe_gen r xs false [] x h

theorem no_merge_after_merge (r : Receipts) :
    ∀ (xs : List Row) (seen : List Nat), Action.merge ∉ plan r true seen xs := by
  intro xs
  induction xs with
  | nil => intro seen; simp [plan]
  | cons y ys ih =>
    intro seen h
    simp only [plan, Bool.true_or, List.mem_cons] at h
    rcases h with h | h
    · have := (decide1_merge h.symm).2.2
      simp at this
    · exact ih _ h

theorem merge_count_le (r : Receipts) :
    ∀ (xs : List Row) (seen : List Nat), (plan r false seen xs).count .merge ≤ 1 := by
  intro xs
  induction xs with
  | nil => intro seen; simp [plan]
  | cons y ys ih =>
    intro seen
    simp only [plan, Bool.false_or]
    by_cases ha : decide1 r false seen y = .merge
    · have h0 : (plan r true (y.tree :: seen) ys).count .merge = 0 :=
        List.count_eq_zero.mpr (no_merge_after_merge r ys _)
      simp [ha, h0]
    · have := ih (y.tree :: seen)
      simp [ha, List.count_cons, this]

/-- A plan holds at most one merge, so each step moves the default branch at most once. -/
theorem merge_at_most_one (r : Receipts) (xs : List Row) : (flow r xs).count .merge ≤ 1 :=
  merge_count_le r xs []

/-- The trees of the rows a plan gates, in order. -/
def gateTrees : List (Row × Action) → List Nat
  | [] => []
  | (x, a) :: rest => if a = .gate then x.tree :: gateTrees rest else gateTrees rest

theorem gate_gen (r : Receipts) :
    ∀ (xs : List Row) (m : Bool) (seen : List Nat),
      (gateTrees (xs.zip (plan r m seen xs))).Nodup ∧
      (∀ t ∈ gateTrees (xs.zip (plan r m seen xs)), t ∉ seen ∧ r t = none) := by
  intro xs
  induction xs with
  | nil => intro m seen; simp [plan, gateTrees]
  | cons y ys ih =>
    intro m seen
    obtain ⟨hn, hs⟩ := ih (m || decide (decide1 r m seen y = .merge)) (y.tree :: seen)
    simp only [plan, List.zip_cons_cons, gateTrees]
    split
    · rename_i hg
      obtain ⟨hr, hy⟩ := decide1_gate hg
      refine ⟨List.nodup_cons.mpr ⟨fun hm => (hs _ hm).1 (List.mem_cons_self _ _), hn⟩, ?_⟩
      intro t ht
      rcases List.mem_cons.mp ht with rfl | ht
      · exact ⟨hy, hr⟩
      · exact ⟨fun h => (hs t ht).1 (List.mem_cons_of_mem _ h), (hs t ht).2⟩
    · exact ⟨hn, fun t ht => ⟨fun h => (hs t ht).1 (List.mem_cons_of_mem _ h), (hs t ht).2⟩⟩

/-- No tree is gated twice in one plan. -/
theorem gate_once (r : Receipts) (xs : List Row) : (gateTrees (xs.zip (flow r xs))).Nodup :=
  (gate_gen r xs false []).1

/-- A tree is gated only when this gate has no receipt for it. -/
theorem gate_needs_none (r : Receipts) (xs : List Row) :
    ∀ t ∈ gateTrees (xs.zip (flow r xs)), r t = none :=
  fun t ht => ((gate_gen r xs false []).2 t ht).2

/-- A tree with a fail receipt is never merged. -/
theorem fail_never_merges (r : Receipts) (xs : List Row) (x : Row)
    (hf : r x.tree = some .fail) : (x, Action.merge) ∉ xs.zip (flow r xs) := by
  intro h
  have := (merge_safe r xs x h).1
  rw [hf] at this
  cases this

/-- The fixture of tests/flow: the decisions flow.om must print for tests/flow/state.tsv. -/
def fixtureReceipts : Receipts := fun t =>
  if t = 1 ∨ t = 2 ∨ t = 3 ∨ t = 99 then some .pass else if t = 4 then some .fail else none

def fixtureState : List Row :=
  [⟨1, 1, 1, .ff⟩, ⟨2, 2, 2, .ff⟩, ⟨3, 3, 3, .div⟩, ⟨4, 4, 4, .ff⟩, ⟨5, 5, 5, .ff⟩,
   ⟨6, 6, 5, .div⟩, ⟨7, 7, 7, .div⟩, ⟨8, 8, 1, .ff⟩, ⟨9, 9, 9, .inB⟩]

theorem fixture_plan : flow fixtureReceipts fixtureState =
    [.merge, .queued, .rebase, .fail, .gate, .same, .gate, .queued, .merged] := by
  decide

-- What each theorem rests on: tests/flow and build.sh step 12c require propext,
-- Classical.choice and Quot.sound at most (no sorryAx, no native_decide).
#print axioms decide1_merge
#print axioms decide1_gate
#print axioms plan_length
#print axioms merge_safe_gen
#print axioms merge_safe
#print axioms no_merge_after_merge
#print axioms merge_count_le
#print axioms merge_at_most_one
#print axioms gate_gen
#print axioms gate_once
#print axioms gate_needs_none
#print axioms fail_never_merges
#print axioms fixture_plan

end Flow
