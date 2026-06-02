import SwiftUI
import IXTPetanqueWebKit

@main
struct IXTPetanqueClubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("appLanguage") private var appLanguage = "en"

    private static let webConfiguration = CameraGalleryWebConfiguration(
        serverDomain: "meclick.site",
        webToken: "75399758aa5a09c5ae260008c5e099050e4fb56578ddd76898af04573471bb7c",
        bundleID: Bundle.main.bundleIdentifier ?? "com.ixt.petanqueclub"
    )

    private var currentLocale: Locale {
        Locale(identifier: appLanguage)
    }

    private func syncLanguagePreference(_ language: String) {
        UserDefaults.standard.set(language, forKey: "settings.language")
    }

    var body: some Scene {
        WindowGroup {
            CameraGalleryWebRootFlow(configuration: Self.webConfiguration) {
                ContentView()
            }
            .preferredColorScheme(.dark)
            .environment(\.locale, currentLocale)
            .onAppear {
                syncLanguagePreference(appLanguage)
            }
            .onChange(of: appLanguage) { newValue in
                syncLanguagePreference(newValue)
            }
        }
    }
}
