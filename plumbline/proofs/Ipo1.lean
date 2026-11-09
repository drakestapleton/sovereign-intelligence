/-
Plumbline proofs: an ipo1 frame can be read back in exactly one way.

WHAT ipo1 IS. A text form for JSON-like values in which every word takes a fixed number of values,
so an object of a known shape is written with no keys and no closing word.

MODEL. A frame is a list of tokens (`Tok`): nil, yes, no, a number, a string, arr, obj, end, and
one word per known shape (`tShape i`). A value (`V`) is nil, a boolean, a number, a string, an
array of values, an object with no known shape (a list of key/value pairs), or an object of known
shape i (`V.shp i xs`: its field values in order). `arity` is the shape table: `arity i` is how
many values shape i takes. A value is well formed (`WF arity v`) when every `V.shp i xs` inside it,
at any depth, has exactly `arity i` values.

  enc v            writes a value, by the token grammar
                     VALUE := nil | yes | no | NUM | STR
                            | arr VALUE* end
                            | obj (STR VALUE)* end
                            | SHAPE_i VALUE{arity i}          (no keys, no end)
  dec arity f ts   reads one value from the front of `ts` and returns it with the unread rest.
                   It is a total function: `f` is a step budget (fuel), and running out of budget
                   gives `none`. On a shape word it reads exactly `arity i` values (`decN`); on arr
                   and obj it reads until `end` (`decUntil`, `decPairs`).
  size v           the explicit budget bound: every f ≥ size v is enough to read v.
  decode arity ts  `dec` with budget 3 × (number of tokens in `ts`): no budget to choose.

CLAIMS, each for every shape table `arity`.
  T1  Round trip with any continuation: for well-formed v, any `rest` and any f ≥ size v,
      dec arity f (enc v ++ rest) = some (v, rest). Reading stops exactly where the value ends.
      Corollary without a budget: decode arity (enc v ++ rest) = some (v, rest).
  T2  Unique decodability: well-formed values with the same frame are the same value.
  T3  Prefix-freeness: if enc v1 ++ r1 = enc v2 ++ r2 for well-formed v1 v2, then v1 = v2 and
      r1 = r2. No frame is the start of a different frame.
  T4  No value starts with `end`: enc v is never empty and its first token is never `tEnd`. This
      is what lets `end` close arr and obj.
T2 and T3 are derived from T1. Ipo1Control.lean holds the negative controls: T2 is false when a
shape word is not tied to a fixed number of values, and false when arr has no closing `end`.

NOT COVERED.
  - The lexical layer: how a token is spelled as text, that is, when a string is written bare or
    quoted, and the reserved words. Here a token is already a token.
  - JSON canonicalization: which value a JSON document stands for.
  - That the Omega program implements this grammar. That is a separate check, made by the program's
    round-trip test over real envelopes; this file is about the grammar only.
  - Strictness of `dec`: that it gives `none` on every token list that is not a frame followed by
    a rest. T1..T4 do not need it, and it is not proved here.
The proofs never look inside a number or a string, so the payload types (Int, String) play no part.

DEPARTURES FROM THE BRIEF (form only, same content).
  - `decUntil` tests the first token with the explicit function `isEnd`, and `decPairs` lists every
    first token, so that no definition has overlapping cases.
  - `decode`, the budget-free corollary of T1, and `examples_compute` are additions.

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

/-! ## The encoder -/

mutual
/-- One value. -/
def enc : V → List Tok
  | .nil => [tNil]
  | .bool true => [tYes]
  | .bool false => [tNo]
  | .num n => [tNum n]
  | .str s => [tStr s]
  | .arr xs => tArr :: (encL xs ++ [tEnd])
  | .obj kvs => tObj :: (encP kvs ++ [tEnd])
  | .shp i xs => tShape i :: encL xs
/-- Values one after another, nothing between them. -/
def encL : List V → List Tok
  | [] => []
  | x :: xs => enc x ++ encL xs
/-- Key/value pairs one after another: the key as a string token, then the value. -/
def encP : List (String × V) → List Tok
  | [] => []
  | (k, v) :: kvs => tStr k :: (enc v ++ encP kvs)
