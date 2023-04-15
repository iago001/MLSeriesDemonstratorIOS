//
//  FaceDetector.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 25/02/23.
//

import AVFoundation
import MLKit
import SwiftUI

class FaceDetectionWorker: BaseWorker {
    
    let faceDetector: FaceDetector
    
    override init() {
        let faceDetectorOption: FaceDetectorOptions = {
            let option = FaceDetectorOptions()
            option.contourMode = .none
            option.performanceMode = .accurate
            return option
        }()
        faceDetector = FaceDetector.faceDetector(options: faceDetectorOption)
    }
    
    override func processImage(uiImage: UIImage, onReady: @escaping (String, UIImage) -> ()) {
        
        faceDetector.process(getVisionImage(from: uiImage)) { faces, error in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                print("Error + \(error.debugDescription)")
                onReady("No faces detected.", uiImage)
                return
            }

            // Faces detected
            self.processResult(faces, uiImage, onReady)
        }
    }
    
    override func processFrame(latestFrame: CMSampleBuffer, position: AVCaptureDevice.Position, onReady: @escaping (String, UIImage) -> ()) {
        
        faceDetector.process(getVisionImage(from: latestFrame, position: position)) { faces, error in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                print("Error + \(error.debugDescription)")
                onReady("No faces detected.", ImageUtils.bufferToUIImage(sampleBuffer: latestFrame))
                return
            }

            // Faces detected
            self.processResult(faces, ImageUtils.bufferToUIImage(sampleBuffer: latestFrame), onReady)
        }
    }
    
    private func processResult(_ faces: [Face], _ uiImage: UIImage, _ onReady: @escaping (String, UIImage) -> ()) {
        var frames = [FrameWithLabel]()
        for (index, face) in faces.enumerated() {
            print("index: \(index)")
            frames.append(FrameWithLabel(frame: face.frame, label: "\(index + 1)"))
        }
        onReady("\(faces.count) faces detected.", ImageUtils.drawFramesWithLabel(frames: frames, uiImage: uiImage))
    }
}
