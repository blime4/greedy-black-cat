import SwiftUI

enum CatEmotion {
    case happy
    case excited
    case focused
    case surprised

    var mouthPath: (CGFloat, CGFloat) {
        switch self {
        case .happy:
            return (0.5, 1.0) // Smile
        case .excited:
            return (0.3, 1.5) // Big smile
        case .focused:
            return (0.2, 0.5) // Slight opening
        case .surprised:
            return (0.8, 0.8) // O shape
        }
    }

    var eyeScale: CGFloat {
        switch self {
        case .happy: return 1.0
        case .excited: return 1.2
        case .focused: return 0.8
        case .surprised: return 1.4
        }
    }

    var whiskerAngle: Double {
        switch self {
        case .happy: return 10
        case .excited: return 20
        case .focused: return 0
        case .surprised: return -10
        }
    }
}
