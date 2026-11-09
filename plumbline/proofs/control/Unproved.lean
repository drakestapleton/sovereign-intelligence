/-
NEGATIVE CONTROL for plumbline/gate.sh. This is not a proof.

The theorem below is true and is left unproved on purpose. Lean still exits with status 0 on this
file: the only signs that nothing was proved are the warning and the axiom `sorryAx` in the list
below. The gate must flag this file; if it accepts it, the gate proves nothing about the others.
-/
theorem unproved : (2 : Nat) + 2 = 4 := sorry

#print axioms unproved
