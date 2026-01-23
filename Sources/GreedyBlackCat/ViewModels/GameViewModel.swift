import Foundation
import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var gameState: GameState = .menu
    @Published var cat: Cat
    @Published var food: Food?
    @Published var powerUps: [PowerUp] = []
    @Published var activePowerUps: [ActivePowerUp] = []
    @Published var obstacles: [Obstacle] = []
    @Published var particles: [Particle] = []
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var comboCount: Int = 0
    @Published var settings: GameSettings
    @Published var scorePopups: [ScorePopup] = []
    @Published var hitEffects: [HitEffect] = []
    @Published var screenShake: CGFloat = 0
    @Published var cameraZoom: CGFloat = 1.0
    @Published var gameOverImpact: Bool = false
    @Published var isTimeRunningOut: Bool = false
    @Published var canDash: Bool = true
    @Published var isDashing: Bool = false
    @Published var gameMode: GameMode = .classic
    @Published var gamePulse: CGFloat = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var foodEaten: Int = 0
    @Published var powerUpsCollected: Int = 0
    @Published var dashesUsed: Int = 0
    @Published var trailPoints: [TrailPoint] = []
    @Published var screenFlashIntensity: Double = 0
    @Published var showingAchievement: Bool = false
    @Published var achievementUnlocked: String = ""
    @Published var showComboPopup: Bool = false
    @Published var comboMultiplier: Int = 1
    @Published var isEating: Bool = false
    @Published var difficultyLevel: Int = 1
    @Published var difficultyNotification: String = ""
    @Published var currentWeather: WeatherType = .sunny
    @Published var showWeatherEffects: Bool = true
    @Published var currentBoss: Boss?
    @Published var bossAttacks: [BossAttack] = []
    @Published var bossBattleActive: Bool = false
    @Published var sceneTransitionActive: Bool = false
    @Published var milestoneCelebration: Bool = false
    @Published var achievementCelebration: Bool = false
    @Published var currentAchievement: AchievementType = .highScore
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastIcon: String = ""
    @Published var toastType: ToastType = .milestone
    @Published var neonGlowActive: Bool = false
    @Published var beatSyncActive: Bool = true
    @Published var screenDistortionActive: Bool = false
    @Published var holographicEffectActive: Bool = false
    @Published var showVictoryCelebration: Bool = false
    @Published var activeFlashType: FlashType? = nil
    @Published var flashIntensity: Double = 0.8

    // MARK: - Trail System
    private var trailSystem = TrailSystem()

    // MARK: - Combo System
    private var lastEatTime: Date?
    private let comboWindow: TimeInterval = 2.0
    private var maxComboStreak: Int = 0
    private var consecutiveFoodsWithoutCollision: Int = 0

    // MARK: - Game Constants
    private static let timeUpdateInterval: TimeInterval = 0.1
    private static let urgencyTimeThreshold: TimeInterval = 10.0
    private static let urgencyFlashIntensity: Double = 0.2
    private static let maxComboMultiplier: Int = 5

    // MARK: - Dash System
    private var dashCooldown: TimeInterval = 0
    private let dashCooldownTime: TimeInterval = 3.0

    // MARK: - Timer System
    private var gameTimer: Timer?
    private var timeTimer: Timer?
    private var currentSpeed: TimeInterval

    // MARK: - Task Storage
    nonisolated(unsafe) private var activeTasks: Set<Task<Void, Never>> = []

    // MARK: - Input Queue
    private var inputQueue: [Direction] = []
    private let maxInputQueueSize = 2

    // MARK: - Grid Dimensions
    var gridWidth: Int { settings.gridWidth }
    var gridHeight: Int { settings.gridHeight }

    // MARK: - Initialization
    init(settings: GameSettings? = nil, gameMode: GameMode = .classic) {
        // Compute all values in local variables first (no self access)
        let theSettings = settings ?? AdaptiveSettings.gameSettings()
        let theSpeed = theSettings.tickInterval / gameMode.speedMultiplier
        let startX = theSettings.gridWidth / 2
        let startY = theSettings.gridHeight / 2
        let theCat = Cat(startPosition: Position(x: startX, y: startY))
        let theHighScore = Self.loadHighScore(for: gameMode)
        let gridW = theSettings.gridWidth
        let gridH = theSettings.gridHeight
        let theFood = Self.generateFood(for: theCat, gridWidth: gridW, gridHeight: gridH)

        // Now assign to all properties
        self.settings = theSettings
        self.currentSpeed = theSpeed
        self.cat = theCat
        self.highScore = theHighScore
        self.food = theFood
        self.gameMode = gameMode
        self.timeRemaining = gameMode.timeLimit ?? 0
    }

    // MARK: - Game Control
    func startGame() {
        gameState = .playing
        resetGame()
        startGameLoop()
        startTimeTimer()
    }

    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
        stopGameLoop()
        stopTimeTimer()
    }

    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        startGameLoop()
        startTimeTimer()
    }

    func restartGame() {
        resetGame()
        startGame()
    }

    func quitToMenu() {
        stopGameLoop()
        stopTimeTimer()
        gameState = .menu
    }

    private func resetGame() {
        let startX = settings.gridWidth / 2
        let startY = settings.gridHeight / 2
        cat = Cat(startPosition: Position(x: startX, y: startY))
        score = 0
        currentSpeed = settings.tickInterval / gameMode.speedMultiplier
        inputQueue = []
        comboCount = 0
        lastEatTime = nil
        consecutiveFoodsWithoutCollision = 0
        scorePopups = []
        powerUps = []
        activePowerUps = []
        obstacles = []
        particles = []
        screenShake = 0
        canDash = true
        isDashing = false
        dashCooldown = 0
        foodEaten = 0
        powerUpsCollected = 0
        dashesUsed = 0
        timeRemaining = gameMode.timeLimit ?? 0
        trailSystem.clear()
        trailPoints = []
        food = Self.generateFood(for: cat, gridWidth: gridWidth, gridHeight: gridHeight)

        // Check if grid is completely filled (win condition)
        if food?.position.x == -1 {
            victory()
        }
    }

    private func victory() {
        // Guard against multiple victory calls in same tick
        guard gameState == .playing else { return }

        stopGameLoop()
        stopTimeTimer()
        gameState = .gameOver
        showVictoryCelebration = true
        achievementUnlocked = "🎉 GRID COMPLETE! 🎉"
        showingAchievement = true
    }

    private func startTimeTimer() {
        stopTimeTimer()
        guard gameMode.hasTimeLimit else { return }

        timeTimer = Timer.scheduledTimer(withTimeInterval: Self.timeUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= Self.timeUpdateInterval

                    // Check for urgency state (less than threshold seconds)
                    let wasRunningOut = self.isTimeRunningOut
                    self.isTimeRunningOut = self.timeRemaining <= Self.urgencyTimeThreshold

                    // Trigger effects when entering urgency state
                    if !wasRunningOut && self.isTimeRunningOut {
                        self.screenFlashIntensity = Self.urgencyFlashIntensity
                        #if os(iOS)
                        HapticFeedback.warning()
                        #endif
                    }
                } else {
                    self.timeUp()
                }
            }
        }
    }

    private func stopTimeTimer() {
        timeTimer?.invalidate()
        timeTimer = nil
    }

    // MARK: - Task Management
    private func addTask(_ task: Task<Void, Never>) {
        activeTasks.insert(task)
    }

    private func cancelAllTasks() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
    }

    deinit {
        cancelAllTasks()
        gameTimer?.invalidate()
        gameTimer = nil
        timeTimer?.invalidate()
        timeTimer = nil
    }

    private func timeUp() {
        stopTimeTimer()
        stopGameLoop()
        gameState = .gameOver

        if score > highScore {
            highScore = score
            Self.saveHighScore(highScore, for: gameMode)
        }
    }

    // MARK: - Game Loop
    private func startGameLoop() {
        stopGameLoop()
        gameTimer = Timer.scheduledTimer(withTimeInterval: currentSpeed, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.gameTick()
            }
        }
    }

    private func stopGameLoop() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    private func gameTick() {
        guard gameState == .playing else { return }

        // Update power-ups
        updatePowerUps()

        // Update particles
        updateParticles()

        // Update dash cooldown
        updateDashCooldown()

        // Update game pulse rhythm
        gamePulse = gamePulse == 0 ? 1.0 : 0

        // Update trails
        trailPoints = trailSystem.update(decayRate: currentSpeed)

        // Process input queue
        if !inputQueue.isEmpty {
            let newDirection = inputQueue.removeFirst()
            cat.changeDirection(newDirection)
        }

        // Calculate new head position with magnetic attraction
        var newPosition = cat.head.applying(cat.direction.offset)

        // Magnetic attraction to food when close (3 cells)
        if let foodPosition = food?.position,
           cat.head.distance(to: foodPosition) <= 3 {
            newPosition = getMagnetizedPosition(toward: foodPosition)
        }

        // Check wall collision (unless invincible)
        if !isInvincible && !newPosition.isInBounds(width: gridWidth, height: gridHeight) {
            gameOver()
            return
        }

        // Check obstacle collision
        if !isInvincible && obstacles.contains(where: { $0.position == newPosition }) {
            gameOver()
            return
        }

        // Check self collision (unless invincible)
        if !isInvincible {
            let testCat = cat
            var testBody = testCat.body
            testBody.insert(newPosition, at: 0)
            if testBody.count > 1 && testBody[1...].contains(newPosition) {
                gameOver()
                return
            }
        }

        // Add trail point before moving
        trailSystem.addPoint(cat.head)

        // Add speed particles during high combos
        if comboCount >= 3 {
            spawnSpeedParticle(at: cat.head, color: comboCount >= Self.maxComboMultiplier ? .yellow : .orange)
        }

        // Check food collision (ignore invalid positions)
        let ateFood = food?.position == newPosition && food?.position.x != -1
        cat.move(to: newPosition, grow: ateFood)

        if ateFood {
            handleFoodEaten(at: newPosition)
        }

        // Check power-up collision
        if let powerUpIndex = powerUps.firstIndex(where: { $0.position == newPosition }) {
            collectPowerUp(powerUps[powerUpIndex])
            powerUps.remove(at: powerUpIndex)
        }

        // Check self collision after move
        if cat.checkSelfCollision() && !isInvincible {
            gameOver()
        }

        // Decay screen shake
        if screenShake > 0 {
            screenShake = max(0, screenShake - 1)
        }

        // Decay screen flash
        if screenFlashIntensity > 0 {
            screenFlashIntensity = max(0, screenFlashIntensity - 0.1)
        }

        // Hide achievement popup after delay
        if showingAchievement {
            let task = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                if !Task.isCancelled {
                    showingAchievement = false
                }
            }
            addTask(task)
        }

        // Spawn obstacles as difficulty increases
        spawnObstaclesIfNeeded()
    }

    private func getMagnetizedPosition(toward target: Position) -> Position {
        let dx = target.x - cat.head.x
        let dy = target.y - cat.head.y

        // If aligned on one axis, prefer that axis
        if dx == 0 {
            return Position(x: cat.head.x, y: cat.head.y + (dy > 0 ? 1 : -1))
        } else if dy == 0 {
            return Position(x: cat.head.x + (dx > 0 ? 1 : -1), y: cat.head.y)
        }

        // Otherwise use current direction but bias toward food
        switch cat.direction {
        case .up:
            if dy < 0 && abs(dy) >= abs(dx) { return cat.head.applying(cat.direction.offset) }
            return Position(x: cat.head.x + (dx > 0 ? 1 : -1), y: cat.head.y)
        case .down:
            if dy > 0 && abs(dy) >= abs(dx) { return cat.head.applying(cat.direction.offset) }
            return Position(x: cat.head.x + (dx > 0 ? 1 : -1), y: cat.head.y)
        case .left:
            if dx < 0 && abs(dx) >= abs(dy) { return cat.head.applying(cat.direction.offset) }
            return Position(x: cat.head.x, y: cat.head.y + (dy > 0 ? 1 : -1))
        case .right:
            if dx > 0 && abs(dx) >= abs(dy) { return cat.head.applying(cat.direction.offset) }
            return Position(x: cat.head.x, y: cat.head.y + (dy > 0 ? 1 : -1))
        }
    }

    private func handleFoodEaten(at position: Position) {
        guard let currentFood = food else { return }

        // Trigger eating animation
        isEating = true
        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            if !Task.isCancelled {
                isEating = false
            }
        }
        addTask(task)

        foodEaten += 1
        consecutiveFoodsWithoutCollision += 1

        // Handle combo system
        let now = Date()
        if let lastTime = lastEatTime, now.timeIntervalSince(lastTime) <= comboWindow {
            comboCount += 1
        } else {
            comboCount = 1
        }
        lastEatTime = now

        // Calculate score with combo multiplier and double points power-up
        let comboMultiplier = min(comboCount, Self.maxComboMultiplier)
        let doublePointsMultiplier: Int = isDoublePoints ? 2 : 1
        let points = currentFood.points * comboMultiplier * doublePointsMultiplier
        score += points

        // Holographic effect for rare food (large fish)
        if currentFood.type == .largeFish {
            holographicEffectActive = true
            let task = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 800_000_000)
                if !Task.isCancelled {
                    holographicEffectActive = false
                }
            }
            addTask(task)
        }

        // Screen flash and shake on combo milestones
        if comboCount == 3 || comboCount == 5 {
            screenShake = CGFloat(comboCount)
            screenFlashIntensity = comboCount == 5 ? 0.5 : 0.3

            // Activate neon glow for mega combos
            if comboCount >= Self.maxComboMultiplier {
                neonGlowActive = true
            }

            // Activate screen distortion on heavy impacts
            if comboCount >= 5 || screenShake > 10 {
                screenDistortionActive = true
                let task = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    if !Task.isCancelled {
                        screenDistortionActive = false
                    }
                }
                addTask(task)
            }

            #if os(iOS)
            HapticFeedback.medium()
            #endif

            // Show combo popup
            self.comboMultiplier = comboCount
            showComboPopup = true

            // Camera zoom effect for combo
            cameraZoom = comboCount == 5 ? 1.15 : 1.08
            let zoomTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 200_000_000)
                if !Task.isCancelled {
                    cameraZoom = 1.0
                    neonGlowActive = false
                }
            }
            addTask(zoomTask)

            // Hide popup after animation
            let popupTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 800_000_000)
                if !Task.isCancelled {
                    showComboPopup = false
                }
            }
            addTask(popupTask)
        }

        // Spawn particles
        spawnParticles(at: position, color: Color.orange, count: 8)

        // Add hit effect
        hitEffects.append(HitEffect(
            position: CGPoint(x: position.x, y: position.y),
            color: Color.orange
        ))

        // Add score popup at food position
        let popup = ScorePopup(points: points, position: currentFood.position)
        scorePopups.append(popup)

        // Clean up old popups and hit effects (with safety limit)
        scorePopups.removeAll { $0.isExpired }
        if scorePopups.count > 20 {
            scorePopups = Array(scorePopups.suffix(20))
        }
        hitEffects.removeAll { $0.isExpired }
        if hitEffects.count > 30 {
            hitEffects = Array(hitEffects.suffix(30))
        }

        // Generate new food
        food = Self.generateFood(for: cat, gridWidth: gridWidth, gridHeight: gridHeight)

        // Check if grid is completely filled (win condition)
        if food?.position.x == -1 {
            victory()
            return
        }

        // Chance to spawn power-up (only in modes that allow it)
        if gameMode.hasPowerUps && Double.random(in: 0...1) < 0.15 {
            spawnPowerUp()
        }

        // Increase speed gradually
        increaseSpeed()

        // Dynamic difficulty adjustment based on performance
        updateDynamicDifficulty()

        // Update weather based on progress
        updateWeatherProgress()

        // Check for score milestone (every 100 points)
        if score > 0 && score % 100 == 0 {
            celebrateScoreMilestone(at: position)
        }

        // Check for streak milestones
        if consecutiveFoodsWithoutCollision >= 10 {
            celebrateStreakMilestone(at: position)
        }

        // Check for boss battle trigger
        checkBossBattleTrigger()

        // Check for growth milestone (every 5 segments)
        let catLength = cat.body.count
        if catLength > 3 && catLength % 5 == 0 {
            celebrateLevelUp(at: position)
        }
    }

    private func celebrateLevelUp(at position: Position) {
        // Trigger level up flash
        triggerFlash(type: .levelUp, intensity: 0.7)

        // Show notification
        // Big screen flash
        screenFlashIntensity = 0.6

        // Extra screen shake
        screenShake = 8

        // Haptic feedback
        #if os(iOS)
        HapticFeedback.success()
        #endif

        // Spawn celebration particles in multiple colors
        let celebrationColors: [Color] = [.yellow, .orange, .pink, .purple, .cyan]
        for color in celebrationColors {
            spawnParticles(at: position, color: color, count: 6)
        }

        // Show achievement popup
        showingAchievement = true
        achievementUnlocked = "Growth: \(cat.body.count)!"
    }

    private func celebrateScoreMilestone(at position: Position) {
        // Trigger achievement flash
        triggerFlash(type: .achievement, intensity: 0.7)

        // Show toast notification
        showToast(
            message: "\(score) Points!",
            icon: "🎯",
            type: .milestone
        )

        // Screen flash for milestone
        screenFlashIntensity = 0.4

        // Screen shake
        screenShake = 5

        // Haptic feedback
        #if os(iOS)
        HapticFeedback.medium()
        #endif

        // Spawn gold particles for score milestone
        for _ in 0..<12 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 1.0...2.5)
            let particle = Particle(
                position: CGPoint(x: CGFloat(position.x), y: CGFloat(position.y)),
                velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed),
                color: .yellow,
                size: CGFloat.random(in: 0.08...0.2),
                life: 0,
                maxLife: Double.random(in: 0.4...0.8)
            )
            particles.append(particle)
        }

        // Show achievement popup
        showingAchievement = true
        achievementUnlocked = "\(score) Points!"
    }

    private func celebrateStreakMilestone(at position: Position) {
        // Only celebrate every 10 foods (10, 20, 30, etc.)
        guard consecutiveFoodsWithoutCollision % 10 == 0 else { return }

        // Trigger scene transition effect
        milestoneCelebration = true

        // Big screen flash for streak
        screenFlashIntensity = 0.5

        // Extra screen shake
        screenShake = CGFloat(min(consecutiveFoodsWithoutCollision / 5, 15))

        // Haptic feedback
        #if os(iOS)
        HapticFeedback.success()
        #endif

        // Spawn rainbow particles for streak
        let streakColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
        for _ in 0..<18 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 1.5...3.0)
            let particle = Particle(
                position: CGPoint(x: CGFloat(position.x), y: CGFloat(position.y)),
                velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed),
                color: streakColors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 0.1...0.25),
                life: 0,
                maxLife: Double.random(in: 0.5...1.0)
            )
            particles.append(particle)
        }

        // Bonus points for streak
        let streakBonus = consecutiveFoodsWithoutCollision * 5
        score += streakBonus

        // Show achievement popup with streak count
        showingAchievement = true
        achievementUnlocked = "Streak: \(consecutiveFoodsWithoutCollision)! +\(streakBonus)"

        // Camera zoom for emphasis
        cameraZoom = 1.12
        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !Task.isCancelled {
                cameraZoom = 1.0
                milestoneCelebration = false
            }
        }
        addTask(task)
    }

    private func spawnParticles(at position: Position, color: Color, count: Int) {
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 0.5...2.0)
            let particle = Particle(
                position: CGPoint(x: CGFloat(position.x), y: CGFloat(position.y)),
                velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed),
                color: color,
                size: CGFloat.random(in: 0.05...0.15),
                life: 0,
                maxLife: Double.random(in: 0.3...0.6)
            )
            particles.append(particle)
        }
    }

    private func spawnSpeedParticle(at position: Position, color: Color) {
        // Create a small trail particle behind the cat
        let particle = Particle(
            position: CGPoint(x: CGFloat(position.x), y: CGFloat(position.y)),
            velocity: CGVector(dx: 0, dy: 0),
            color: color,
            size: CGFloat.random(in: 0.08...0.12),
            life: 0,
            maxLife: 0.4
        )
        particles.append(particle)
    }

    private func updateParticles() {
        // Update particles and filter out dead ones in a single pass
        particles = particles.compactMap { particle in
            var updated = particle
            updated.life += currentSpeed
            updated.position.x += updated.velocity.dx * CGFloat(currentSpeed)
            updated.position.y += updated.velocity.dy * CGFloat(currentSpeed)
            return updated.isDead ? nil : updated
        }
    }

    private func spawnObstaclesIfNeeded() {
        // Only spawn in modes that allow obstacles
        guard gameMode.hasObstacles else { return }

        // Spawn obstacles based on game mode settings
        let obstacleCount = score / gameMode.obstacleSpawnRate
        let targetObstacles = min(obstacleCount, gameMode.maxObstacles)

        if obstacles.count < targetObstacles {
            spawnObstacle()
        }
    }

    private func spawnObstacle() {
        let types: [ObstacleType] = [.rock, .spike, .ice]
        guard let type = types.randomElement() else { return }

        var validPositions: [Position] = []
        for x in 0..<gridWidth {
            for y in 0..<gridHeight {
                let pos = Position(x: x, y: y)
                let centerSafeZone = abs(x - gridWidth / 2) < 3 && abs(y - gridHeight / 2) < 3
                if !cat.body.contains(pos) &&
                   pos != food?.position &&
                   !obstacles.contains(where: { $0.position == pos }) &&
                   !centerSafeZone {
                    validPositions.append(pos)
                }
            }
        }

        if let position = validPositions.randomElement() {
            obstacles.append(Obstacle(type: type, position: position))
        }
    }

    private func updateDashCooldown() {
        if dashCooldown > 0 {
            dashCooldown -= currentSpeed
            if dashCooldown <= 0 {
                canDash = true
            }
        }
    }

    func performDash() {
        guard canDash && !isDashing && gameState == .playing else { return }

        isDashing = true
        canDash = false
        dashCooldown = dashCooldownTime
        dashesUsed += 1

        // Move 3 spaces instantly in current direction
        for _ in 0..<3 {
            let newPosition = cat.head.applying(cat.direction.offset)
            if newPosition.isInBounds(width: gridWidth, height: gridHeight) &&
               !obstacles.contains(where: { $0.position == newPosition }) {
                cat.move(to: newPosition, grow: false)
            }
        }

        // Spawn particles at dash end
        spawnParticles(at: cat.head, color: .cyan, count: 12)
        screenShake = 5
        screenFlashIntensity = 0.3

        #if os(iOS)
        HapticFeedback.medium()
        #endif

        // End dash after brief moment
        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            if !Task.isCancelled {
                isDashing = false
            }
        }
        addTask(task)
    }

    private func spawnPowerUp() {
        let availableTypes = PowerUpType.allCases
        guard let type = availableTypes.randomElement() else { return }

        var validPositions: [Position] = []
        for x in 0..<gridWidth {
            for y in 0..<gridHeight {
                let pos = Position(x: x, y: y)
                if !cat.body.contains(pos) &&
                   pos != food?.position &&
                   !obstacles.contains(where: { $0.position == pos }) &&
                   !powerUps.contains(where: { $0.position == pos }) {
                    validPositions.append(pos)
                }
            }
        }

        if let position = validPositions.randomElement() {
            powerUps.append(PowerUp(type: type, position: position))
        }
    }

    private func collectPowerUp(_ powerUp: PowerUp) {
        powerUpsCollected += 1

        #if os(iOS)
        HapticFeedback.success()
        #endif

        let activePowerUp = ActivePowerUp(type: powerUp.type, duration: powerUp.type.duration)
        activePowerUps.append(activePowerUp)

        // Check for power-up stacking bonus
        checkPowerUpCombination(newPowerUp: powerUp.type)

        // Apply immediate effect based on type
        switch powerUp.type {
        case .speedBoost:
            currentSpeed = (settings.tickInterval / gameMode.speedMultiplier) * 0.7
            startGameLoop()
        case .slowMotion:
            currentSpeed = (settings.tickInterval / gameMode.speedMultiplier) * 1.5
            startGameLoop()
        case .doublePoints, .invincibility:
            break // These are handled during scoring
        }

        // Show score popup for power-up
        let popup = ScorePopup(points: 50, position: powerUp.position)
        scorePopups.append(popup)

        // Spawn particles for power-up collection
        spawnParticles(at: powerUp.position, color: powerUp.type.color, count: 15)

        // Add hit effect for power-up
        hitEffects.append(HitEffect(
            position: CGPoint(x: powerUp.position.x, y: powerUp.position.y),
            color: powerUp.type.color
        ))

        // Screen flash for power-up collection
        triggerFlash(type: .powerUp, intensity: 0.6)
        screenFlashIntensity = 0.4

        // Camera zoom for power-up
        cameraZoom = 1.1
        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            if !Task.isCancelled {
                cameraZoom = 1.0
            }
        }
        addTask(task)
    }

    private func updatePowerUps() {
        // Remove expired power-ups from field
        powerUps.removeAll { $0.isExpired }

        // Remove expired active power-ups
        activePowerUps.removeAll { !$0.isActive }

        // Restore speed when speed boost/slow motion ends
        let hasSpeedModifier = activePowerUps.contains { $0.type == .speedBoost || $0.type == .slowMotion }
        if !hasSpeedModifier && currentSpeed != settings.tickInterval {
            // Apply speed progression
            let speedReduction = min(Double(score) * 0.001, 0.05) // Max 5% faster
            currentSpeed = settings.tickInterval * (1.0 - speedReduction)
            startGameLoop()
        }
    }

    var isInvincible: Bool {
        activePowerUps.contains { $0.type == .invincibility }
    }

    private var isDoublePoints: Bool {
        activePowerUps.contains { $0.type == .doublePoints }
    }

    private func increaseSpeed() {
        let newSpeed = currentSpeed * 0.98
        if newSpeed >= 0.05 {
            currentSpeed = newSpeed
            startGameLoop() // Restart with new speed
        }
    }

    private func gameOver() {
        // Guard against multiple game over calls in same tick
        guard gameState == .playing else { return }

        // Stop boss battle if active
        bossBattleActive = false
        currentBoss = nil
        bossAttacks.removeAll()

        stopGameLoop()
        stopTimeTimer()
        gameState = .gameOver

        // Update max combo streak
        if consecutiveFoodsWithoutCollision > maxComboStreak {
            maxComboStreak = consecutiveFoodsWithoutCollision
        }

        #if os(iOS)
        HapticFeedback.error()
        #endif

        // Game over impact effect
        gameOverImpact = true
        screenShake = 10
        screenFlashIntensity = 0.3
        cameraZoom = 0.9

        // Trigger damage flash
        triggerFlash(type: .damage, intensity: 0.6)

        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !Task.isCancelled {
                gameOverImpact = false
                cameraZoom = 1.0
            }
        }
        addTask(task)

        if score > highScore {
            highScore = score
            Self.saveHighScore(highScore, for: gameMode)
            #if os(iOS)
            HapticFeedback.success()
            #endif

            // Trigger victory celebration for new high score
            if score >= 500 {
                showVictoryCelebration = true
            }
        }

        // Trigger victory flash for good runs
        if score >= 300 {
            triggerFlash(type: .victory, intensity: 0.9)
        }

        // Update achievements
        var stats = GameStats.load()
        stats.updateFromGame(
            score: score,
            foodEaten: foodEaten,
            powerUpsCollected: powerUpsCollected,
            dashesUsed: dashesUsed,
            comboCount: comboCount,
            length: cat.body.count,
            gameMode: gameMode
        )
    }

    // MARK: - Input Handling
    func changeDirection(_ direction: Direction) {
        guard gameState == .playing else { return }

        // Add to input queue
        if inputQueue.count < maxInputQueueSize {
            // Prevent 180-degree turns in queue
            if let lastInput = inputQueue.last {
                guard lastInput != direction.opposite else { return }
            } else {
                guard cat.direction != direction.opposite else { return }
            }
            inputQueue.append(direction)
        }
    }

    // MARK: - Food Generation
    private static func generateFood(for cat: Cat, gridWidth: Int, gridHeight: Int) -> Food {
        var validPositions: [Position] = []

        for x in 0..<gridWidth {
            for y in 0..<gridHeight {
                let pos = Position(x: x, y: y)
                if !cat.body.contains(pos) {
                    validPositions.append(pos)
                }
            }
        }

        // If grid is completely filled, the cat has won - return a position
        // that will trigger game over on next move
        guard let randomPosition = validPositions.randomElement() else {
            return Food(position: Position(x: -1, y: -1))
        }

        return Food(position: randomPosition)
    }

    // MARK: - Dynamic Difficulty Adjustment
    private func updateDynamicDifficulty() {
        let previousLevel = difficultyLevel

        // Calculate performance metrics
        let avgCombo = foodEaten > 0 ? Double(score) / Double(foodEaten) : 0
        let recentPerformance = comboCount >= 3 // Good performance indicator

        // Determine new difficulty level based on score and performance
        let newLevel: Int
        if score < 50 {
            newLevel = 1
        } else if score < 150 {
            newLevel = avgCombo > 15 ? 3 : 2
        } else if score < 300 {
            newLevel = avgCombo > 20 ? 4 : 3
        } else if score < 500 {
            newLevel = avgCombo > 25 ? 5 : 4
        } else {
            newLevel = min(avgCombo > 30 ? 6 : 5, 6)
        }

        // Only update if level changed
        if newLevel != previousLevel {
            difficultyLevel = newLevel

            // Show notification for difficulty increase
            if newLevel > previousLevel {
                let notifications = [
                    "Level Up! Speed Increased!",
                    "Faster! More Obstacles!",
                    "Challenge Accepted!",
                    "Getting Intense!",
                    "Maximum Speed!",
                    "Ultimate Challenge!"
                ]

                if newLevel <= notifications.count {
                    difficultyNotification = notifications[newLevel - 1]
                    showingAchievement = true
                    achievementUnlocked = "Difficulty Lv\(newLevel)"

                    // Visual feedback
                    screenFlashIntensity = 0.3
                    screenShake = CGFloat(newLevel)

                    #if os(iOS)
                    HapticFeedback.warning()
                    #endif

                    // Clear notification after delay
                    let task = Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        if !Task.isCancelled {
                            difficultyNotification = ""
                        }
                    }
                    addTask(task)
                }
            }

            // Apply difficulty modifiers
            applyDifficultyModifiers(level: newLevel)
        }
    }

    private func applyDifficultyModifiers(level: Int) {
        // Speed increases with difficulty
        let speedMultiplier = 1.0 - (Double(level) * 0.08) // Up to 48% faster at level 6
        let baseSpeed = settings.tickInterval / gameMode.speedMultiplier
        let hasSpeedModifier = activePowerUps.contains { $0.type == .speedBoost || $0.type == .slowMotion }

        if !hasSpeedModifier {
            currentSpeed = baseSpeed * max(0.5, speedMultiplier)
            startGameLoop()
        }

        // Obstacle spawn chance increases with difficulty
        // (This will be handled in spawnObstaclesIfNeeded)
    }

    // MARK: - Power-up Combination Effects
    private func checkPowerUpCombination(newPowerUp: PowerUpType) {
        let activeTypes = activePowerUps.map { $0.type }
        let totalCount = activeTypes.count + 1 // Include the new one

        // Check for specific combinations
        if totalCount >= 2 {
            // Speed + Invincibility = "Unstoppable"
            if activeTypes.contains(.speedBoost) && activeTypes.contains(.invincibility) && newPowerUp == .doublePoints {
                showPowerUpComboNotification(
                    name: "UNSTOPPABLE!",
                    description: "Speed + Invincibility + Double Points!",
                    bonus: 200,
                    color: .purple
                )
            }
            // Double Points + Speed = "Greedy Cat"
            else if activeTypes.contains(.doublePoints) && activeTypes.contains(.speedBoost) && newPowerUp == .doublePoints {
                showPowerUpComboNotification(
                    name: "GREEDY CAT!",
                    description: "Triple Points Active!",
                    bonus: 150,
                    color: .pink
                )
            }
            // Invincibility + Slow Motion = "Time Lord"
            else if activeTypes.contains(.invincibility) && activeTypes.contains(.slowMotion) && newPowerUp == .invincibility {
                showPowerUpComboNotification(
                    name: "TIME LORD!",
                    description: "Invincible + Slow Motion!",
                    bonus: 100,
                    color: .blue
                )
            }
            // Any 3+ power-ups = "Power Overload"
            else if totalCount >= 3 {
                showPowerUpComboNotification(
                    name: "POWER OVERLOAD!",
                    description: "\(totalCount) Power-ups Active!",
                    bonus: totalCount * 50,
                    color: .orange
                )
            }
        }
    }

    private func showPowerUpComboNotification(name: String, description: String, bonus: Int, color: Color) {
        // Add bonus score
        score += bonus

        // Visual feedback
        screenFlashIntensity = 0.5
        screenShake = 10
        cameraZoom = 1.15

        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !Task.isCancelled {
                cameraZoom = 1.0
            }
        }
        addTask(task)

        // Show achievement
        showingAchievement = true
        achievementUnlocked = "\(name)\n\(description)\n+\(bonus)"

        #if os(iOS)
        HapticFeedback.success()
        #endif

        // Spawn celebratory particles
        if let headPosition = cat.body.first {
            for _ in 0..<15 {
                let angle = Double.random(in: 0...(2 * .pi))
                let speed = Double.random(in: 2.0...4.0)
                let particle = Particle(
                    position: CGPoint(x: CGFloat(headPosition.x), y: CGFloat(headPosition.y)),
                    velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed),
                    color: color,
                    size: CGFloat.random(in: 0.12...0.3),
                    life: 0,
                    maxLife: Double.random(in: 0.6...1.2)
                )
                particles.append(particle)
            }
        }
    }

    // MARK: - High Score Persistence
    private static func highScoreKey(for mode: GameMode) -> String {
        return "GreedyBlackCatHighScore_\(mode.rawValue)"
    }

    private static func loadHighScore(for mode: GameMode) -> Int {
        return UserDefaults.standard.integer(forKey: highScoreKey(for: mode))
    }

    private static func saveHighScore(_ score: Int, for mode: GameMode) {
        UserDefaults.standard.set(score, forKey: highScoreKey(for: mode))
    }

    // MARK: - Weather System
    private func updateWeatherProgress() {
        guard showWeatherEffects else { return }

        let previousWeather = currentWeather

        // Weather changes based on score milestones and difficulty
        switch score {
        case 0..<100:
            currentWeather = .sunny
        case 100..<300:
            currentWeather = .cloudy
        case 300..<500:
            currentWeather = difficultyLevel >= 3 ? .rainy : .cloudy
        case 500..<800:
            currentWeather = difficultyLevel >= 4 ? .snowy : .rainy
        case 800..<1200:
            currentWeather = difficultyLevel >= 5 ? .stormy : .snowy
        default:
            currentWeather = .stormy
        }

        // Show notification when weather changes
        if previousWeather != currentWeather {
            showingAchievement = true
            achievementUnlocked = "Weather: \(currentWeather.rawValue)"

            #if os(iOS)
            HapticFeedback.light()
            #endif
        }
    }

    // MARK: - Boss Battle System
    private func checkBossBattleTrigger() {
        // Only trigger boss battles at specific milestones
        guard currentBoss == nil else { return }

        let bossType: BossType?
        switch score {
        case 200..<300:
            bossType = .giantFish
        case 500..<600:
            bossType = .ghostCat
        case 800..<900:
            bossType = .shadowBeast
        case 1200..<1300:
            bossType = .goldenDragon
        default:
            bossType = nil
        }

        if let type = bossType {
            spawnBoss(type: type)
        }
    }

    private func spawnBoss(type: BossType) {
        // Find a valid spawn position away from the cat
        let spawnPosition = findBossSpawnPosition()

        let boss = Boss(type: type, position: spawnPosition)
        currentBoss = boss
        bossBattleActive = true

        // Show boss spawn notification
        showingAchievement = true
        achievementUnlocked = "⚠️ BOSS: \(type.rawValue)!"

        // Visual feedback
        screenFlashIntensity = 0.6
        screenShake = 12
        cameraZoom = 1.2

        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            if !Task.isCancelled {
                cameraZoom = 1.0
            }
        }
        addTask(task)

        #if os(iOS)
        HapticFeedback.notification(.warning)
        #endif

        // Start boss attack pattern
        startBossAttackPattern()
    }

    private func findBossSpawnPosition() -> Position {
        // Try to spawn far from the cat
        let catPos = cat.head
        let candidates = [
            Position(x: max(0, catPos.x - 5), y: max(0, catPos.y - 5)),
            Position(x: min(gridWidth - 1, catPos.x + 5), y: max(0, catPos.y - 5)),
            Position(x: max(0, catPos.x - 5), y: min(gridHeight - 1, catPos.y + 5)),
            Position(x: min(gridWidth - 1, catPos.x + 5), y: min(gridHeight - 1, catPos.y + 5))
        ]

        // Return first valid position that's not occupied
        for pos in candidates {
            if !cat.body.contains(pos) && food?.position != pos {
                return pos
            }
        }

        return Position(x: gridWidth / 2, y: gridHeight / 2)
    }

    private func startBossAttackPattern() {
        guard let boss = currentBoss else { return }

        // Attack based on boss type
        switch boss.type.ability {
        case .dashAttack:
            scheduleBossAttack(interval: 3.0)
        case .teleport:
            scheduleBossAttack(interval: 4.0)
        case .split:
            scheduleBossAttack(interval: 5.0)
        case .fireBreath:
            scheduleBossAttack(interval: 2.5)
        }
    }

    private func scheduleBossAttack(interval: TimeInterval) {
        let task = Task { @MainActor in
            while !Task.isCancelled && bossBattleActive && currentBoss != nil {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                if !Task.isCancelled && bossBattleActive, let boss = currentBoss {
                    performBossAttack(boss: boss)
                }
            }
        }
        addTask(task)
    }

    private func performBossAttack(boss: Boss) {
        // Determine attack direction (towards cat)
        let dx = cat.head.x - boss.position.x
        let dy = cat.head.y - boss.position.y

        let direction: Direction
        if abs(dx) > abs(dy) {
            direction = dx > 0 ? .right : .left
        } else {
            direction = dy > 0 ? .down : .up
        }

        let attack = BossAttack(type: boss.type, position: boss.position, direction: direction, createdAt: Date())
        bossAttacks.append(attack)

        // Warning effect
        screenShake = 5
        #if os(iOS)
        HapticFeedback.warning()
        #endif
    }

    func attackBoss() {
        guard let boss = currentBoss else { return }

        // Damage boss
        var damagedBoss = boss
        damagedBoss.health -= 1
        currentBoss = damagedBoss

        // Visual feedback
        screenShake = 8
        spawnParticles(at: cat.head, color: boss.type.color, count: 12)

        #if os(iOS)
        HapticFeedback.medium()
        #endif

        // Check if boss is defeated
        if damagedBoss.isDefeated {
            defeatBoss(boss: damagedBoss)
        }
    }

    private func defeatBoss(boss: Boss) {
        bossBattleActive = false

        // Trigger achievement celebration
        achievementCelebration = true
        currentAchievement = .bossSlayer

        // Big celebration
        screenFlashIntensity = 0.8
        screenShake = 15
        cameraZoom = 1.25

        // Spawn victory particles
        for _ in 0..<30 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 2.0...5.0)
            let particle = Particle(
                position: CGPoint(x: CGFloat(boss.position.x), y: CGFloat(boss.position.y)),
                velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed),
                color: boss.type.color,
                size: CGFloat.random(in: 0.15...0.4),
                life: 0,
                maxLife: Double.random(in: 0.8...1.5)
            )
            particles.append(particle)
        }

        // Score bonus
        let bossBonus = boss.type.spawnScore
        score += bossBonus

        // Show victory notification
        showingAchievement = true
        achievementUnlocked = "🎉 \(boss.type.rawValue) DEFEATED!\n+\(bossBonus) pts"

        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            if !Task.isCancelled {
                cameraZoom = 1.0
            }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if !Task.isCancelled {
                currentBoss = nil
            }
        }
        addTask(task)

        #if os(iOS)
        HapticFeedback.success()
        #endif
    }

    // MARK: - Toast Notification System
    func showToast(message: String, icon: String, type: ToastType) {
        toastMessage = message
        toastIcon = icon
        toastType = type
        showToast = true

        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if !Task.isCancelled {
                showToast = false
            }
        }
        addTask(task)
    }

    // MARK: - Flash Effects
    func triggerFlash(type: FlashType, intensity: Double = 0.8) {
        activeFlashType = type
        flashIntensity = intensity

        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            if !Task.isCancelled {
                activeFlashType = nil
            }
        }
        addTask(task)
    }
}
