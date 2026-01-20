# Greedy Black Cat - Tasks

## Phase 1: Project Setup

- [x] 1.1 Create project structure directories
- [x] 1.2 Configure XcodeGen project.yml
- [x] 1.3 Set up minimum deployment targets (iOS 15, macOS 12)
- [x] 1.4 Create basic App entry point
- [x] 1.5 Verify project builds for all platforms
- [x] 1.6 Set up git repository and initial commit

## Phase 2: Core Data Models

- [x] 2.1 Create Direction enum (UP, DOWN, LEFT, RIGHT)
- [x] 2.2 Create Position struct (x, y coordinates)
- [x] 2.3 Create Cat model (head position, body segments, direction)
- [x] 2.4 Create Food model (position, type)
- [x] 2.5 Create GameState enum (menu, playing, paused, gameOver)
- [x] 2.6 Create GameSettings model (speed, grid size, difficulty)
- [ ] 2.7 Write unit tests for models

## Phase 3: Game Logic Engine

- [x] 3.1 Implement cat movement logic
- [x] 3.2 Implement direction change with 180-degree prevention
- [x] 3.3 Implement body following logic
- [x] 3.4 Implement food collision detection
- [x] 3.5 Implement wall collision detection
- [x] 3.6 Implement self-collision detection
- [x] 3.7 Implement food spawning algorithm
- [x] 3.8 Implement score calculation
- [ ] 3.9 Write unit tests for game engine

## Phase 4: Game Loop & ViewModel

- [x] 4.1 Create GameViewModel
- [x] 4.2 Implement game loop with timer
- [x] 4.3 Implement pause/resume functionality
- [x] 4.4 Implement restart functionality
- [x] 4.5 Connect controls to ViewModel actions
- [ ] 4.6 Write unit tests for ViewModel

## Phase 5: Basic Views

- [x] 5.1 Create MainMenuView with title and start button
- [x] 5.2 Create GameView with grid and game elements
- [x] 5.3 Create GameOverView with score and restart button
- [x] 5.4 Create CatView (basic shape representation)
- [x] 5.5 Create FoodView (basic shape representation)
- [x] 5.6 Create ScoreDisplayView
- [x] 5.7 Create PauseButtonView
- [x] 5.8 Test basic view navigation

## Phase 6: Touch Controls (iOS/iPadOS)

- [x] 6.1 Create TouchControlsView with swipe detection
- [x] 6.2 Implement UISwipeGestureRecognizer integration
- [x] 6.3 Add directional buttons as fallback
- [x] 6.4 Optimize touch responsiveness
- [ ] 6.5 Test on iPhone simulator
- [ ] 6.6 Test on iPad simulator

## Phase 7: Keyboard/Mouse Controls (macOS)

- [x] 7.1 Create KeyboardControls handler
- [x] 7.2 Map arrow keys to direction changes
- [x] 7.3 Map space bar to pause
- [x] 7.4 Map return/enter to restart
- [x] 7.5 Add mouse/touch bar controls (optional)
- [ ] 7.6 Test on Mac

## Phase 8: Adaptive UI

- [x] 8.1 Implement grid size adaptation by device
- [x] 8.2 Create responsive layout for different screen sizes
- [x] 8.3 Adjust cat and food sizes proportionally
- [x] 8.4 Optimize UI for landscape/portrait modes
- [ ] 8.5 Test all layout configurations

## Phase 9: Polish & Visuals

- [x] 9.1 Design cat head graphics (all 4 directions)
- [x] 9.2 Design cat body segments
- [x] 9.3 Design food sprites (fish)
- [x] 9.4 Create background theme
- [ ] 9.5 Add simple animations (eating, moving)
- [ ] 9.6 Implement sound effects (optional)
- [ ] 9.7 Create app icon

## Phase 10: Testing & Quality Assurance

- [ ] 10.1 Run unit tests on all platforms
- [ ] 10.2 Perform UI testing on all platforms
- [ ] 10.3 Test game balance (speed, difficulty)
- [ ] 10.4 Test edge cases (wall collisions, wrapping)
- [ ] 10.5 Fix bugs and polish issues
- [ ] 10.6 Performance profiling
- [ ] 10.7 Final build verification

## Phase 11: Documentation & Release Prep

- [ ] 11.1 Write README with setup instructions
- [ ] 11.2 Add App Store metadata
- [ ] 11.3 Create screenshots for App Store
- [ ] 11.4 Clean up code and remove debug logging
- [ ] 11.5 Final commit and tag

## Dependency Graph
```
1.1 ─► 1.2 ─► 1.3 ─► 1.4 ─► 1.5 ─► 1.6
                              │
                              ▼
                    2.1 ─► 2.2 ─► ... ─► 2.7
                              │
                              ▼
                    3.1 ─► 3.2 ─► ... ─► 3.9
                              │
                              ▼
                    4.1 ─► 4.2 ─► ... ─► 4.6
                              │
                              ▼
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
            5.1-5.8         6.1-6.6         7.1-7.6
              │               │               │
              └───────────────┼───────────────┘
                              ▼
                    8.1 ─► 8.2 ─► ... ─► 8.5
                              │
                              ▼
                    9.1 ─► 9.2 ─► ... ─► 9.7
                              │
                              ▼
                   10.1 ─► 10.2 ─► ... ─► 10.7
                              │
                              ▼
                   11.1 ─► 11.2 ─► ... ─► 11.5
```
