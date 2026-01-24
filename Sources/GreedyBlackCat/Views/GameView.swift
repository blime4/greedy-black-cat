import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingPauseMenu = false
    @State private var pauseMenuScale: CGFloat = 0.8
    @State private var pauseMenuOpacity: Double = 0

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            // Background with ambient animation
            #if os(macOS)
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
                .overlay(AnimatedBackgroundView())
            #else
            Color(.systemBackground)
                .ignoresSafeArea()
                .overlay(AnimatedBackgroundView())
            #endif

            // Dynamic background based on combo
            if viewModel.comboCount >= 3 {
                DynamicBackgroundView(
                    comboCount: viewModel.comboCount,
                    difficultyLevel: viewModel.difficultyLevel
                )
            }

            // Chromatic aberration on damage/game over
            if viewModel.gameOverImpact || viewModel.screenShake > 8 {
                ChromaticAberrationView(intensity: viewModel.gameOverImpact ? 0.8 : Double(viewModel.screenShake) / 20)
            }

            // Screen distortion on heavy impact
            if viewModel.screenDistortionActive {
                ScreenDistortionView(
                    isActive: viewModel.screenDistortionActive,
                    distortionIntensity: CGFloat(min(viewModel.screenShake, 15)) / 15
                )
            }

            // Neon glow for mega combos
            if viewModel.neonGlowActive {
                NeonGlowView(
                    comboCount: viewModel.comboCount,
                    isActive: true
                )
            }

            // Beat sync visualizer
            if viewModel.beatSyncActive && viewModel.gameState == .playing {
                BeatSyncVisualizer(
                    beatValue: viewModel.gamePulse,
                    isActive: true
                )
            }

            // Weather system overlay
            if viewModel.showWeatherEffects && viewModel.gameState == .playing {
                GeometryReader { geometry in
                    WeatherSystemView(
                        weatherType: viewModel.currentWeather,
                        screenSize: geometry.size
                    )
                }
            }

            // Time warp effect
            TimeWarpView(
                isActive: viewModel.activePowerUps.contains { $0.type == .slowMotion },
                intensity: 0.8
            )

            VStack(spacing: 0) {
                // HUD
                hudView
                    .padding()

                // Game Grid
                gameGridView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        // Speed lines during dash
                        GeometryReader { geometry in
                            let gridSize = min(geometry.size.width, geometry.size.height)
                            let cellSize = gridSize / CGFloat(max(viewModel.gridWidth, viewModel.gridHeight))
                            SpeedLinesView(
                                isDashing: viewModel.isDashing,
                                direction: viewModel.cat.direction,
                                gridSize: cellSize
                            )
                        }
                    }
                    .timeWarpEffect(
                        isActive: viewModel.activePowerUps.contains { $0.type == .slowMotion },
                        intensity: 0.8
                    )
                    .scaleEffect(viewModel.cameraZoom)
                    .grayscale(viewModel.gameOverImpact ? 0.5 : 0)
                    .opacity(viewModel.gameOverImpact ? 0.8 : 1.0)
                    .offset(
                        x: directionalShakeOffset(direction: viewModel.cat.direction, isX: true),
                        y: directionalShakeOffset(direction: viewModel.cat.direction, isX: false)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.cameraZoom)
                    .animation(.easeOut(duration: 0.3), value: viewModel.gameOverImpact)

                // Controls (iOS only)
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    touchControlsView
                        .padding()
                }
                #endif
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Active Power-ups Indicator
            if !viewModel.activePowerUps.isEmpty {
                activePowerUpsView
                    .padding(.leading)
                    .padding(.bottom, 100)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Combo Indicator
            if viewModel.comboCount > 1 {
                comboIndicatorView
                    .padding(.trailing)
                    .padding(.bottom, 100)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // Mini-map and compass
            if viewModel.gameState == .playing {
                VStack(spacing: 8) {
                    // Compass indicator
                    if let food = viewModel.food {
                        CompassIndicator(
                            direction: viewModel.cat.direction,
                            catPosition: viewModel.cat.head,
                            foodPosition: food.position
                        )
                    }

                    // Mini-map
                    MiniMapView(
                        catPosition: viewModel.cat.head,
                        foodPosition: viewModel.food?.position,
                        powerUps: viewModel.powerUps,
                        obstacles: viewModel.obstacles,
                        boss: viewModel.currentBoss,
                        gridWidth: viewModel.gridWidth,
                        gridHeight: viewModel.gridHeight
                    )
                }
                .padding(.trailing)
                .padding(.top, 60)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // Combo Multiplier Popup
            if viewModel.showComboPopup {
                ComboMultiplierPopup(multiplier: viewModel.comboMultiplier)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

            // Pause Menu Overlay
            if viewModel.gameState.isPaused || showingPauseMenu {
                pauseMenuOverlay
            }

            // Screen flash and achievement overlay
            if viewModel.screenFlashIntensity > 0 || viewModel.showingAchievement {
                GameOverlayView(
                    showAchievement: viewModel.showingAchievement,
                    achievementName: viewModel.achievementUnlocked,
                    achievementIcon: "🏆",
                    flashIntensity: viewModel.screenFlashIntensity
                )
            }

            // Scene transition for milestones
            if viewModel.milestoneCelebration {
                SceneTransitionView(isActive: true, transitionType: .ripple)
            }

            // Achievement celebration
            if viewModel.achievementCelebration {
                AchievementCelebrationView(
                    isActive: viewModel.achievementCelebration,
                    achievementType: viewModel.currentAchievement
                )
            }

            // Multi-color flash effects
            if let flashType = viewModel.activeFlashType {
                MultiColorFlashView(
                    flashType: flashType,
                    intensity: viewModel.flashIntensity
                )
            }

            // Holographic effect for special events
            if viewModel.holographicEffectActive {
                HolographicEffectView(
                    intensity: 0.8
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }

            // Victory celebration
            if viewModel.showVictoryCelebration {
                VictoryCelebrationView(
                    score: viewModel.score,
                    isNewHighScore: viewModel.score > viewModel.highScore && viewModel.score > 0,
                    onContinue: {
                        viewModel.showVictoryCelebration = false
                        viewModel.restartGame()
                    }
                )
            }

            // Toast notification
            if viewModel.showToast {
                ToastNotificationView(
                    message: viewModel.toastMessage,
                    icon: viewModel.toastIcon,
                    type: viewModel.toastType
                )
                .padding(.top, 80)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            // Border glow effect for special events
            if viewModel.comboCount >= 3 || viewModel.isInvincible || viewModel.isTimeRunningOut {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderGlowColor, lineWidth: borderGlowWidth)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        #if os(macOS)
        .frame(minWidth: 600, minHeight: 600)
        .keyboardControls(viewModel: viewModel)
        #else
        .touchControls(viewModel: viewModel)
        #endif
    }

    // MARK: - HUD
    private var hudView: some View {
        HStack(spacing: 8) {
            // Score
            HStack(spacing: 6) {
                Text("Score:")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(viewModel.score)")
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.05), radius: 3)
            )

            // Time remaining (Time Attack mode)
            if viewModel.gameMode.hasTimeLimit {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.subheadline)
                        .foregroundColor(urgencyColor)
                        .symbolEffect(.pulse, options: .repeating, isActive: viewModel.isTimeRunningOut)
                    Text("\(Int(viewModel.timeRemaining))s")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(urgencyColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(urgencyBackgroundColor)
                        .shadow(color: urgencyShadowColor, radius: viewModel.isTimeRunningOut ? 8 : 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(urgencyColor, lineWidth: viewModel.isTimeRunningOut ? 2 : 0)
                        .opacity(viewModel.isTimeRunningOut ? 0.5 : 0)
                )
                .scaleEffect(viewModel.isTimeRunningOut ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isTimeRunningOut)
            }

            // Combo indicator in HUD
            if viewModel.comboCount > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("\(viewModel.comboCount)x")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.2))
                )
            }

            // Difficulty indicator
            if viewModel.difficultyLevel > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "speedometer.fill")
                        .font(.caption)
                        .foregroundColor(difficultyColor)
                    Text("Lv\(viewModel.difficultyLevel)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(difficultyColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(difficultyColor.opacity(0.2))
                )
            }

            // Weather indicator
            if viewModel.showWeatherEffects {
                Button(action: {
                    viewModel.showWeatherEffects.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.currentWeather.icon)
                            .font(.caption)
                            .foregroundColor(weatherIconColor)
                        Text(viewModel.currentWeather.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(weatherIconColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(weatherIconColor.opacity(0.15))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            Spacer()

            // High Score
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                Text("\(viewModel.highScore)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.05), radius: 3)
            )

            Spacer()

            // Pause Button
            Button(action: {
                viewModel.pauseGame()
                showingPauseMenu = true
            }) {
                Image(systemName: "pause.circle.fill")
                    .font(.title)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(GameButtonStyle(isPrimary: false))
            .pressEffect()
        }
    }

    // MARK: - Game Grid
    private var gameGridView: some View {
        GeometryReader { geometry in
            // Calculate cell size to fill entire screen
            let cellSizeFromWidth = geometry.size.width / CGFloat(viewModel.gridWidth)
            let cellSizeFromHeight = geometry.size.height / CGFloat(viewModel.gridHeight)
            let cellSize = max(cellSizeFromWidth, cellSizeFromHeight)

            ZStack {
                // Grid background with gradient and rhythmic pulse
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.95),
                                Color(white: 0.88)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(1.0 + (viewModel.gamePulse * 0.003))
                    .animation(.easeInOut(duration: 0.1), value: viewModel.gamePulse)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

                // Draw grid lines
                gridLinesView(cellSize: cellSize)

                // Food
                if let food = viewModel.food {
                    FoodView(food: food, cellSize: cellSize, catHead: viewModel.cat.head)
                        .id(food.id)
                        .position(
                            x: CGFloat(food.position.x) * cellSize + cellSize / 2,
                            y: CGFloat(food.position.y) * cellSize + cellSize / 2
                        )
                }

                // Power-ups
                ForEach(viewModel.powerUps) { powerUp in
                    PowerUpView(powerUp: powerUp, cellSize: cellSize)
                        .position(
                            x: CGFloat(powerUp.position.x) * cellSize + cellSize / 2,
                            y: CGFloat(powerUp.position.y) * cellSize + cellSize / 2
                        )
                }

                // Obstacles
                ForEach(viewModel.obstacles) { obstacle in
                    ObstacleView(obstacle: obstacle, cellSize: cellSize)
                        .position(
                            x: CGFloat(obstacle.position.x) * cellSize + cellSize / 2,
                            y: CGFloat(obstacle.position.y) * cellSize + cellSize / 2
                        )
                }

                // Boss (if active)
                if let boss = viewModel.currentBoss {
                    BossView(boss: boss, cellSize: cellSize)
                        .position(
                            x: CGFloat(boss.position.x) * cellSize + cellSize / 2,
                            y: CGFloat(boss.position.y) * cellSize + cellSize / 2
                        )
                        .onTapGesture {
                            viewModel.attackBoss()
                        }
                }

                // Boss attacks
                ForEach(viewModel.bossAttacks) { attack in
                    BossAttackView(attack: attack, cellSize: cellSize)
                        .position(
                            x: CGFloat(attack.position.x) * cellSize + cellSize / 2,
                            y: CGFloat(attack.position.y) * cellSize + cellSize / 2
                        )
                }

                // Combo chain effect
                if viewModel.comboCount >= 3 {
                    ComboChainView(
                        comboCount: viewModel.comboCount,
                        cellSize: cellSize,
                        catPosition: CGPoint(
                            x: CGFloat(viewModel.cat.head.x) * cellSize + cellSize / 2,
                            y: CGFloat(viewModel.cat.head.y) * cellSize + cellSize / 2
                        )
                    )
                }

                // Cat body
                ForEach(viewModel.cat.body, id: \.self) { position in
                    CatSegmentView(
                        isHead: position == viewModel.cat.head,
                        direction: viewModel.cat.direction,
                        cellSize: cellSize,
                        comboCount: viewModel.comboCount,
                        isInvincible: viewModel.isInvincible,
                        gameMode: viewModel.gameMode,
                        isEating: viewModel.isEating
                    )
                    .position(
                        x: CGFloat(position.x) * cellSize + cellSize / 2,
                        y: CGFloat(position.y) * cellSize + cellSize / 2
                    )
                }

                // Enhanced ribbon trail effect
                if viewModel.comboCount >= 2 {
                    RibbonTrailView(
                        trailPoints: viewModel.trailPoints,
                        comboCount: viewModel.comboCount,
                        cellSize: cellSize
                    )
                } else {
                    // Simple ghost trail for low combos
                    ForEach(viewModel.trailPoints) { trailPoint in
                        let trailColor: Color = viewModel.comboCount >= 3 ? .orange : Color.accentColor
                        let trailAlpha = trailPoint.alpha * (viewModel.comboCount >= 3 ? 0.5 : 0.3)

                        Circle()
                            .fill(trailColor.opacity(trailAlpha))
                            .frame(width: cellSize * 0.6, height: cellSize * 0.6)
                            .blur(radius: viewModel.comboCount >= 3 ? 6 : 4)
                            .position(
                                x: CGFloat(trailPoint.position.x) * cellSize + cellSize / 2,
                                y: CGFloat(trailPoint.position.y) * cellSize + cellSize / 2
                            )
                    }
                }

                // Danger zone indicators
                if !viewModel.obstacles.isEmpty {
                    DangerZoneView(
                        obstacles: viewModel.obstacles,
                        catPosition: viewModel.cat.head,
                        gridWidth: viewModel.gridWidth,
                        gridHeight: viewModel.gridHeight,
                        cellSize: cellSize
                    )
                }

                // Score popups
                ForEach(viewModel.scorePopups) { popup in
                    ScorePopupView(
                        points: popup.points,
                        position: CGPoint(
                            x: CGFloat(popup.position.x) * cellSize + cellSize / 2,
                            y: CGFloat(popup.position.y) * cellSize + cellSize / 2
                        ),
                        cellSize: cellSize
                    )
                    .position(
                        x: CGFloat(popup.position.x) * cellSize + cellSize / 2,
                        y: CGFloat(popup.position.y) * cellSize + cellSize / 2
                    )
                }

                // Particles
                ParticleSystemView(particles: viewModel.particles, cellSize: cellSize)

                // Speed lines during dash
                SpeedLinesView(
                    isDashing: viewModel.isDashing,
                    direction: viewModel.cat.direction,
                    gridSize: cellSize
                )

                // Hit effects (ripple/shockwave)
                ForEach(viewModel.hitEffects) { effect in
                    RippleShockwaveView(
                        position: CGPoint(
                            x: effect.position.x * cellSize + cellSize / 2,
                            y: effect.position.y * cellSize + cellSize / 2
                        ),
                        color: effect.color,
                        maxRadius: 150,
                        duration: 0.8
                    )
                }

                // Vortex suction for magnetic food
                if let food = viewModel.food, let catHead = viewModel.cat.body.first {
                    let foodPos = CGPoint(
                        x: CGFloat(food.position.x) * cellSize + cellSize / 2,
                        y: CGFloat(food.position.y) * cellSize + cellSize / 2
                    )
                    let catPos = CGPoint(
                        x: CGFloat(catHead.x) * cellSize + cellSize / 2,
                        y: CGFloat(catHead.y) * cellSize + cellSize / 2
                    )
                    let distance = sqrt(pow(foodPos.x - catPos.x, 2) + pow(foodPos.y - catPos.y, 2))

                    if distance < cellSize * 3 {
                        VortexSuctionView(
                            foodPosition: foodPos,
                            catPosition: catPos,
                            cellSize: cellSize,
                            isActive: true
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func gridLinesView(cellSize: CGFloat) -> some View {
        ZStack {
            // Vertical lines - more subtle and elegant
            ForEach(0...viewModel.gridWidth, id: \.self) { x in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0),
                                Color.gray.opacity(0.15),
                                Color.gray.opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1)
                    .offset(x: CGFloat(x) * cellSize - cellSize * CGFloat(viewModel.gridWidth) / 2)
            }

            // Horizontal lines - more subtle and elegant
            ForEach(0...viewModel.gridHeight, id: \.self) { y in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0),
                                Color.gray.opacity(0.15),
                                Color.gray.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .offset(y: CGFloat(y) * cellSize - cellSize * CGFloat(viewModel.gridHeight) / 2)
            }
        }
        .frame(width: cellSize * CGFloat(viewModel.gridWidth),
               height: cellSize * CGFloat(viewModel.gridHeight))
    }

    // MARK: - Touch Controls
    #if os(iOS)
    private var touchControlsView: some View {
        HStack(spacing: 20) {
            // D-pad
            VStack(spacing: 12) {
                // Up button
                Button(action: { viewModel.changeDirection(.up) }) {
                    controlButtonArrow(systemName: "arrow.up")
                }
                .pressEffect()

                HStack(spacing: 24) {
                    // Left button
                    Button(action: { viewModel.changeDirection(.left) }) {
                        controlButtonArrow(systemName: "arrow.left")
                    }
                    .pressEffect()

                    // Down button
                    Button(action: { viewModel.changeDirection(.down) }) {
                        controlButtonArrow(systemName: "arrow.down")
                    }
                    .pressEffect()

                    // Right button
                    Button(action: { viewModel.changeDirection(.right) }) {
                        controlButtonArrow(systemName: "arrow.right")
                    }
                    .pressEffect()
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(16)

            // Dash button
            Button(action: { viewModel.performDash() }) {
                VStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                    Text("Dash")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(viewModel.canDash ? .cyan : .gray)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(viewModel.canDash ? Color.cyan.opacity(0.2) : Color.gray.opacity(0.2))
                )
                .overlay(
                    Circle()
                        .stroke(viewModel.canDash ? Color.cyan : Color.gray, lineWidth: 2)
                )
            }
            .pressEffect()
            .disabled(!viewModel.canDash)
        }
    }

    private func controlButtonArrow(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(.accentColor)
            .frame(width: 55, height: 55)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
    }
    #endif

    // MARK: - Pause Menu Overlay
    private var pauseMenuOverlay: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .opacity(pauseMenuOpacity)

            VStack(spacing: 20) {
                Text("Paused")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                // Game Stats
                VStack(spacing: 12) {
                    HStack(spacing: 40) {
                        StatItem(icon: "fish", label: "Eaten", value: "\(viewModel.foodEaten)")
                        StatItem(icon: "bolt.fill", label: "Dashes", value: "\(viewModel.dashesUsed)")
                    }
                    HStack(spacing: 40) {
                        StatItem(icon: "star.fill", label: "Power-ups", value: "\(viewModel.powerUpsCollected)")
                        StatItem(icon: viewModel.gameMode.icon, label: "Mode", value: viewModel.gameMode.displayName)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )

                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.resumeGame()
                        showingPauseMenu = false
                    }) {
                        Text("Resume")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(GameButtonStyle(isPrimary: true))
                    .pressEffect()

                    Button(action: {
                        showingPauseMenu = false
                        viewModel.restartGame()
                    }) {
                        Text("Restart")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .buttonStyle(GameButtonStyle(isPrimary: false))
                    .pressEffect()

                    Button(action: {
                        showingPauseMenu = false
                        viewModel.quitToMenu()
                        dismiss()
                    }) {
                        Text("Quit to Menu")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .buttonStyle(GameButtonStyle(isPrimary: false))
                    .pressEffect()
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(backgroundColor)
            .cornerRadius(16)
            .padding(40)
            .scaleEffect(pauseMenuScale)
            .opacity(pauseMenuOpacity)
        }
        .onChange(of: viewModel.gameState.isPaused) { _, isPaused in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                pauseMenuScale = isPaused ? 1.0 : 0.8
                pauseMenuOpacity = isPaused ? 1.0 : 0
            }
        }
    }
}

// Stat Item Component for Pause Menu
struct StatItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
            Text(value)
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Active Power-ups View
private extension GameView {
    var activePowerUpsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(viewModel.activePowerUps) { powerUp in
                HStack(spacing: 8) {
                    Text(powerUp.type.icon)
                        .font(.title3)
                        .opacity(powerUp.isExpiringSoon ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: powerUp.isExpiringSoon)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(powerUp.type.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(powerUp.isExpiringSoon ? Color.red : powerUp.type.color)
                                    .frame(width: geometry.size.width * (1 - powerUp.progress), height: 4)
                            }
                        }
                        .frame(width: 60, height: 4)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(powerUp.isExpiringSoon ? Color.red.opacity(0.3) : powerUp.type.color.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(powerUp.isExpiringSoon ? 0.8 : 0), lineWidth: 2)
                )
            }
        }
    }

    var comboIndicatorView: some View {
        VStack(spacing: 4) {
            Text("\(viewModel.comboCount)x")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.yellow)
            Text("COMBO")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.9))
                .shadow(color: Color.orange.opacity(0.5), radius: 8)
        )
        .scaleEffect(viewModel.comboCount > 1 ? 1.0 : 0.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.comboCount)
    }
}

