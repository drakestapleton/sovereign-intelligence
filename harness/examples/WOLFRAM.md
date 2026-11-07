# Wolfram checks for the example expectations

Every arithmetic value in an `examples/*.stdout` file and the FNV-1a bytes of
`skills/omega-encoding/examples/fnv1a32.stdout` were checked with one WolframLanguageEvaluator call
on 2026-10-27. The `.stdout` files hold what the pinned compiler's programs printed
(omega-mv `e5b32567`, omc sha256 `2c824805…029f`); this call is the independent check that those
outputs are the right numbers. Byte counts, exit statuses and the `before` lines are bookkeeping and
are not listed.
The same stdout bytes were printed again on 2026-10-29 by omc `62775d2a…712b` (omega-mv `bf54b19f`); the gate compared them. Wolfram was not rerun that day.

Query (verbatim):

```wolfram
toBits[x_] := FromDigits[Flatten[{RealDigits[x, 2, 1, 0]}], 2]; u64[x_?NumericQ] := Module[{b = ExportString[{x}, "Real64", ByteOrdering -> -1]}, FromDigits[Reverse[ToCharacterCode[b]], 256]];
<|
"print_decimal" -> {2^64 - 1, 2^63 - 1, -2^63},
"int_arith" -> {Quotient[-7, 2] + If[Mod[-7, 2] != 0 && -7 < 0, 1, 0], -7 - 2*IntegerPart[-7/2], IntegerPart[7/-2], 7 - (-2)*IntegerPart[7/-2], 123456789*987654321, Floor[-16/2^2], 0 - (-7)},
"unsigned_wrap" -> {Mod[2^32 - 1 + 1, 2^32], Mod[0 - 1, 2^32], Mod[65536*65536, 2^32], Mod[-1, 2^32], BitNot[0] + 2^32, 2^31, Mod[2^64 - 1 + 1, 2^64]},
"exit_status" -> Mod[300, 256],
"float_arith" -> {IntegerPart[Sqrt[2.`30]*10^9], u64[0.1 + 0.2], u64[1.0], IntegerPart[-2.5], IntegerPart[Abs[-7.9]]},
"float_to_int" -> {2^63 - 1, -2^63, IntegerPart[-5.75]},
"checked_conv" -> {BitAnd[300, 255], 2^31 - 1, 2^16 - 1},
"arrays" -> {Sum[k^2, {k, 1, 8}], 8^2},
"globals" -> {DigitCount[1234567890, 10, 9] + DigitCount[9999, 10, 9], DigitCount[1234567890, 10, 0] + 1, DigitCount[1234567890, 10, 5]},
"loops" -> {Length[NestWhileList[If[EvenQ[#], #/2, 3 # + 1] &, 27, # != 1 &]] - 1, Total[Select[Range[0, 50], Mod[#, 3] != 0 &]]},
"functions" -> {20!, GCD[1071, 462], 1 + 6 + 2*(5 - 4)},
"text" -> {StringLength["tab\there \"q\" back\\slash\n"], ToCharacterCode["t"]},
"structs" -> {5 + (-12), 8*2},
"stdin_count" -> {StringLength["alpha\nbeta\ngamma delta\n\nend"], StringCount["alpha\nbeta\ngamma delta\n\nend", "\n"], Total[ToCharacterCode["alpha\nbeta\ngamma delta\n\nend"]]},
"wire_le" -> {IntegerDigits[16^^12345678, 256], FromDigits[Reverse[{120, 86, 52, 255}], 256] - 2^32},
"om2_hex_rotr" -> {16^^deadbeef, BitOr[BitShiftRight[16^^deadbeef, 8], BitAnd[BitShiftLeft[16^^deadbeef, 24], 2^32 - 1]], 2^64 - 1, BitAnd[16^^deadbeef, 255]},
"om2_views" -> {Total[Range[6]], 2 + 3 + 4, 6},
"om2_tour" -> {7*3, 7*2^32 + 7 == 16^^0000000700000007},
"contract_release" -> Quotient[7, 2],
"tmp_files" -> {BitOr[1, 64, 128], FromDigits["600", 8], FromDigits["700", 8], StringLength["omega\n"]},
"env_read" -> {StringLength["LONG=" <> StringRepeat["v", 70]]},
"echo_args" -> {1 + 4, StringLength[StringRepeat["x", 40]]},
"trap_bounds" -> {2^31 - 1 + 1 > 2^31 - 1, 2^63 - 1},
"fnv1a32_abc" -> IntegerDigits[Fold[Mod[BitXor[#1, #2]*16777619, 2^32] &, 2166136261, ToCharacterCode["abc"]], 256, 4] // Reverse
|>
```

Result (verbatim):

```
<|"print_decimal" -> {18446744073709551615, 9223372036854775807, -9223372036854775808}, "int_arith" -> {-3, -1, -3, 1, 121932631112635269, -4, 7}, "unsigned_wrap" -> {0, 4294967295, 0, 4294967295, 4294967295, 2147483648, 0}, "exit_status" -> 44, "float_arith" -> {1414213562, 4599075939470750516, 4607182418800017408, -2, 7}, "float_to_int" -> {9223372036854775807, -9223372036854775808, -5}, "checked_conv" -> {44, 2147483647, 65535}, "arrays" -> {204, 64}, "globals" -> {5, 2, 1}, "loops" -> {111, 867}, "functions" -> {2432902008176640000, 21, 9}, "text" -> {24, {116}}, "structs" -> {-7, 16}, "stdin_count" -> {27, 4, 2350}, "wire_le" -> {{18, 52, 86, 120}, -13347208}, "om2_hex_rotr" -> {3735928559, 4024348094, 18446744073709551615, 239}, "om2_views" -> {21, 9, 6}, "om2_tour" -> {21, True}, "contract_release" -> 3, "tmp_files" -> {193, 384, 448, 6}, "env_read" -> {75}, "echo_args" -> {5, 40}, "trap_bounds" -> {True, 9223372036854775807}, {26, 71, 233, 11} -> "fnv1a32_abc"|>
```

Reading notes:

- `int_arith`: Omega `div` and `rem` truncate toward zero, so the program prints `-3 -1 -3 1` for
  `-7/2`, `-7 rem 2`, `7/-2`, `7 rem -2`; `shr long -16 2` is an arithmetic shift, `-4`.
- `float_arith`: `IntegerPart` matches Omega's float-to-integer truncation toward zero.
- `wire_le`: Wolfram lists the bytes of `0x12345678` most significant first (`18 52 86 120`); the
  program stores them least significant first and prints `120 86 52 18`.
- `fnv1a32_abc`: the trailing `// Reverse` applied to the rule, so the result shows as
  `{26, 71, 233, 11} -> "fnv1a32_abc"`: hash `0x1a47e90b`, written little-endian as the bytes
  `0b e9 47 1a` in `fnv1a32.stdout`.
- `env_read`: the `LONG=` entry is 75 bytes, over the 63-byte capacity, so `envread` returns -105 and
  the program prints an empty line for it.

Second call, for `int_bits_and` (exit status 8 is the value checked), query and result verbatim:

```wolfram
BitAnd[12, 10]
```

```
8
```

Third call, 2026-10-31, for `for_bound` (exit status 10, the sum of `i` over the 5 passes) with the
omc `24caacf4…abb7` pin, query and result verbatim:

```wolfram
{Sum[i, {i, 0, 4}], 512 - 495, Mod[1500000,89], Mod[1100000,89], Mod[1234567,89], Mod[2000000,89], 2^63 - 1}
```

```
{10, 17, 83, 49, 48, 81, 9223372036854775807}
```

The other entries are the `omega-encoding` section 0 and section 8 numbers (free om4 function entries,
loop probe exit statuses, the largest `bound`).
