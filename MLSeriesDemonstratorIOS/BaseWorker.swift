//
//  BaseWorker.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 26/02/23.
//

import AVFoundation
import MLKit
import SwiftUI

class BaseWorker {
    
    func processImage(uiImage: UIImage, onReady: @escaping (String, UIImage) -> ()) {
    }
    
    func processFrame(latestFrame: CMSampleBuffer, position: AVCaptureDevice.Position, onReady: @escaping (String, UIImage) -> ()) {

    }
    
    func getVisionImage(from uiImage: UIImage) -> VisionImage {
        let visionImage = VisionImage(image: uiImage)
        visionImage.orientation = uiImage.imageOrientation
        return visionImage
    }
    
    func getVisionImage(from sampleBufer: CMSampleBuffer, position: AVCaptureDevice.Position) -> VisionImage {
        let visionImage = VisionImage(buffer: sampleBufer)
        visionImage.orientation = UIUtilities.imageOrientation(fromDevicePosition: position)
        return visionImage
    }
}
