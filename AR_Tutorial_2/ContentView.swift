 //
//  ContentView.swift
//  AR_Tutorial_2
//
//  Created by Georgi Manev on 29.09.22.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: String?
    @State private var modelConfirmedForPlacement: String?
    
    private var models: [String] {
        //Dynamically get our model filenames
        let filemanager = FileManager.default
        guard let path = Bundle.main.resourcePath,
              let files = try?
                filemanager.contentsOfDirectory(atPath: path)
        else {
            return []
        }
       
        var availableModels: [String] = []
        for filename in files where filename.hasSuffix("usdz"){
            let modelName = filename.replacingOccurrences(of: ".usdz",
                                                          with: "")
            availableModels.append(modelName)
        }
        
        return availableModels
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(
                modelConfirmedForPlacement: $modelConfirmedForPlacement
            )
            if self.isPlacementEnabled {
                PlacementButtonsView(
                    isPlacementEnabled: self.$isPlacementEnabled,
                    selectedModel:  self.$selectedModel,
                    modelConfirmedForPlacement: self.$modelConfirmedForPlacement
                )
            }
            else {
                ModelPickerView(
                    isPlacementEnabled: self.$isPlacementEnabled,
                    selectedModel: self.$selectedModel,
                    models: self.models)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: String?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            config.sceneReconstruction = .mesh
        }
    
        arView.session.run(config)
        
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        print("Updating UIVIEW")
        if let modelName = self.modelConfirmedForPlacement {
            print("DEBUG: adding model to scene - \(modelName)")
            let filename = modelName + ".usdz"
            let modelEntity = try! ModelEntity.loadModel(named: filename)
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(modelEntity)
            
            uiView.scene.addAnchor(anchorEntity)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    
    var models: [String]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 10){
                ForEach(0 ..< self.models.count) {
                    index in
                    Button(
                        action: {
                            self.isPlacementEnabled = true
                            self.selectedModel = self.models[index]
                            print("DEBUG: selected model - \(self.models[index])")
                            
                    },
                        label: {
                            Image(uiImage: UIImage(named: self.models[index])!)
                                .resizable()
                                .frame(height: 80)
                                .aspectRatio(
                                    1/1,
                                    contentMode: .fit)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                    ).buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.2))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    @Binding var modelConfirmedForPlacement: String?
    
    var body: some View {
        HStack {
            Button {
                self.resetPlacementParameters()
                print("DEBUG: Cancel model placement")
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            Button {
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
                print("DEBUG: Confirmed model placement")
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }

        }
    }
    
    func resetPlacementParameters(){
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

