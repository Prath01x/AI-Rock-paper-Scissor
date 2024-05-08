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
 
    move $t3, $ra

    li $v0, 0         
    
Loop:
    jal gen_bit       
    move $t0, $v0     
    
    jal gen_bit       
    move $t1, $v0     
    
    sll $t0, $t0, 1   
    or $v0, $t0, $t1 
    
    li $t2, 3         
    beq $v0, $t2, Loop  
    
   
    move $ra, $t3

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
   
    move $t5, $ra

    
    li $v0, 41
    
    
    li $a0, 0
    
   
    syscall
    
    andi $v0, $a0, 1
     
 
    move $ra, $t5
    
  
    jr $ra

