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
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    private var models: [Model] {
        //Dynamically get our model filenames
        let filemanager = FileManager.default
        guard let path = Bundle.main.resourcePath,
              let files = try?
                filemanager.contentsOfDirectory(atPath: path)
        else {
            return []
        }
       
        var availableModels: [Model] = []
        for filename in files where filename.hasSuffix("usdz"){
            let modelName = filename.replacingOccurrences(of: ".usdz",
                                                          with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
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
    @Binding var modelConfirmedForPlacement: Model?
    
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
        if let model = self.modelConfirmedForPlacement {
            if let modelEntity = model.modelEntity{
                print("DEBUG: adding model to scene - \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                uiView.scene.addAnchor(anchorEntity)
            }
            else{
                print("ERROR: Unable to load modelEntity - \(model.modelName)")
            }
            
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
    @Binding var selectedModel: Model?
    
    var models: [Model]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 10){
                ForEach(0 ..< self.models.count) {
                    index in
                    Button(
                        action: {
                            self.isPlacementEnabled = true
                            self.selectedModel = self.models[index]
                            print("DEBUG: selected model - \(self.models[index].modelName)")
                            
                    },
                        label: {
                            Image(uiImage: self.models[index].image)
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
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
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

