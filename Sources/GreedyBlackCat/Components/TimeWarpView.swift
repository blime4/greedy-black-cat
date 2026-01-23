import SwiftUI

struct TimeWarpView: View {
    let isActive: Bool
    let intensity: Double

    @State private var warpPhase: Double = 0
    @State private var chromaticAberration: CGFloat = 0

    var body: some View {
        ZStack {
            if isActive {
                // Time warp tunnel effect
                ZStack {
                    // Radial blur layers
                    ForEach(0..<5, id: \.self) { layer in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.3 - Double(layer) * 0.05),
                                        Color.purple.opacity(0.2 - Double(layer) * 0.03)
                                    ],
                                    startPoint: .center,
                                    endPoint: .trailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 300 + CGFloat(layer) * 100, height: 300 + CGFloat(layer) * 100)
                            .rotationEffect(.degrees(warpPhase + Double(layer * 20)))
                            .opacity(intensity)
                    }

                    // Time particles
                    ForEach(0..<20, id: \.self) { index in
                        TimeParticle(
                            index: index,
                            warpPhase: warpPhase,
                            intensity: intensity
                        )
                    }

                    // Chromatic aberration effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.clear,
                                    Color.blue.opacity(chromaticAberration * 0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 100,
                                endRadius: 400
                            )
                        )
                        .frame(width: 600, height: 600)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }
        .onAppear {
            if isActive {
                startTimeWarp()
            }
        }
        .onChange(of: isActive) { _, active in
            if active {
                startTimeWarp()
            }
        }
    }

    private func startTimeWarp() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            warpPhase = 360
        }
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            chromaticAberration = 1.0
        }
    }
}

struct TimeParticle: View {
    let index: Int
    let warpPhase: Double
    let intensity: Double

    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .fill(Color.cyan.opacity(opacity * intensity))
            .frame(width: 4, height: 4)
            .blur(radius: 2)
            .position(position)
            .onAppear {
                // Random starting position
                position = CGPoint(
                    x: CGFloat.random(in: 0...400),
                    y: CGFloat.random(in: 0...800)
                )

                // Animate particle moving outward from center
                animate()
            }
    }

    private func animate() {
        let centerX = 200.0
        let centerY = 400.0
        let angle = Double(index) * 18 + warpPhase
        let distance = CGFloat.random(in: 50...300)

        withAnimation(
            Animation.easeOut(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            position = CGPoint(
                x: centerX + cos(angle * .pi / 180) * distance,
                y: centerY + sin(angle * .pi / 180) * distance
            )
            opacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 0
            }
        }
    }
}

// Time warp effect modifier
struct TimeWarpEffect: ViewModifier {
    let isActive: Bool
    let intensity: Double

    @State private var timeScale: CGFloat = 1.0
    @State private var saturation: Double = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(timeScale)
            .saturation(saturation)
            .animation(.easeOut(duration: 0.3), value: timeScale)
            .animation(.easeOut(duration: 0.3), value: saturation)
            .onChange(of: isActive) { _, active in
                if active {
                    timeScale = 0.95
                    saturation = 0.7
                } else {
                    timeScale = 1.0
                    saturation = 1.0
                }
            }
    }
}

extension View {
    func timeWarpEffect(isActive: Bool, intensity: Double = 1.0) -> some View {
        self.modifier(TimeWarpEffect(isActive: isActive, intensity: intensity))
    }
}
