//
//  FaceDetectorViewModel.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 25/02/23.
//

import SwiftUI

@MainActor class FaceDetectorViewModel: BaseViewModel {

    init() {
        super.init(worker: FaceDetectionWorker())
    }
}
