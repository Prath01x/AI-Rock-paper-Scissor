
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


# $a0 3 bits (cell) we need to determine
# $a1 rule to use

determinecell:
addi $sp $sp -4
sw $ra ($sp) 
srlv $v0 $a1 $a0
andi $v0 $v0 1
lw $ra ($sp)
addi $sp $sp 4
jr $ra 

simulate_automaton:
addi $sp $sp -20
sw $ra ($sp) 

lw $s1 4($a0)# tape
lb $s2 8($a0)
subi $s2 $s2 1
lb $s3 9($a0)
move $s7 $a0
li $t1 0 # result
move $s5 $t0
move $s6 $t1
jal get_right_most_bits
move $t0 $s5
move $t1 $s6

move $a0 $v0
move $a1 $s3
jal determinecell
move $t1 $v0

li $t4 0 # counter
li $t5 7 # mask for current 3 bits
fucker:
and $a0 $s1 $t5 # get the current 3 bits with our mask
srlv $a0 $a0 $t4 # shift result all the way to the right
jal determinecell # determine the value of the cell
addi $t2 $t4 1 # add one to counter because we need to shift the one more time to center
sllv $v0 $v0 $t2 # "put it back" to the previous position
or $t1 $t1 $v0 # "insert" the value into the full result
addi $t4 $t4 1 # increase counter
sll $t5 $t5 1 # shift mask one to the left
bne $t4 $s2 fucker # looooooop

move $a0 $s7

move $s5 $t0
move $s6 $t1
jal get_left_most_bits
move $t0 $s5
move $t1 $s6
move $a0 $v0
jal determinecell
sllv $v0 $v0 $t4
or $t1 $t1 $v0
move $a0 $s7
sw $t1 4($a0)
lw $ra ($sp)
li $t1 0
addi $sp $sp 20
jr $ra 




get_right_most_bits:
addi $sp $sp -4
sw $ra ($sp) 
lw $t0 4($a0) # tape
lb $t1 8($a0) # tape_len

andi $v0 $t0 3 # 2 right-most bits of the tape
subi $t1 $t1 1 # subtract 1 from len to get pos of left most bits
srlv $t0 $t0 $t1 # shift right by (len-1) so the left most bit is now at the right most position
   		# (and everything else is 0)
sll $v0 $v0 1 # shift the  2 bits we arleady have one to the left to make "space" for the next bit
or $v0 $v0 $t0 # "insert" the last bit 

lw $ra ($sp)
addi $sp $sp 4
jr $ra 

get_left_most_bits:
addi $sp $sp -32
sw $ra 0($sp) 
lw $t0 4($a0) # t
lb $t1 8($a0) # t

andi $v0 $t0 1 # t
sll $v0 $v0 2 # ps the left neighbor
subi $t1 $t1 2 # om len to get pos of 2 left most bits

srlv $t0 $t0 $t1  
or $v0 $v0 $t0 # 						mbine the two results

lw $ra 0($sp)
addi $sp $sp 32
jr $ra 



















 
 


print_tape:
addi $sp $sp -4
sw $ra ($sp) 

lw $s1 4($a0)
lb $s2 8($a0)

sub $t1, $s2, 1    
li $t2, 1          
sllv $t2, $t2, $t1
li $s3 0

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
lw $ra ($sp)
addi $sp $sp 4
jr $ra 


