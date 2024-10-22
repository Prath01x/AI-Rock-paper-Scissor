# vim:sw=2 syntax=asm
.data

.text
  .globl play_game_once

# Play the game once, that is
# (1) compute two moves (RPS) for the two computer players
# (2) Print (W)in (L)oss or (T)ie, whether the first player wins, looses or ties.
#
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, only print either character 'W', 'L', or 'T' to stdout
play_game_once:
addi $sp $sp -200
sw $ra 8($sp) 
sw $a0 4($sp)

  jal gen_byte
  sw $s1 0($sp)
  lw $a0 4($sp)
  move $s1 $v0
  sw $s1 0($sp)
  jal gen_byte
  lw $a0 4($sp)
  move $s2 $v0
  b check

  


check:
lw $s1 0($sp)
beq $s1 $s2 Tie
beq $s1 0 rock
beq $s1 1 paper
beq $s1 2 scissor

Tie:
li $v0, 11     
li $a0, 'T'      
syscall 
j end


rock:
beq $s2 2 Win
li $v0, 11     
li $a0, 'L'      
syscall   
j end

paper:
beq $s2 0 Win
li $v0, 11     
li $a0, 'L'      
syscall  
j end

scissor:
beq $s2 1 Win
li $v0, 11     
li $a0, 'L'      
syscall  
j end

Win:
li $v0 11
li $a0 'W'
syscall 
j end

end:

lw $ra 8($sp)
addi $sp $sp 200
jr $ra 


