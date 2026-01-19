# Core Gameplay Requirements

## ADDED Requirements

### Requirement: Cat Movement
The game SHALL allow the player to control a black cat that moves continuously in the current direction.

#### Scenario: Cat moves forward in current direction
Given the game is in playing state
And the cat has direction UP
When the game tick occurs
Then the cat's head position updates to (x, y-1)

#### Scenario: Cat changes direction via input
Given the game is in playing state
And the cat has direction UP
When the player inputs LEFT
Then the cat's direction changes to LEFT
And the cat cannot immediately change to RIGHT

### Requirement: Food Consumption
The game SHALL spawn food that the cat can eat to grow and increase score.

#### Scenario: Cat eats food
Given the cat's head position equals food position
When collision is detected
Then score increases by 10
Then food is removed
Then cat body grows by one segment
Then new food spawns at random valid position

#### Scenario: Food spawns in valid location
Given food needs to spawn
When spawning algorithm runs
Then food position is randomly selected from empty grid cells
And food position is not occupied by cat body

### Requirement: Collision Detection
The game SHALL detect collisions with walls and the cat's own body.

#### Scenario: Cat hits wall - game over
Given the cat's head position is outside grid bounds
When collision is detected
Then game state changes to gameOver
And final score is displayed

#### Scenario: Cat hits self - game over
Given the cat's head position matches any body segment position
When collision is detected
Then game state changes to gameOver
And final score is displayed

### Requirement: Score Tracking
The game SHALL track and display the player's score.

#### Scenario: Score increases when eating food
Given the cat eats food
When food consumption occurs
Then score increases by 10 points
And score is displayed in the UI

#### Scenario: High score persistence
Given the player achieves a new high score
When game ends
Then high score is saved to persistent storage
