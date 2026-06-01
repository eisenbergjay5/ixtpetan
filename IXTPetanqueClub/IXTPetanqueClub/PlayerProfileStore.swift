import Foundation

enum PlayerProfileDefaults {
    static let name = "Pierre Martin"
    static let nickname = "Pierre"
    static let city = "Lyon"
    static let club = "Club de Lyon"
    static let favoriteFormat = "2 vs 2"
    static let handedness = "Right"
    static let bio = "Local pétanque player"

    static func initials(name: String, nickname: String) -> String {
        let source = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nickname : name
        let initials = source
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map { String($0).uppercased() }
            .joined()
        return initials.isEmpty ? "IX" : initials
    }
}
