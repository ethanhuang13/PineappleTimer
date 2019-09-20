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

class ListHostingController: WKHostingController<ListViewContainer> {
    override var body: ListViewContainer {
        return ListViewContainer()
    }

    override func didAppear() {
        print("didAppear ListView")
        userStatus.currentPage = .list
    }
}

struct ListViewContainer: View {
    var body: some View {
        ListView()
            .environmentObject(userStatus)
    }
}
