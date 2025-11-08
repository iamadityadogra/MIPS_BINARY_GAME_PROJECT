# validate.asm - Input validation and answer verification
# This module validates user inputs and verifies if answers are correct

.data
    correct_msg:    .asciiz "*** CORRECT! ***\n"
    wrong_msg:      .asciiz "*** WRONG! The correct answer was: "
    close_msg:      .asciiz " ***\n"
   
.text
.globl check_answer
.globl validate_binary_input
.globl validate_decimal_input

check_answer:
    # Verify if user's answer is correct
    # $a0 = problem type (0 = bin->dec, 1 = dec->bin)
    # $a1 = correct answer
    # $a2 = user's answer
    # Returns: $v0 = 1 if correct, 0 if incorrect
   
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
   
    move $s0, $a0               # Preserve problem type
    move $s1, $a1               # Preserve correct answer
    move $s2, $a2               # Preserve user's answer
   
    # Compare the two answers
    beq $s1, $s2, answer_correct    # If equal, answer is correct
   
    # Answer is incorrect - play incorrect answer sound
    jal play_wrong_sound
   
    li $v0, 4
    la $a0, wrong_msg           # "*** WRONG! The correct answer was: "
    syscall
   
    # Present the correct answer based on problem type
    beq $s0, $zero, show_decimal_answer
    # Otherwise present binary answer
    j show_binary_answer

show_decimal_answer:
    # Problem was bin->dec, so present decimal
    li $v0, 1
    move $a0, $s1               # Output correct decimal value
    syscall
   
    li $v0, 4
    la $a0, close_msg           # " ***\n"
    syscall
   
    li $v0, 0                   # Return 0 (incorrect answer)
    j check_done

show_binary_answer:
    # Problem was dec->bin, so present binary
    # Transform correct answer to binary string and display
    move $a0, $s1
    jal decimal_to_binary       # Obtain binary string
    move $t0, $v0               # Preserve string address
   
    li $v0, 4
    move $a0, $t0               # Output binary string
    syscall
   
    la $a0, close_msg           # " ***\n"
    syscall
   
    li $v0, 0                   # Return 0 (incorrect)
    j check_done

answer_correct:
    # Play correct answer sound
    jal play_correct_sound
   
    # Present correct message
    li $v0, 4
    la $a0, correct_msg         # "*** CORRECT! ***"
    syscall
   
    li $v0, 1                   # Return 1 (correct)

check_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

play_correct_sound:
    # Play a pleasant "correct" sound (rising notes)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    # Note 1: C5 (MIDI 72)
    li $v0, 31              # MIDI out syscall
    li $a0, 72              # Pitch (C5)
    li $a1, 500             # Duration in milliseconds
    li $a2, 0               # Instrument (0 = Acoustic Grand Piano)
    li $a3, 100             # Volume (0-127)
    syscall
   
    # Note 2: E5 (MIDI 76)
    li $v0, 31
    li $a0, 76              # Pitch (E5)
    li $a1, 500             # Duration
    li $a2, 0               # Instrument
    li $a3, 100             # Volume
    syscall
   
    # Note 3: G5 (MIDI 79)
    li $v0, 31
    li $a0, 79              # Pitch (G5)
    li $a1, 1000             # Duration (extended final note)
    li $a2, 0               # Instrument
    li $a3, 100             # Volume
    syscall
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

play_wrong_sound:
    # Play an "incorrect" sound (falling notes)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    # Note 1: E4 (MIDI 64)
    li $v0, 31              # MIDI out syscall
    li $a0, 64              # Pitch (E4)
    li $a1, 800             # Duration in milliseconds
    li $a2, 0               # Instrument
    li $a3, 100             # Volume
    syscall
   
    # Note 2: D4 (MIDI 62)
    li $v0, 31
    li $a0, 62              # Pitch (D4)
    li $a1, 600             # Duration
    li $a2, 0               # Instrument
    li $a3, 100             # Volume
    syscall
   
    # Note 3: C4 (MIDI 60) - lower, somber sound
    li $v0, 31
    li $a0, 60              # Pitch (C4)
    li $a1, 1000            # Duration (extended final note)
    li $a2, 0               # Instrument
    li $a3, 100             # Volume
    syscall
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

validate_decimal_input:
    # Confirm that a decimal input is in valid range (0-255)
    # $a0 = decimal number to confirm
    # Returns: $v0 = 1 if valid, 0 if invalid
   
    # Verify if negative
    bltz $a0, decimal_invalid   # Branch if less than zero
   
    # Verify if >= 256
    li $t0, 256
    bge $a0, $t0, decimal_invalid   # Branch if greater or equal to 256
   
    # Valid input
    li $v0, 1
    jr $ra

decimal_invalid:
    li $v0, 0
    jr $ra

validate_binary_input:
    # Confirm that a binary string contains only '0' and '1' and is 8 bits
    # $a0 = address of binary string
    # Returns: $v0 = 1 if valid, 0 if invalid
   
    move $t0, $a0               # $t0 = current character address
    li $t1, 0                   # $t1 = character counter
   
validate_loop:
    lb $t2, 0($t0)              # Load byte: obtain current character
   
    # Verify for end of string
    beq $t2, 10, check_binary_length    # Newline
    beq $t2, 0, check_binary_length     # Null terminator
   
    # Verify if character is '0' (ASCII 48)
    li $t3, 48
    beq $t2, $t3, valid_binary_char
   
    # Verify if character is '1' (ASCII 49)
    li $t3, 49
    beq $t2, $t3, valid_binary_char
   
    # Invalid character detected
    li $v0, 0
    jr $ra

valid_binary_char:
    addi $t1, $t1, 1            # Advance counter
    addi $t0, $t0, 1            # Proceed to next character
    j validate_loop

check_binary_length:
    # Must have exactly 8 characters
    li $t3, 8
    beq $t1, $t3, binary_valid
   
    # Incorrect length
    li $v0, 0
    jr $ra

binary_valid:
    li $v0, 1
    jr $ra

validate_range:
    # Generic function to confirm a number is in a range [min, max]
    # $a0 = number to confirm
    # $a1 = min value (inclusive)
    # $a2 = max value (inclusive)
    # Returns: $v0 = 1 if in range, 0 if outside range
   
    blt $a0, $a1, out_of_range  # Branch if less than min
    bgt $a0, $a2, out_of_range  # Branch if greater than max
   
    # Within range
    li $v0, 1
    jr $ra

out_of_range:
    li $v0, 0
    jr $ra

check_all_zeros:
    # Verify if a binary number is all zeros
    # $a0 = number
    # Returns: $v0 = 1 if all zeros, 0 otherwise
   
    beq $a0, $zero, is_all_zeros
    li $v0, 0
    jr $ra

is_all_zeros:
    li $v0, 1
    jr $ra

check_all_ones:
    # Verify if a binary number is all ones (255 for 8 bits)
    # $a0 = number
    # Returns: $v0 = 1 if all ones, 0 otherwise
   
    li $t0, 255
    beq $a0, $t0, is_all_ones
    li $v0, 0
    jr $ra

is_all_ones:
    li $v0, 1
    jr $ra