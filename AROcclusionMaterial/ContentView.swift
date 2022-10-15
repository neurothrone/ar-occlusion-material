//
//  ContentView.swift
//  AROcclusionMaterial
//
//  Created by Zaid Neurothrone on 2022-10-15.
//

import Combine
import RealityKit
import SwiftUI

struct ContentView : View {
  var body: some View {
    ARViewContainer().edgesIgnoringSafeArea(.all)
  }
}

final class Coordinator {
  var arView: ARView?
  var cancellable: AnyCancellable?
  
  func setUp() {
    guard let arView = arView else { return }
    
    let anchor = AnchorEntity(plane: .horizontal)
    
    let box = ModelEntity(mesh: .generateBox(size: 0.3), materials: [OcclusionMaterial()])
    box.generateCollisionShapes(recursive: true)
    arView.installGestures(.all, for: box)
    
    cancellable = ModelEntity.loadAsync(named: "toy_robot_vintage")
      .sink { [weak self] completion in
        if case let .failure(error) = completion {
          fatalError("❌ -> Unable to load model. Error: \(error)")
        }
        
        self?.cancellable?.cancel()
      } receiveValue: { entity in
        anchor.addChild(entity)
      }
    
    anchor.addChild(box)
    arView.scene.addAnchor(anchor)
  }
}

struct ARViewContainer: UIViewRepresentable {
  func makeUIView(context: Context) -> ARView {
    let arView = ARView(frame: .zero)
    
    context.coordinator.arView = arView
    context.coordinator.setUp()
    
    return arView
  }
  
  func updateUIView(_ uiView: ARView, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    .init()
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
