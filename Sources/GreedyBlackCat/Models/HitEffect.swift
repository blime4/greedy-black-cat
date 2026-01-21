import SwiftUI

struct HitEffect: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let createdAt = Date()

    var isExpired: Bool {
        Date().timeIntervalSince(createdAt) > 0.6
    }
}
