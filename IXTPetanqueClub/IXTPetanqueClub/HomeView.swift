import SwiftUI
import UIKit
import UserNotifications

struct HomeView: View {
    @Binding var selectedTab: MainTab
    @Binding var moreDestination: MoreDestination
    @AppStorage("playerName") private var playerName = PlayerProfileDefaults.name
    @AppStorage("playerNickname") private var playerNickname = PlayerProfileDefaults.nickname
    @AppStorage("playerClub") private var playerClub = PlayerProfileDefaults.club
    @State private var showingTournament = false
    @State private var showingShare = false
    @State private var showingNotifications = false
    @State private var shareItems: [Any] = []
    @State private var alertMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HeaderBar(title: "Bonjour, \(displayName)", subtitle: "The modern home of French pétanque.", trailingIcon: "bell") {
                    showingNotifications = true
                }

                heroCard

                activityStrip

                VStack(spacing: 12) {
                    SectionTitle(title: "Nearby Players", action: "Invite") {
                        shareInvite("Join my pétanque match at \(playerClub) today. IXT Pétanque Club: local games, clubs and rankings.")
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(SampleData.players.prefix(7)) { player in
                                Button {
                                    selectedTab = .match
                                } label: {
                                    nearbyPlayer(player)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                VStack(spacing: 12) {
                    SectionTitle(title: "Today's Tournaments", action: "Create") {
                        showingTournament = true
                    }
                    ForEach(SampleData.tournaments.prefix(3)) { tournament in
                        Button {
                            showingTournament = true
                        } label: {
                            tournamentRow(tournament)
                        }
                        .buttonStyle(.plain)
                    }
                }

                featureLauncher

                VStack(spacing: 12) {
                    SectionTitle(title: "Club Board", action: "Open") {
                        selectedTab = .clubs
                    }
                    clubBoardCard
                }

                VStack(spacing: 12) {
                    SectionTitle(title: "Event Calendar")
                    ForEach(SampleData.events.prefix(3)) { event in
                        Button {
                            selectedTab = .clubs
                        } label: {
                            eventRow(event)
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: 12) {
                    SectionTitle(title: "Club Rankings", action: "Open") {
                        selectedTab = .rankings
                    }
                    ForEach(Array(SampleData.players.prefix(3).enumerated()), id: \.element.id) { index, player in
                        RankingMiniRow(rank: index + 1, player: player)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .sheet(isPresented: $showingTournament) {
            ClubScreen {
                ScrollView(showsIndicators: false) {
                    TournamentView()
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 26)
                }
            }
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(items: shareItems)
        }
        .sheet(isPresented: $showingNotifications) {
            ClubScreen {
                NotificationCenterView()
                    .padding(20)
            }
        }
        .alert("IXT Pétanque", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func shareInvite(_ text: String) {
        shareItems = [text]
        showingShare = true
    }

    private var displayName: String {
        let nickname = playerNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        if !nickname.isEmpty { return nickname }
        let first = playerName.split(separator: " ").first.map(String.init)
        return first ?? PlayerProfileDefaults.nickname
    }

    private var clubBoardCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(playerClub)
                        .font(.system(size: 19, weight: .black))
                    Text("42 members · 5 matches today")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ClubTheme.muted)
                }
                Spacer()
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(ClubTheme.electricBlue)
            }
            HStack(spacing: 10) {
                MetricPill(value: "#2", label: "city rank")
                MetricPill(value: "87", label: "weekly points")
                MetricPill(value: "68%", label: "club win rate")
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent matches")
                    .font(.system(size: 14, weight: .bold))
                ForEach(SampleData.matchHistory.prefix(2)) { match in
                    HStack {
                        Text(match.title)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                        Spacer()
                        Text(match.score)
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(ClubTheme.electricBlue)
                    }
                }
            }
            .padding(12)
            .background(ClubTheme.graphite.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(18)
        .clubCard()
    }

    private func eventRow(_ event: ClubEvent) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "calendar")
                .foregroundStyle(ClubTheme.electricBlue)
                .frame(width: 40, height: 40)
                .background(ClubTheme.electricBlue.opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.system(size: 15, weight: .bold))
                Text("\(event.date) · \(event.place)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ClubTheme.muted)
            }
            Spacer()
            Text(event.players)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ClubTheme.lightGray)
        }
        .padding(14)
        .glassPanel(radius: 16)
    }

    private var heroCard: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(ClubTheme.electricBlue.opacity(0.12))
                        .frame(width: 132, height: 132)
                    Ball(color: .gray, size: 78)
                        .offset(x: 12, y: -14)
                    Ball(color: ClubTheme.electricBlue, size: 26)
                        .offset(x: -38, y: 32)
                    Circle()
                        .fill(Color(red: 0.72, green: 0.55, blue: 0.35))
                        .frame(width: 24, height: 24)
                        .offset(x: -8, y: 42)
                }
                .frame(width: 142, height: 148)
                .offset(x: 6, y: -10)
            }

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    BrandLockup()
                    Text(playerClub)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(ClubTheme.lightGray)
                    HStack(spacing: 8) {
                        Label("12 active", systemImage: "person.2.fill")
                        Label("5 matches", systemImage: "scope")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(ClubTheme.muted)
                }

                HStack(spacing: 10) {
                    Button {
                        selectedTab = .match
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("START MATCH")
                        }
                        .font(.system(size: 14, weight: .black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(ClubTheme.electricBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        openMore(.measure)
                    } label: {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 52, height: 50)
                            .background(ClubTheme.ink.opacity(0.36))
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(ClubTheme.stroke))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .clubCard(radius: 22)
    }

    private var activityStrip: some View {
        HStack(spacing: 10) {
            MiniStatCard(value: "8", label: "matches today")
            MiniStatCard(value: "3", label: "clubs active")
            MiniStatCard(value: "21", label: "online now")
        }
    }

    private func nearbyPlayer(_ player: Player) -> some View {
        VStack(spacing: 8) {
            PlayerAvatar(player: player, size: 46)
            Text(player.name.components(separatedBy: " ").first ?? player.name)
                .font(.system(size: 12, weight: .bold))
                .lineLimit(1)
            Text("\(player.rating)")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(ClubTheme.electricBlue)
        }
        .frame(width: 82)
        .padding(.vertical, 12)
        .background(ClubTheme.card.opacity(0.58))
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(ClubTheme.stroke, lineWidth: 1))
    }

    private var featureLauncher: some View {
        VStack(spacing: 12) {
            SectionTitle(title: "Club Tools")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                featureCard(
                    title: "Tournament",
                    subtitle: "Builder",
                    icon: "trophy.fill",
                    tint: ClubTheme.electricBlue
                ) {
                    showingTournament = true
                }
                featureCard(
                    title: "Guide",
                    subtitle: "Rules & news",
                    icon: "book.closed.fill",
                    tint: ClubTheme.lightGray
                ) {
                    openMore(.guide)
                }
                featureCard(
                    title: "Measure",
                    subtitle: "AR",
                    icon: "camera.viewfinder",
                    tint: ClubTheme.frenchRed
                ) {
                    openMore(.measure)
                }
            }
        }
    }

    private func openMore(_ destination: MoreDestination) {
        moreDestination = destination
        selectedTab = .more
    }

    private func featureCard(title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.14))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .black))
                    Text(subtitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(ClubTheme.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glassPanel(radius: 18)
        }
        .buttonStyle(.plain)
    }

    private func tournamentRow(_ tournament: Tournament) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy")
                .foregroundStyle(ClubTheme.electricBlue)
                .frame(width: 38, height: 38)
                .background(ClubTheme.electricBlue.opacity(0.10))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(tournament.name)
                    .font(.system(size: 15, weight: .bold))
                Text("\(tournament.city) · \(tournament.startsIn)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ClubTheme.muted)
            }
            Spacer()
            Text(tournament.capacity)
                .font(.system(size: 14, weight: .bold))
        }
        .padding(14)
        .glassPanel(radius: 16)
    }
}

