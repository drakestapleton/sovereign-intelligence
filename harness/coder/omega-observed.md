
## Observed with the pinned omc (2c824805)

- `struct` definitions come before the first `fn`; a `struct` after a function is error 9.
- `global`, `const` and `text` may appear between functions.
- An `if` with an `else` arm: `if COND` ... `else` ... `end`. There is no `elif`; nest a second `if`
  inside the `else` arm.
