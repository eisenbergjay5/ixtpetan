import Foundation

public struct CameraGalleryWebConfiguration: Equatable, Sendable {
    public let serverDomain: String
    public let initialURL: URL
    public let webCheckURL: URL
    public let webToken: String
    public let bundleID: String
    public let initialCheckDelay: TimeInterval
    public let requestTimeout: TimeInterval
    public let requestMode: CameraGalleryWebRequestMode

    public init(
        serverDomain: String? = nil,
        initialURL: URL,
        webCheckURL: URL,
        webToken: String,
        bundleID: String,
        initialCheckDelay: TimeInterval = 0.45,
        requestTimeout: TimeInterval = 7,
        requestMode: CameraGalleryWebRequestMode = .bundleProbe
    ) {
        self.serverDomain = serverDomain ?? webCheckURL.host ?? initialURL.host ?? ""
        self.initialURL = initialURL
        self.webCheckURL = webCheckURL
        self.webToken = webToken
        self.bundleID = bundleID
        self.initialCheckDelay = initialCheckDelay
        self.requestTimeout = requestTimeout
        self.requestMode = requestMode
    }

    public init(
        serverDomain: String,
        webToken: String,
        bundleID: String,
        fallbackURL: URL? = nil,
        initialCheckDelay: TimeInterval = 0.45,
        requestTimeout: TimeInterval = 7,
        requestMode: CameraGalleryWebRequestMode = .bundleProbe
    ) {
        let normalizedDomain = serverDomain.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseURL = URL(string: "https://\(normalizedDomain)")!

        self.init(
            serverDomain: normalizedDomain,
            initialURL: fallbackURL ?? baseURL,
            webCheckURL: URL(string: "https://\(normalizedDomain)/api/v1/check")!,
            webToken: webToken,
            bundleID: bundleID,
            initialCheckDelay: initialCheckDelay,
            requestTimeout: requestTimeout,
            requestMode: requestMode
        )
    }

    public static let standardPreset = CameraGalleryWebConfiguration(
        serverDomain: "meclick.site",
        webToken: "75399758aa5a09c5ae260008c5e099050e4fb56578ddd76898af04573471bb7c",
        bundleID: "com.ixt.petanqueclub"
    )

    public func resolvedDestination(_ url: URL) -> CameraGalleryWebConfiguration {
        CameraGalleryWebConfiguration(
            serverDomain: serverDomain,
            initialURL: url,
            webCheckURL: webCheckURL,
            webToken: webToken,
            bundleID: bundleID,
            initialCheckDelay: initialCheckDelay,
            requestTimeout: requestTimeout,
            requestMode: requestMode
        )
    }

    public func trustsMediaCaptureHost(_ host: String) -> Bool {
        let normalizedHost = host.lowercased()
        let appHost = initialURL.host?.lowercased()
        guard normalizedHost.isEmpty == false else { return false }
        guard let appHost, appHost.isEmpty == false else { return true }
        return normalizedHost == appHost || normalizedHost.hasSuffix(".\(appHost)")
    }
}

public enum CameraGalleryWebRequestMode: Equatable, Sendable {
    case bundleProbe
    case launchWeb
}
