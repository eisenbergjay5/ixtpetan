import SwiftUI

struct ClubsView: View {
    @State private var selectedClub = SampleData.clubs[0]
    @State private var selectedSection = "Board"
    @State private var showingShare = false
    @State private var shareItems: [Any] = []
    @State private var showingResultForm = false
    @State private var showingEventForm = false
    @State private var showingNoticeForm = false
    @State private var matches = SampleData.matchHistory
    @State private var events = SampleData.events
    @State private var notices = SampleData.notices
    @State private var alertMessage: String?

    private let sections = ["Board", "Members", "Calendar", "Notices"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HeaderBar(title: "Clubs", subtitle: "Your local pétanque communities", trailingIcon: "person.3.fill")

                clubList

                Picker("", selection: $selectedSection) {
                    ForEach(sections, id: \.self) { section in
                        Text(LocalizedStringKey(section)).tag(section)
                    }
                }
                .pickerStyle(.segmented)

                selectedClubHeader

                switch selectedSection {
                case "Members":
                    members
                case "Calendar":
                    calendar
                case "Notices":
                    noticesView
                default:
                    board
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(items: shareItems)
        }
        .sheet(isPresented: $showingResultForm) {
            ClubScreen {
                ClubResultForm { record in
                    matches.insert(record, at: 0)
                    selectedSection = "Board"
                }
                .padding(20)
            }
        }
        .sheet(isPresented: $showingEventForm) {
            ClubScreen {
                ClubEventForm { event in
                    events.insert(event, at: 0)
                    selectedSection = "Calendar"
                }
                .padding(20)
            }
        }
        .sheet(isPresented: $showingNoticeForm) {
            ClubScreen {
                ClubNoticeForm { notice in
                    notices.insert(notice, at: 0)
                    selectedSection = "Notices"
                }
                .padding(20)
            }
        }
        .alert("Club", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var clubList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Club Directory", action: "Invite") {
                shareItems = ["Join \(selectedClub.name) on IXT Pétanque Club. Local matches, rankings, tournaments and club board."]
                showingShare = true
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SampleData.clubs) { club in
                        Button {
                            selectedClub = club
                            selectedSection = "Board"
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(selectedClub.id == club.id ? .white : ClubTheme.electricBlue)
                                Text(club.name)
                                    .font(.system(size: 15, weight: .black))
                                    .lineLimit(2)
                                Text("\(club.members) members")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(selectedClub.id == club.id ? .white.opacity(0.8) : ClubTheme.muted)
                            }
                            .frame(width: 150, alignment: .leading)
                            .padding(16)
                            .background(selectedClub.id == club.id ? ClubTheme.electricBlue : ClubTheme.card.opacity(0.82))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(ClubTheme.stroke))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var selectedClubHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedClub.name)
                        .font(.system(size: 22, weight: .black))
                    Text("\(selectedClub.city) · city rank #\(selectedClub.cityRank)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(ClubTheme.muted)
                }
                Spacer()
                Button {
                    shareItems = ["I’m inviting you to \(selectedClub.name). Next event: \(selectedClub.nextEvent)."]
                    showingShare = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .bold))
                        .frame(width: 46, height: 46)
                        .background(ClubTheme.electricBlue.opacity(0.14))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: 10) {
                MetricPill(value: "\(selectedClub.members)", label: "members")
                MetricPill(value: "\(selectedClub.matchesToday)", label: "matches today")
                MetricPill(value: "#\(selectedClub.cityRank)", label: "city rank")
            }
        }
        .padding(18)
        .clubCard()
    }

    private var board: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Recent Matches", action: "Add result") {
                showingResultForm = true
            }
            ForEach(matches) { match in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(match.title)
                            .font(.system(size: 14, weight: .bold))
                            .lineLimit(1)
                        Text("\(match.place) · \(match.duration) · \(match.ratingChange)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ClubTheme.muted)
                    }
                    Spacer()
                    Text(match.score)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(match.result == "Win" ? ClubTheme.electricBlue : ClubTheme.frenchRed)
                }
                .padding(14)
                .glassPanel(radius: 15)
            }
        }
    }

    private var members: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Members", action: "Invite") {
                shareItems = ["Come play at \(selectedClub.name) with Pierre, Lucas and the club crew."]
                showingShare = true
            }
            ForEach(SampleData.players.filter { selectedClub.name == "Club de Lyon" ? $0.club == "Club de Lyon" : true }.prefix(8)) { player in
                RankingCard(rank: memberRank(for: player), player: player, highlighted: player.name == "Pierre Martin")
            }
        }
    }

    private var calendar: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Calendar", action: "Create") {
                showingEventForm = true
            }
            ForEach(events) { event in
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundStyle(ClubTheme.electricBlue)
                        .frame(width: 42, height: 42)
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
                        .font(.system(size: 12, weight: .black))
                }
                .padding(14)
                .glassPanel(radius: 16)
            }
        }
    }

    private var noticesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Club Notices", action: "Add") {
                showingNoticeForm = true
            }
            ForEach(notices) { notice in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: notice.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ClubTheme.electricBlue)
                        .frame(width: 38, height: 38)
                        .background(ClubTheme.electricBlue.opacity(0.14))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(notice.title)
                                .font(.system(size: 13, weight: .black))
                            Text(notice.time)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(ClubTheme.muted)
                        }
                    Text(LocalizedStringKey(notice.detail))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(ClubTheme.lightGray)
                    }
                    Spacer()
                }
                .padding(14)
                .glassPanel(radius: 16)
            }
        }
    }

    private func memberRank(for player: Player) -> Int {
        let sorted = SampleData.players.sorted { $0.rating > $1.rating }
        return (sorted.firstIndex(of: player) ?? 0) + 1
    }
}

