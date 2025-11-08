# rnd_generate.asm - Random number creation
# This module creates pseudo-random numbers for the game
# Utilizes a Linear Congruential Generator (LCG) algorithm
.data
    # Seed for random number generator
    # We'll utilize system time to set it up
    random_seed:    .word 12345     # Starting seed value
.text
.globl random_int
.globl init_random
init_random:
    # Set up random seed using system time
    # This ensures the game is different each time you play
    
    # Obtain system time (milliseconds since epoch)
    li $v0, 30                  # System time syscall (provides time in $a0)
    syscall                     # $a0 now contains low 32 bits of time
    
    # Utilize the time value as our seed
    sw $a0, random_seed         # Save time as seed
    
    jr $ra                      # Return
random_int:
    # Create a random integer in range [0, n-1]
    # $a0 = n (upper bound, exclusive)
    # Returns: $v0 = random number in range [0, n-1]
    
    # Preserve registers
    addi $sp, $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    
    move $s0, $a0               # Preserve the upper bound
    
    # Linear Congruential Generator formula:
    # next_seed = (a * seed + c) mod m
    # We utilize: a = 1103515245, c = 12345, m = 2^31
    
    lw $t0, random_seed         # Retrieve current seed
    
    # Multiply seed by 1103515245
    li $t1, 1103515245          # Retrieve multiplier 'a'
    mult $t0, $t1               # Multiply: result in HI:LO registers
    mflo $t0                    # Move from LO: obtain low 32 bits of result
    
    # Include constant 12345
    li $t1, 12345               # Retrieve constant 'c'
    add $t0, $t0, $t1           # Include to seed
    
    # We implicitly utilize mod 2^31 by retaining only lower bits
    # Guarantee it's positive by clearing the sign bit
    sll $t0, $t0, 1             # Shift left to eliminate sign bit
    srl $t0, $t0, 1             # Shift right to restore value (now positive)
    
    # Save new seed for next time
    sw $t0, random_seed
    
    # Now we have a random number, but we require it in range [0, n-1]
    # We utilize: result = random_number % n
    
    divu $t0, $s0               # Divide unsigned: $t0 / $s0
    mfhi $v0                    # Move from HI: obtain remainder (this is our result)
    
    # Retrieve and return
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    addi $sp, $sp, 8
    jr $ra
# Additional helper function to obtain a random number in a specific range
random_range:
    # Create random number in range [min, max] inclusive
    # $a0 = min
    # $a1 = max
    # Returns: $v0 = random number
    
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0               # Preserve min
    move $s1, $a1               # Preserve max
    
    # Determine range size: (max - min + 1)
    sub $t0, $s1, $s0           # $t0 = max - min
    addi $t0, $t0, 1            # $t0 = max - min + 1
    
    # Obtain random number in [0, range-1]
    move $a0, $t0
    jal random_int
    
    # Include min to shift range to [min, max]
    add $v0, $v0, $s0
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra