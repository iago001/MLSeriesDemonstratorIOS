//
//  ImageClassificationViewModel.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 26/02/23.
//

import SwiftUI

@MainActor class ImageClassificationViewModel: BaseViewModel {

    init() {
        super.init(worker: ImageClassificationWorker())
    }
}
