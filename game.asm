# game.asm - Primary game logic and level management
# This module handles the game state, levels, and problem creation
# It manages the flow of the game from level 1 through level 10

.data
    level_msg:      .asciiz "\n======== LEVEL "
    level_msg2:     .asciiz " ========\n"
    complete_msg:   .asciiz "\nCongratulations! Level completed!\n"
    game_over_win:  .asciiz "\n*** YOU WIN! All 10 levels completed! ***\n"
    game_over_lose: .asciiz "\nGame Over! Better luck next time!\n"
    press_enter:    .asciiz "Press Enter to continue..."
    line_label:     .asciiz "Problem "
    colon:          .asciiz ": "
    newline:        .asciiz "\n"
    
    # Game state variables (kept in memory)
    current_level:  .word 1     # Active level (1-10)
    problems_array: .space 80   # Array for storing problem types (0=bin->dec, 1=dec->bin)
                                # Maximum 10 problems * 8 bytes = 80 bytes
    answers_array:  .space 80   # Array for storing correct answers
    user_answers:   .space 80   # Array for storing user answers

.text
.globl init_game

init_game:
    # This function sets up and executes the entire game
    # It oversees all 10 levels
    
    # Preserve return address on stack (so we can go back to main.asm later)
    addi $sp, $sp, -4           # Reduce stack pointer by 4 bytes
    sw $ra, 0($sp)              # Save return address at top of stack
    
    # Set up random number generator
    jal init_random             # Invoke init_random from random_generator.asm
    
    # Set current level to 1
    li $t0, 1                   # Load immediate: $t0 = 1
    sw $t0, current_level       # Save 1 into current_level variable
    
game_level_loop:
    # This loop executes for each level (1 through 10)
    
    lw $t0, current_level       # Retrieve current level into $t0
    li $t1, 11                  # Place 11 into $t1 (we want to verify if level > 10)
    bge $t0, $t1, game_won      # Branch if greater or equal: if level >= 11, game is completed
    
    # Show level number
    li $v0, 4                   # Print string
    la $a0, level_msg           # "======== LEVEL "
    syscall
    
    li $v0, 1                   # Print integer syscall
    lw $a0, current_level       # Retrieve current level number
    syscall                     # Display the level number
    
    li $v0, 4                   # Print string
    la $a0, level_msg2          # " ========"
    syscall
    
    # Create problems for this level
    # Number of problems = current level (level 1 has 1 problem, level 2 has 2, etc.)
    lw $a0, current_level       # Supply current level as argument
    jal generate_problems       # Invoke function to create problems
    
    # Present and solve all problems for this level
    lw $a0, current_level       # Supply current level as argument
    jal play_level              # Invoke function to play through the level
    
    # Determine if level was passed (play_level returns 1 in $v0 if passed, 0 if failed)
    beq $v0, $zero, game_lost   # If $v0 == 0, player failed, game over
    
    # Level passed! Display completion message
    li $v0, 4
    la $a0, complete_msg        # "Congratulations! Level completed!"
    syscall
    
    la $a0, press_enter
    syscall
    
    # Wait for Enter
    li $v0, 8
    la $a0, buffer_game
    li $a1, 2
    syscall
    
    # Advance level
    lw $t0, current_level       # Retrieve current level
    addi $t0, $t0, 1            # Increase level by 1
    sw $t0, current_level       # Save new level back
    
    j game_level_loop           # Jump back to beginning of level loop

game_won:
    # Player finished all 10 levels!
    li $v0, 4
    la $a0, game_over_win       # "YOU WIN!"
    syscall
    j game_end

game_lost:
    # Player did not pass a level
    li $v0, 4
    la $a0, game_over_lose      # "Game Over!"
    syscall
    j game_end

game_end:
    # Retrieve return address and go back to main
    lw $ra, 0($sp)              # Retrieve return address from stack
    addi $sp, $sp, 4            # Restore stack pointer
    jr $ra                      # Jump to return address (back to main.asm)