private struct ClubResultForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var opponent = "Thomas & Julien"
    @State private var blueScore = "13"
    @State private var redScore = "9"
    let onSave: (MatchRecord) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderBar(title: "Add Result", subtitle: "Save a club match", trailingIcon: "plus.circle.fill")
            formField("Opponent", text: $opponent)
            HStack(spacing: 12) {
                formField("Your score", text: $blueScore)
                formField("Opponent", text: $redScore)
            }
            PrimaryButton(title: "Save Result", icon: "tray.and.arrow.down.fill") {
                let blue = Int(blueScore) ?? 0
                let red = Int(redScore) ?? 0
                let didWin = blue > red
                let record = MatchRecord(
                    title: "Pierre & Lucas vs \(opponent)",
                    score: "\(blueScore) : \(redScore)",
                    place: "Club de Lyon",
                    duration: "New",
                    ratingChange: didWin ? "+12" : "-8",
                    result: didWin ? "Win" : "Loss"
                )
                onSave(record)
                dismiss()
            }
            Button("Cancel") { dismiss() }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ClubTheme.electricBlue)
        }
    }

    private func formField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ClubTheme.muted)
            TextField(LocalizedStringKey(title), text: text)
                .font(.system(size: 15, weight: .bold))
                .padding(14)
                .glassPanel(radius: 14)
        }
    }
}

private struct ClubEventForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = "Friday Doubles"
    @State private var date = "Tonight · 19:00"
    @State private var place = "Club de Lyon"
    let onSave: (ClubEvent) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderBar(title: "Create Event", subtitle: "Add it to the club calendar", trailingIcon: "calendar.badge.plus")
            formField("Title", text: $title)
            formField("Date", text: $date)
            formField("Place", text: $place)
            PrimaryButton(title: "Create Event", icon: "calendar") {
                onSave(ClubEvent(title: title, date: date, place: place, players: "New event"))
                dismiss()
            }
            Button("Cancel") { dismiss() }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ClubTheme.electricBlue)
        }
    }

    private func formField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ClubTheme.muted)
            TextField(LocalizedStringKey(title), text: text)
                .font(.system(size: 15, weight: .bold))
                .padding(14)
                .glassPanel(radius: 14)
        }
    }
}

private struct ClubNoticeForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = "Court availability"
    @State private var detail = "Court 2 is free after 18:30."
    let onSave: (ClubNotice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderBar(title: "New Notice", subtitle: "Add a club board announcement", trailingIcon: "megaphone.fill")
            formField("Title", text: $title)
            TextEditor(text: $detail)
                .font(.system(size: 15, weight: .semibold))
                .frame(height: 130)
                .padding(12)
                .scrollContentBackground(.hidden)
                .glassPanel(radius: 14)
            PrimaryButton(title: "Add Notice", icon: "megaphone.fill") {
                onSave(ClubNotice(title: title, detail: detail, time: "New", icon: "megaphone.fill"))
                dismiss()
            }
            Button("Cancel") { dismiss() }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ClubTheme.electricBlue)
        }
    }

    private func formField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ClubTheme.muted)
            TextField(LocalizedStringKey(title), text: text)
                .font(.system(size: 15, weight: .bold))
                .padding(14)
                .glassPanel(radius: 14)
        }
    }
}
