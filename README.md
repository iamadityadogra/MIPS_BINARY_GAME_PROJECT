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
