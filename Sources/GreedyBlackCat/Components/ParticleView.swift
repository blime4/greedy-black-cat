import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var color: Color
    var size: CGFloat
    var life: Double
    let maxLife: Double

    var isDead: Bool {
        life >= maxLife
    }
}

struct ParticleSystemView: View {
    let particles: [Particle]
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color.opacity(1 - particle.life / particle.maxLife))
                    .frame(width: particle.size * cellSize, height: particle.size * cellSize)
                    .position(particle.position)
            }
        }
    }
}
