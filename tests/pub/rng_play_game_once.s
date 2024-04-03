.data
    .globl main

# Memory layout of the Configuration
# |   eca  |   tape   |  tape_len  |  rule  |  skip  | column |
# | 1 word |  1 word  |   1 byte   | 1 byte | 1 byte | 1 byte |
automaton:
  .word 0       # eca
  .word 420     # tape
  .byte 8       # tape_len
  .byte 106     # rule
  .byte 1       # skip
  .byte 5       # column

.text

main:
  li $v0 40 # set seed syscall
  li $a0 0 # rng id
  lw $a1 automaton+4 # seed
  syscall

  la $a0 automaton
  jal play_game_once
  la $a0 automaton
  jal play_game_once
  la $a0 automaton
  jal play_game_once
  la $a0 automaton
  jal play_game_once

  li      $v0 10
  syscall

