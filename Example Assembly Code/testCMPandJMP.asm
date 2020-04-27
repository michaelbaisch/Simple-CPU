; Test the compare and conditional jump instructions
; Expected output: 0 3 2 2 1 4
SECTION .data
  num1 10
  num2 20   
  output 0

SECTION .text
beginning:
  mov output, 0
  out output
  jmp jumpTo
afterFirstJump:
  mov output, 1
  out output
  sub num2, 18
  jz beginning
  jnz endLabel
someWhereElseToJumpTo:
  mov output, 2
  out output
  dec num1
  cmp num1 8
  jg someWhereElseToJumpTo
  cmp num1 8
  jle afterFirstJump
jumpTo: 
  mov output, 3
  out output
  cmp num1, 10
  je someWhereElseToJumpTo
  out num1
endLabel:   
  mov output, 4
  out output