import SwiftUI

enum MainTab: String, CaseIterable {
    case home = "Home"
    case match = "Match"
    case rankings = "Rank"
    case places = "Places"
    case clubs = "Clubs"
    case more = "More"

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .match: "scope"
        case .rankings: "trophy.fill"
        case .places: "mappin.and.ellipse"
        case .clubs: "person.3.fill"
        case .more: "ellipsis.circle.fill"
        }
    }
}

enum MoreDestination: String, CaseIterable {
    case menu = "More"
    case measure = "AR Measure"
    case profile = "Profile"
    case settings = "Settings"
    case guide = "Guide"

    var icon: String {
        switch self {
        case .menu: "ellipsis.circle.fill"
        case .measure: "camera.viewfinder"
        case .profile: "person.fill"
        case .settings: "gearshape.fill"
        case .guide: "book.closed.fill"
        }
    }
}

struct ClubScreen<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient.appBackground.ignoresSafeArea()
            RadialGradient(
                colors: [ClubTheme.electricBlue.opacity(0.22), .clear],
                center: UnitPoint(x: 0.82, y: 0.04),
                startRadius: 18,
                endRadius: 420
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [ClubTheme.frenchRed.opacity(0.08), .clear],
                center: UnitPoint(x: 0.02, y: 0.92),
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()
            content
        }
        .foregroundStyle(ClubTheme.white)
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(LocalizedStringKey(title))
                    .font(.system(size: 14, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [ClubTheme.brightBlue, ClubTheme.electricBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .foregroundStyle(.white)
            .shadow(color: ClubTheme.electricBlue.opacity(0.30), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

struct SectionTitle: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
                .font(.system(size: 18, weight: .bold))
            Spacer()
            if let action {
                Button {
                    onAction?()
                } label: {
                    Text(LocalizedStringKey(action))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ClubTheme.electricBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(ClubTheme.electricBlue.opacity(0.10))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(onAction == nil)
            }
        }
    }
}

struct PlayerAvatar: View {
    let player: Player
    var size: CGFloat = 42

    var body: some View {
        Text(player.avatar)
            .font(.system(size: size * 0.33, weight: .bold))
            .frame(width: size, height: size)
            .background(player.color.gradient)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
    }
}

struct MetricPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(ClubTheme.electricBlue)
            Text(LocalizedStringKey(label))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(ClubTheme.muted)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct BottomNav: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                            Text(LocalizedStringKey(tab.rawValue))
                            .font(.system(size: 10, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(selectedTab == tab ? ClubTheme.electricBlue : ClubTheme.muted)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedTab == tab ? ClubTheme.electricBlue.opacity(0.11) : .clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(ClubTheme.ink)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(ClubTheme.stroke, lineWidth: 1))
        .shadow(color: .black.opacity(0.38), radius: 22, x: 0, y: 12)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct HeaderBar: View {
    let title: String
    var subtitle: String? = nil
    var trailingIcon: String? = "bell"
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 28, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                if let subtitle {
                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ClubTheme.muted)
                        .lineLimit(2)
                }
            }
            Spacer()
            if let trailingIcon {
                Button {
                    trailingAction?()
                } label: {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 48, height: 48)
                        .glassPanel(radius: 14)
                }
                .buttonStyle(.plain)
                .disabled(trailingAction == nil)
                .opacity(trailingAction == nil ? 0.82 : 1)
            }
        }
    }
}

struct BrandLockup: View {
    var compact = false

    var body: some View {
        HStack(alignment: .center, spacing: compact ? 5 : 8) {
            HStack(spacing: compact ? 2 : 4) {
                Text("IX")
                    .foregroundStyle(.white)
                Text("T")
                    .foregroundStyle(ClubTheme.electricBlue)
            }
            .font(.system(size: compact ? 24 : 34, weight: .black))

            VStack(alignment: .leading, spacing: compact ? -1 : 1) {
                Text("PÉTANQUE")
                Text("CLUB")
            }
            .font(.system(size: compact ? 10 : 13, weight: .black))
            .foregroundStyle(.white)
            .lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: true)
    }
}

struct MiniStatCard: View {
    let value: String
    let label: String
    var tint: Color = ClubTheme.electricBlue

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(ClubTheme.muted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(ClubTheme.ink.opacity(0.32))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
