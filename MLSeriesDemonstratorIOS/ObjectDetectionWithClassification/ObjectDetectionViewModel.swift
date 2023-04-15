//
//  ObjectDetectionViewModel.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 27/02/23.
//

import SwiftUI

@MainActor class ObjectDetectionViewModel: BaseViewModel {

    init() {
        super.init(worker: ObjectDetectionWorker())
    }
}
