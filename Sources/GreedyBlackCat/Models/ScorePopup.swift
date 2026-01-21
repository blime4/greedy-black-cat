import Foundation
import SwiftUI

struct ScorePopup: Identifiable {
    let id = UUID()
    let points: Int
    let position: Position
    let createdAt = Date()

    // Remove popups older than 1 second
    var isExpired: Bool {
        Date().timeIntervalSince(createdAt) > 1.0
    }
}
