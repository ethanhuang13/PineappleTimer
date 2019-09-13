//
//  ListHostingController.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/14/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class ListHostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        return AnyView(
            ListView()
                .environmentObject(dataStorage)
        )
    }
}

