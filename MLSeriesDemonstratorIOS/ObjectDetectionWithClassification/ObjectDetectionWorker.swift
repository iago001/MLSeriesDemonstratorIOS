//
//  ObjectDetectionWorker.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 27/02/23.
//

import AVFoundation
import MLKit
import MLKitObjectDetection
import SwiftUI

class ObjectDetectionWorker: BaseWorker {
    
    let photoObjectDetector: ObjectDetector
    let videoObjectDetector: ObjectDetector
    
    override init() {
        let options = ObjectDetectorOptions()
        options.detectorMode = .singleImage
        options.shouldEnableMultipleObjects = true
        options.shouldEnableClassification = true
        photoObjectDetector = ObjectDetector.objectDetector(options: options)
        
        let videoOptions = ObjectDetectorOptions()
        videoOptions.detectorMode = .stream
        videoOptions.shouldEnableMultipleObjects = false
        videoOptions.shouldEnableClassification = true
        videoObjectDetector = ObjectDetector.objectDetector(options: videoOptions)
    }
    
    override func processImage(uiImage: UIImage, onReady: @escaping (String, UIImage) -> ()) {
        
        photoObjectDetector.process(getVisionImage(from: uiImage)) { objects, error in
            guard error == nil, let objects = objects, !objects.isEmpty else {
                print("Error + \(error.debugDescription)")
                onReady("No objects detected.", uiImage)
                return
            }

            self.processResults(objects, uiImage, onReady)
        }
    }
    
    override func processFrame(latestFrame: CMSampleBuffer, position: AVCaptureDevice.Position, onReady: @escaping (String, UIImage) -> ()) {
        
        videoObjectDetector.process(getVisionImage(from: latestFrame, position: position)) { objects, error in
            guard error == nil, let objects = objects, !objects.isEmpty else {
                print("Error + \(error.debugDescription)")
                onReady("No objects detected.", ImageUtils.bufferToUIImage(sampleBuffer: latestFrame))
                return
            }
            self.processResults(objects, ImageUtils.bufferToUIImage(sampleBuffer: latestFrame), onReady)
        }
    }
    
    private func processResults(_ objects: [Object], _ uiImage: UIImage, _ onReady: @escaping (String, UIImage) -> ()) {
        let output = "\(objects.count) objects detected"
        let frames = objects.map { object in
            FrameWithLabel(frame: object.frame, label: object.labels.map { label in
                label.text
            }.joined(separator: ","))
        }
        onReady(output, ImageUtils.drawFramesWithLabel(frames: frames, uiImage: uiImage))
    }
}
