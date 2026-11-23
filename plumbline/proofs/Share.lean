/-
Plumbline proofs: the hub's share figure is the nearest tenth of a percent.

MODEL. `permil a b` is the function of the same name in plumbline/hub/src/10-data.om:
  ret div add mul a 1000 div t 2 t      with t = a + b
that is, (1000 a + t / 2) / t in natural-number division. a is a count of Omega lines, b of other
lines.

CLAIM. With t = a + b > 0 and q = permil a b:  |1000 a - q t| <= t / 2, written without division
and without subtraction as two inequalities. So q is 1000 a / t rounded to a nearest whole
permille, and never off by more than half a permille.

LINK TO THE RUNNING SYSTEM. The Omega program computes with unsigned 64-bit words that wrap; this
model uses unbounded naturals. The two agree while 1000 a + t / 2 < 2^64, which holds for any line
count below 1.8e16. The nine subsystem values the hub prints were also computed with Wolfram
(recorded in the note above `fn permil` in 10-data.om).

Checked with Lean 4.35.0, core library only.
-/

def permil (a b : Nat) : Nat := (1000 * a + (a + b) / 2) / (a + b)

theorem permil_nearest (a b : Nat) (h : 0 < a + b) :
    2 * (permil a b * (a + b)) ≤ 2 * (1000 * a) + (a + b) ∧
    2 * (1000 * a) ≤ 2 * (permil a b * (a + b)) + (a + b) := by
  unfold permil
  have h1 := Nat.div_mul_le_self (1000 * a + (a + b) / 2) (a + b)
  have h2 := Nat.lt_div_mul_add (a := 1000 * a + (a + b) / 2) h
  have h3 := Nat.div_mul_le_self (a + b) 2
  have h4 := Nat.lt_div_mul_add (a := a + b) (b := 2) (by decide)
  constructor <;> omega

/-- The nine subsystem shares the hub prints, from the ledger's own line counts. -/
theorem shares_as_printed :
    permil 214235 537943 = 285 ∧ permil 89600 230442 = 280 ∧ permil 349008 986798 = 261 ∧
    permil 24327 460355 = 50 ∧ permil 112692 11425 = 908 ∧ permil 3165 56067 = 53 ∧
    permil 20249 139462 = 127 ∧ permil 12584 18852 = 400 ∧ permil 76764 77622 = 497 := by
  decide

/-- NEGATIVE CONTROL. Rounding down instead (the ledger's own rule) gives a different figure for
the compiler subsystem, so the two rules are distinguishable on this data. -/
theorem floor_differs : 1000 * 214235 / (214235 + 537943) = 284 := by decide

#print axioms permil_nearest
#print axioms shares_as_printed
#print axioms floor_differs
