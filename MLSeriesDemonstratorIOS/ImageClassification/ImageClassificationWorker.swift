//
//  ImageClassification.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 26/02/23.
//

import AVFoundation
import MLKit
import SwiftUI

class ImageClassificationWorker: BaseWorker {
    
    let labeler: ImageLabeler
    
    override init() {
        let options = ImageLabelerOptions()
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
