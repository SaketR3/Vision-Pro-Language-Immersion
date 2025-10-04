/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Extensions and utilities.
*/

import RealityKit
import UIKit

extension Entity {
    static func createText(_ string: String, height: Float, color: UIColor = .white) -> ModelEntity {
        let font = MeshResource.Font(name: "Helvetica", size: CGFloat(height))!
        let mesh = MeshResource.generateText(string, extrusionDepth: height * 0.05, font: font)
        let material = UnlitMaterial(color: color)
        let text = ModelEntity(mesh: mesh, materials: [material])
        return text
    }
    
    func applyMaterialRecursively(_ material: RealityFoundation.Material) {
        if let modelEntity = self as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        for child in children {
            child.applyMaterialRecursively(material)
        }
    }
}
