import RealityKit
import simd

extension simd_float4x4 {
    var translation: SIMD3<Float> { [columns.3.x, columns.3.y, columns.3.z] }
}

extension Entity {
    func faceCamera(_ cameraTransform: simd_float4x4) {
        let cameraPosition = cameraTransform.translation
        let panelPosition = self.position(relativeTo: nil)
        self.look(at: cameraPosition, from: panelPosition, relativeTo: nil)
    }
}
