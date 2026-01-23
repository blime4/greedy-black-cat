import SwiftUI
import Combine

struct WeatherSystemView: View {
    let weatherType: WeatherType
    let screenSize: CGSize

    @State private var raindrops: [Raindrop] = []
    @State private var snowflakes: [Snowflake] = []
    @State private var clouds: [Cloud] = []
    @State private var lightningOpacity: Double = 0
    @State private var isStorming = false

    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            switch weatherType {
            case .sunny:
                sunnyView
            case .rainy:
                rainyView
            case .snowy:
                snowyView
            case .stormy:
                stormyView
            case .cloudy:
                cloudyView
            }

            // Ambient particles for all weather types
            ambientParticlesView
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            initializeWeather()
        }
        .onDisappear {
            // Properly cancel all timer subscriptions
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: weatherType) { _, newType in
            // Cancel existing timers before switching weather type
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
            updateWeather(for: newType)
        }
    }

    private var sunnyView: some View {
        ZStack {
            // Sun rays
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.3),
                            Color.yellow.opacity(0.1),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 50,
                        endRadius: 400
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: -150, y: -200)

            // Lens flare effect
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.15 - Double(index) * 0.04))
                    .frame(width: 100 + CGFloat(index * 50), height: 100 + CGFloat(index * 50))
                    .blur(radius: 20)
                    .offset(x: -100 + CGFloat(index * 80), y: -150)
            }
        }
    }

    private var rainyView: some View {
        ZStack {
            // Dark overlay
            Color.blue.opacity(0.05)
                .ignoresSafeArea()

            // Rain drops
            ForEach(raindrops) { drop in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 2, height: drop.length)
                    .offset(x: drop.position.x, y: drop.position.y)
                    .opacity(drop.opacity)
            }
        }
        .onAppear {
            startRain()
        }
    }

    private var snowyView: some View {
        ZStack {
            // Cool overlay
            Color.cyan.opacity(0.03)
                .ignoresSafeArea()

            // Snowflakes
            ForEach(snowflakes) { flake in
                Image(systemName: "snowflake")
                    .font(.system(size: flake.size))
                    .foregroundColor(.white.opacity(flake.opacity))
                    .offset(x: flake.position.x, y: flake.position.y)
                    .rotationEffect(.degrees(flake.rotation))
            }
        }
        .onAppear {
            startSnow()
        }
    }

    private var stormyView: some View {
        ZStack {
            // Very dark overlay
            Color.gray.opacity(0.15)
                .ignoresSafeArea()

            // Lightning flash
            Color.white.opacity(lightningOpacity)
                .ignoresSafeArea()

            // Rain (heavier)
            ForEach(raindrops) { drop in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 2, height: drop.length * 1.5)
                    .offset(x: drop.position.x, y: drop.position.y)
                    .opacity(drop.opacity)
            }
        }
        .onAppear {
            startRain()
            startLightning()
        }
    }

    private var cloudyView: some View {
        ZStack {
            // Slightly dim overlay
            Color.gray.opacity(0.08)
                .ignoresSafeArea()

            // Clouds
            ForEach(clouds) { cloud in
                CloudShape()
                    .fill(Color.white.opacity(cloud.opacity))
                    .frame(width: cloud.size, height: cloud.size * 0.6)
                    .offset(x: cloud.position.x, y: cloud.position.y)
                    .blur(radius: 3)
            }
        }
        .onAppear {
            startClouds()
        }
    }

    private var ambientParticlesView: some View {
        ZStack {
            // Floating dust/sparkles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                    .position(
                        x: CGFloat.random(in: 0...screenSize.width),
                        y: CGFloat.random(in: 0...screenSize.height)
                    )
                    .blur(radius: 1)
            }
        }
    }

    // MARK: - Weather Initialization
    private func initializeWeather() {
        updateWeather(for: weatherType)
    }

    private func updateWeather(for type: WeatherType) {
        raindrops.removeAll()
        snowflakes.removeAll()
        clouds.removeAll()

        switch type {
        case .rainy, .stormy:
            startRain()
            if type == .stormy {
                startLightning()
            }
        case .snowy:
            startSnow()
        case .cloudy:
            startClouds()
        default:
            break
        }
    }

    // MARK: - Animation Controllers
    private func startRain() {
        Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if raindrops.count < 100 {
                    let drop = Raindrop(
                        position: CGPoint(
                            x: CGFloat.random(in: 0...screenSize.width),
                            y: -20
                        ),
                        length: CGFloat.random(in: 10...20),
                        opacity: Double.random(in: 0.3...0.6),
                        speed: CGFloat.random(in: 15...25)
                    )
                    raindrops.append(drop)
                }

                // Update positions
                for i in raindrops.indices {
                    raindrops[i].position.y += raindrops[i].speed
                }

                // Remove off-screen drops
                raindrops.removeAll { $0.position.y > screenSize.height + 20 }
            }
            .store(in: &cancellables)
    }

    private func startSnow() {
        Timer.publish(every: 0.02, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if snowflakes.count < 50 {
                    let flake = Snowflake(
                        position: CGPoint(
                            x: CGFloat.random(in: 0...screenSize.width),
                            y: -10
                        ),
                        size: CGFloat.random(in: 8...15),
                        opacity: Double.random(in: 0.4...0.8),
                        rotation: Double.random(in: 0...360),
                        speed: CGFloat.random(in: 2...5),
                        wobble: Double.random(in: -1...1)
                    )
                    snowflakes.append(flake)
                }

                // Update positions
                for i in snowflakes.indices {
                    snowflakes[i].position.y += snowflakes[i].speed
                    snowflakes[i].position.x += snowflakes[i].wobble
                    snowflakes[i].rotation += 2
                }

                // Remove off-screen flakes
                snowflakes.removeAll { $0.position.y > screenSize.height + 10 }
            }
            .store(in: &cancellables)
    }

    private func startClouds() {
        for _ in 0..<5 {
            let cloud = Cloud(
                position: CGPoint(
                    x: CGFloat.random(in: -100...screenSize.width + 100),
                    y: CGFloat.random(in: 50...200)
                ),
                size: CGFloat.random(in: 80...150),
                opacity: Double.random(in: 0.3...0.5),
                speed: CGFloat.random(in: 0.2...0.5)
            )
            clouds.append(cloud)
        }

        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                for i in clouds.indices {
                    clouds[i].position.x += clouds[i].speed
                }

                // Wrap around
                for i in clouds.indices {
                    if clouds[i].position.x > screenSize.width + 150 {
                        clouds[i].position.x = -150
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func startLightning() {
        Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if Double.random(in: 0...1) < 0.3 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        lightningOpacity = 0.8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            lightningOpacity = 0
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Weather Types
enum WeatherType: String, CaseIterable {
    case sunny = "Sunny"
    case rainy = "Rainy"
    case snowy = "Snowy"
    case stormy = "Stormy"
    case cloudy = "Cloudy"

    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .stormy: return "cloud.bolt.fill"
        case .cloudy: return "cloud.fill"
        }
    }
}

// MARK: - Weather Particle Models
struct Raindrop: Identifiable {
    let id = UUID()
    var position: CGPoint
    let length: CGFloat
    let opacity: Double
    let speed: CGFloat
}

struct Snowflake: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    var rotation: Double
    let speed: CGFloat
    let wobble: CGFloat
}

struct Cloud: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    let speed: CGFloat
}

// MARK: - Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.1, y: height * 0.6))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.3, y: height * 0.2),
            control: CGPoint(x: width * 0.15, y: height * 0.3)
        )
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.1),
            control: CGPoint(x: width * 0.4, y: height * 0.15)
        )
        path.addQuadCurve(
            to: CGPoint(x: width * 0.7, y: height * 0.2),
            control: CGPoint(x: width * 0.6, y: height * 0.15)
        )
        path.addQuadCurve(
            to: CGPoint(x: width * 0.9, y: height * 0.6),
            control: CGPoint(x: width * 0.85, y: height * 0.3)
        )
        path.closeSubpath()

        return path
    }
}
