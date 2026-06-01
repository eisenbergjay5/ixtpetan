import ARKit
import SceneKit
import SwiftUI

enum ARPlacementStep: String {
    case cochonnet = "Tap the cochonnet"
    case blue = "Tap the blue ball"
    case red = "Tap the red ball"
    case complete = "Measurement complete"
}

struct MeasureARView: View {
    @State private var blueDistance: Double?
    @State private var redDistance: Double?
    @State private var placementStep: ARPlacementStep = .cochonnet
    @State private var status = "Move your iPhone over the terrain, then tap the cochonnet."
    @State private var resetToken = 0
    @State private var scanCount = 1
    @State private var alertMessage: String?

    var body: some View {
        ZStack {
            if ARWorldTrackingConfiguration.isSupported {
                ARMeasureCameraView(
                    blueDistance: $blueDistance,
                    redDistance: $redDistance,
                    placementStep: $placementStep,
                    status: $status,
                    resetToken: $resetToken
                )
                .ignoresSafeArea()
            } else {
                unsupportedARView
            }

            VStack(spacing: 0) {
                header
                Spacer()
                measureOverlay
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
            }
        }
        .alert("Measure AR", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Measure AR")
                    .font(.system(size: 26, weight: .black))
                Text(status)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ClubTheme.lightGray)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "viewfinder")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 44, height: 44)
                .background(ClubTheme.graphite.opacity(0.78))
                .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var measureOverlay: some View {
        VStack(spacing: 12) {
            Text(placementStep.rawValue)
                .font(.system(size: 15, weight: .black))
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(ClubTheme.graphite.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack {
                distanceCard(team: "Blue Ball", distance: formatted(blueDistance), tint: ClubTheme.electricBlue)
                distanceCard(team: "Red Ball", distance: formatted(redDistance), tint: ClubTheme.frenchRed)
            }

            Text(resultText)
                .font(.system(size: 15, weight: .black))
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(ClubTheme.graphite.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack {
                Button("Reset") {
                    resetMeasurement()
                }
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(ClubTheme.graphite.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button("Save") {
                    saveMeasurement()
                }
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(ClubTheme.electricBlue)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .opacity(canSave ? 1 : 0.45)
                .disabled(!canSave)
            }
        }
    }

    private var resultText: String {
        guard let blueDistance, let redDistance else {
            return "Place all three markers to compare distances"
        }
        if abs(blueDistance - redDistance) < 0.5 {
            return "Too close to call. Measure again."
        }
        return blueDistance < redDistance ? "Blue ball is closest" : "Red ball is closest"
    }

    private var canSave: Bool {
        blueDistance != nil && redDistance != nil
    }

    private var unsupportedARView: some View {
        ZStack {
            LinearGradient.appBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "iphone.slash")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(ClubTheme.electricBlue)
                Text("AR requires a physical iPhone")
                    .font(.system(size: 22, weight: .black))
                Text("The simulator can build this screen, but live camera measurement runs on an ARKit-capable device.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ClubTheme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)
            }
        }
    }

    private func distanceCard(team: String, distance: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Text(team)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
            Text(distance)
                .font(.system(size: 18, weight: .black))
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(ClubTheme.graphite.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func formatted(_ distance: Double?) -> String {
        guard let distance else { return "-- cm" }
        return "\(Int(distance.rounded())) cm"
    }

    private func resetMeasurement() {
        blueDistance = nil
        redDistance = nil
        placementStep = .cochonnet
        status = "Move your iPhone over the terrain, then tap the cochonnet."
        scanCount += 1
        resetToken += 1
    }

    private func saveMeasurement() {
        guard canSave else { return }
        alertMessage = "Scan #\(scanCount) saved. \(resultText)"
    }
}

struct ARMeasureCameraView: UIViewRepresentable {
    @Binding var blueDistance: Double?
    @Binding var redDistance: Double?
    @Binding var placementStep: ARPlacementStep
    @Binding var status: String
    @Binding var resetToken: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [.showFeaturePoints]
        context.coordinator.sceneView = sceneView

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tap)

        context.coordinator.runSession()
        return sceneView
    }

    func updateUIView(_ sceneView: ARSCNView, context: Context) {
        context.coordinator.parent = self
        if context.coordinator.lastResetToken != resetToken {
            context.coordinator.reset()
            context.coordinator.lastResetToken = resetToken
        }
    }

    final class Coordinator: NSObject {
        var parent: ARMeasureCameraView
        weak var sceneView: ARSCNView?
        var lastResetToken = 0

        private var cochonnetPosition: simd_float3?
        private var bluePosition: simd_float3?
        private var redPosition: simd_float3?
        private var markerNodes: [SCNNode] = []

        init(_ parent: ARMeasureCameraView) {
            self.parent = parent
        }

        func runSession() {
            guard ARWorldTrackingConfiguration.isSupported else { return }
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]
            configuration.environmentTexturing = .automatic
            sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }

        func reset() {
            markerNodes.forEach { $0.removeFromParentNode() }
            markerNodes.removeAll()
            cochonnetPosition = nil
            bluePosition = nil
            redPosition = nil
            runSession()
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView else { return }
            let location = gesture.location(in: sceneView)
            guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .horizontal),
                  let result = sceneView.session.raycast(query).first else {
                updateStatus("Aim at a flat terrain area and try again.")
                return
            }

            let position = simd_float3(
                result.worldTransform.columns.3.x,
                result.worldTransform.columns.3.y,
                result.worldTransform.columns.3.z
            )

            switch parent.placementStep {
            case .cochonnet:
                cochonnetPosition = position
                addMarker(at: position, color: UIColor(red: 0.72, green: 0.55, blue: 0.35, alpha: 1), radius: 0.018, label: "Cochonnet")
                updateStep(.blue, status: "Cochonnet placed. Tap the blue ball.")
            case .blue:
                bluePosition = position
                addMarker(at: position, color: .systemBlue, radius: 0.035, label: "Blue")
                updateBlueDistance()
                updateStep(.red, status: "Blue ball placed. Tap the red ball.")
            case .red:
                redPosition = position
                addMarker(at: position, color: .systemRed, radius: 0.035, label: "Red")
                updateRedDistance()
                addMeasurementLines()
                updateStep(.complete, status: "Measurement complete. Save or reset.")
            case .complete:
                updateStatus("Measurement complete. Reset to measure again.")
            }
        }

        private func updateBlueDistance() {
            guard let cochonnetPosition, let bluePosition else { return }
            let distance = simd_distance(cochonnetPosition, bluePosition) * 100
            DispatchQueue.main.async {
                self.parent.blueDistance = Double(distance)
            }
        }

        private func updateRedDistance() {
            guard let cochonnetPosition, let redPosition else { return }
            let distance = simd_distance(cochonnetPosition, redPosition) * 100
            DispatchQueue.main.async {
                self.parent.redDistance = Double(distance)
            }
        }

        private func updateStep(_ step: ARPlacementStep, status: String) {
            DispatchQueue.main.async {
                self.parent.placementStep = step
                self.parent.status = status
            }
        }

        private func updateStatus(_ status: String) {
            DispatchQueue.main.async {
                self.parent.status = status
            }
        }

        private func addMarker(at position: simd_float3, color: UIColor, radius: CGFloat, label: String) {
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            sphere.firstMaterial?.specular.contents = UIColor.white

            let node = SCNNode(geometry: sphere)
            node.simdPosition = position
            sceneView?.scene.rootNode.addChildNode(node)
            markerNodes.append(node)

            let text = SCNText(string: label, extrusionDepth: 0.001)
            text.font = .boldSystemFont(ofSize: 0.035)
            text.firstMaterial?.diffuse.contents = UIColor.white
            let textNode = SCNNode(geometry: text)
            textNode.scale = SCNVector3(0.8, 0.8, 0.8)
            textNode.position = SCNVector3(-0.045, Float(radius + 0.025), 0)
            node.addChildNode(textNode)
        }

        private func addMeasurementLines() {
            guard let cochonnetPosition else { return }
            if let bluePosition {
                addLine(from: cochonnetPosition, to: bluePosition, color: .systemBlue)
            }
            if let redPosition {
                addLine(from: cochonnetPosition, to: redPosition, color: .systemRed)
            }
        }

        private func addLine(from start: simd_float3, to end: simd_float3, color: UIColor) {
            let vertices = [
                SCNVector3(start.x, start.y + 0.006, start.z),
                SCNVector3(end.x, end.y + 0.006, end.z)
            ]
            let source = SCNGeometrySource(vertices: vertices)
            let indices: [Int32] = [0, 1]
            let data = Data(bytes: indices, count: MemoryLayout<Int32>.size * indices.count)
            let element = SCNGeometryElement(
                data: data,
                primitiveType: .line,
                primitiveCount: 1,
                bytesPerIndex: MemoryLayout<Int32>.size
            )
            let geometry = SCNGeometry(sources: [source], elements: [element])
            geometry.firstMaterial?.diffuse.contents = color
            let node = SCNNode(geometry: geometry)
            sceneView?.scene.rootNode.addChildNode(node)
            markerNodes.append(node)
        }
    }
}

struct Ball: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.white.opacity(0.35), color, .black.opacity(0.78)],
                    center: .topLeading,
                    startRadius: 4,
                    endRadius: size
                )
            )
            .frame(width: size, height: size)
            .overlay(Circle().stroke(.white.opacity(0.24), lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 8)
    }
}
