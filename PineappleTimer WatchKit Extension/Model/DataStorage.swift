//
//  DataStorage.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/14/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

#if DEBUG
let limit: Double = 0.3 * 60
#else
let limit: Double = 25 * 60
#endif

let datesKey = "pineapple.dates"

class DataStorage: ObservableObject {
    @Published var dates: [Date] = [] {
        didSet {
            save()
        }
    }

    @Published var end = Date()
    var start: Date { end.addingTimeInterval(limit) }
    @Published var isCountingDown = false

    /// Call when appDidFinishLaunching
    func load(_ dates: [Date]) {
        self.dates = dates
    }

    func save() {
        UserDefaults.standard.set(dates, forKey: datesKey)
    }
}
