import Foundation

enum GameState {
    case menu
    case playing
    case paused
    case gameOver

    var isPlaying: Bool {
        return self == .playing
    }

    var isPaused: Bool {
        return self == .paused
    }

    var isGameOver: Bool {
        return self == .gameOver
    }

    var isMenu: Bool {
        return self == .menu
    }
}
