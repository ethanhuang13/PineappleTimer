//
//  DatedRecord.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/14/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

private var dayFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}

struct DatedRecord {
    let date: Date
    let count: Int

    var dateString: String {
        dayFormatter.string(from: date)
    }

    var countString: String {
        String(count)
    }

    var 🍍String: String {
        String(repeating: "🍍", count: count)
    }
}

extension Array where Element == Date {
    func groupedBy(dateComponents: Set<Calendar.Component>) -> [Date: Int] {
        let cal = Calendar(identifier: .gregorian)
        let initial: [Date: Int] = [:]
        let groupedByDateComponents = reduce(into: initial) { dict, current in
            let components = cal.dateComponents(dateComponents, from: current)
            let date = cal.date(from: components)!
            let existing = dict[date] ?? 0
            dict[date] = existing + 1
        }

        return groupedByDateComponents
    }

    func datedRecords() -> [DatedRecord] {
        return self.groupedBy(dateComponents: [.year, .month, .day])
        .map { date, count in DatedRecord(date: date, count: count) }
        .sorted { $0.date > $1.date }
    }
}
