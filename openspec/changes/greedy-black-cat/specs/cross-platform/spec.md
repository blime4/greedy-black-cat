# Cross-Platform Requirements

## ADDED Requirements

### Requirement: Platform Support
The game SHALL run on iPhone, iPad, and Mac devices.

#### Scenario: iPhone build verification
Given Xcode project is configured
When building for iOS simulator
Then build succeeds
And game runs on iPhone simulator

#### Scenario: iPad build verification
Given Xcode project is configured
When building for iPadOS simulator
Then build succeeds
And game runs on iPad simulator

#### Scenario: Mac build verification
Given Xcode project is configured
When building for macOS
Then build succeeds
And game runs on Mac

### Requirement: Adaptive Grid Sizing
The game SHALL adjust grid size based on device type and screen size.

#### Scenario: iPhone uses compact grid
Given game runs on iPhone
When new game starts
Then grid size is 20x20 cells
And cell size is scaled for compact screen

#### Scenario: iPad uses regular grid
Given game runs on iPad
When new game starts
Then grid size is 30x30 cells
And cell size is scaled for larger screen

#### Scenario: Mac uses large grid
Given game runs on Mac
When new game starts
Then grid size is 32x32 cells
And cell size is scaled for desktop screen

### Requirement: Responsive Layout
The game UI SHALL adapt to different screen sizes and orientations.

#### Scenario: Portrait mode layout
Given game runs in portrait orientation
When view renders
Then game grid centers vertically
And controls position at bottom

#### Scenario: Landscape mode layout
Given game runs in landscape orientation
When view renders
Then game grid centers horizontally
And controls position at side

#### Scenario: Window resize on Mac
Given game runs on Mac
When user resizes window
Then game view adapts to new size
And grid maintains aspect ratio

### Requirement: Conditional Compilation
Platform-specific code SHALL use proper Swift conditional compilation.

#### Scenario: iOS-specific imports
Given code runs on iOS platform
When importing UIKit
Then import succeeds
And touch controls are available

#### Scenario: macOS-specific imports
Given code runs on macOS platform
When importing AppKit
Then import succeeds
And keyboard controls are available