generate_problems:
    # This function creates random problems for the current level
    # $a0 = number of problems to create (same as level number)
    
    # Preserve registers we'll use
    addi $sp, $sp, -16          # Allocate space on stack for 4 registers
    sw $ra, 0($sp)              # Preserve return address
    sw $s0, 4($sp)              # Preserve $s0 (we'll use it as counter)
    sw $s1, 8($sp)              # Preserve $s1
    sw $s2, 12($sp)             # Preserve $s2
    
    move $s0, $a0               # $s0 = number of problems to create
    li $s1, 0                   # $s1 = counter (current problem index)
    
gen_loop:
    bge $s1, $s0, gen_done      # If counter >= num_problems, we're finished
    
    # Switch problem type based on problem number
    # Odd problem numbers (1, 3, 5...) = Binary to Decimal (type 0)
    # Even problem numbers (2, 4, 6...) = Decimal to Binary (type 1)
    
    # Determine problem number (index + 1)
    addi $t0, $s1, 1            # $t0 = problem number (1-based)
    
    # Verify if odd or even using modulo 2
    andi $t1, $t0, 1            # AND with 1 provides us remainder when dividing by 2
                                # If result is 1, it's odd; if 0, it's even
    
    # If odd (remainder = 1), problem type = 0 (Binary->Decimal)
    # If even (remainder = 0), problem type = 1 (Decimal->Binary)
    beq $t1, $zero, set_dec_to_bin
    # It's odd, assign to Binary->Decimal
    li $s2, 0                   # Binary to Decimal
    j store_problem_type

set_dec_to_bin:
    li $s2, 1                   # Decimal to Binary

store_problem_type:
    # Save problem type in array
    la $t0, problems_array      # Retrieve base address of problems array
    add $t0, $t0, $s1           # Include offset (index * 1 byte)
    sb $s2, 0($t0)              # Store byte: problem type at this index
    
    # Create random answer (0-255 for 8-bit numbers)
    li $a0, 256                 # Create number 0-255
    jal random_int              # Invoke random generator
    
    # Save answer in array
    la $t0, answers_array       # Retrieve base address of answers array
    sll $t1, $s1, 2             # Multiply index by 4 (each answer is 4 bytes/word)
    add $t0, $t0, $t1           # Include offset
    sw $v0, 0($t0)              # Store word: correct answer at this index
    
    addi $s1, $s1, 1            # Advance counter
    j gen_loop                  # Continue loop

gen_done:
    # Retrieve registers and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

play_level:
    # This function executes one level
    # $a0 = number of problems in this level
    # Returns: $v0 = 1 if all correct, 0 if any incorrect
    
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0               # $s0 = number of problems
    li $s1, 0                   # $s1 = current problem index
    
play_problem_loop:
    bge $s1, $s0, play_success  # If we've completed all problems, success!
    
    # Show problem number
    li $v0, 4
    la $a0, line_label          # "Problem "
    syscall
    
    li $v0, 1
    addi $a0, $s1, 1            # Problem number = index + 1
    syscall
    
    li $v0, 4
    la $a0, colon               # ": "
    syscall
    
    # Retrieve problem type for this problem
    la $t0, problems_array
    add $t0, $t0, $s1           # Include offset
    lb $s2, 0($t0)              # Load byte: $s2 = problem type
    
    # Retrieve correct answer for this problem
    la $t0, answers_array
    sll $t1, $s1, 2             # index * 4
    add $t0, $t0, $t1
    lw $s3, 0($t0)              # $s3 = correct answer
    
    # Present the problem based on type
    move $a0, $s2               # Supply problem type
    move $a1, $s3               # Supply answer value
    jal display_problem         # Invoke display function (in drawboard.asm)
    
    # Obtain user's answer
    move $a0, $s2               # Supply problem type (to know what input to expect)
    jal get_user_answer         # Invoke input function (in io_handler.asm)
    # $v0 now holds user's answer
    
    # Verify the answer
    move $a0, $s2               # Problem type
    move $a1, $s3               # Correct answer
    move $a2, $v0               # User's answer
    jal check_answer            # Invoke validation (in validate.asm)
    
    # Determine if answer was correct
    beq $v0, $zero, play_failed # If $v0 == 0, answer was incorrect
    
    # Answer correct, advance to next problem
    addi $s1, $s1, 1
    j play_problem_loop

play_success:
    li $v0, 1                   # Return 1 (success)
    j play_end

play_failed:
    li $v0, 0                   # Return 0 (failed)
    j play_end

play_end:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

.data
buffer_game: .space 2