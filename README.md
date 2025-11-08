The Binary Conversion Game is a MIPS assembly program designed to help users practice converting between binary and decimal numbers. The game consists of 10 levels. Each level has a set of conversion problems — either binary to decimal or decimal to binary. If the player answers all problems correctly, they move to the next level; if not, the game ends. Completing all 10 levels displays a win message.
As the player progresses:
Level 1 has 1 problem, Level 2 has 2 problems, and so on up to Level 10 with 10 problems.
The problems alternate between binary-to-decimal and decimal-to-binary formats.
If the user correctly answers all problems in a level, they advance to the next.
A single incorrect answer results in a game over.
Completing all 10 levels displays a winning message.
The program is divided into modules:
- main.asm: Shows the main menu and handles user choices.
- game.asm: Manages levels and game flow.
- drawboard.asm: Displays problems.
- io_handler.asm: Handles user input.
- convert.asm: Converts between binary and decimal.
- validate.asm: Checks answers.
- rnd_generate.asm: Creates random numbers for problems.


User Manual:
1. Requirements
You will need the MARS MIPS Simulator and the following files:
main.asm, game.asm, drawboard.asm, io_handler.asm, convert.asm, validate.asm, rnd_generate.asm.
2. How to Run
1. Open MARS.
2. Load all .asm files.
3. Make sure 'Program arguments provided to MIPS' is unchecked.
4. Assemble (F3) and run (F5).
5. The main menu will appear with options:
   - 1. Start New Game
   - 2. How to Play
   - 3. Exit
3. How to Play
Choose 1 to start. Each level will display a binary or decimal number.
Convert and enter your answer:
- If it’s binary, type the decimal number (0–255).
- If it’s decimal, type an 8-bit binary (e.g., 10101010).
Correct answers move you forward; a wrong one ends the game.
Complete all 10 levels to win.
4. Example
======== LEVEL 1 ========
Problem 1: Binary Number: 10110101
Enter your answer in decimal: 181
*** CORRECT! ***
5. Troubleshooting
- Make sure all .asm files are loaded and assembled.
- If input doesn’t work, uncheck 'Program arguments provided to MIPS.'
- Restart MARS if random numbers repeat or if display glitches occur.
6. Exit
Choose 3 from the main menu to exit.
You’ll see: Thank you for playing! Goodbye!
