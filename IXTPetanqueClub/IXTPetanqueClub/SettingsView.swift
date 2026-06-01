import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("pushNotificationsEnabled") private var pushNotificationsEnabled = false
    @State private var defaultFormat = "2 vs 2"
    @State private var scoreLimit = 13.0
    @State private var ratedMatches = true
    @State private var weatherAlerts = true
    @State private var arHints = true
    @State private var selectedClub = "Club de Lyon"
    @State private var pushStatus = "Checking"
    @State private var fcmToken = ""

    private let formats = ["1 vs 1", "2 vs 2", "3 vs 3"]
    private let clubs = SampleData.clubs.map(\.name)
    private let languages = ["en", "fr"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HeaderBar(title: "Settings", subtitle: "Club and match preferences", trailingIcon: nil)

                languageSection
                pushNotifications
                preferences
                matchDefaults
                appOptions
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .onAppear(perform: refreshPushState)
        .onReceive(NotificationCenter.default.publisher(for: .fcmTokenDidChange)) { notification in
            fcmToken = notification.object as? String ?? PushNotificationService.shared.fcmToken ?? ""
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Language")
            Picker("Language", selection: $appLanguage) {
                Text("English").tag("en")
                Text("Français").tag("fr")
            }
            .pickerStyle(.segmented)
            Text("Language changes apply immediately across the app.")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ClubTheme.muted)
        }
        .padding(16)
        .clubCard()
    }

    private var pushNotifications: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Push Notifications")

            HStack(spacing: 10) {
                MetricPill(value: pushStatus, label: "permission")
                MetricPill(value: pushNotificationsEnabled ? "On" : "Off", label: "in app")
            }

            HStack(spacing: 10) {
                Button {
                    if pushNotificationsEnabled {
                        PushNotificationService.shared.disablePushNotifications()
                        refreshPushState()
                    } else {
                        PushNotificationService.shared.requestAuthorization()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: refreshPushState)
                    }
                } label: {
                    Label(
                        LocalizedStringKey(pushNotificationsEnabled ? "Disable Push" : "Enable Push"),
                        systemImage: pushNotificationsEnabled ? "bell.slash.fill" : "bell.badge.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(pushNotificationsEnabled ? ClubTheme.frenchRed : ClubTheme.electricBlue)

                Button {
                    if pushNotificationsEnabled {
                        PushNotificationService.shared.refreshFCMToken()
                    }
                    refreshPushState()
                } label: {
                    Label(LocalizedStringKey("Refresh Status"), systemImage: "arrow.clockwise")
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

    private var preferences: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Club")
            Picker(LocalizedStringKey("Club"), selection: $selectedClub) {
                ForEach(clubs, id: \.self) { club in
                    Text(club).tag(club)
                }
            }
            .pickerStyle(.menu)
            .tint(ClubTheme.electricBlue)

            HStack(spacing: 10) {
                MetricPill(value: selectedClub == "Club de Lyon" ? "42" : "24+", label: "members")
                MetricPill(value: "France", label: "region")
                MetricPill(value: "Local", label: "rating scope")
            }
        }
        .padding(16)
        .clubCard()
    }

    private var matchDefaults: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Match Defaults")
            Picker(LocalizedStringKey("Default format"), selection: $defaultFormat) {
                ForEach(formats, id: \.self) { format in
                    Text(format).tag(format)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Score limit")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("\(Int(scoreLimit))")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(ClubTheme.electricBlue)
                }
                Slider(value: $scoreLimit, in: 11...15, step: 1)
                    .tint(ClubTheme.electricBlue)
            }

            Toggle("Rated local matches", isOn: $ratedMatches)
                .tint(ClubTheme.electricBlue)
        }
        .padding(16)
        .glassPanel()
    }

    private var appOptions: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "App Options")
            Toggle("Weather alerts for club events", isOn: $weatherAlerts)
                .tint(ClubTheme.electricBlue)
            Toggle("AR placement hints", isOn: $arHints)
                .tint(ClubTheme.electricBlue)
            Text("Settings are stored locally in this prototype UI and can be connected to app storage or a club backend later.")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ClubTheme.muted)
        }
        .padding(16)
        .glassPanel()
    }

    private func refreshPushState() {
        fcmToken = PushNotificationService.shared.fcmToken ?? ""
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
                pushStatus = status
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
