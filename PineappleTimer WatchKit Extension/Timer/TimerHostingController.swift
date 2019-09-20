//
//  TimerController.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/11/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class TimerHostingController: WKHostingController<TimerViewContainer> {
    override var body: TimerViewContainer {
        return TimerViewContainer()
    }

    override func didAppear() {
        print("didAppear TimerView")
        userStatus.currentPage = .timer
    }
}

struct TimerViewContainer: View {
    var body: some View {
        TimerView()
            .environmentObject(userStatus)
    }
}
