import SwiftUI

struct FoodView: View {
    let food: Food
    let cellSize: CGFloat

    @State private var isFloating = false
    @State private var glowScale: CGFloat = 1.0

    init(food: Food, cellSize: CGFloat) {
        self.food = food
        self.cellSize = cellSize
    }

    var body: some View {
        ZStack {
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
        .onAppear {
            isFloating = true
            glowScale = 0.9
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
