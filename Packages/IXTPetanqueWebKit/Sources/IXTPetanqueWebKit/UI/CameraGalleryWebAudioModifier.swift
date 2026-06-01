import SwiftUI

#if canImport(UIKit)
import UIKit

private struct CameraGalleryWebAudioModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                CameraGalleryWebRuntime.activateGameAudio()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                CameraGalleryWebRuntime.activateGameAudio()
            }
    }
}

extension View {
    func cameraGalleryWebAudioAware() -> some View {
        modifier(CameraGalleryWebAudioModifier())
    }
}
#endif
