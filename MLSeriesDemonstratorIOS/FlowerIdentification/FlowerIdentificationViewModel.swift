//
//  FlowerIdentificationViewModel.swift
//  MLSeriesDemonstratorIOS
//
//  Created by iago on 01/04/23.
//

import SwiftUI

@MainActor class FlowerIdentificationViewModel: BaseViewModel {

    init() {
        super.init(worker: FlowerIdentificationWorker())
    }
}
