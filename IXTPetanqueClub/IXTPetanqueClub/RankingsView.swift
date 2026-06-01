import SwiftUI

struct RankingsView: View {
    @Binding var selectedTab: MainTab
    @State private var scope = "Local"
    private let scopes = ["Local", "City", "Region", "Friends"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HeaderBar(title: "Rankings", subtitle: "Club, city, region and friends")

                Picker("", selection: $scope) {
                    ForEach(scopes, id: \.self) { scope in
                        Text(LocalizedStringKey(scope)).tag(scope)
                    }
                }
                .pickerStyle(.segmented)

                VStack(spacing: 10) {
                    ForEach(Array(rankedPlayers.enumerated()), id: \.element.id) { index, player in
                        RankingCard(rank: index + 1, player: player, highlighted: player.name == "Pierre Martin")
                    }
                }

                seasonSnapshot
                clubBoard
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
    }

    private var rankedPlayers: [Player] {
        switch scope {
        case "Local":
            return SampleData.players
                .filter { $0.club == "Club de Lyon" }
                .sorted { $0.rating > $1.rating }
        case "City":
            return SampleData.players
                .filter { ["Club de Lyon", "Petanque Passion"].contains($0.club) }
                .sorted {
                    if $0.winRate == $1.winRate { return $0.rating > $1.rating }
                    return $0.winRate > $1.winRate
                }
        case "Region":
            return SampleData.players
                .sorted {
                    let firstScore = $0.rating + ($0.winRate * 4)
                    let secondScore = $1.rating + ($1.winRate * 4)
                    return firstScore > secondScore
                }
        case "Friends":
            return SampleData.players
                .filter { ["Pierre Martin", "Lucas Bernard", "Sophie Garnier", "Thomas Durand", "Julien Moreau"].contains($0.name) }
                .sorted { $0.rating > $1.rating }
        default:
            return SampleData.players.sorted { $0.rating > $1.rating }
        }
    }

    private var clubBoard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Club Board", action: "All clubs") {
                selectedTab = .clubs
            }
            ForEach(SampleData.clubs) { club in
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundStyle(ClubTheme.electricBlue)
                        VStack(alignment: .leading) {
                            Text(club.name)
                                .font(.system(size: 16, weight: .bold))
                            Text("\(club.members) members · \(club.matchesToday) matches today")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(ClubTheme.muted)
                        }
                        Spacer()
                        Text("#\(club.cityRank)")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(ClubTheme.electricBlue)
                    }
                    Text("Next: \(club.nextEvent)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(ClubTheme.lightGray)
                }
                .padding(16)
                .clubCard()
            }
        }
    }

    private var seasonSnapshot: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Rating System")
            HStack(spacing: 10) {
                MetricPill(value: "ELO", label: "club rating")
                MetricPill(value: "Top 100", label: "leaderboard")
                MetricPill(value: "+18", label: "last win")
            }
            Text("Ratings update after every saved local match and weight close wins, opponent strength and tournament games.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ClubTheme.muted)
        }
        .padding(16)
        .glassPanel()
    }
}

struct RankingCard: View {
    let rank: Int
    let player: Player
    let highlighted: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.system(size: 15, weight: .black))
                .frame(width: 40, alignment: .leading)
                .foregroundStyle(highlighted ? ClubTheme.electricBlue : ClubTheme.muted)
            PlayerAvatar(player: player, size: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text(player.name)
                    .font(.system(size: 15, weight: .bold))
                Text(player.club)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ClubTheme.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("Rating \(player.rating)")
                    .font(.system(size: 13, weight: .bold))
                Text("Win Rate \(player.winRate)%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ClubTheme.muted)
            }
        }
        .padding(14)
        .background(highlighted ? ClubTheme.electricBlue.opacity(0.16) : ClubTheme.card.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(highlighted ? ClubTheme.electricBlue.opacity(0.45) : ClubTheme.stroke))
    }
}
