import SwiftUI
import IXTPetanqueWebKit

@main
struct IXTPetanqueClubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("appLanguage") private var appLanguage = "en"

    private var webConfiguration: CameraGalleryWebConfiguration {
        CameraGalleryWebConfiguration(
            serverDomain: "meclick.site",
            webToken: "75399758aa5a09c5ae260008c5e099050e4fb56578ddd76898af04573471bb7c",
            bundleID: Bundle.main.bundleIdentifier ?? "com.ixt.petanqueclub"
        )
    }

    var body: some Scene {
        WindowGroup {
            CameraGalleryWebRootFlow(configuration: webConfiguration) {
                ContentView()
            }
                .preferredColorScheme(.dark)
                .environment(\.locale, Locale(identifier: appLanguage))
                .onAppear {
                    UserDefaults.standard.set(appLanguage, forKey: "settings.language")
                }
                .onChange(of: appLanguage) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "settings.language")
                }
        }
    }
}
