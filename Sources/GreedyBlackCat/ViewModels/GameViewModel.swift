import Foundation
import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var gameState: GameState = .menu
    @Published var cat: Cat
    @Published var food: Food?
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var settings: GameSettings

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

        // Process input queue
        if !inputQueue.isEmpty {
            let newDirection = inputQueue.removeFirst()
            cat.changeDirection(newDirection)
        }

        // Calculate new head position
        let newPosition = cat.head.applying(cat.direction.offset)

        // Check wall collision
        if !newPosition.isInBounds(width: gridWidth, height: gridHeight) {
            gameOver()
            return
        }

        // Check self collision
        let testCat = cat
        var testBody = testCat.body
        testBody.insert(newPosition, at: 0)
        if testBody.count > 1 && testBody[1...].contains(newPosition) {
            gameOver()
            return
        }

        // Check food collision
        let ateFood = food?.position == newPosition
        cat.move(to: newPosition, grow: ateFood)

        if ateFood {
            handleFoodEaten()
        }

        // Check self collision after move
        if cat.checkSelfCollision() {
            gameOver()
        }
    }

    private func handleFoodEaten() {
        guard let currentFood = food else { return }
        score += currentFood.points

        // Generate new food
        food = Self.generateFood(for: cat, gridWidth: gridWidth, gridHeight: gridHeight)

        // Optionally increase speed
        // increaseSpeed()
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
