//
//  DataStorage.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/14/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

let datesKey = "pineapple.dates"

class DataStorage: ObservableObject {
    @Published var dates: [Date] = [] {
        didSet {
            save()
        }
    }

    /// Call when appDidFinishLaunching
    func load(_ dates: [Date]) {
        self.dates = dates
    }

    func save() {
        UserDefaults.standard.set(dates, forKey: datesKey)
    }
}
