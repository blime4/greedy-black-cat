# Greedy Black Cat - Design Document

## Architecture Overview

### MVVM Pattern
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│     Views       │ ◄── │  ViewModels     │ ◄── │    Models       │
│ (SwiftUI)       │     │ (GameState)     │     │ (Game entities) │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Component Structure
```
GreedyBlackCat/
├── App/
│   └── GreedyBlackCatApp.swift
├── Models/
│   ├── Cat.swift
│   ├── Food.swift
│   └── GameState.swift
├── ViewModels/
│   └── GameViewModel.swift
├── Views/
│   ├── MainMenuView.swift
│   ├── GameView.swift
│   ├── GameOverView.swift
│   └── Components/
│       ├── CatView.swift
│       ├── FoodView.swift
│       └── GridView.swift
├── Controls/
│   ├── TouchControls.swift
│   └── KeyboardControls.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Info.plist
└── Project/
    └── project.yml (XcodeGen)
```

## Game Mechanics Design

### Grid System
- Fixed grid size for consistent gameplay
- 20x20 cells for iPhone, 30x30 for iPad, adaptive for Mac
- Each cell represents one unit of movement

### Cat (Player) Properties
- Position: (x, y) grid coordinates
- Direction: UP, DOWN, LEFT, RIGHT
- Body segments: Array of positions
- Speed: Ticks per second (configurable)

### Movement Rules
1. Head moves one cell in current direction each tick
2. Body follows head, each segment moves to previous segment's position
3. 180-degree turns are prevented

### Food Spawning
- Random position not occupied by cat
- Spawns after food is eaten
- No food spawns on cat body

## Cross-Platform Strategy

### Adaptive Layout
```swift
struct GameView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone layout
        } else {
            // iPad/Mac layout
        }
    }
}
```

### Control Scheme Routing
```swift
#if os(iOS)
import UIKit
typealias PlatformView = UIView
#elseif os(macOS)
import AppKit
typealias PlatformView = NSView
#endif
```

### Screen Size Categories
| Category | Devices | Grid Size | UI Scale |
|----------|---------|-----------|----------|
| Compact | iPhone | 20x20 | 1.0x |
| Regular | iPad | 30x30 | 1.5x |
| Large | Mac | 32x32 | 2.0x |

## Performance Considerations

### Rendering Approach
1. **Phase 1**: SwiftUI Views (simpler, less performant)
2. **Phase 2**: Canvas API (better performance if needed)
3. **Phase 3**: SpriteKit (advanced animations, if required)

### Optimization Techniques
- Use `@StateObject` for game state
- Avoid unnecessary view redraws
- Batch updates where possible
- Profile with Instruments

## Visual Design

### Character Design: Greedy Black Cat

#### Cat Head Design
| Direction | Visual Elements |
|-----------|-----------------|
| UP | Two圆形耳朵竖立, 眼睛向下看, 嘴巴微张 |
| DOWN | Two圆形耳朵平放, 眼睛向上看, 舌头微微伸出 |
| LEFT | 右耳朝前, 左眼圆睁, 右眼略微眯起, 表情期待 |
| RIGHT | 左耳朝前, 右眼圆睁, 左眼略微眯起, 表情期待 |

