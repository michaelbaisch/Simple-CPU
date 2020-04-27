; Calculate Fibonacci Numbers
SECTION .data
  Fnumber 5   ; number of numbers to produce
  F1 0        ; Initial number 1
  F2 1        ; Initial number 2
  Result 1    ; Variable to store result

SECTION .text
  out F1
  out F2
loop:
  add Result, F1
  mov F1, F2
  mov F2, Result
  out Result
  dec Fnumber
  jnz loop
