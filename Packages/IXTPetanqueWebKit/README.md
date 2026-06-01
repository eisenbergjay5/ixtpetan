# IXTPetanqueWebKit

Reusable SwiftUI package for server-driven WebView launches with:

- camera upload support for web file inputs
- photo library upload support
- files picker fallback
- WebKit media capture permission handling for trusted hosts
- reactive language forwarding through `@AppStorage("settings.language")`
- audio keepalive workarounds for game-like web runtimes

Requires `iOS 16+`.

## Add To An App

```swift
dependencies: [
    .package(path: "../IXTPetanqueWebKit")
]
```

```swift
import IXTPetanqueWebKit
```

## Configure

```swift
let webConfiguration = CameraGalleryWebConfiguration(
    serverDomain: "example.com",
    webToken: "token",
    bundleID: Bundle.main.bundleIdentifier ?? "com.ixt.petanqueclub"
)
```

Preset example:

```swift
CameraGalleryWebConfiguration.standardPreset
```

## Launch Panel

```swift
CameraGalleryWebLaunchPanel(
    configuration: .standardPreset
)
```

## Root Flow

```swift
CameraGalleryWebRootFlow(
    configuration: .standardPreset,
    requestReviewBeforeCheck: false
) {
    RootView()
}
```

## Required Info.plist Keys

- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSPhotoLibraryUsageDescription`
