# drawboard.asm - Present game board and problems
# This module manages all visual presentation of the game board (simplified version)
.data
    # Simple prompt messages
    dec_to_bin_msg: .asciiz "\nDecimal Number: "
    bin_to_dec_msg: .asciiz "\nBinary Number: "
    newline:        .asciiz "\n"
.text
.globl display_problem
display_problem:
    # This function presents a single problem
    # $a0 = problem type (0 = bin->dec, 1 = dec->bin)
    # $a1 = the number to present (either as binary or decimal)
    
    addi $sp, $sp, -16          # Preserve registers on stack
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0               # $s0 = problem type
    move $s1, $a1               # $s1 = number to present
    
    # Verify problem type and present accordingly
    beq $s0, $zero, show_bin_to_dec
    # Otherwise it's decimal to binary
    j show_dec_to_bin
show_bin_to_dec:
    # Binary -> Decimal: present "Binary Number: 10110101"
    li $v0, 4
    la $a0, bin_to_dec_msg      # "Binary Number: "
    syscall
    
    # Present the binary representation
    move $a0, $s1
    jal display_binary_number   # Present as 8-bit binary
    
    j display_done
show_dec_to_bin:
    # Decimal -> Binary: present "Decimal Number: 181"
    li $v0, 4
    la $a0, dec_to_bin_msg      # "Decimal Number: "
    syscall
    
    # Present the decimal number
    li $v0, 1
    move $a0, $s1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
display_done:
    # Retrieve and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra
display_binary_number:
    # Present a number as 8-bit binary
    # $a0 = number to present
    
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0               # Preserve number
    li $s1, 7                   # Begin with bit 7 (leftmost)
    
display_bit_loop:
    # Isolate bit at position $s1
    li $t0, 1                   # $t0 = 1
    sllv $t0, $t0, $s1          # Shift left by $s1 positions (creates mask)
    and $t1, $s0, $t0           # AND number with mask to obtain that bit
    
    # Determine if bit is 0 or 1
    beq $t1, $zero, display_zero_bit
    # Otherwise output 1
    li $v0, 1
    li $a0, 1
    syscall
    j after_display_bit
display_zero_bit:
    li $v0, 1
    li $a0, 0
    syscall
after_display_bit:
    # Proceed to next bit
    addi $s1, $s1, -1           # Reduce bit position
    li $t0, -1
    bgt $s1, $t0, display_bit_loop  # If $s1 > -1, continue
    
    # Output newline after presenting all bits
    li $v0, 4
    la $a0, newline
    syscall
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra