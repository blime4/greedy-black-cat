import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingPauseMenu = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            // Background
            #if os(macOS)
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            #else
            Color(.systemBackground)
                .ignoresSafeArea()
            #endif

            VStack(spacing: 0) {
                // HUD
                hudView
                    .padding()

                // Game Grid
                gameGridView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Controls (iOS only)
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    touchControlsView
                        .padding()
                }
                #endif
            }

            // Pause Menu Overlay
            if viewModel.gameState.isPaused || showingPauseMenu {
                pauseMenuOverlay
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
        HStack {
            // Score
            HStack(spacing: 8) {
                Text("Score:")
                    .font(.headline)
                Text("\(viewModel.score)")
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            }

            Spacer()

            // High Score
            HStack(spacing: 8) {
                Text("High Score:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(viewModel.highScore)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }

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
            #if os(iOS)
            .buttonStyle(.plain)
            #endif
        }
    }

    // MARK: - Game Grid
    private var gameGridView: some View {
        GeometryReader { geometry in
            let gridSize = min(geometry.size.width, geometry.size.height)
            let cellSize = gridSize / CGFloat(max(viewModel.gridWidth, viewModel.gridHeight))

            ZStack {
                // Grid background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: 0.9, opacity: 1.0))
                    .frame(width: cellSize * CGFloat(viewModel.gridWidth),
                           height: cellSize * CGFloat(viewModel.gridHeight))

                // Draw grid lines (optional)
                gridLinesView(cellSize: cellSize)

                // Food
                if let food = viewModel.food {
                    FoodView(food: food, cellSize: cellSize)
                        .position(
                            x: CGFloat(food.position.x) * cellSize + cellSize / 2,
                            y: CGFloat(food.position.y) * cellSize + cellSize / 2
                        )
                }

                // Cat body
                ForEach(Array(viewModel.cat.body.enumerated()), id: \.offset) { index, position in
                    CatSegmentView(
                        isHead: index == 0,
                        direction: viewModel.cat.direction,
                        cellSize: cellSize
                    )
                    .position(
                        x: CGFloat(position.x) * cellSize + cellSize / 2,
                        y: CGFloat(position.y) * cellSize + cellSize / 2
                    )
                }
            }
            .frame(width: gridSize, height: gridSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    private func gridLinesView(cellSize: CGFloat) -> some View {
        ZStack {
            // Vertical lines
            ForEach(0...viewModel.gridWidth, id: \.self) { x in
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                    .offset(x: CGFloat(x) * cellSize - cellSize * CGFloat(viewModel.gridWidth) / 2)
            }

            // Horizontal lines
            ForEach(0...viewModel.gridHeight, id: \.self) { y in
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
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
        VStack(spacing: 16) {
            // Up button
            Button(action: { viewModel.changeDirection(.up) }) {
                controlButtonArrow(systemName: "arrow.up")
            }

            HStack(spacing: 32) {
                // Left button
                Button(action: { viewModel.changeDirection(.left) }) {
                    controlButtonArrow(systemName: "arrow.left")
                }

                // Down button
                Button(action: { viewModel.changeDirection(.down) }) {
                    controlButtonArrow(systemName: "arrow.down")
                }

                // Right button
                Button(action: { viewModel.changeDirection(.right) }) {
                    controlButtonArrow(systemName: "arrow.right")
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
    }

    private func controlButtonArrow(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 32, weight: .semibold))
            .foregroundColor(.accentColor)
            .frame(width: 60, height: 60)
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

            VStack(spacing: 24) {
                Text("Paused")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                VStack(spacing: 16) {
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
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(backgroundColor)
            .cornerRadius(16)
            .padding(40)
        }
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
