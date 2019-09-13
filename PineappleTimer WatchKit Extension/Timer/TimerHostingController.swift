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

class TimerHostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        return AnyView(
            TimerView()
                .environmentObject(dataStorage)
        )
    }
}
