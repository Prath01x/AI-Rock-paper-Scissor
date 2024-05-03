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
    # Save the return address
    move $t3, $ra

    li $v0, 0         # Initialize the byte value to 0
    
Loop:
    jal gen_bit       # Generate the first bit
    move $t0, $v0     # Store the result in $t0
    
    jal gen_bit       # Generate the second bit
    move $t1, $v0     # Store the result in $t1
    
    sll $t0, $t0, 1   # Shift the first bit to the left
    or $v0, $t0, $t1  # Combine the bits
    
    li $t2, 3         # Check if the result is "11"
    beq $v0, $t2, Loop  # If the result is "11", generate new bits
    
    # Restore the return address
    move $ra, $t3

    jr $ra            # Return
 




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
    # Save the return address
    move $t5, $ra

    # Set the syscall code for generating a random number
    li $v0, 41
    
    # Set the pseudorandom number generator ID to 0
    li $a0, 0
    
    # Perform syscall to generate a random number
    syscall
    
    # Extract the least significant bit (LSB)
    andi $v0, $a0, 1
     
    # Restore the return address
    move $ra, $t5
    
    # Return the computed bit
    jr $ra