// MARK: - Helpers
extension View {
    var backgroundColor: Color {
        #if os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color(.systemBackground)
        #endif
    }
}

// MARK: - Urgency Color Helpers
private extension GameView {
    var urgencyColor: Color {
        switch viewModel.timeRemaining {
        case 0...10: return .red
        case 11...20: return .orange
        case 21...30: return .yellow
        default: return .primary
        }
    }

    var urgencyBackgroundColor: Color {
        switch viewModel.timeRemaining {
        case 0...10: return Color.red.opacity(0.3)
        case 11...20: return Color.orange.opacity(0.25)
        case 21...30: return Color.yellow.opacity(0.2)
        default: return Color.white.opacity(0.8)
        }
    }

    var urgencyShadowColor: Color {
        switch viewModel.timeRemaining {
        case 0...10: return Color.red.opacity(0.6)
        case 11...20: return Color.orange.opacity(0.4)
        case 21...30: return Color.yellow.opacity(0.3)
        default: return Color.black.opacity(0.05)
        }
    }

    var difficultyColor: Color {
        switch viewModel.difficultyLevel {
        case 1: return .green
        case 2: return .blue
        case 3: return .yellow
        case 4: return .orange
        case 5: return .red
        case 6: return .purple
        default: return .gray
        }
    }

