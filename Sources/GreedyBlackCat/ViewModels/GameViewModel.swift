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
    @Published var canDash: Bool = true
    @Published var isDashing: Bool = false
    @Published var gameMode: GameMode = .classic
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

    // MARK: - Trail System
    private var trailSystem = TrailSystem()

    // MARK: - Combo System
    private var lastEatTime: Date?
    private let comboWindow: TimeInterval = 2.0

    // MARK: - Dash System
    private var dashCooldown: TimeInterval = 0
    private let dashCooldownTime: TimeInterval = 3.0

    // MARK: - Timer System
    private var gameTimer: Timer?
    private var timeTimer: Timer?
    private var currentSpeed: TimeInterval

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
    }

    private func startTimeTimer() {
        stopTimeTimer()
        guard gameMode.hasTimeLimit else { return }

        timeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.1
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

        // Check food collision
        let ateFood = food?.position == newPosition
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
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showingAchievement = false
            }
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

        foodEaten += 1

        // Handle combo system
        let now = Date()
        if let lastTime = lastEatTime, now.timeIntervalSince(lastTime) <= comboWindow {
            comboCount += 1
        } else {
            comboCount = 1
        }
        lastEatTime = now

        // Calculate score with combo multiplier
        let comboMultiplier = min(comboCount, 5) // Max 5x multiplier
        let points = currentFood.points * comboMultiplier
        score += points

        // Screen flash and shake on combo milestones
        if comboCount == 3 || comboCount == 5 {
            screenShake = CGFloat(comboCount)
            screenFlashIntensity = comboCount == 5 ? 0.5 : 0.3
            #if os(iOS)
            HapticFeedback.medium()
            #endif

            // Show combo popup
            self.comboMultiplier = comboCount
            showComboPopup = true

            // Hide popup after animation
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 800_000_000)
                showComboPopup = false
            }
        }

        // Spawn particles
        spawnParticles(at: position, color: currentFood.type.color, count: 8)

        // Add hit effect
        hitEffects.append(HitEffect(
            position: CGPoint(x: position.x, y: position.y),
            color: currentFood.type.color
        ))

        // Add score popup at food position
        let popup = ScorePopup(points: points, position: currentFood.position)
        scorePopups.append(popup)

        // Clean up old popups and hit effects
        scorePopups.removeAll { $0.isExpired }
        hitEffects.removeAll { $0.isExpired }

        // Generate new food
        food = Self.generateFood(for: cat, gridWidth: gridWidth, gridHeight: gridHeight)

        // Chance to spawn power-up (only in modes that allow it)
        if gameMode.hasPowerUps && Double.random(in: 0...1) < 0.15 {
            spawnPowerUp()
        }

        // Increase speed gradually
        increaseSpeed()

        // Check for growth milestone (every 5 segments)
        let catLength = cat.body.count
        if catLength > 3 && catLength % 5 == 0 {
            celebrateLevelUp(at: position)
        }
    }

    private func celebrateLevelUp(at position: Position) {
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

    private func updateParticles() {
        for i in particles.indices {
            particles[i].life += currentSpeed
            particles[i].position.x += particles[i].velocity.dx * CGFloat(currentSpeed)
            particles[i].position.y += particles[i].velocity.dy * CGFloat(currentSpeed)
        }
        particles.removeAll { $0.isDead }
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
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            isDashing = false
        }
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
        screenFlashIntensity = 0.4
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

    private var isInvincible: Bool {
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
        stopGameLoop()
        stopTimeTimer()
        gameState = .gameOver

        #if os(iOS)
        HapticFeedback.error()
        #endif

        if score > highScore {
            highScore = score
            Self.saveHighScore(highScore, for: gameMode)
            #if os(iOS)
            HapticFeedback.success()
            #endif
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

        guard let randomPosition = validPositions.randomElement() else {
            // Fallback if no valid positions (shouldn't happen)
            return Food(position: Position(x: 0, y: 0))
        }

        return Food(position: randomPosition)
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

    // MARK: - Cleanup
    deinit {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}
