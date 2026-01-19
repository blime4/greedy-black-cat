import Foundation

struct GameSettings {
    var gridWidth: Int
    var gridHeight: Int
    var tickInterval: TimeInterval
    var initialSpeed: TimeInterval

    static let iPhone = GameSettings(
        gridWidth: 20,
        gridHeight: 20,
        tickInterval: 0.15,
        initialSpeed: 0.15
    )

    static let iPad = GameSettings(
        gridWidth: 30,
        gridHeight: 30,
        tickInterval: 0.12,
        initialSpeed: 0.12
    )

    static let mac = GameSettings(
        gridWidth: 32,
        gridHeight: 32,
        tickInterval: 0.10,
        initialSpeed: 0.10
    )

    #if os(iOS)
    static let `default` = iPhone
    #elseif os(macOS)
    static let `default` = mac
    #endif
}
