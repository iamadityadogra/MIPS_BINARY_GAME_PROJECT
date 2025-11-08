# convert.asm - Binary and decimal conversion utilities
# This module offers functions to convert between binary and decimal

.data
    binary_string:  .space 9        # Space for 8-bit binary string + null terminator

.text
.globl decimal_to_binary
.globl binary_to_decimal

decimal_to_binary:
    # Transform decimal number to 8-bit binary representation
    # $a0 = decimal number (0-255)
    # Returns: $v0 = address of binary string (8 characters + null)
    
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0               # $s0 = decimal number to transform
    la $s1, binary_string       # $s1 = address of output buffer
    
    # We'll isolate each bit from position 7 down to 0
    li $t0, 7                   # $t0 = current bit position (begin at bit 7)
    
dec_to_bin_loop:
    # Generate a mask for the current bit position
    li $t1, 1                   # Begin with 1
    sllv $t1, $t1, $t0          # Shift left by bit position (generates mask)
    
    # AND the number with the mask to isolate that bit
    and $t2, $s0, $t1           # $t2 = number & mask
    
    # Verify if the bit is 0 or 1
    beq $t2, $zero, store_zero_char
    
    # Bit is 1, save '1' character (ASCII 49)
    li $t3, 49                  # ASCII code for '1'
    sb $t3, 0($s1)              # Save byte at current position in string
    j next_bit_position

store_zero_char:
    # Bit is 0, save '0' character (ASCII 48)
    li $t3, 48                  # ASCII code for '0'
    sb $t3, 0($s1)              # Save byte

next_bit_position:
    addi $s1, $s1, 1            # Advance to next position in string
    addi $t0, $t0, -1           # Reduce bit position
    
    # Verify if we've completed all 8 bits
    li $t4, -1
    bgt $t0, $t4, dec_to_bin_loop   # If bit_pos > -1, continue
    
    # Append null terminator to string
    sb $zero, 0($s1)            # Save null byte at end
    
    # Return address of binary string
    la $v0, binary_string
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

binary_to_decimal:
    # Transform 8-bit binary number to decimal
    # $a0 = binary number as integer (e.g., 0b10110101)
    # Returns: $v0 = decimal value
    # Note: This function is straightforward since in MIPS, binary numbers
    # are already kept as integers. We just return the value.
    
    move $v0, $a0               # The "conversion" is just transferring the value
    jr $ra                      # Because it's already in integer form

# Helper function: transform binary string to integer (already in io_handler.asm)
# This function would parse a string like "10110101" into an integer

extract_bit:
    # Helper function to isolate a specific bit from a number
    # $a0 = number
    # $a1 = bit position (0-7)
    # Returns: $v0 = 0 or 1
    
    li $t0, 1                   # Begin with 1
    sllv $t0, $t0, $a1          # Shift left by bit position (generate mask)
    and $t1, $a0, $t0           # AND number with mask
    
    # If result is 0, bit is 0; otherwise bit is 1
    beq $t1, $zero, bit_is_zero
    li $v0, 1                   # Bit is 1
    jr $ra

bit_is_zero:
    li $v0, 0                   # Bit is 0
    jr $ra

count_bits:
    # Helper function to tally number of 1 bits in a number
    # $a0 = number
    # Returns: $v0 = count of 1 bits
    
    move $t0, $a0               # Duplicate number
    li $v0, 0                   # Set count to 0
    
count_loop:
    beq $t0, $zero, count_done  # If number is 0, we're finished
    
    andi $t1, $t0, 1            # Verify if lowest bit is 1
    add $v0, $v0, $t1           # Include it to count (0 or 1)
    
    srl $t0, $t0, 1             # Shift right by 1 (divide by 2)
    j count_loop                # Continue

count_done:
    jr $ra

get_bit_value:
    # Obtain the decimal value of a specific bit position
    # $a0 = bit position (0-7)
    # Returns: $v0 = decimal value (e.g., bit 0 = 1, bit 1 = 2, bit 2 = 4, etc.)
    
    li $v0, 1                   # Begin with 1
    sllv $v0, $v0, $a0          # Shift left by position (2^position)
    jr $ra