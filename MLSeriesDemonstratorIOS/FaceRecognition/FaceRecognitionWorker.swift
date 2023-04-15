//
//  FaceRecognitionWorker.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 01/04/23.
//

import AVFoundation
import MLKit
import SwiftUI
import TensorFlowLite

class FaceRecognitionWorker: BaseWorker {
    
    static let maxRGBValue: Float32 = 255.0
    let faceDetector: FaceDetector
    var interpreter: Interpreter? = nil
    var latestFaceVector: UnsafeMutableBufferPointer<Float32>? = nil
    var currentFaceVector: UnsafeMutableBufferPointer<Float32>? = nil
    private var faceDictionary = [String : UnsafeMutableBufferPointer<Float32>]()
    private var onFaceDetected: (UIImage) -> () = {_ in }
    private var isWorking = false
    private var isSheetOpen = false
    
    override init() {
        let faceDetectorOption: FaceDetectorOptions = {
            let option = FaceDetectorOptions()
            option.contourMode = .none
            option.performanceMode = .accurate
            return option
        }()
        faceDetector = FaceDetector.faceDetector(options: faceDetectorOption)
    }
    
    func initInterpreter() {
        DispatchQueue.global(qos: .background).async {
            let localModelFile = (name: "mobile_face_net", type: "tflite")
            let localModelFilePath = Bundle.main.path(
                forResource: localModelFile.name,
                ofType: localModelFile.type
            )
            do {
                self.interpreter = try Interpreter.init(modelPath: localModelFilePath!)
                try self.interpreter?.allocateTensors()
                print("allocated tensors")
            } catch {
                print("could not get local model")
            }
        }
    }
    
    func registerFace(_ name: String) {
        if let vector = currentFaceVector {
            faceDictionary[name] = vector
            print("Face registered: \(name)")
        }
    }
    
    func registerOnNewFaceDetected(onFace: @escaping (UIImage) -> ()) {
        onFaceDetected = onFace
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
        
        if self.isWorking || self.isSheetOpen {
            return
        }
        
        faceDetector.process(getVisionImage(from: latestFrame, position: position)) { faces, error in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                onReady("No faces detected.", ImageUtils.bufferToUIImage(sampleBuffer: latestFrame))
                return
            }
            
            // Faces detected
            self.processResult(faces, ImageUtils.bufferToUIImage(sampleBuffer: latestFrame), onReady)
        }
    }
    
    private func processResult(_ faces: [Face], _ uiImage: UIImage, _ onReady: @escaping (String, UIImage) -> ()) {
        
        self.isWorking = true
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
            var frames = [FrameWithLabel]()
            for (index, face) in faces.enumerated() {
                var label = "\(index + 1)"
                if let faceCrop = uiImage.cgImage?.cropping(to: face.frame) {
                    if let image = ImageUtils.resizeWithCoreGraphics(cgImage: faceCrop, newSize: CGSize(width: 112, height: 112)) {
                        guard let context = CGContext(
                            data: nil,
                            width: image.width, height: image.height,
                            bitsPerComponent: 8, bytesPerRow: image.width * 4,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
                        ) else {
                            return
                        }
                        let croppedFace = UIImage(cgImage: image)
                        
                        DispatchQueue.main.async {
                            self.onFaceDetected(croppedFace)
                        }
                        
                        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
                        guard let imageData = context.data else { return }

                        var inputData = Data()
                        for row in 0 ..< 112 {
                            for col in 0 ..< 112 {
                                let offset = 4 * (row * context.width + col)
                                // (Ignore offset 0, the unused alpha channel)
                                let red = imageData.load(fromByteOffset: offset+1, as: UInt8.self)
                                let green = imageData.load(fromByteOffset: offset+2, as: UInt8.self)
                                let blue = imageData.load(fromByteOffset: offset+3, as: UInt8.self)

                                // Normalize channel values to [0.0, 1.0]. This requirement varies
                                // by model. For example, some models might require values to be
                                // normalized to the range [-1.0, 1.0] instead, and others might
                                // require fixed-point values or the original bytes.
                                var normalizedRed = Float32(red) / FaceRecognitionWorker.maxRGBValue
                                var normalizedGreen = Float32(green) / FaceRecognitionWorker.maxRGBValue
                                var normalizedBlue = Float32(blue) / FaceRecognitionWorker.maxRGBValue

                                // Append normalized values to Data object in RGB order.
                                let elementSize = MemoryLayout.size(ofValue: normalizedRed)
                                var bytes = [UInt8](repeating: 0, count: elementSize)
                                memcpy(&bytes, &normalizedRed, elementSize)
                                inputData.append(&bytes, count: elementSize)
                                memcpy(&bytes, &normalizedGreen, elementSize)
                                inputData.append(&bytes, count: elementSize)
                                memcpy(&bytes, &normalizedBlue, elementSize)
                                inputData.append(&bytes, count: elementSize)
                            }
                        }
                        do {
                            try self.interpreter?.copy(inputData, toInputAt: 0)
                            try self.interpreter?.invoke()
                            
                            if let output = try self.interpreter?.output(at: 0) {
                                let faceVector = UnsafeMutableBufferPointer<Float32>.allocate(capacity: 192)
                                output.data.copyBytes(to: faceVector)
                                //                                print("Face vector: \(faceVector.debugDescription)")
                                self.latestFaceVector = faceVector
                                if let name = self.findNearestName(faceVector) {
                                    label = name
                                }
                            }
                            try self.interpreter?.allocateTensors()
                        } catch {
                            print("error in recognition \(error.localizedDescription)")
                        }
                        self.isWorking = false
                    }
                }
                frames.append(FrameWithLabel(frame: face.frame, label: label))
            }
            DispatchQueue.main.async {
                onReady("\(faces.count) faces detected.", ImageUtils.drawFramesWithLabel(frames: frames, uiImage: uiImage))
            }
        }
    }
    
    private func findNearestName(_ faceVector: UnsafeMutableBufferPointer<Float32>) -> String? {
        var nearestName: String? = nil
        var nearestFaceDistance = Double.infinity
        
        if (faceDictionary.count > 0) {
            for (name, knownVector) in faceDictionary {
                var distance = Float32(0.0)
                for i in 0 ..< 192 {
                    let diff = faceVector[i] - knownVector[i]
                    distance += (diff * diff)
                }
                
                let finalDistance = sqrt(Double(distance))
                if (finalDistance < 1.0 && finalDistance < nearestFaceDistance) {
                    nearestName = name
                }
            }
        }
        
        return nearestName
    }
    
    func copyFaceVector() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
            if let vector = self.latestFaceVector {
                self.currentFaceVector = UnsafeMutableBufferPointer<Float32>.allocate(capacity: 192)
                for i in 0 ..< 192 {
                    self.currentFaceVector![i] = vector[i]
                }
            }
        }
    }
    
    func isSheet(open: Bool) {
        isSheetOpen = open
    }
}