#### Cat Head Specifications
- **Base Shape**: 圆角矩形或椭圆形头部, 黑色填充 (#1A1A1A)
- **Ears**: 两个小三角形/半圆形耳朵, 深灰色内耳 (#333333)
- **Eyes**: 圆形眼睛, 金色/黄色虹膜 (#FFD700), 黑色瞳孔
- **Nose**: 粉色小三角形 (#FFB6C1)
- **Whiskers**: 三条细线从脸颊两侧延伸
- **Mouth**: 微笑弧线, 稍微带点"馋嘴"的表情
- **Size**: Grid cell size × 0.8 for each direction variant

#### Cat Body Design
- **Segment Style**: 圆形身体节段, 逐渐变小向尾部
- **Color Gradient**: 从头部 (#1A1A1A) 到尾部 (#2D2D2D)
- **Pattern**: 细微的虎斑纹路可选, 增加视觉趣味
- **Spacing**: Body segments maintain 1-cell gap during movement
- **Tail**: 可选小尾巴, 随移动方向摆动动画

### Food Design: Fish Theme

#### Food Variants
| Type | Appearance | Points |
|------|------------|--------|
| 小鱼 (Small Fish) | 完整的浅色小鱼轮廓 | 10 points |
| 中鱼 (Medium Fish) | 稍大的深色小鱼, 带有光泽 | 20 points |
| 大鱼 (Large Fish) | 最大的金色鱼, 带闪光效果 | 50 points |

#### Fish Sprite Specifications
- **Body Shape**: 椭圆形鱼身, 带三角形尾巴
- **Color Palette**: 银色 (#C0C0C0), 金色 (#FFD700), 橙色 (#FF8C00)
- **Eye**: 圆点眼睛, 黑色瞳孔
- **Fin**: 小三角形鳍, 两侧各一个
- **Scale**: Grid cell size × 0.6
- **Animation**: 轻微漂浮/摆动效果

#### Food Spawning Logic
- 70% 概率生成小鱼
- 25% 概率生成中鱼
- 5% 概率生成大鱼 (特殊奖励)

### Color Scheme

#### Primary Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Charcoal Black | #1A1A1A | Cat head, primary game elements |
| Dark Gray | #2D2D2D | Cat body, secondary elements |
| Soft White | #F5F5F5 | Background, UI text |
| Warm Cream | #FFF8E7 | Menu background |
| Golden Yellow | #FFD700 | Eyes, highlights, score |
| Coral Pink | #FF6B6B | Accent buttons, errors |
| Mint Green | #98FF98 | Success, food indicators |

#### UI Color Mapping
| Element | Color |
|---------|-------|
| Main Menu Background | Warm Cream (#FFF8E7) |
| Game Grid Background | Soft White (#F5F5F5) with subtle pattern |
| Pause Button | Coral Pink (#FF6B6B) |
| Score Display | Golden Yellow (#FFD700) |
| Game Over Overlay | Semi-transparent Charcoal (#1A1A1A with 80% opacity) |

### Typography

| Element | Font | Size (iPhone) | Size (iPad) | Size (Mac) | Weight |
|---------|------|---------------|-------------|------------|--------|
| Game Title | SF Rounded / System | 48pt | 64pt | 72pt | Bold |
| Score | SF Mono / Monospace | 24pt | 32pt | 36pt | Regular |
| Button Text | SF Pro / System | 18pt | 24pt | 28pt | Medium |
| Menu Items | SF Pro / System | 20pt | 28pt | 32pt | Regular |
| Game Over Score | SF Pro / System | 36pt | 48pt | 56pt | Bold |
| High Score Label | SF Pro / System | 14pt | 18pt | 20pt | Light |

### UI Elements

#### Main Menu
```
┌─────────────────────────────────────────┐
│         🐱 贪吃的黑猫 🐱                 │
│                                         │
│         High Score: 12345               │
│                                         │
│    ┌─────────────────────────┐          │
│    │      Start Game         │          │
│    └─────────────────────────┘          │
│                                         │
│         [Settings]  [About]             │
└─────────────────────────────────────────┘
```

#### Game HUD (Heads-Up Display)
```
┌─────────────────────────────────────────┐
│  Score: 1250     🐟 × 5    ⏸ Pause     │
├─────────────────────────────────────────┤
│                                         │
│         ┌───────────────┐               │
│         │   [GRID]      │               │
│         │               │               │
│         └───────────────┘               │
│                                         │
├─────────────────────────────────────────┤
│  [←]    [↓]    [↑]    [→]   (D-Pad)    │
└─────────────────────────────────────────┘
```

#### Game Over Screen
```
┌─────────────────────────────────────────┐
│                                         │
│           Game Over                     │
│                                         │
│         Final Score: 1250               │
│                                         │
│         🏆 New High Score! 🏆           │
│                                         │
│    ┌─────────────────────────┐          │
│    │      Play Again         │          │
│    └─────────────────────────┘          │
│                                         │
│    ┌─────────────────────────┐          │
│    │      Main Menu          │          │
│    └─────────────────────────┘          │
└─────────────────────────────────────────┘
```

### Animations

#### Movement Animation
- **Tick Rate**: 10-15 ticks per second (adjustable)
- **Smooth Interpolation**: Optional smooth movement between grid cells
- **Body Wave Effect**: Subtle scale pulse as body follows head

#### Eating Animation
| Duration | Effect |
|----------|--------|
| 0-100ms | Cat mouth opens wider |
| 100-200ms | Food scales down to 0 |
| 200-300ms | Cat body pulses (growth) |
| 300-400ms | Score popup appears (+10) |

#### Food Animation
- 轻微的上下浮动效果 (2秒周期)
- 被吃掉时缩小并消失
- 生成时从0放大到正常大小

#### UI Animations
| Interaction | Animation |
|-------------|-----------|
| Button Press | Scale down 95%, lift shadow |
| Menu Transition | Slide from bottom, fade in |
| Game Start | Grid expands from center |
| Game Over | Fade to overlay, scale title |

### App Icon

#### Icon Design
```
┌─────────────────────────┐
│                         │
│      🐱 Black Cat       │
│      with fish in mouth │
│                         │
│    Golden circle bg     │
│                         │
└─────────────────────────┘
```

#### Icon Specifications
- **Style**: Flat design with subtle depth
- **Background**: Golden yellow gradient circle
- **Cat**: Black silhouette, facing forward
- **Prop**: Small fish in mouth for recognition
- **Size**: 1024×1024px (App Store), 180×180px (iPhone), 128×128px (Mac)
- **Safe Zone**: 80% of icon area for key content

### Platform-Specific Visual Considerations

| Platform | Consideration | Solution |
|----------|---------------|----------|
| iPhone | Small screen | Larger touch targets, simplified HUD |
| iPad | Large screen | More detailed background, split controls |
| Mac | Mouse cursor | Custom cat-shaped cursor during gameplay |
| All | Dark/Light Mode | Support both with color adjustments |
| All | Dynamic Type | Respect system text size settings |

### Asset Export Requirements

| Asset | Format | Sizes | Color Space |
|-------|--------|-------|-------------|
| Cat Heads | PNG / SVG | 4 directions @ 1x, 2x, 3x | sRGB |
| Cat Body | PNG / SVG | 1x, 2x, 3x | sRGB |
| Food Items | PNG / SVG | 3 variants @ 1x, 2x, 3x | sRGB |
| UI Icons | PDF (vector) | @1x scalable | sRGB |
| App Icon | PNG | 1024, 180, 128, 80, 60, 40 | sRGB, P3 for newer devices |

### Audio Assets (Optional)

| Sound | Type | Duration | Trigger |
|-------|------|----------|---------|
| BGM | Loopable ambient | Infinite | Game start |
| Eat | Short crisp | 0.2s | Food collision |
| Grow | Satisfying | 0.3s | Body growth |
| Die | Descending | 0.5s | Game over |
| UI Click | Subtle | 0.1s | Button press |

## Testing Strategy

### Unit Tests
- Game logic tests (movement, collision detection)
- State machine transitions
- Score calculations

### UI Tests
- Navigation flows
- Control responsiveness
- Layout adaptability

### Platform-Specific Tests
- Touch gesture recognition
- Keyboard input handling
- Window resizing behavior (Mac)
