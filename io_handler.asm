# io_handler.asm - Input and output management
# This module manages all user input for the game

.data
    prompt_decimal: .asciiz "Enter your answer in decimal: "
    prompt_binary:  .asciiz "Enter your answer in binary: "
    invalid_input:  .asciiz "Invalid input! Please try again.\n"
    input_buffer:   .space 12       # Buffer for storing user's string input
    
.text
.globl get_user_answer

get_user_answer:
    # This function obtains the user's answer based on problem type
    # $a0 = problem type (0 = bin->dec, so user provides decimal)
    #                    (1 = dec->bin, so user provides binary)
    # Returns: $v0 = user's answer as an integer (0-255)
    
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    move $s0, $a0               # Preserve problem type

get_input_retry:
    # Verify problem type to determine what to request
    beq $s0, $zero, ask_for_decimal
    # Otherwise request binary
    j ask_for_binary

ask_for_decimal:
    # User must provide a decimal number
    li $v0, 4
    la $a0, prompt_decimal      # "Enter your answer in decimal: "
    syscall
    
    # Read integer directly
    li $v0, 5                   # Read integer syscall
    syscall                     # Result in $v0
    
    move $t0, $v0               # Preserve result
    
    # Confirm that it's 0-255
    bltz $t0, invalid_dec_input # If negative, invalid
    li $t1, 256
    bge $t0, $t1, invalid_dec_input # If >= 256, invalid
    
    # Valid input
    move $v0, $t0               # Place answer in return register
    j get_input_done

invalid_dec_input:
    li $v0, 4
    la $a0, invalid_input       # "Invalid input!"
    syscall
    j get_input_retry           # Request again

ask_for_binary:
    # User must provide binary string
    li $v0, 4
    la $a0, prompt_binary       # "Enter your answer in binary: "
    syscall
    
    # Read string
    li $v0, 8                   # Read string syscall
    la $a0, input_buffer        # Buffer for storing input
    li $a1, 12                  # Maximum length (8 bits + newline + null)
    syscall
    
    # Now we must convert binary string to integer
    la $a0, input_buffer        # Supply buffer address
    jal binary_string_to_int    # Invoke conversion function
    # $v0 now holds the integer value, or -1 if invalid
    
    bltz $v0, invalid_bin_input # If negative, it was invalid
    
    # Valid binary input
    j get_input_done

invalid_bin_input:
    li $v0, 4
    la $a0, invalid_input
    syscall
    j get_input_retry

get_input_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

binary_string_to_int:
    # Transform binary string to integer
    # $a0 = address of string
    # Returns: $v0 = integer value (0-255), or -1 if invalid
    
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0               # $s0 = string address
    li $s1, 0                   # $s1 = result (accumulated value)
    li $t0, 0                   # $t0 = character counter (must be exactly 8)
    
convert_loop:
    lb $t1, 0($s0)              # Load byte: obtain current character
    
    # Verify for end of string (newline or null terminator)
    beq $t1, 10, check_length   # ASCII 10 = newline
    beq $t1, 0, check_length    # ASCII 0 = null terminator
    
    # Verify if character is '0' or '1'
    li $t2, 48                  # ASCII '0' = 48
    li $t3, 49                  # ASCII '1' = 49
    
    beq $t1, $t2, process_zero  # If character is '0'
    beq $t1, $t3, process_one   # If character is '1'
    
    # Invalid character detected
    li $v0, -1
    j convert_done

process_zero:
    # Shift result left by 1 (multiply by 2) and include 0
    sll $s1, $s1, 1             # Shift left logical: $s1 = $s1 * 2
    # Including 0 does nothing
    addi $t0, $t0, 1            # Advance character count
    addi $s0, $s0, 1            # Proceed to next character
    j convert_loop

process_one:
    # Shift result left by 1 and include 1
    sll $s1, $s1, 1             # $s1 = $s1 * 2
    addi $s1, $s1, 1            # $s1 = $s1 + 1
    addi $t0, $t0, 1            # Advance character count
    addi $s0, $s0, 1            # Proceed to next character
    j convert_loop

check_length:
    # Confirm we received exactly 8 bits
    li $t1, 8
    bne $t0, $t1, invalid_length    # If count != 8, invalid
    
    # Valid conversion
    move $v0, $s1               # Return the result
    j convert_done

invalid_length:
    li $v0, -1                  # Return -1 for invalid

convert_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra