/-
Plumbline proofs: negative controls for Ipo1.lean. Two broken designs, each with two different
values that are written as the same frame.

This file stands alone (a single file cannot import another without a build), so `Tok`, `V` and
`WF` are repeated here word for word from Ipo1.lean.

C1  A shape word that is NOT tied to a fixed number of values. The encoder `encBad` is the encoder
    of Ipo1.lean unchanged; what is dropped is the well-formedness requirement. In the first value
    shape 0 takes one value both times; in the second it takes two values, then none:
      shp 0 [shp 0 [nil]]   and   shp 0 [shp 0 [], nil]   are both   tShape 0, tShape 0, tNil.
    The second value is well formed under no shape table at all, so this does not contradict T2;
    it shows T2 needs the fixed arity.
C2  An arr that does not emit `end` (`encNoEnd`; everything else as in Ipo1.lean):
      arr [arr [nil]]   and   arr [arr [], nil]   are both   tArr, tArr, tNil.
    Both values are well formed under every shape table (they contain no shape), so here T2 itself
    is false: the closing `end` is needed.

Each control is proved on concrete terms: the two values differ, and the two frames are equal.

Checked with Lean 4.35.0, core library only (no Mathlib). The `#print` lines at the end list what
each theorem rests on beyond the rules of the logic.
-/

inductive Tok where
  | tNil : Tok
  | tYes : Tok
  | tNo : Tok
  | tNum (n : Int) : Tok
  | tStr (s : String) : Tok
  | tArr : Tok
  | tObj : Tok
  | tEnd : Tok
  | tShape (i : Nat) : Tok

inductive V where
  | nil : V
  | bool (b : Bool) : V
  | num (n : Int) : V
  | str (s : String) : V
  | arr (xs : List V) : V
  | obj (kvs : List (String × V)) : V
  | shp (i : Nat) (xs : List V) : V

open Tok

mutual
def WF (arity : Nat → Nat) : V → Prop
  | .nil => True
  | .bool _ => True
  | .num _ => True
  | .str _ => True
  | .arr xs => WFL arity xs
  | .obj kvs => WFP arity kvs
  | .shp i xs => xs.length = arity i ∧ WFL arity xs
def WFL (arity : Nat → Nat) : List V → Prop
  | [] => True
  | x :: xs => WF arity x ∧ WFL arity xs
def WFP (arity : Nat → Nat) : List (String × V) → Prop
  | [] => True
  | (_, v) :: kvs => WF arity v ∧ WFP arity kvs
end

/-! ## C1: a shape word with no fixed number of values -/

mutual
/-- The encoder of Ipo1.lean, used on values that need not be well formed. -/
def encBad : V → List Tok
  | .nil => [tNil]
  | .bool true => [tYes]
  | .bool false => [tNo]
  | .num n => [tNum n]
  | .str s => [tStr s]
  | .arr xs => tArr :: (encBadL xs ++ [tEnd])
  | .obj kvs => tObj :: (encBadP kvs ++ [tEnd])
  | .shp i xs => tShape i :: encBadL xs
def encBadL : List V → List Tok
  | [] => []
  | x :: xs => encBad x ++ encBadL xs
def encBadP : List (String × V) → List Tok
  | [] => []
  | (k, v) :: kvs => tStr k :: (encBad v ++ encBadP kvs)
end

def c1a : V := .shp 0 [.shp 0 [.nil]]
def c1b : V := .shp 0 [.shp 0 [], .nil]

/-- C1. Two different values, one frame. -/
theorem C1 : c1a ≠ c1b ∧ encBad c1a = encBad c1b ∧ encBad c1b = [tShape 0, tShape 0, tNil] :=
  ⟨fun h => (by cases h), rfl, rfl⟩

/-- So T2 without the well-formedness hypotheses is false. -/
theorem C1_T2_fails_without_fixed_arity :
    ¬ ∀ v1 v2 : V, encBad v1 = encBad v2 → v1 = v2 :=
  fun h => C1.1 (h c1a c1b C1.2.1)

/-- The control lies outside T2: under every shape table the second value is not well formed
(shape 0 would have to take both 2 values and 0 values). -/
theorem C1_second_value_never_well_formed (arity : Nat → Nat) : ¬ WF arity c1b := by
  intro h
  have a : 2 = arity 0 := h.1
  have b : 0 = arity 0 := h.2.1.1
  exact absurd (a.trans b.symm) (by decide)

/-! ## C2: an arr with no closing `end` -/

mutual
/-- As the encoder of Ipo1.lean, except that arr does not emit `tEnd`. -/
def encNoEnd : V → List Tok
  | .nil => [tNil]
  | .bool true => [tYes]
  | .bool false => [tNo]
  | .num n => [tNum n]
  | .str s => [tStr s]
  | .arr xs => tArr :: encNoEndL xs
  | .obj kvs => tObj :: (encNoEndP kvs ++ [tEnd])
  | .shp i xs => tShape i :: encNoEndL xs
def encNoEndL : List V → List Tok
  | [] => []
  | x :: xs => encNoEnd x ++ encNoEndL xs
def encNoEndP : List (String × V) → List Tok
  | [] => []
  | (k, v) :: kvs => tStr k :: (encNoEnd v ++ encNoEndP kvs)
end

def c2a : V := .arr [.arr [.nil]]
def c2b : V := .arr [.arr [], .nil]

/-- C2. Two different values, one frame. -/
theorem C2 : c2a ≠ c2b ∧ encNoEnd c2a = encNoEnd c2b ∧ encNoEnd c2b = [tArr, tArr, tNil] :=
  ⟨fun h => (by cases h), rfl, rfl⟩

/-- Both values are well formed under every shape table. -/
theorem C2_both_well_formed (arity : Nat → Nat) : WF arity c2a ∧ WF arity c2b :=
  ⟨⟨⟨trivial, trivial⟩, trivial⟩, ⟨trivial, trivial, trivial⟩⟩

/-- So the statement of T2 itself, with its well-formedness hypotheses, is false for this
encoder, under every shape table. -/
theorem C2_T2_fails_without_end (arity : Nat → Nat) :
    ¬ ∀ v1 v2 : V, WF arity v1 → WF arity v2 → encNoEnd v1 = encNoEnd v2 → v1 = v2 :=
  fun h => C2.1 (h c2a c2b (C2_both_well_formed arity).1 (C2_both_well_formed arity).2 C2.2.1)

#print axioms C1
#print axioms C1_T2_fails_without_fixed_arity
#print axioms C1_second_value_never_well_formed
#print axioms C2
#print axioms C2_both_well_formed
#print axioms C2_T2_fails_without_end
