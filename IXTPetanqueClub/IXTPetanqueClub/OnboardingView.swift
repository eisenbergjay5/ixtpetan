import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("playerName") private var playerName = PlayerProfileDefaults.name
    @AppStorage("playerNickname") private var playerNickname = PlayerProfileDefaults.nickname
    @AppStorage("playerCity") private var playerCity = PlayerProfileDefaults.city
    @AppStorage("playerClub") private var playerClub = PlayerProfileDefaults.club
    @AppStorage("playerFavoriteFormat") private var favoriteFormat = PlayerProfileDefaults.favoriteFormat
    @AppStorage("playerHandedness") private var handedness = PlayerProfileDefaults.handedness
    @AppStorage("playerBio") private var bio = PlayerProfileDefaults.bio
    @State private var showValidation = false

    private let formats = ["1 vs 1", "2 vs 2", "3 vs 3"]
    private let hands = ["Right", "Left"]
    private let clubs = SampleData.clubs.map(\.name)

    var body: some View {
        ClubScreen {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        BrandLockup()
                        Text("Create your player profile")
                            .font(.system(size: 32, weight: .black))
                            .lineLimit(2)
                        Text("Set the name your club, friends and match history will use.")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(ClubTheme.muted)
                    }

                    profileForm

                    PrimaryButton(title: "Continue", icon: "checkmark.circle.fill") {
                        completeOnboarding()
                    }

                    if showValidation {
                        Text("Add at least a name or nickname to continue.")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(ClubTheme.frenchRed)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 34)
            }
        }
    }

    private var profileForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Player")
            profileTextField("Full name", text: $playerName, icon: "person.fill")
            profileTextField("Nickname", text: $playerNickname, icon: "at")
            profileTextField("City", text: $playerCity, icon: "mappin.and.ellipse")

            VStack(alignment: .leading, spacing: 8) {
                Text("Club")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ClubTheme.muted)
                Picker("Club", selection: $playerClub) {
                    ForEach(clubs, id: \.self) { club in
                        Text(club).tag(club)
                    }
                }
                .pickerStyle(.menu)
                .tint(ClubTheme.electricBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(ClubTheme.card.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Favorite format")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ClubTheme.muted)
                Picker("Favorite format", selection: $favoriteFormat) {
                    ForEach(formats, id: \.self) { format in
                        Text(format).tag(format)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Preferred hand")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ClubTheme.muted)
                Picker("Preferred hand", selection: $handedness) {
                    ForEach(hands, id: \.self) { hand in
                        Text(hand).tag(hand)
                    }
                }
                .pickerStyle(.segmented)
            }

            profileTextField("Short bio", text: $bio, icon: "quote.bubble.fill")
        }
        .padding(18)
        .clubCard()
    }

    private func profileTextField(_ title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ClubTheme.muted)
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(ClubTheme.electricBlue)
                    .frame(width: 22)
                TextField(LocalizedStringKey(title), text: text)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }
            .font(.system(size: 15, weight: .bold))
            .padding(14)
            .background(ClubTheme.card.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func completeOnboarding() {
        let name = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let nickname = playerNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty || !nickname.isEmpty else {
            showValidation = true
            return
        }
        if playerNickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            playerNickname = name.components(separatedBy: " ").first ?? name
        }
        hasCompletedOnboarding = true
    }
}
