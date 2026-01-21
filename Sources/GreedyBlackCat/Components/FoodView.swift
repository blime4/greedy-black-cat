import SwiftUI

struct FoodView: View {
    let food: Food
    let cellSize: CGFloat
    var catHead: Position?

    @State private var isFloating = false
    @State private var glowScale: CGFloat = 1.0
    @State private var isMagnetic = false
    @State private var spawnScale: CGFloat = 0.0

    init(food: Food, cellSize: CGFloat, catHead: Position? = nil) {
        self.food = food
        self.cellSize = cellSize
        self.catHead = catHead
    }

    var body: some View {
        ZStack {
            // Magnetic attraction rings
            if isMagnetic {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [fishColor.opacity(0.6), fishColor.opacity(0.1)],
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: cellSize * 1.2, height: cellSize * 1.2)
                    .rotationEffect(.degrees(isMagnetic ? 360 : 0))
            }

            // Glow effect
            Circle()
                .fill(fishColor.opacity(0.3))
                .frame(width: cellSize * glowScale, height: cellSize * glowScale)
                .blur(radius: 5)

            fishBody
                .fill(fishColor)
                .frame(width: cellSize * 0.7, height: cellSize * 0.5)

            // Eye
            Circle()
                .fill(Color.black)
                .frame(width: cellSize * 0.08, height: cellSize * 0.08)
                .offset(x: -cellSize * 0.15, y: -cellSize * 0.05)

            // Tail
            Triangle()
                .fill(fishColor)
                .frame(width: cellSize * 0.15, height: cellSize * 0.15)
                .offset(x: cellSize * 0.3, y: cellSize * 0.05)
                .rotationEffect(.degrees(45))

            // Fin
            Triangle()
                .fill(fishColor.opacity(0.8))
                .frame(width: cellSize * 0.1, height: cellSize * 0.1)
                .offset(x: 0, y: -cellSize * 0.15)
                .rotationEffect(.degrees(-90))
        }
        .rotationEffect(.degrees(-90))
        .scaleEffect(spawnScale)
        .shadow(color: fishColor.opacity(0.4), radius: 4, x: 0, y: 2)
        // Floating animation - bob up and down
        .offset(y: isFloating ? -cellSize * 0.05 : cellSize * 0.05)
        .animation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
            value: isFloating
        )
        // Glow pulsing animation
        .animation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true),
            value: glowScale
        )
        .animation(
            Animation.linear(duration: 4.0)
                .repeatForever(autoreverses: false),
            value: isMagnetic
        )
        // Spawn pop-in animation
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: spawnScale)
        .onAppear {
            isFloating = true
            glowScale = 0.9
            spawnScale = 1.0
            updateMagneticState()
        }
        .onChange(of: catHead) { _ in
            updateMagneticState()
        }
    }

    private func updateMagneticState() {
        if let catHead = catHead {
            let distance = abs(food.position.x - catHead.x) + abs(food.position.y - catHead.y)
            withAnimation {
                isMagnetic = distance <= 3
            }
        }
    }

    private var fishBody: some Shape {
        Ellipse()
    }

    private var fishColor: Color {
        switch food.type {
        case .smallFish:
            return Color(hex: "C0C0C0") // Silver
        case .mediumFish:
            return Color(hex: "FF8C00") // Orange
        case .largeFish:
            return Color(hex: "FFD700") // Gold
        }
    }
}
