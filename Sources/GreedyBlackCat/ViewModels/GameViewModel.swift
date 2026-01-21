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
    @Published var screenShake: CGFloat = 0
    @Published var canDash: Bool = true
    @Published var isDashing: Bool = false

    // MARK: - Combo System
    private var lastEatTime: Date?
    private let comboWindow: TimeInterval = 2.0

    // MARK: - Dash System
    private var dashCooldown: TimeInterval = 0
    private let dashCooldownTime: TimeInterval = 3.0

    // MARK: - Timer
    private var gameTimer: Timer?
    private var currentSpeed: TimeInterval

    // MARK: - Input Queue
    private var inputQueue: [Direction] = []
    private let maxInputQueueSize = 2

    // MARK: - Grid Dimensions
    var gridWidth: Int { settings.gridWidth }
    var gridHeight: Int { settings.gridHeight }

    // MARK: - Initialization
    init(settings: GameSettings? = nil) {
        // Compute all values in local variables first (no self access)
        let theSettings = settings ?? AdaptiveSettings.gameSettings()
        let theSpeed = theSettings.tickInterval
        let startX = theSettings.gridWidth / 2
        let startY = theSettings.gridHeight / 2
        let theCat = Cat(startPosition: Position(x: startX, y: startY))
        let theHighScore = Self.loadHighScore()
        let gridW = theSettings.gridWidth
        let gridH = theSettings.gridHeight
        let theFood = Self.generateFood(for: theCat, gridWidth: gridW, gridHeight: gridH)

        // Now assign to all properties
        self.settings = theSettings
        self.currentSpeed = theSpeed
        self.cat = theCat
        self.highScore = theHighScore
        self.food = theFood
    }

    // MARK: - Game Control
    func startGame() {
        gameState = .playing
        resetGame()
        startGameLoop()
    }

    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
        stopGameLoop()
    }

    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        startGameLoop()
    }

    func restartGame() {
        resetGame()
        startGame()
    }

    func quitToMenu() {
        stopGameLoop()
        gameState = .menu
    }

    private func resetGame() {
        let startX = settings.gridWidth / 2
        let startY = settings.gridHeight / 2
        cat = Cat(startPosition: Position(x: startX, y: startY))
        score = 0
        currentSpeed = settings.tickInterval
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
        food = Self.generateFood(for: cat, gridWidth: gridWidth, gridHeight: gridHeight)
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

        // Process input queue
        if !inputQueue.isEmpty {
            let newDirection = inputQueue.removeFirst()
            cat.changeDirection(newDirection)
        }

        // Calculate new head position
        let newPosition = cat.head.applying(cat.direction.offset)

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

        // Spawn obstacles as difficulty increases
        spawnObstaclesIfNeeded()
    }

    private func handleFoodEaten(at position: Position) {
        guard let currentFood = food else { return }

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

        // Spawn particles
        spawnParticles(at: position, color: currentFood.type.color, count: 8)

        // Add score popup at food position
        let popup = ScorePopup(points: points, position: currentFood.position)
        scorePopups.append(popup)

        // Clean up old popups
        scorePopups.removeAll { $0.isExpired }

        // Generate new food
        food = Self.generateFood(for: cat, gridWidth: gridWidth, gridHeight: gridHeight)

        // Chance to spawn power-up
        if Double.random(in: 0...1) < 0.15 {
            spawnPowerUp()
        }

        // Increase speed gradually
        increaseSpeed()
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
        // Spawn obstacles every 50 points, max 5 obstacles
        let obstacleCount = score / 50
        let targetObstacles = min(obstacleCount, 5)

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
        let activePowerUp = ActivePowerUp(type: powerUp.type, duration: powerUp.type.duration)
        activePowerUps.append(activePowerUp)

        // Apply immediate effect based on type
        switch powerUp.type {
        case .speedBoost:
            currentSpeed = settings.tickInterval * 0.7
            startGameLoop()
        case .slowMotion:
            currentSpeed = settings.tickInterval * 1.5
            startGameLoop()
        case .doublePoints, .invincibility:
            break // These are handled during scoring
        }

        // Show score popup for power-up
        let popup = ScorePopup(points: 50, position: powerUp.position)
        scorePopups.append(popup)
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
        gameState = .gameOver

        if score > highScore {
            highScore = score
            Self.saveHighScore(highScore)
        }
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
    private static let highScoreKey = "GreedyBlackCatHighScore"

    private static func loadHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: highScoreKey)
    }

    private static func saveHighScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: highScoreKey)
    }

    // MARK: - Cleanup
    deinit {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}
