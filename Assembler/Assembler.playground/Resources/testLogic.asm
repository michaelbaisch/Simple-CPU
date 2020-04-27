; Test the logic instructions
SECTION .data
  num1 0xffffff55     ; hex value
  num2 20             ; decimal value

SECTION .text
  not num1          ; = 0b10101010; 0xaa   ("not" memory location)
  out num1
  or num1, num2     ; = 0b10101010 or 0b10100 = 0b10111110; 0xbe    ("or" two memory locations)
  out num1
  xor num1, num2    ; = 0b10111110 xor 0b10100 = 0b10101010; 0xaa   ("xor" two memory locations)
  out num1
  and num1, 23      ; = 0b10101010 and 0b10111 = 0b10; 0x2        ("and" memory location and constant)
  out num1
