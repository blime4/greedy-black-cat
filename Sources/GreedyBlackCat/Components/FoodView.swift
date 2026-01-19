import SwiftUI

struct FoodView: View {
    let food: Food
    let cellSize: CGFloat

    init(food: Food, cellSize: CGFloat) {
        self.food = food
        self.cellSize = cellSize
    }

    var body: some View {
        ZStack {
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
        .shadow(color: fishColor.opacity(0.3), radius: 3, x: 0, y: 2)
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

#Preview {
    VStack(spacing: 20) {
        FoodView(food: Food(position: Position(x: 0, y: 0), type: .smallFish), cellSize: 40)
        FoodView(food: Food(position: Position(x: 0, y: 0), type: .mediumFish), cellSize: 40)
        FoodView(food: Food(position: Position(x: 0, y: 0), type: .largeFish), cellSize: 40)
    }
    .padding()
}
