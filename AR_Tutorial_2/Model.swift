//
//  Model.swift
//  AR_Tutorial_2
//
//  Created by Georgi Manev on 6.10.22.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: {loadCompletion in
                //Handle our error
                print("ERROR: Unable to load modelEntity for modelName: \(self.modelName)")
            },receiveValue: {modelEntity in
                //Get our modelEntity
                self.modelEntity = modelEntity
                print ("DEBUG: Succesfully loaded modelEntity for modelName: \(self.modelName) ")
            })
    }
}
