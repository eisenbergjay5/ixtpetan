import SwiftUI

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("playerName") private var playerName = PlayerProfileDefaults.name
    @AppStorage("playerNickname") private var playerNickname = PlayerProfileDefaults.nickname
    @AppStorage("playerCity") private var playerCity = PlayerProfileDefaults.city
    @AppStorage("playerClub") private var playerClub = PlayerProfileDefaults.club
    @AppStorage("playerFavoriteFormat") private var favoriteFormat = PlayerProfileDefaults.favoriteFormat
    @AppStorage("playerHandedness") private var handedness = PlayerProfileDefaults.handedness
    @AppStorage("playerBio") private var bio = PlayerProfileDefaults.bio

    private let formats = ["1 vs 1", "2 vs 2", "3 vs 3"]
    private let hands = ["Right", "Left"]
    private let clubs = SampleData.clubs.map(\.name)

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderBar(title: "Edit Profile", subtitle: "Name, club and playing preferences", trailingIcon: "checkmark") {
                dismiss()
            }

            VStack(alignment: .leading, spacing: 14) {
                editorTextField("Full name", text: $playerName, icon: "person.fill")
                editorTextField("Nickname", text: $playerNickname, icon: "at")
                editorTextField("City", text: $playerCity, icon: "mappin.and.ellipse")

                Picker("Club", selection: $playerClub) {
                    ForEach(clubs, id: \.self) { club in
                        Text(club).tag(club)
                    }
                }
                .pickerStyle(.menu)
                .tint(ClubTheme.electricBlue)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ClubTheme.card.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Picker("Favorite format", selection: $favoriteFormat) {
                    ForEach(formats, id: \.self) { format in
                        Text(format).tag(format)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Preferred hand", selection: $handedness) {
                    ForEach(hands, id: \.self) { hand in
                        Text(hand).tag(hand)
                    }
                }
                .pickerStyle(.segmented)

                editorTextField("Short bio", text: $bio, icon: "quote.bubble.fill")
            }
            .padding(18)
            .clubCard()

            PrimaryButton(title: "Save", icon: "checkmark.circle.fill") {
                dismiss()
            }
        }
        .padding(20)
    }

    private func editorTextField(_ title: String, text: Binding<String>, icon: String) -> some View {
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
