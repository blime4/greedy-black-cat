# UI and Controls Requirements

## ADDED Requirements

### Requirement: Touch Controls
The game SHALL support touch-based controls on iPhone and iPad devices.

#### Scenario: Swipe gesture changes direction
Given game runs on touch device
When player swipes UP on game area
Then cat direction changes to UP
And swipe is registered only when significant movement detected

#### Scenario: Virtual D-Pad as fallback
Given touch controls are enabled
When player taps directional button
Then cat direction changes to button direction
And buttons are visible and tappable

#### Scenario: Touch responsiveness
Given player inputs direction change
When input is processed
Then direction updates within 100ms
And input queue handles rapid inputs

### Requirement: Keyboard Controls
The game SHALL support keyboard controls on Mac devices.

#### Scenario: Arrow keys control direction
Given game runs on Mac
When player presses UP arrow key
Then cat direction changes to UP

#### Scenario: Space bar pauses game
Given game is in playing state
When player presses space bar
Then game pauses
And pause menu appears

#### Scenario: Return key restarts game
Given game is in gameOver state
When player presses return key
Then new game starts

### Requirement: Main Menu UI
The game SHALL have a main menu for game entry.

#### Scenario: Main menu displays
Given app launches
When main menu view loads
Then game title "贪吃的黑猫" is displayed
And "Start Game" button is visible
And high score is displayed

#### Scenario: Start game navigation
Given main menu is displayed
When player taps/clicks "Start Game"
Then game transitions to playing state
And game grid appears

### Requirement: Game UI Elements
The game SHALL display essential UI elements during gameplay.

#### Scenario: Score display during game
Given game is in playing state
When view renders
Then current score is visible
And high score is visible

#### Scenario: Pause button visibility
Given game is in playing state
When view renders
Then pause button is visible
And accessible for touch/click

#### Scenario: Pause menu display
Given game is paused
When pause menu appears
Then "Resume" button is visible
And "Restart" button is visible
And "Quit to Menu" button is visible

### Requirement: Game Over UI
The game SHALL display game over screen with relevant information.

#### Scenario: Game over displays score
Given game state is gameOver
When game over view appears
Then final score is displayed
And "Play Again" button is visible
And "Main Menu" button is visible

#### Scenario: New high score celebration
Given player achieves new high score
When game ends
Then "New High Score!" message appears
