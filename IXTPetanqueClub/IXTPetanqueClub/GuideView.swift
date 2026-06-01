import SwiftUI

struct GuideView: View {
    @Environment(\.openURL) private var openURL
    @State private var section = "Rules"
    private let sections = ["Rules", "History", "News"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HeaderBar(title: "Guide", subtitle: "Rules, history and official news", trailingIcon: "book.closed.fill")

                Picker("", selection: $section) {
                    ForEach(sections, id: \.self) { item in
                        Text(LocalizedStringKey(item)).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                sourceNotice

                switch section {
                case "History":
                    historyContent
                case "News":
                    newsContent
                default:
                    rulesContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
    }

    private var sourceNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verified Content")
                .font(.system(size: 16, weight: .black))
            Text("Rules and factual notes are based on official federation sources. News cards link out to the original source instead of inventing live articles.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ClubTheme.muted)
        }
        .padding(16)
        .glassPanel()
    }

    private var rulesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Game Rules", action: "Official PDF") {
                openURL(URL(string: "https://fipjp.org/images/2021/reglements/Official_Rules_Petanque-En.pdf")!)
            }
            ForEach(SampleData.rules) { rule in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(ClubTheme.electricBlue)
                        Text(LocalizedStringKey(rule.title))
                            .font(.system(size: 16, weight: .black))
                    }
                    Text(LocalizedStringKey(rule.detail))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ClubTheme.lightGray)
                    Text(LocalizedStringKey(rule.source))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(ClubTheme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .clubCard(radius: 16)
            }
        }
    }

    private var historyContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "History", action: "La Ciotat") {
                openURL(URL(string: "https://www.destinationlaciotat.com/profiter/loisirs-en-plein-air/la-petanque/")!)
            }
            ForEach(SampleData.history) { event in
                HStack(alignment: .top, spacing: 14) {
                    Text(event.year)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(ClubTheme.electricBlue)
                        .frame(width: 54, alignment: .leading)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(LocalizedStringKey(event.title))
                            .font(.system(size: 16, weight: .black))
                        Text(LocalizedStringKey(event.detail))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ClubTheme.muted)
                    }
                }
                .padding(16)
                .glassPanel(radius: 16)
            }
        }
    }

    private var newsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Official News", action: "FIPJP") {
                openURL(URL(string: "https://www.fipjp.org/")!)
            }
            ForEach(SampleData.news) { item in
                Button {
                    openURL(item.url)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(LocalizedStringKey(item.sourceName))
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(ClubTheme.electricBlue)
                            Spacer()
                            Text(LocalizedStringKey(item.date))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(ClubTheme.muted)
                        }
                        Text(LocalizedStringKey(item.title))
                            .font(.system(size: 17, weight: .black))
                            .multilineTextAlignment(.leading)
                        Text(LocalizedStringKey(item.summary))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ClubTheme.muted)
                            .multilineTextAlignment(.leading)
                        Label("Open source", systemImage: "arrow.up.right")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(ClubTheme.lightGray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .clubCard(radius: 16)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