    var weatherIconColor: Color {
        switch viewModel.currentWeather {
        case .sunny: return .yellow
        case .rainy: return .blue
        case .snowy: return .cyan
        case .stormy: return .purple
        case .cloudy: return .gray
        }
    }

    var borderGlowColor: Color {
        if viewModel.isInvincible {
            return .purple
        } else if viewModel.isTimeRunningOut {
            return .red
        } else if viewModel.comboCount >= 5 {
            return .yellow
        } else if viewModel.comboCount >= 3 {
            return .orange
        }
        return .clear
    }

    var borderGlowWidth: CGFloat {
        if viewModel.isInvincible {
            return 4
        } else if viewModel.isTimeRunningOut {
            return 3
        } else if viewModel.comboCount >= 3 {
            return CGFloat(viewModel.comboCount)
        }
        return 0
    }

    func directionalShakeOffset(direction: Direction, isX: Bool) -> CGFloat {
        guard viewModel.screenShake > 0 else { return 0 }

        let baseShake = CGFloat.random(in: 0...viewModel.screenShake)
        let randomMultiplier = CGFloat.random(in: -1...1)

        switch direction {
        case .up:
            // Shake more vertically, less horizontally
            return isX ? baseShake * 0.3 * randomMultiplier : -baseShake * abs(randomMultiplier)
        case .down:
            return isX ? baseShake * 0.3 * randomMultiplier : baseShake * abs(randomMultiplier)
        case .left:
            // Shake more horizontally, less vertically
            return isX ? -baseShake * abs(randomMultiplier) : baseShake * 0.3 * randomMultiplier
        case .right:
            return isX ? baseShake * abs(randomMultiplier) : baseShake * 0.3 * randomMultiplier
        }
    }
}

// MARK: - Game Over Extension
extension GameView {
    var gameOverView: some View {
        GameOverView(
            score: viewModel.score,
            highScore: viewModel.highScore,
            onRestart: {
                viewModel.restartGame()
            },
            onMainMenu: {
                viewModel.quitToMenu()
            }
        )
    }
}
