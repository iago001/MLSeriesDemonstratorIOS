//
//  FaceRecognitionViewModel.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 01/04/23.
//

import SwiftUI

@MainActor class FaceRecognitionViewModel: BaseViewModel {
    
    @Published var croppedFaceImage: Image?
    
    private var faceRecognitionWorker: FaceRecognitionWorker

    init() {
        faceRecognitionWorker = FaceRecognitionWorker()
        super.init(worker: faceRecognitionWorker)
        faceRecognitionWorker.initInterpreter()
        viewfinderImage = Image(uiImage: UIImage())
//        Task {
//            // Delay the task by 2 seconds:
//            try await Task.sleep(nanoseconds: 2_000_000_000)
//
//            await camera.start()
//        }
        faceRecognitionWorker.registerOnNewFaceDetected { face in
            self.croppedFaceImage = Image(uiImage: face)
        }
    }
    
    func registerFace(_ name: String) {
        faceRecognitionWorker.registerFace(name)
    }
    
    func copyFaceVector() {
        faceRecognitionWorker.copyFaceVector()
    }
    
    func isSheet(open: Bool) {
        faceRecognitionWorker.isSheet(open: open)
    }
}
