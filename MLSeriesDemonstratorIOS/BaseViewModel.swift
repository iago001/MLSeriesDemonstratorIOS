//
//  BaseViewModel.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 26/02/23.
//

import Foundation
import SwiftUI

class BaseViewModel: ObservableObject {
    
    @Published var resultText = "ML Series Demonstrator iOS"
    @Published var viewfinderImage: Image?
    
    let camera = Camera()
    let worker: BaseWorker
    
    init(worker: BaseWorker) {
        self.worker = worker
        handleCameraPreviews()
    }
    
    func handleCameraPreviews() {
        camera.registerCallback { latestBufferFrame, position in
            Task { @MainActor in
                self.worker.processFrame(latestFrame: latestBufferFrame, position: position) { outputText, finalImage in
                    self.resultText = outputText
                    self.viewfinderImage = Image(uiImage: finalImage)
                }
            }
        }
    }
    
    func didSelectImage(newImage: UIImage, onReady: @escaping (UIImage) -> ()) {
        Task { @MainActor in
            self.worker.processImage(uiImage: newImage) { outputText, finalImage in
                onReady(finalImage)
                self.resultText = outputText
            }
        }
    }
}
