/-
Plumbline proofs: why the untied Neuralese model cannot learn which of two always-equal inputs
an output should follow.

MODEL. One output's two incoming sender weights, from inputs p and q, in exact integer arithmetic.
One step of gradient descent changes a weight by  c * (its input), where c is the same for both
weights: it is the learning rate times the derivative of the loss at that output's pre-activation.
That is the shape of the update in the experiment's source (the gradient of a weight is the
output-side factor times the input: nl8.om, arm 1; and aien-train native/neuralese/nl1r/capacity.om,
`NG[j*d+k] = v*NX[j]`).

LINK TO THE RUNNING SYSTEM. The program computes in IEEE binary64, not in integers, so this theorem
is about the model. The program checks the same statement on its own numbers: the `max_drift`
column of `nl8 all` is the largest change of that difference over a whole training run, and the
pre-registered criterion P6 bounds it by 1e-9 on the two correlated masks.

Checked with Lean 4.35.0, core library only (no Mathlib). The axioms each theorem depends on are
printed at the end of this file.
-/

/-- The two weights. -/
structure W where
  p : Int
  q : Int

/-- One training step: common factor `c`, input values `sp` and `sq`. -/
def step (w : W) (c sp sq : Int) : W := ⟨w.p - c * sp, w.q - c * sq⟩

/-- What the training data would have to change for the model to tell p from q. -/
def diff (w : W) : Int := w.p - w.q

/-- A step on a case where the two inputs agree leaves the difference exactly as it was. -/
theorem step_keeps_diff (w : W) (c s : Int) : diff (step w c s s) = diff w := by
  simp only [diff, step]
  omega

/-- A whole run: a list of steps `(c, sp, sq)`. -/
def run (w : W) : List (Int × Int × Int) → W
  | [] => w
  | (c, sp, sq) :: t => run (step w c sp sq) t

/-- If the two inputs agree on every training case, no run of any length, with any learning rate
and any loss, moves the difference from its initial value. -/
theorem run_keeps_diff (l : List (Int × Int × Int)) (h : ∀ x ∈ l, x.2.1 = x.2.2) (w : W) :
    diff (run w l) = diff w := by
  induction l generalizing w with
  | nil => rfl
  | cons x t ih =>
    obtain ⟨c, sp, sq⟩ := x
    have hx : sp = sq := h (c, sp, sq) (List.mem_cons_self ..)
    have ht : ∀ y ∈ t, y.2.1 = y.2.2 := fun y hy => h y (List.mem_cons_of_mem _ hy)
    simp only [run]
    rw [ih ht, hx]
    exact step_keeps_diff w c sq

/-- NEGATIVE CONTROL. The statement is not vacuous: one step on a case where the inputs differ,
with a non-zero factor, does move the difference. -/
theorem step_moves_diff (w : W) (c sp sq : Int) (hc : c ≠ 0) (hs : sp ≠ sq) :
    diff (step w c sp sq) ≠ diff w := by
  simp only [diff, step]
  intro h
  have h2 : c * (sp - sq) = 0 := by
    rw [Int.mul_sub]
    omega
  rcases Int.mul_eq_zero.mp h2 with h3 | h3
  · exact hc h3
  · exact hs (by omega)

/-- NEGATIVE CONTROL, concrete: from (0, 0), one step with c = 1 on inputs (1, -1) gives -2, not 0. -/
theorem control_example : diff (step ⟨0, 0⟩ 1 1 (-1)) = -2 := by decide

/-
SECOND PART. What the tied model buys, and what the data cannot decide.

MODEL. An ID is four bits. The tied sender, the one-bit wire, the tied receiver and the decision
rule together are ONE function f on a single bit, applied to every position alike (the same
weights serve every position, and each position's wire bit depends on that position's input bit
only). The untied model may read any input at any output.

LINK TO THE RUNNING SYSTEM. In nl8.om, arm 0, the four positions share the parameters a, b, v, c
and position k reads only x_k, so the same floating-point operations run on the same inputs at
every position and give the same bit: the system has this form. That the trained f is the
identity on the training cases is not proved here; it is what the program measures (criterion P1).
-/

/-- The tied system: the same one-bit map at every position. -/
def tied (f : Bool → Bool) (x : Fin 4 → Bool) : Fin 4 → Bool := fun k => f (x k)

/-- If the tied system reproduces one case that has a 0 somewhere and one case that has a 1
somewhere, it reproduces all sixteen IDs: the held-out ones are not a matter of luck. Every one
of the four training masks contains such cases (0000 and 1111 are in all of them). -/
theorem tied_generalizes (f : Bool → Bool) (a b : Fin 4 → Bool) (i j : Fin 4)
    (ha : a i = false) (hb : b j = true) (h1 : tied f a = a) (h2 : tied f b = b) :
    ∀ x, tied f x = x := by
  have f0 : f false = false := by
    have := congrFun h1 i
    simp only [tied, ha] at this
    exact this
  have f1 : f true = true := by
    have := congrFun h2 j
    simp only [tied, hb] at this
    exact this
  intro x
  funext k
  simp only [tied]
  cases h : x k
  · exact f0
  · exact f1

/-- Two untied systems: one copies every bit; the other writes input 1 where input 0 belongs. -/
def copyAll (x : Fin 4 → Bool) : Fin 4 → Bool := x
def crossed (x : Fin 4 → Bool) : Fin 4 → Bool := fun k => if k = 0 then x 1 else x k

/-- On every case where inputs 0 and 1 agree (the whole training set of mask 39321) the two
systems give the same answer, so no training on those cases can prefer one to the other. -/
theorem data_cannot_decide (x : Fin 4 → Bool) (h : x 0 = x 1) : copyAll x = crossed x := by
  funext k
  simp only [copyAll, crossed]
  split
  · next hk => rw [hk]; exact h
  · rfl

/-- NEGATIVE CONTROL. They are different systems: on a held-out case they disagree. -/
theorem but_they_differ : ∃ x : Fin 4 → Bool, copyAll x ≠ crossed x := by
  refine ⟨fun k => decide (k = 0), ?_⟩
  intro h
  have := congrFun h 0
  simp [copyAll, crossed] at this

/-- NEGATIVE CONTROL for `tied_generalizes`: with only cases made of 0 bits in training, a tied
system can fit them and still be wrong elsewhere (the map that sends every bit to 0). -/
theorem tied_needs_both_values :
    ∃ f : Bool → Bool, tied f (fun _ => false) = (fun _ => false) ∧ ∃ x, tied f x ≠ x := by
  refine ⟨fun _ => false, rfl, fun _ => true, ?_⟩
  intro h
  have := congrFun h 0
  simp [tied] at this

#print axioms step_keeps_diff
#print axioms run_keeps_diff
#print axioms step_moves_diff
#print axioms control_example
#print axioms tied_generalizes
#print axioms data_cannot_decide
#print axioms but_they_differ
#print axioms tied_needs_both_values
