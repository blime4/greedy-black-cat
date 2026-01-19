import SwiftUI

struct AdaptiveSettings {
    @Environment(\.horizontalSizeClass) static var horizontalSizeClass

    #if os(iOS)
    static func detectDevice() -> DeviceType {
        #if os(iOS)
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        switch userInterfaceIdiom {
        case .phone:
            return .iPhone
        case .pad:
            return .iPad
        default:
            return .iPhone
        }
        #else
        return .iPhone
        #endif
    }
    #endif

    #if os(macOS)
    static func detectDevice() -> DeviceType {
        return .mac
    }
    #endif

    static func gameSettings() -> GameSettings {
        switch detectDevice() {
        case .iPhone:
            return .iPhone
        case .iPad:
            return .iPad
        case .mac:
            return .mac
        }
    }

    enum DeviceType {
        case iPhone
        case iPad
        case mac
    }
}

// Extension for device detection
#if os(iOS)
import UIKit

extension UIDevice {
    var isiPhone: Bool {
        return userInterfaceIdiom == .phone
    }

    var isiPad: Bool {
        return userInterfaceIdiom == .pad
    }
}
#endif
