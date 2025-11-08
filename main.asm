# main.asm - Starting point for Binary Game
# This is the primary module that launches the program and manages the overall game flow
# Author: [Your Name]
# Date: October 2025

.data
    # String constants for the primary menu and messages
    welcome_msg:    .asciiz "\n-----------------------------------------\n"
    welcome_msg2:   .asciiz "     WELCOME TO THE BINARY GAME!\n"
    welcome_msg3:   .asciiz "-----------------------------------------\n"
    menu_msg:       .asciiz "\nMain Menu:\n"
    menu_option1:   .asciiz "1. New Game\n"
    menu_option2:   .asciiz "2. User Manual\n"
    menu_option3:   .asciiz "3. Exit\n"
    menu_prompt:    .asciiz "Enter your choice (1-3): "
    
    instructions:   .asciiz "\n--- HOW TO PLAY ---\n"
    inst_line1:     .asciiz "1. Each level presents conversion problems\n"
    inst_line2:     .asciiz "2. Level 1 = 1 problem, Level 2 = 2 problems, etc.\n"
    inst_line3:     .asciiz "3. Binary-to-Decimal: Convert 8-bit binary to decimal\n"
    inst_line4:     .asciiz "4. Decimal-to-Binary: Convert decimal to 8-bit binary\n"
    inst_line5:     .asciiz "5. Complete all 10 levels to win!\n"
    inst_line6:     .asciiz "Press Enter to continue...\n"
    
    goodbye_msg:    .asciiz "\nThank you for playing! Goodbye!\n"
    invalid_choice: .asciiz "Invalid choice! Please enter 1, 2, or 3.\n"

.text
.globl main

main:
    # This serves as the program's entry point
    # We'll show the welcome message and primary menu
    
main_loop:
    # Show welcome banner
    # $v0 = 4 indicates print string syscall
    # $a0 contains the address of the string to print
    
    li $v0, 4                   # Load immediate: place 4 into $v0 (print string syscall code)
    la $a0, welcome_msg         # Load address: place address of welcome_msg into $a0
    syscall                     # Execute the system call to print
    
    la $a0, welcome_msg2        # Load address of second line of welcome message
    syscall                     # Print it
    
    la $a0, welcome_msg3        # Load address of third line (border)
    syscall                     # Print it
    
    # Show menu options
    la $a0, menu_msg            # Load menu header
    syscall                     # Print "Main Menu:"
    
    la $a0, menu_option1        # Load "1. Start New Game"
    syscall                     # Print it
    
    la $a0, menu_option2        # Load "2. How to Play"
    syscall                     # Print it
    
    la $a0, menu_option3        # Load "3. Exit"
    syscall                     # Print it
    
    # Request user input
    la $a0, menu_prompt         # Load "Enter your choice"
    syscall                     # Print the prompt
    
    # Read integer input from user
    li $v0, 5                   # $v0 = 5 represents the "read integer" syscall
    syscall                     # Execute read integer (result placed in $v0)
    move $t0, $v0               # Transfer the result from $v0 to $t0 to preserve it
    
    # Determine which option the user chose
    # We'll use branches to navigate to different code sections
    
    beq $t0, 1, start_game      # Branch if equal: if $t0 == 1, navigate to start_game
    beq $t0, 2, show_instructions   # If $t0 == 2, navigate to show_instructions
    beq $t0, 3, exit_game       # If $t0 == 3, navigate to exit_game
    
    # If execution reaches here, the choice was invalid
    la $a0, invalid_choice      # Load invalid choice message
    syscall                     # Print it
    j main_loop                 # Jump back to main_loop to display menu again

start_game:
    # Invoke the game initialization function from game.asm
    jal init_game               # Jump and link: invoke init_game, store return address in $ra
    # When init_game completes, execution resumes here
    j main_loop                 # After game concludes, return to main menu

show_instructions:
    # Show the instructions for how to play
    li $v0, 4                   # Prepare to print string
    la $a0, instructions        # Load instruction header
    syscall
    
    la $a0, inst_line1          # Load first instruction line
    syscall
    
    la $a0, inst_line2          # Load second instruction line
    syscall
    
    la $a0, inst_line3          # Load third instruction line
    syscall
    
    la $a0, inst_line4          # Load fourth instruction line
    syscall
    
    la $a0, inst_line5          # Load fifth instruction line
    syscall
    
    la $a0, inst_line6          # Load "Press Enter" message
    syscall
    
    # Wait for user to press Enter
    li $v0, 8                   # Read string syscall (we'll just capture the Enter)
    la $a0, buffer              # Require a buffer to read into
    li $a1, 2                   # Buffer size (just need to capture the Enter)
    syscall
    
    j main_loop                 # Go back to main menu

exit_game:
    # Terminate the program gracefully
    li $v0, 4                   # Print string
    la $a0, goodbye_msg         # Load goodbye message
    syscall                     # Print it
    
    li $v0, 10                  # Exit syscall code is 10
    syscall                     # End program execution

# Small buffer for capturing Enter key
.data
buffer: .space 2                # Reserve 2 bytes for capturing Enter key