end

/-! ## Well-formedness: every shape has exactly as many values as the shape table says -/

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

/-! ## The budget bound -/

mutual
def size : V → Nat
  | .nil => 1
  | .bool _ => 1
  | .num _ => 1
  | .str _ => 1
  | .arr xs => sizeL xs + 1
  | .obj kvs => sizeP kvs + 1
  | .shp _ xs => sizeL xs + 1
def sizeL : List V → Nat
  | [] => 1
  | x :: xs => size x + sizeL xs + 1
def sizeP : List (String × V) → Nat
  | [] => 1
  | (_, v) :: kvs => size v + sizeP kvs + 1
end

/-! ## The decoder -/

def isEnd : Tok → Bool
  | tEnd => true
  | tNil | tYes | tNo | tNum _ | tStr _ | tArr | tObj | tShape _ => false

mutual
/-- Read one value. -/
def dec (arity : Nat → Nat) : Nat → List Tok → Option (V × List Tok)
  | 0, _ => none
  | _+1, [] => none
  | _+1, tNil :: r => some (.nil, r)
  | _+1, tYes :: r => some (.bool true, r)
  | _+1, tNo :: r => some (.bool false, r)
  | _+1, tNum n :: r => some (.num n, r)
  | _+1, tStr s :: r => some (.str s, r)
  | f+1, tArr :: r =>
    match decUntil arity f r with
    | some (xs, r') => some (.arr xs, r')
    | none => none
  | f+1, tObj :: r =>
    match decPairs arity f r with
    | some (kvs, r') => some (.obj kvs, r')
    | none => none
  | _+1, tEnd :: _ => none
  | f+1, tShape i :: r =>
    match decN arity f (arity i) r with
    | some (xs, r') => some (.shp i xs, r')
    | none => none
