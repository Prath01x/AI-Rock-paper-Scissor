.data
    .globl main

# Memory layout of the Configuration
# |   eca  |   tape   |  tape_len  |  rule  |  skip  | column |
# | 1 word |  1 word  |   1 byte   | 1 byte | 1 byte | 1 byte |
automaton:
  .word 1       # eca
  .word 252     # tape
  .byte 8       # tape_len
  .byte 106     # rule
  .byte 1       # skip
  .byte 5       # column

.text

main:
  la $a0 automaton
  jal play_game_once

  li      $v0 10
  syscall
