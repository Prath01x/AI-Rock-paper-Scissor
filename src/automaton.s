# vim:sw=2 syntax=asm
.text
  .globl simulate_automaton, print_tape

# Simulate one step of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, but updates the tape in memory location 4($a0)
simulate_automaton:
  # TODO
  jr $ra


print_tape:
move $t6 $ra
lw $s1 4($a0)
lb $s2 8($a0)

sub $t1, $s2, 1    
li $t2, 1          
sllv $t2, $t2, $t1


loop:
bge $s3 $s2 end
and $t7 $s1 $t2
beq $t7 $zero dead
li $v0 11
li $a0 'X'
syscall
srl $t2, $t2, 1
addi $s3 $s3 1
j loop

dead:
li $v0 11
li $a0 '_'
syscall
srl $t2, $t2, 1
addi $s3 $s3 1
j loop



end:
li $v0 11        
li $a0 '\n'    
syscall           

 move $ra $t6
 move $a0 $t5
 jr $ra
