import SwiftUI

@main
struct GreedyBlackCatApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
