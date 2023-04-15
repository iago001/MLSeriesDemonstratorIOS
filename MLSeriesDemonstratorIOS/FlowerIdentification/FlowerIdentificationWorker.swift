//
//  FlowerIdentificationWorker.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 05/03/23.
//

import AVFoundation
import MLKit
import SwiftUI

class FlowerIdentificationWorker: BaseWorker {
    
    let labeler: ImageLabeler
    
    override init() {
        let localModelFile = (name: "model_flowers", type: "tflite")
        guard
            let localModelFilePath = Bundle.main.path(
                forResource: localModelFile.name,
                ofType: localModelFile.type
            )
        else {
            print("Failed to find custom local model file.")
            // fallback to base labeler
            let options = ImageLabelerOptions()
            options.confidenceThreshold = 0.7
            labeler = ImageLabeler.imageLabeler(options: options)
            return
        }
        
        // use custome labeler if found in bundle
        let options = CustomImageLabelerOptions(localModel: LocalModel(path: localModelFilePath))
        options.confidenceThreshold = 0.7
        labeler = ImageLabeler.imageLabeler(options: options)
    }
    
    override func processImage(uiImage: UIImage, onReady: @escaping (String, UIImage) -> ()) {
        
        labeler.process(getVisionImage(from: uiImage)) { labels, error in
            guard error == nil, let labels = labels, !labels.isEmpty else {
                print("Error + \(error.debugDescription)")
                onReady("No labels detected.", uiImage)
                return
            }

            // Labels detected
            let output = labels.map { label in
                label.text
            }.joined(separator: ",")
            onReady(output, uiImage)
        }
    }
    
    override func processFrame(latestFrame: CMSampleBuffer, position: AVCaptureDevice.Position, onReady: @escaping (String, UIImage) -> ()) {
        
        labeler.process(getVisionImage(from: latestFrame, position: position)) { labels, error in
            guard error == nil, let labels = labels, !labels.isEmpty else {
                print("Error + \(error.debugDescription)")
                onReady("No labels detected.", ImageUtils.bufferToUIImage(sampleBuffer: latestFrame))
                return
            }

            let output = labels.map { label in
                label.text
            }.joined(separator: ",")
            onReady(output, ImageUtils.bufferToUIImage(sampleBuffer: latestFrame))
        }
    }
}
