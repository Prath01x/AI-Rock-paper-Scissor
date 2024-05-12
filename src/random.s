# vim:sw=2 syntax=asm
.data

.text
  .globl gen_byte, gen_bit

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Compute the next valid byte (00, 01, 10) and put into $v0
#  If 11 would be returned, produce two new bits until valid
#

gen_byte:
addi $sp $sp -100
sw $ra ($sp) 
sw $a0 4($sp)
   move $s7 $a0
    li $v0, 0         
    
Loop:
    jal gen_bit       
    move $t0, $v0     
    lw $a0 4($sp)
    jal gen_bit       
    move $t1, $v0     
    lw $a0 4($sp)
    
    sll $t0, $t0, 1   
    or $v0, $t0, $t1 
    
    li $t2, 3         
    beq $v0, $t2, Loop  
    
   
lw $ra ($sp)
addiu $sp $sp 100
jr $ra
 
 




# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape                                                                                                                                                          (1 word)
#   8($a0): tape_len  (1 byte)


#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Look at the field {eca} and use the associated random number generator to generate one bit.
#  Put the computed bit into $v0
#
# Set the seed and generate a random bit
# gen_bit function

gen_bit:	
 addiu $sp $sp -56
 sw $ra 12($sp)#in stack
lw $s1 0($a0)
	


    bne $s1 $zero gen_simulate
    
    li $v0, 41
    li $a0, 0
    syscall
    andi $v0, $a0, 1
j end1
 
    gen_simulate:
    
   
    lw $s2 4($a0)#tape
    lb $s3 8($a0)
    lb $s4 10($a0)#skip
    lb $s5 11($a0)#col
    subu $s3 $s3 1
    subu $s3 $s3 $s5
    sw $s3 8($sp)#len len which i need to shift in stack
    
   li $t7 0
    
    
    loop:  
     beq  $t7 $s4 end
    sw $s4 4($sp)#skip in stack
    sw $t7 0($sp)#counter in stack
    jal simulate_automaton
    lw $t7 0($sp)
    lw $s4 4($sp)
   
    addiu $t7 $t7 1
    j loop
    end:
    lw $s2 4($a0)#tape
    lw $s3 8($sp)
    srlv $s2 $s2 $s3
    andi $v0 $s2 1
    end1:
    lw $ra 12($sp)
    addiu $sp $sp 56
    jr $ra
    
    
      

































   
 
   
    