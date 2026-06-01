import SwiftUI

enum MatchStage {
    case setup
    case scoring
    case result
}

struct MatchView: View {
    @State private var mode = "2 vs 2"
    @State private var stage: MatchStage = .setup
    @State private var blueScore = 0
    @State private var redScore = 0
    @State private var lastScoringTeam = "Blue"
    @State private var scoreHistory: [(blue: Int, red: Int)] = []
    @State private var pointLog: [String] = []
    @State private var bluePlayers: [Player] = Array(SampleData.players.prefix(2))
    @State private var redPlayers: [Player] = Array(SampleData.players.dropFirst(2).prefix(2))
    @State private var matchSaved = false
    @State private var alertMessage: String?

    private let modes = ["1 vs 1", "2 vs 2", "3 vs 3"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HeaderBar(
                    title: stageTitle,
                    subtitle: "Local match · first to 13",
                    trailingIcon: "arrow.counterclockwise",
                    trailingAction: resetCurrentStage
                )

                switch stage {
                case .setup:
                    setupView
                case .scoring:
                    scoringView
                case .result:
                    resultView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .alert("Match", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
        .onChange(of: mode) { _ in
            bluePlayers = Array(bluePlayers.prefix(playersPerTeam))
            redPlayers = Array(redPlayers.prefix(playersPerTeam))
        }
    }

    private var stageTitle: String {
        switch stage {
        case .setup: "Quick Match"
        case .scoring: "Match Score"
        case .result: "Match Result"
        }
    }

    private var setupView: some View {
        VStack(alignment: .leading, spacing: 22) {
            matchContextCard

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Choose Format")
                HStack(spacing: 10) {
                    ForEach(modes, id: \.self) { item in
                        Button {
                            mode = item
                        } label: {
                            Text(item)
                                .font(.system(size: 14, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(mode == item ? ClubTheme.electricBlue : ClubTheme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(ClubTheme.stroke))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            teamSelector(title: "Team Bleu", players: bluePlayers, tint: ClubTheme.electricBlue)
            teamSelector(title: "Team Rouge", players: redPlayers, tint: ClubTheme.frenchRed)

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Available Players")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(SampleData.players.dropFirst(4).prefix(6)) { player in
                        Button {
                            addAvailablePlayer(player)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                PlayerAvatar(player: player, size: 38)
                                Text(player.name)
                                    .font(.system(size: 12, weight: .bold))
                                    .lineLimit(1)
                                Text(assignmentLabel(for: player))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(isSelected(player) ? ClubTheme.electricBlue : ClubTheme.muted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .glassPanel(radius: 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            PrimaryButton(title: "Start Match", icon: "scope") {
                startMatch()
            }
        }
    }

    private var matchContextCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Club de Lyon")
                        .font(.system(size: 18, weight: .black))
                    Text("Terrain 2 · rated local game")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ClubTheme.muted)
                }
                Spacer()
                Text("to 13")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(ClubTheme.electricBlue)
            }
            HStack(spacing: 10) {
                MetricPill(value: "+18", label: "win estimate")
                MetricPill(value: "42m", label: "avg duration")
                MetricPill(value: "2v2", label: "club favorite")
            }
        }
        .padding(16)
        .clubCard()
    }

    private func teamSelector(title: String, players: [Player], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
            ForEach(players) { player in
                HStack(spacing: 12) {
                    PlayerAvatar(player: player, size: 42)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
                            .font(.system(size: 14, weight: .bold))
                        Text("Rating \(player.rating)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(ClubTheme.muted)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(tint)
                }
            }
            Button {
                addNextPlayer(to: title)
            } label: {
                Label("Add player", systemImage: "plus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ClubTheme.muted)
            }
        }
        .padding(16)
        .glassPanel()
    }

    private var scoringView: some View {
        VStack(spacing: 22) {
            HStack(alignment: .center) {
                scoreColumn(team: "Team Bleu", score: blueScore, tint: ClubTheme.electricBlue)
                Text("vs")
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(ClubTheme.lightGray)
                    .frame(width: 48)
                scoreColumn(team: "Team Rouge", score: redScore, tint: ClubTheme.frenchRed)
            }
            .padding(22)
            .clubCard(radius: 20)

            VStack(spacing: 16) {
                HStack {
                    Text("Point winner")
                        .foregroundStyle(ClubTheme.muted)
                    Spacer()
                    Picker("", selection: $lastScoringTeam) {
                        Text("Blue").tag("Blue")
                        Text("Red").tag("Red")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(1...6, id: \.self) { value in
                        Button {
                            add(points: value)
                        } label: {
                            Text("+\(value)")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(ClubTheme.cardRaised)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(ClubTheme.stroke))
                                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .glassPanel()

            progressView

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Point Log")
                if pointLog.isEmpty {
                    Text("No points yet. Add the first mène with the buttons above.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ClubTheme.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(ClubTheme.card.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    ForEach(pointLog.prefix(5), id: \.self) { item in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(item.contains("Bleu") ? ClubTheme.electricBlue : ClubTheme.frenchRed)
                            Text(item)
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                        }
                        .padding(12)
                        .background(ClubTheme.card.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding(16)
            .glassPanel()

            Button {
                undoLastPoint()
            } label: {
                Text("Undo last point")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(ClubTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func scoreColumn(team: String, score: Int, tint: Color) -> some View {
        VStack(spacing: 8) {
            Text(team)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)
            Text("\(score)")
                .font(.system(size: 64, weight: .black))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity)
    }

    private var progressView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Progress to 13")
                .font(.system(size: 15, weight: .bold))
            progressRow(score: blueScore, tint: ClubTheme.electricBlue)
            progressRow(score: redScore, tint: ClubTheme.frenchRed)
        }
        .padding(16)
        .glassPanel()
    }

    private func progressRow(score: Int, tint: Color) -> some View {
        HStack(spacing: 6) {
            Text("\(score)")
                .font(.system(size: 13, weight: .bold))
                .frame(width: 24, alignment: .leading)
            ForEach(1...13, id: \.self) { point in
                Circle()
                    .fill(point <= score ? tint : ClubTheme.lightGray.opacity(0.18))
                    .frame(width: 10, height: 10)
            }
        }
    }

    private var resultView: some View {
        VStack(spacing: 18) {
            VStack(spacing: 10) {
                Text("Winner")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ClubTheme.muted)
                Text(blueScore >= redScore ? "Team Bleu" : "Team Rouge")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(blueScore >= redScore ? ClubTheme.electricBlue : ClubTheme.frenchRed)
                Text("\(blueScore) : \(redScore)")
                    .font(.system(size: 42, weight: .black))
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .clubCard(radius: 20)

            VStack(spacing: 0) {
                resultMetric("Duration", "42 min")
                resultMetric("Points scored", "\(max(blueScore, redScore))")
                resultMetric("Longest streak", "6")
                resultMetric("Winning percentage", "72%")
                resultMetric("Rating update", blueScore >= redScore ? "+18 ELO" : "-9 ELO")
                resultMetric("Saved to", "Club de Lyon history")
            }
            .glassPanel()

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Unlocked Badges")
                HStack(spacing: 10) {
                    resultBadge("scope", "Precision")
                    resultBadge("flame.fill", "Streak")
                    resultBadge("star.fill", "Rated Win")
                }
            }
            .padding(16)
            .glassPanel()

            PrimaryButton(title: "Save to History", icon: "tray.and.arrow.down.fill") {
                matchSaved = true
            }
            if matchSaved {
                Label("Saved to local match history", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(ClubTheme.electricBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(ClubTheme.electricBlue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            Button("New Match") {
                resetMatch()
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(ClubTheme.electricBlue)
        }
    }

    private func resultMetric(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(ClubTheme.muted)
            Spacer()
            Text(value)
                .fontWeight(.bold)
        }
        .font(.system(size: 14))
        .padding(16)
        .overlay(Rectangle().fill(ClubTheme.stroke).frame(height: 1), alignment: .bottom)
    }

    private func resultBadge(_ icon: String, _ title: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(ClubTheme.electricBlue)
            Text(title)
                .font(.system(size: 11, weight: .black))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(ClubTheme.graphite.opacity(0.34))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private func add(points: Int) {
        scoreHistory.append((blueScore, redScore))
        if lastScoringTeam == "Blue" {
            blueScore = min(13, blueScore + points)
            pointLog.insert("Mene \(pointLog.count + 1) · Bleu +\(points)", at: 0)
        } else {
            redScore = min(13, redScore + points)
            pointLog.insert("Mene \(pointLog.count + 1) · Rouge +\(points)", at: 0)
        }
        if blueScore >= 13 || redScore >= 13 {
            stage = .result
        }
    }

    private func undoLastPoint() {
        guard let previous = scoreHistory.popLast() else {
            alertMessage = "No point to undo."
            return
        }
        blueScore = previous.blue
        redScore = previous.red
        if !pointLog.isEmpty {
            pointLog.removeFirst()
        }
        stage = .scoring
    }

    private func resetMatch() {
        blueScore = 0
        redScore = 0
        scoreHistory.removeAll()
        pointLog.removeAll()
        matchSaved = false
        stage = .setup
    }

    private func resetCurrentStage() {
        switch stage {
        case .setup:
            resetMatch()
        case .scoring, .result:
            startMatch()
        }
    }

    private var playersPerTeam: Int {
        Int(mode.prefix(1)) ?? 2
    }

    private func startMatch() {
        guard bluePlayers.count == playersPerTeam, redPlayers.count == playersPerTeam else {
            alertMessage = "Select \(playersPerTeam) player(s) per team for \(mode)."
            return
        }
        blueScore = 0
        redScore = 0
        scoreHistory.removeAll()
        pointLog.removeAll()
        matchSaved = false
        stage = .scoring
    }

    private func isSelected(_ player: Player) -> Bool {
        bluePlayers.contains(player) || redPlayers.contains(player)
    }

    private func assignmentLabel(for player: Player) -> String {
        if bluePlayers.contains(player) { return "Team Bleu · \(player.rating)" }
        if redPlayers.contains(player) { return "Team Rouge · \(player.rating)" }
        return "Tap to add · \(player.rating)"
    }

    private func addAvailablePlayer(_ player: Player) {
        if bluePlayers.contains(player) {
            bluePlayers.removeAll { $0 == player }
            return
        }
        if redPlayers.contains(player) {
            redPlayers.removeAll { $0 == player }
            return
        }
        if bluePlayers.count < playersPerTeam {
            bluePlayers.append(player)
        } else if redPlayers.count < playersPerTeam {
            redPlayers.append(player)
        } else {
            alertMessage = "Both teams are full for \(mode). Remove a player before adding another."
        }
    }

    private func addNextPlayer(to teamTitle: String) {
        guard let player = SampleData.players.first(where: { !bluePlayers.contains($0) && !redPlayers.contains($0) }) else {
            alertMessage = "No available players left."
            return
        }
        if teamTitle.contains("Bleu"), bluePlayers.count < playersPerTeam {
            bluePlayers.append(player)
        } else if teamTitle.contains("Rouge"), redPlayers.count < playersPerTeam {
            redPlayers.append(player)
        } else {
            alertMessage = "\(teamTitle) already has \(playersPerTeam) player(s) for \(mode)."
        }
    }
}
