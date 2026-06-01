import SwiftUI

struct ProfileView: View {
    @AppStorage("playerName") private var playerName = PlayerProfileDefaults.name
    @AppStorage("playerNickname") private var playerNickname = PlayerProfileDefaults.nickname
    @AppStorage("playerCity") private var playerCity = PlayerProfileDefaults.city
    @AppStorage("playerClub") private var playerClub = PlayerProfileDefaults.club
    @AppStorage("playerFavoriteFormat") private var favoriteFormat = PlayerProfileDefaults.favoriteFormat
    @AppStorage("playerHandedness") private var handedness = PlayerProfileDefaults.handedness
    @AppStorage("playerBio") private var bio = PlayerProfileDefaults.bio
    @State private var showingAllHistory = false
    @State private var showingEditor = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                profileHeader
                statsGrid
                analytics
                matchHistory
                badges
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .sheet(isPresented: $showingAllHistory) {
            ClubScreen {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        HeaderBar(title: "Match History", subtitle: "All saved games", trailingIcon: "clock.fill")
                        ForEach(SampleData.matchHistory) { match in
                            historyRow(match)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            ClubScreen {
                ScrollView(showsIndicators: false) {
                    ProfileEditorView()
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(ClubTheme.electricBlue.opacity(0.16))
                    .frame(width: 112, height: 112)
                Text(initials)
                    .font(.system(size: 30, weight: .black))
                    .frame(width: 92, height: 92)
                    .background(ClubTheme.electricBlue.gradient)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
            }
            Text(displayName)
                .font(.system(size: 25, weight: .black))
            Text("\(playerClub) · \(playerCity)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ClubTheme.electricBlue)
            if !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(bio)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ClubTheme.muted)
                    .multilineTextAlignment(.center)
            }
            HStack(spacing: 8) {
                Label("1540", systemImage: "star.fill")
                Text("Local rank #12")
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(ClubTheme.lightGray)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .clubCard(radius: 20)
        .overlay(alignment: .topTrailing) {
            Button {
                showingEditor = true
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(ClubTheme.electricBlue)
                    .frame(width: 42, height: 42)
                    .background(ClubTheme.card.opacity(0.72))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Statistics")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statTile("128", "Games Played")
                statTile("87", "Wins")
                statTile("41", "Losses")
                statTile("68%", "Win Rate")
                statTile("8.7", "Average Points")
                statTile("10", "Longest Streak")
            }
        }
    }

    private func statTile(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(ClubTheme.electricBlue)
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ClubTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassPanel(radius: 16)
    }

    private var analytics: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Performance Analytics")
            HStack(alignment: .bottom, spacing: 8) {
                ForEach([0.25, 0.42, 0.38, 0.55, 0.48, 0.72, 0.64, 0.82, 0.76, 0.92], id: \.self) { value in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(ClubTheme.electricBlue)
                        .frame(height: 90 * value)
                }
            }
            .frame(height: 105, alignment: .bottom)
            HStack {
                MetricPill(value: "Lucas", label: "favorite partner")
                MetricPill(value: favoriteFormat.replacingOccurrences(of: " vs ", with: "v"), label: "favorite format")
                MetricPill(value: handedness, label: "preferred hand")
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(SampleData.analytics) { metric in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metric.title)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(ClubTheme.muted)
                        Text(metric.value)
                            .font(.system(size: 18, weight: .black))
                        Text(metric.detail)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(ClubTheme.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(ClubTheme.graphite.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .padding(18)
        .clubCard()
    }

    private var matchHistory: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Match History", action: "All") {
                showingAllHistory = true
            }
            ForEach(SampleData.matchHistory) { match in
                historyRow(match)
            }
        }
    }

    private func historyRow(_ match: MatchRecord) -> some View {
        HStack(spacing: 12) {
            Text(match.result == "Win" ? "W" : "L")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(match.result == "Win" ? ClubTheme.electricBlue : ClubTheme.frenchRed)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(match.title)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                Text("\(match.place) · \(match.duration)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ClubTheme.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(match.score)
                    .font(.system(size: 14, weight: .black))
                Text(match.ratingChange)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(match.result == "Win" ? ClubTheme.electricBlue : ClubTheme.frenchRed)
            }
        }
        .padding(14)
        .glassPanel(radius: 16)
    }

    private var badges: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Badges")
            HStack(spacing: 12) {
                badge("trophy.fill", "Club Champion", .yellow)
                badge("scope", "Precision Master", ClubTheme.electricBlue)
                badge("flame.fill", "10 Wins Streak", ClubTheme.frenchRed)
            }
        }
    }

    private func badge(_ icon: String, _ title: String, _ color: Color) -> some View {
        VStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 56, height: 56)
                .background(color.opacity(0.16))
                .clipShape(Circle())
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(height: 30)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .glassPanel(radius: 16)
    }

    private var displayName: String {
        let name = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty { return name }
        let nickname = playerNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return nickname.isEmpty ? PlayerProfileDefaults.name : nickname
    }

    private var initials: String {
        PlayerProfileDefaults.initials(name: playerName, nickname: playerNickname)
    }
}
