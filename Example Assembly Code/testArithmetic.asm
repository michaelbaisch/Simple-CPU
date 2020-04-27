; Test the arithmetic instructions
SECTION .data
  num1 10
  num2 20        

SECTION .text
  add num1, 42      
  add num1, num2
  out num1          ; output 10 + 42 + 20 = 72; 0x48
  sub num1, num2
  sub num1, 23
  out num1          ; output 72 - 20 - 23 = 29; 0x1D
  inc num2
  out num2          ; output 20 + 1 = 21; 0x15
  dec num1
  out num1          ; output 29 - 1 = 28; 0x1C