struct RankingMiniRow: View {
    let rank: Int
    let player: Player

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ClubTheme.muted)
                .frame(width: 32, alignment: .leading)
            PlayerAvatar(player: player, size: 38)
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 14, weight: .bold))
                Text(player.club)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ClubTheme.muted)
            }
            Spacer()
            Text("\(player.rating)")
                .font(.system(size: 14, weight: .bold))
        }
        .padding(14)
        .glassPanel(radius: 16)
    }
}

private struct NotificationCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("pushNotificationsEnabled") private var pushNotificationsEnabled = false
    @State private var permissionStatus = "Checking"

    private let notifications = [
        ("Weekend Cup", "Bracket closes today at 20:00.", "trophy.fill"),
        ("Club de Lyon", "Court 2 is free after 18:30.", "figure.petanque"),
        ("Weather", "Light wind expected for tonight's games.", "cloud.sun.fill"),
        ("Ranking", "Pierre moved to local rank #12.", "chart.line.uptrend.xyaxis")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notifications")
                            .font(.system(size: 28, weight: .black))
                        Text("Club updates and match alerts")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(ClubTheme.muted)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .black))
                            .frame(width: 42, height: 42)
                            .background(ClubTheme.card)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                pushControlCard

                ForEach(notifications, id: \.0) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.2)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(ClubTheme.electricBlue)
                            .frame(width: 42, height: 42)
                            .background(ClubTheme.electricBlue.opacity(0.12))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.0)
                                .font(.system(size: 15, weight: .black))
                            Text(item.1)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(ClubTheme.muted)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .glassPanel(radius: 16)
                }
            }
        }
        .onAppear(perform: refreshPushState)
    }

    private var pushControlCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Push Notifications")

            HStack(spacing: 10) {
                MetricPill(value: permissionStatus, label: "permission")
                MetricPill(value: pushNotificationsEnabled ? "On" : "Off", label: "in app")
            }

            HStack(spacing: 10) {
                Button {
                    togglePushNotifications()
                } label: {
                    Label(
                        LocalizedStringKey(pushNotificationsEnabled ? "Disable Push" : "Enable Push"),
                        systemImage: pushNotificationsEnabled ? "bell.slash.fill" : "bell.badge.fill"
                    )
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                }
                .buttonStyle(.borderedProminent)
                .tint(pushNotificationsEnabled ? ClubTheme.frenchRed : ClubTheme.electricBlue)

                Button {
                    refreshPushState()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 50, height: 46)
                }
                .buttonStyle(.bordered)
                .tint(ClubTheme.electricBlue)
            }

            Button {
                openSystemSettings()
            } label: {
                Label(LocalizedStringKey("Open iOS Settings"), systemImage: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .bold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(ClubTheme.electricBlue)

            Text("You can turn club reminders and match alerts on or off for this app. System permission is managed in iOS Settings.")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ClubTheme.muted)
        }
        .padding(16)
        .clubCard()
    }

    private func togglePushNotifications() {
        if pushNotificationsEnabled {
            PushNotificationService.shared.disablePushNotifications()
            refreshPushState()
        } else {
            PushNotificationService.shared.requestAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: refreshPushState)
        }
    }

    private func refreshPushState() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .authorized:
                status = "Allowed"
            case .denied:
                status = "Denied"
            case .notDetermined:
                status = "Not asked"
            case .provisional:
                status = "Provisional"
            case .ephemeral:
                status = "Ephemeral"
            @unknown default:
                status = "Unknown"
            }

            DispatchQueue.main.async {
                permissionStatus = status
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
