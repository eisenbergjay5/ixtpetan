import SwiftUI

#if canImport(UIKit)
public struct CameraGalleryWebLaunchPanel: View {
    public let configuration: CameraGalleryWebConfiguration
    @AppStorage("settings.language") private var preferredLanguage = "en"
    @State private var isLoading = false
    @State private var statusMessage: String?
    @State private var presentedDestination: CameraGalleryWebPresentedDestination?

    public init(configuration: CameraGalleryWebConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Web Launch Check", systemImage: "camera.viewfinder")
                .font(.headline)
                .foregroundStyle(CameraGalleryWebTheme.accent)

            Text("Sends the web launch check and continues with the server-provided destination when available.")
                .font(.subheadline)
                .foregroundStyle(CameraGalleryWebTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await loadDestination() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(CameraGalleryWebTheme.navy)
                    }
                    Text(isLoading ? "Checking..." : "Check and open")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(CameraGalleryWebTheme.accent)
            .foregroundStyle(CameraGalleryWebTheme.navy)
            .disabled(isLoading)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(CameraGalleryWebTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CameraGalleryWebTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .fullScreenCover(item: $presentedDestination) { destination in
            NavigationStack {
                CameraGalleryWebBrowserScreen(configuration: destination.configuration)
            }
        }
        .cameraGalleryWebAudioAware()
    }

    @MainActor
    private func loadDestination() async {
        isLoading = true
        statusMessage = nil
        defer { isLoading = false }

        do {
            let client = CameraGalleryWebRequestClient(configuration: configuration)
            let decision = try await client.loadDecision(preferredLanguage: preferredLanguage)

            guard decision.enabled else {
                statusMessage = "Server returned false. Continuing with the local app."
                return
            }

            guard let url = decision.url else {
                statusMessage = "Server returned true but did not include a URL."
                return
            }

            presentedDestination = CameraGalleryWebPresentedDestination(
                configuration: configuration.resolvedDestination(url)
            )
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

public struct CameraGalleryWebPresentedDestination: Identifiable {
    public let id = UUID()
    public let configuration: CameraGalleryWebConfiguration

    public init(configuration: CameraGalleryWebConfiguration) {
        self.configuration = configuration
    }
}
#endif
