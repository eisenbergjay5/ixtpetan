import SwiftUI

struct MoreView: View {
    @Binding var destination: MoreDestination

    var body: some View {
        Group {
            switch destination {
            case .menu:
                menu
            case .measure:
                detail {
                    MeasureARView()
                }
            case .profile:
                detail {
                    ProfileView()
                }
            case .settings:
                detail {
                    SettingsView()
                }
            case .guide:
                detail {
                    GuideView()
                }
            }
        }
    }

    private var menu: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HeaderBar(title: "More", subtitle: "AR, profile, settings and guide", trailingIcon: "ellipsis.circle.fill")

                VStack(spacing: 12) {
                    moreRow(.measure, title: "AR Measure", subtitle: "Camera distance comparison")
                    moreRow(.profile, title: "Profile", subtitle: "Stats, history and badges")
                    moreRow(.settings, title: "Settings", subtitle: "Club preferences and app options")
                    moreRow(.guide, title: "Guide", subtitle: "Rules, history and official news")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
    }

    private func detail<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    destination = .menu
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .black))
                        Text("More")
                            .font(.system(size: 14, weight: .black))
                    }
                    .foregroundStyle(ClubTheme.lightGray)
                    .padding(.horizontal, 14)
                    .frame(height: 38)
                    .background(ClubTheme.ink.opacity(0.86))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(ClubTheme.stroke))
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 2)

            content()
        }
    }

    private func moreRow(_ destination: MoreDestination, title: String, subtitle: String) -> some View {
        Button {
            self.destination = destination
        } label: {
            HStack(spacing: 14) {
                Image(systemName: destination.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(ClubTheme.electricBlue)
                    .frame(width: 48, height: 48)
                    .background(ClubTheme.electricBlue.opacity(0.13))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 16, weight: .black))
                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(ClubTheme.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(ClubTheme.muted)
            }
            .padding(16)
            .clubCard(radius: 18)
        }
        .buttonStyle(.plain)
    }
}
