import SwiftUI

struct TournamentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var size = "8 players"
    @State private var type = "Single Elimination"
    @State private var ratingMode = true
    @State private var tournamentName = "Weekend Cup"
    @State private var invitedPlayers = Set<UUID>()
    @State private var showingShare = false
    @State private var shareItems: [Any] = []
    @State private var alertMessage: String?
    @State private var createdSummary: String?
    private let sizes = ["4 players", "8 players", "16 players"]
    private let types = ["Single Elimination", "Round Robin", "Swiss System"]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 12) {
                HeaderBar(title: "Create Tournament", subtitle: "Mini tournament builder", trailingIcon: "calendar.badge.plus")
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .black))
                        .frame(width: 42, height: 42)
                        .background(ClubTheme.card)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(ClubTheme.stroke))
                }
                .buttonStyle(.plain)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("Tournament name")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ClubTheme.muted)
                TextField(LocalizedStringKey("Weekend Cup"), text: $tournamentName)
                    .font(.system(size: 15, weight: .bold))
                    .padding(16)
                    .glassPanel(radius: 14)
            }
            segmented(title: "Format", values: sizes, selection: $size)
            segmented(title: "Type", values: types, selection: $type)
            tournamentOptions
            participants
            bracketPreview
            if let createdSummary {
                Text(createdSummary)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ClubTheme.lightGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(ClubTheme.electricBlue.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            PrimaryButton(title: "Create Tournament", icon: "trophy.fill") {
                createdSummary = "\(tournamentName) is ready: \(size), \(type), \(invitedPlayers.count) invited, \(ratingMode ? "rated" : "friendly")."
            }
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(items: shareItems)
        }
        .alert("Tournament", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func segmented(title: String, values: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
            Picker("", selection: selection) {
                ForEach(values, id: \.self) { value in
                    Text(LocalizedStringKey(value)).tag(value)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var bracketPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Automatic Bracket")
                .font(.system(size: 16, weight: .bold))
            HStack(alignment: .center, spacing: 12) {
                VStack(spacing: 8) {
                    ForEach(["Pierre & Lucas", "Thomas & Julien", "Jean & Marc", "Michel & Antoine"], id: \.self) { team in
                        bracketTeam(team)
                    }
                }
                Image(systemName: "chevron.right")
                    .foregroundStyle(ClubTheme.electricBlue)
                VStack(spacing: 18) {
                    bracketTeam("Semi-final A")
                    bracketTeam("Semi-final B")
                }
                Image(systemName: "chevron.right")
                    .foregroundStyle(ClubTheme.electricBlue)
                bracketTeam("Final")
            }
            Text("Bracket and rating impact are generated automatically for every tournament size.")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ClubTheme.muted)
        }
        .padding(16)
        .clubCard()
    }

    private var tournamentOptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $ratingMode) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Rated tournament")
                        .font(.system(size: 14, weight: .bold))
                    Text("Automatic ELO updates after every game")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(ClubTheme.muted)
                }
            }
            .tint(ClubTheme.electricBlue)
            HStack(spacing: 10) {
                MetricPill(value: "Free", label: "club entry")
                MetricPill(value: "13", label: "points per game")
                MetricPill(value: "4", label: "courts needed")
            }
        }
        .padding(16)
        .glassPanel()
    }

    private var participants: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Participants", action: "Invite") {
                invitedPlayers = Set(SampleData.players.prefix(6).map(\.id))
                shareItems = ["\(tournamentName) at Club de Lyon. \(size), \(type). Join the bracket in IXT Pétanque Club."]
                showingShare = true
            }
            ForEach(SampleData.players.prefix(6)) { player in
                Button {
                    if invitedPlayers.contains(player.id) {
                        invitedPlayers.remove(player.id)
                    } else {
                        invitedPlayers.insert(player.id)
                    }
                } label: {
                    HStack(spacing: 12) {
                        PlayerAvatar(player: player, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name)
                                .font(.system(size: 13, weight: .bold))
                            Text(player.club)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(ClubTheme.muted)
                        }
                        Spacer()
                        Text("\(player.rating)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(ClubTheme.electricBlue)
                        Image(systemName: invitedPlayers.contains(player.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(invitedPlayers.contains(player.id) ? ClubTheme.electricBlue : ClubTheme.muted)
                    }
                    .padding(12)
                    .glassPanel(radius: 14)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func bracketTeam(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(ClubTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
