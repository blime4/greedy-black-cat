import SwiftUI

struct SceneTransitionView: View {
    let isActive: Bool
    let transitionType: TransitionType

    @State private var progress: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            if isActive {
                switch transitionType {
                case .fade:
                    fadeTransition
                case .zoom:
                    zoomTransition
                case .slide:
                    slideTransition
                case .ripple:
                    rippleTransition
                case .pixelate:
                    pixelateTransition
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var fadeTransition: some View {
        Color.black
            .opacity(1 - progress)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    progress = 1.0
                }
            }
    }

    private var zoomTransition: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .scaleEffect(progress * 3)
                .opacity(progress > 0.5 ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                progress = 1.0
            }
        }
    }

    private var slideTransition: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.5),
                            Color.black.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: (progress - 1) * 500)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                progress = 1.0
            }
        }
    }

    private var rippleTransition: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .stroke(Color.black.opacity(0.8), lineWidth: 3)
                    .frame(width: CGFloat(progress) * 800 + CGFloat(index) * 100, height: CGFloat(progress) * 800 + CGFloat(index) * 100)
                    .opacity(1 - progress)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                progress = 1.0
            }
        }
    }

    private var pixelateTransition: some View {
        ZStack {
            GeometryReader { geometry in
                let pixelSize: CGFloat = 20
                let columns = Int(geometry.size.width / pixelSize)
                let rows = Int(geometry.size.height / pixelSize)

                ForEach(0..<columns * rows, id: \.self) { index in
                    let row = index / columns
                    let col = index % columns
                    let delay = Double(row + col) * 0.01

                    Rectangle()
                        .fill(Color.black)
                        .frame(width: pixelSize, height: pixelSize)
                        .position(
                            x: CGFloat(col) * pixelSize + pixelSize / 2,
                            y: CGFloat(row) * pixelSize + pixelSize / 2
                        )
                        .opacity(delay < progress ? 1 : 0)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.0)) {
                progress = 1.0
            }
        }
    }
}

enum TransitionType {
    case fade
    case zoom
    case slide
    case ripple
    case pixelate
}

// Transition modifier for views
struct TransitionModifier: ViewModifier {
    let isActive: Bool
    let type: TransitionType

    @State private var offset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    func body(content: Content) -> some View {
        content
            .offset(x: type == .slide ? offset : 0)
            .scaleEffect(type == .zoom ? scale : 1.0)
            .opacity(type == .fade ? opacity : 1.0)
            .onChange(of: isActive) { _, active in
                if active {
                    startTransition()
                } else {
                    resetTransition()
                }
            }
    }

    private func startTransition() {
        switch type {
        case .fade:
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
            }
        case .zoom:
            withAnimation(.easeOut(duration: 0.4)) {
                scale = 1.1
            }
        case .slide:
            withAnimation(.easeInOut(duration: 0.5)) {
                offset = -50
            }
        default:
            break
        }
    }

    private func resetTransition() {
        withAnimation(.easeIn(duration: 0.2)) {
            opacity = 1.0
            scale = 1.0
            offset = 0
        }
    }
}

extension View {
    func sceneTransition(isActive: Bool, type: TransitionType = .fade) -> some View {
        self.modifier(TransitionModifier(isActive: isActive, type: type))
    }
}
