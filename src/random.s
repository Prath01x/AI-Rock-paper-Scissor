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
  # TODO
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
gen_bit:
    # Set syscall code for generating a random integer
    li $v0, 41              # Set to the appropriate syscall number
    
    # Set pseudorandom number generator ID to 0
    li $a0, 0
    
    # Perform syscall to obtain a random integer
    syscall
    
    # Extract the least significant bit (LSB) from the random integer
    andi $v0, $a0, 1        # Extract the least significant bit (LSB) of the generated random integer
    
    # Return from the function
    jr $ra



