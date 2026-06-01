import SwiftUI

enum ClubTheme {
    static let deepNavy = Color(red: 0.039, green: 0.086, blue: 0.200)
    static let graphite = Color(red: 0.030, green: 0.047, blue: 0.071)
    static let ink = Color(red: 0.009, green: 0.017, blue: 0.031)
    static let card = Color(red: 0.055, green: 0.102, blue: 0.173)
    static let cardRaised = Color(red: 0.071, green: 0.135, blue: 0.235)
    static let electricBlue = Color(red: 0.000, green: 0.600, blue: 1.000)
    static let brightBlue = Color(red: 0.000, green: 0.718, blue: 1.000)
    static let frenchRed = Color(red: 0.886, green: 0.239, blue: 0.239)
    static let white = Color.white
    static let lightGray = Color(red: 0.906, green: 0.929, blue: 0.961)
    static let muted = Color(red: 0.600, green: 0.682, blue: 0.784)
    static let stroke = Color.white.opacity(0.10)
}

extension LinearGradient {
    static var clubCard: LinearGradient {
        LinearGradient(
            colors: [
                ClubTheme.cardRaised.opacity(0.98),
                ClubTheme.card.opacity(0.98),
                ClubTheme.deepNavy.opacity(0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [ClubTheme.ink, ClubTheme.graphite, ClubTheme.deepNavy.opacity(0.96)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension View {
    func clubCard(radius: CGFloat = 18) -> some View {
        self
            .background(LinearGradient.clubCard)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(ClubTheme.stroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.24), radius: 18, x: 0, y: 12)
    }

    func glassPanel(radius: CGFloat = 18) -> some View {
        self
            .background(ClubTheme.card.opacity(0.74))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(ClubTheme.stroke, lineWidth: 1)
            )
    }
}