/-- Read values until `end`, and consume the `end`. -/
def decUntil (arity : Nat → Nat) : Nat → List Tok → Option (List V × List Tok)
  | 0, _ => none
  | _+1, [] => none
  | f+1, t :: r =>
    match isEnd t with
    | true => some ([], r)
    | false =>
      match dec arity f (t :: r) with
      | some (x, r') =>
        match decUntil arity f r' with
        | some (xs, r'') => some (x :: xs, r'')
        | none => none
      | none => none
/-- Read exactly `n` values. -/
def decN (arity : Nat → Nat) : Nat → Nat → List Tok → Option (List V × List Tok)
  | 0, _, _ => none
  | _+1, 0, ts => some ([], ts)
  | f+1, n+1, ts =>
    match dec arity f ts with
    | some (x, r') =>
      match decN arity f n r' with
      | some (xs, r'') => some (x :: xs, r'')
      | none => none
    | none => none
/-- Read key/value pairs until `end`, and consume the `end`. A key must be a string token. -/
def decPairs (arity : Nat → Nat) : Nat → List Tok → Option (List (String × V) × List Tok)
  | 0, _ => none
  | _+1, [] => none
  | _+1, tEnd :: r => some ([], r)
  | f+1, tStr k :: r =>
    match dec arity f r with
    | some (v, r') =>
      match decPairs arity f r' with
      | some (kvs, r'') => some ((k, v) :: kvs, r'')
      | none => none
    | none => none
  | _+1, tNil :: _ => none
  | _+1, tYes :: _ => none
  | _+1, tNo :: _ => none
  | _+1, tNum _ :: _ => none
  | _+1, tArr :: _ => none
  | _+1, tObj :: _ => none
  | _+1, tShape _ :: _ => none
end

/-- The decoder with no budget to choose: three steps per token are always enough. -/
def decode (arity : Nat → Nat) (ts : List Tok) : Option (V × List Tok) :=
  dec arity (3 * ts.length) ts

/-! ## Helper lemmas -/

theorem app_assoc : ∀ (a b c : List Tok), (a ++ b) ++ c = a ++ (b ++ c)
  | [], _, _ => rfl
  | t :: a, b, c => congrArg (t :: ·) (app_assoc a b c)

/-- Every encoding has a first token, and it is not `end`. -/
theorem enc_head : ∀ v : V, ∃ t ts, enc v = t :: ts ∧ isEnd t = false
  | .nil => ⟨_, _, rfl, rfl⟩
  | .bool true => ⟨_, _, rfl, rfl⟩
  | .bool false => ⟨_, _, rfl, rfl⟩
  | .num _ => ⟨_, _, rfl, rfl⟩
  | .str _ => ⟨_, _, rfl, rfl⟩
  | .arr _ => ⟨_, _, rfl, rfl⟩
  | .obj _ => ⟨_, _, rfl, rfl⟩
  | .shp _ _ => ⟨_, _, rfl, rfl⟩

/-! One step of each decoder, given what its inner calls return. -/

theorem dec_arr_step {arity : Nat → Nat} {f : Nat} {r r' : List Tok} {xs : List V}
    (h : decUntil arity f r = some (xs, r')) :
    dec arity (f+1) (tArr :: r) = some (V.arr xs, r') := by
  rw [dec, h]

theorem dec_obj_step {arity : Nat → Nat} {f : Nat} {r r' : List Tok} {kvs : List (String × V)}
    (h : decPairs arity f r = some (kvs, r')) :
    dec arity (f+1) (tObj :: r) = some (V.obj kvs, r') := by
  rw [dec, h]

theorem dec_shp_step {arity : Nat → Nat} {f i : Nat} {r r' : List Tok} {xs : List V}
    (h : decN arity f (arity i) r = some (xs, r')) :
    dec arity (f+1) (tShape i :: r) = some (V.shp i xs, r') := by
  rw [dec, h]

theorem decUntil_step {arity : Nat → Nat} {f : Nat} {t : Tok} {r r' r'' : List Tok} {x : V}
    {xs : List V} (hne : isEnd t = false) (h1 : dec arity f (t :: r) = some (x, r'))
    (h2 : decUntil arity f r' = some (xs, r'')) :
    decUntil arity (f+1) (t :: r) = some (x :: xs, r'') := by
  rw [decUntil, hne, h1]; dsimp only; rw [h2]

theorem decN_step {arity : Nat → Nat} {f n : Nat} {ts r' r'' : List Tok} {x : V} {xs : List V}
    (h1 : dec arity f ts = some (x, r')) (h2 : decN arity f n r' = some (xs, r'')) :
    decN arity (f+1) (n+1) ts = some (x :: xs, r'') := by
  rw [decN, h1]; dsimp only; rw [h2]

theorem decPairs_step {arity : Nat → Nat} {f : Nat} {k : String} {r r' r'' : List Tok} {v : V}
    {kvs : List (String × V)} (h1 : dec arity f r = some (v, r'))
    (h2 : decPairs arity f r' = some (kvs, r'')) :
    decPairs arity (f+1) (tStr k :: r) = some ((k, v) :: kvs, r'') := by
  rw [decPairs, h1]; dsimp only; rw [h2]

/-! ## The round trip, by induction on the value together with its lists -/

mutual
theorem dec_enc (arity : Nat → Nat) : ∀ (v : V), WF arity v → ∀ (f : Nat) (rest : List Tok),
    size v ≤ f → dec arity f (enc v ++ rest) = some (v, rest)
  | .nil, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | .nil, _, _+1, _, _ => rfl
  | .bool true, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | .bool true, _, _+1, _, _ => rfl
  | .bool false, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | .bool false, _, _+1, _, _ => rfl
  | .num _, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | .num _, _, _+1, _, _ => rfl
  | .str _, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | .str _, _, _+1, _, _ => rfl
  | .arr _, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | .arr xs, hw, f+1, rest, hf => by
    have ih := decUntil_encL arity xs hw f rest (Nat.le_of_succ_le_succ hf)
    have e : enc (.arr xs) ++ rest = tArr :: (encL xs ++ tEnd :: rest) :=
      congrArg (tArr :: ·) (app_assoc (encL xs) [tEnd] rest)
    rw [e]
    exact dec_arr_step ih
  | .obj _, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | .obj kvs, hw, f+1, rest, hf => by
    have ih := decPairs_encP arity kvs hw f rest (Nat.le_of_succ_le_succ hf)
    have e : enc (.obj kvs) ++ rest = tObj :: (encP kvs ++ tEnd :: rest) :=
      congrArg (tObj :: ·) (app_assoc (encP kvs) [tEnd] rest)
    rw [e]
    exact dec_obj_step ih
  | .shp _ _, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | .shp i xs, hw, f+1, rest, hf => by
    -- the only place the fixed arity is used: `hw.1 : xs.length = arity i`
    have ih := decN_encL arity xs hw.2 f rest (Nat.le_of_succ_le_succ hf)
    rw [hw.1] at ih
    exact dec_shp_step ih
theorem decUntil_encL (arity : Nat → Nat) : ∀ (xs : List V), WFL arity xs →
    ∀ (f : Nat) (rest : List Tok), sizeL xs ≤ f →
    decUntil arity f (encL xs ++ tEnd :: rest) = some (xs, rest)
  | [], _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | [], _, _+1, _, _ => rfl
  | _ :: _, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | x :: xs, hw, f+1, rest, hf => by
    have hf' : size x + sizeL xs ≤ f := Nat.le_of_succ_le_succ hf
    have h1 := dec_enc arity x hw.1 f (encL xs ++ tEnd :: rest)
      (Nat.le_trans (Nat.le_add_right _ _) hf')
    have h2 := decUntil_encL arity xs hw.2 f rest (Nat.le_trans (Nat.le_add_left _ _) hf')
    have e : encL (x :: xs) ++ tEnd :: rest = enc x ++ (encL xs ++ tEnd :: rest) :=
      app_assoc _ _ _
    rw [e]
    -- the only place T4 is used: the next value does not start with `end`
    obtain ⟨t, ts, ht, hne⟩ := enc_head x
    rw [ht] at h1 ⊢
    exact decUntil_step hne h1 h2
theorem decN_encL (arity : Nat → Nat) : ∀ (xs : List V), WFL arity xs →
    ∀ (f : Nat) (rest : List Tok), sizeL xs ≤ f →
    decN arity f xs.length (encL xs ++ rest) = some (xs, rest)
  | [], _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | [], _, _+1, _, _ => rfl
  | _ :: _, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | x :: xs, hw, f+1, rest, hf => by
    have hf' : size x + sizeL xs ≤ f := Nat.le_of_succ_le_succ hf
    have h1 := dec_enc arity x hw.1 f (encL xs ++ rest)
      (Nat.le_trans (Nat.le_add_right _ _) hf')
    have h2 := decN_encL arity xs hw.2 f rest (Nat.le_trans (Nat.le_add_left _ _) hf')
    have e : encL (x :: xs) ++ rest = enc x ++ (encL xs ++ rest) := app_assoc _ _ _
    rw [e]
    exact decN_step h1 h2
theorem decPairs_encP (arity : Nat → Nat) : ∀ (kvs : List (String × V)), WFP arity kvs →
    ∀ (f : Nat) (rest : List Tok), sizeP kvs ≤ f →
    decPairs arity f (encP kvs ++ tEnd :: rest) = some (kvs, rest)
  | [], _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | [], _, _+1, _, _ => rfl
  | _ :: _, _, 0, _, hf => absurd hf (Nat.not_succ_le_zero _)
  | (k, v) :: kvs, hw, f+1, rest, hf => by
    have hf' : size v + sizeP kvs ≤ f := Nat.le_of_succ_le_succ hf
    have h1 := dec_enc arity v hw.1 f (encP kvs ++ tEnd :: rest)
      (Nat.le_trans (Nat.le_add_right _ _) hf')
    have h2 := decPairs_encP arity kvs hw.2 f rest (Nat.le_trans (Nat.le_add_left _ _) hf')
    have e : encP ((k, v) :: kvs) ++ tEnd :: rest
        = tStr k :: (enc v ++ (encP kvs ++ tEnd :: rest)) :=
      congrArg (tStr k :: ·) (app_assoc _ _ _)
    rw [e]
    exact decPairs_step h1 h2
end

/-! ## The budget bound against the number of tokens: size v < 3 × (tokens of enc v) -/

theorem arith_cons {R R' E sx sl : Nat} (h1 : R' + (sx + 1) ≤ E) (h2 : R + sl ≤ R' + 1) :
    R + (sx + sl + 1) ≤ E + 1 := by
  have a : R + (sx + sl) = R + sl + sx := by rw [Nat.add_comm sx sl, Nat.add_assoc]
  have b : R' + 1 + sx = R' + (sx + 1) := by rw [Nat.add_assoc, Nat.add_comm 1 sx]
  have c : R + (sx + sl) ≤ E := by
    rw [a]
    exact Nat.le_trans (Nat.add_le_add_right h2 sx) (by rw [b]; exact h1)
  exact Nat.succ_le_succ c

mutual
theorem size_le (v : V) : ∀ (rest : List Tok),
    3 * rest.length + (size v + 1) ≤ 3 * (enc v ++ rest).length :=
  match v with
  | .nil => fun _ => Nat.le_succ _
  | .bool true => fun _ => Nat.le_succ _
  | .bool false => fun _ => Nat.le_succ _
  | .num _ => fun _ => Nat.le_succ _
  | .str _ => fun _ => Nat.le_succ _
  | .arr xs => fun rest => by
    have ih := sizeL_le xs (tEnd :: rest)
    have e : enc (.arr xs) ++ rest = tArr :: (encL xs ++ tEnd :: rest) :=
      congrArg (tArr :: ·) (app_assoc (encL xs) [tEnd] rest)
    rw [e]
    have ih' : 3 * rest.length + sizeL xs + 3 ≤ 3 * (encL xs ++ tEnd :: rest).length + 1 :=
      Nat.add_right_comm (3 * rest.length) 3 (sizeL xs) ▸ ih
    exact Nat.le_trans (Nat.le_succ _) (Nat.le_trans ih' (Nat.le_add_right _ 2))
  | .obj kvs => fun rest => by
    have ih := sizeP_le kvs (tEnd :: rest)
    have e : enc (.obj kvs) ++ rest = tObj :: (encP kvs ++ tEnd :: rest) :=
      congrArg (tObj :: ·) (app_assoc (encP kvs) [tEnd] rest)
    rw [e]
    have ih' : 3 * rest.length + sizeP kvs + 3 ≤ 3 * (encP kvs ++ tEnd :: rest).length + 1 :=
      Nat.add_right_comm (3 * rest.length) 3 (sizeP kvs) ▸ ih
    exact Nat.le_trans (Nat.le_succ _) (Nat.le_trans ih' (Nat.le_add_right _ 2))
  | .shp _ xs => fun rest => Nat.add_le_add_right (sizeL_le xs rest) 2
theorem sizeL_le (xs : List V) : ∀ (rest : List Tok),
    3 * rest.length + sizeL xs ≤ 3 * (encL xs ++ rest).length + 1 :=
  match xs with
  | [] => fun _ => Nat.le_refl _
  | x :: xs => fun rest => by
    have e : encL (x :: xs) ++ rest = enc x ++ (encL xs ++ rest) := app_assoc _ _ _
    rw [e]
    exact arith_cons (size_le x (encL xs ++ rest)) (sizeL_le xs rest)
theorem sizeP_le (kvs : List (String × V)) : ∀ (rest : List Tok),
    3 * rest.length + sizeP kvs ≤ 3 * (encP kvs ++ rest).length + 1 :=
  match kvs with
  | [] => fun _ => Nat.le_refl _
  | (k, v) :: kvs => fun rest => by
    have e : encP ((k, v) :: kvs) ++ rest = tStr k :: (enc v ++ (encP kvs ++ rest)) :=
      congrArg (tStr k :: ·) (app_assoc _ _ _)
    rw [e]
    exact Nat.le_trans (arith_cons (size_le v (encP kvs ++ rest)) (sizeP_le kvs rest))
      (Nat.succ_le_succ (Nat.le_add_right _ 3))
end

/-! ## The theorems -/

/-- T1. Round trip with any continuation, for every budget at or above `size v`. -/
theorem T1_round_trip (arity : Nat → Nat) (v : V) (hv : WF arity v) (rest : List Tok) (f : Nat)
    (hf : size v ≤ f) : dec arity f (enc v ++ rest) = some (v, rest) :=
  dec_enc arity v hv f rest hf

/-- T1 with no budget to choose. -/
theorem T1_round_trip_no_fuel (arity : Nat → Nat) (v : V) (hv : WF arity v) (rest : List Tok) :
    decode arity (enc v ++ rest) = some (v, rest) :=
  T1_round_trip arity v hv rest _
    (Nat.le_trans (Nat.le_trans (Nat.le_succ _) (Nat.le_add_left _ _)) (size_le v rest))

/-- T3. Prefix-freeness, from T1: decode both sides of the equation with one budget. -/
theorem T3_prefix_free (arity : Nat → Nat) (v1 v2 : V) (h1 : WF arity v1) (h2 : WF arity v2)
    (r1 r2 : List Tok) (h : enc v1 ++ r1 = enc v2 ++ r2) : v1 = v2 ∧ r1 = r2 := by
  have a := T1_round_trip arity v1 h1 r1 (size v1 + size v2) (Nat.le_add_right _ _)
  have b := T1_round_trip arity v2 h2 r2 (size v1 + size v2) (Nat.le_add_left _ _)
  rw [h, b] at a
  injection a with a
  injection a with a1 a2
  exact ⟨a1.symm, a2.symm⟩

/-- T2. Unique decodability, from T1 (through T3 with nothing after either frame). -/
theorem T2_unique_decodability (arity : Nat → Nat) (v1 v2 : V) (h1 : WF arity v1)
    (h2 : WF arity v2) (h : enc v1 = enc v2) : v1 = v2 :=
  (T3_prefix_free arity v1 v2 h1 h2 [] [] (congrArg (· ++ []) h)).1

/-- T4. No value starts with `end`. -/
theorem T4_no_value_starts_with_end (v : V) : enc v ≠ [] ∧ (enc v).head? ≠ some tEnd := by
  obtain ⟨t, ts, h, hne⟩ := enc_head v
  rw [h]
  refine ⟨List.cons_ne_nil _ _, fun e => ?_⟩
  have e' : t = tEnd := Option.some.inj e
  rw [e'] at hne
  exact Bool.noConfusion hne

/-- The definitions compute. With a shape table in which every shape takes two values: what one
frame looks like; it is read back and the token after it is left unread; a shape frame cut short
is refused; a lone `end` is refused. -/
theorem examples_compute :
    enc (.arr [.shp 7 [.num 1, .str "a"], .obj [("k", .nil)], .bool true])
      = [tArr, tShape 7, tNum 1, tStr "a", tObj, tStr "k", tNil, tEnd, tYes, tEnd]
    ∧ decode (fun _ => 2)
        ([tArr, tShape 7, tNum 1, tStr "a", tObj, tStr "k", tNil, tEnd, tYes, tEnd] ++ [tNo])
      = some (.arr [.shp 7 [.num 1, .str "a"], .obj [("k", .nil)], .bool true], [tNo])
    ∧ decode (fun _ => 2) [tShape 7, tNum 1] = none
    ∧ decode (fun _ => 2) [tEnd] = none :=
  ⟨rfl, rfl, rfl, rfl⟩

#print axioms T1_round_trip
#print axioms T1_round_trip_no_fuel
#print axioms T2_unique_decodability
#print axioms T3_prefix_free
#print axioms T4_no_value_starts_with_end
#print axioms examples_compute
#print axioms app_assoc
#print axioms enc_head
#print axioms dec_arr_step
#print axioms dec_obj_step
#print axioms dec_shp_step
#print axioms decUntil_step
#print axioms decN_step
#print axioms decPairs_step
#print axioms dec_enc
#print axioms decUntil_encL
#print axioms decN_encL
#print axioms decPairs_encP
#print axioms arith_cons
#print axioms size_le
#print axioms sizeL_le
#print axioms sizeP_le
