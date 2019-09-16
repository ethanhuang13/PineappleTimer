//
//  ListView.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/14/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var dataStorage: DataStorage

    var body: some View {
        if dataStorage.dates.isEmpty {
            return AnyView(Text("No history"))
        } else {
            return AnyView(
                List {
                    ForEach(dataStorage.dates.datedRecords(), id: \.date) { record in
                        ListItem(record: record)
                            .environmentObject(self.dataStorage)
                    }
                }
                .listStyle(CarouselListStyle())
                .contextMenu(menuItems: {
                    Button(action: {
                        WKInterfaceDevice.current().play(.success)
                        self.dataStorage.load([])
                    }) {
                        VStack {
                            Image(systemName: "trash")
                            Text("Clear All")
                        }
                    }
                })
                .navigationBarTitle("🍍History")
            )
        }
    }
}

struct ListItem: View {
    @EnvironmentObject var dataStorage: DataStorage
    @State var showDetail = false

    let record: DatedRecord
    var body: some View {
        NavigationLink(
            destination: RecordDetailView(showing: $showDetail, record: record)
                .environmentObject(self.dataStorage),
            isActive: $showDetail) {
                VStack(alignment: .leading) {
                    Text(record.dateString)
                        .font(.headline)
                    Text(record.🍍String)
                        .font(.subheadline)
                        .lineLimit(3)
                }
        }
        .padding(.vertical)
    }
}

struct RecordDetailView: View {
    @EnvironmentObject var dataStorage: DataStorage
    @Binding var showing: Bool

    let record: DatedRecord
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("🍍")
            Image(systemName: "multiply")
            Text("\(record.count)")
        }
        .font(.title)
        .lineLimit(10)
        .navigationBarTitle(record.dateString)
        .contextMenu(menuItems: {
            Button(action: {
                WKInterfaceDevice.current().play(.success)
                let cal = Calendar(identifier: .gregorian)
                let dates = self.dataStorage.dates.filter { cal.isDate($0, inSameDayAs: self.record.date) == false }
                self.dataStorage.load(dates)
                self.showing = false
            }) {
                VStack {
                    Image(systemName: "trash")
                    Text("Clear this day")
                }
            }
        })
    }
}

#if DEBUG

let previewDates: [Date] = [
    Date().addingTimeInterval(0),
    Date().addingTimeInterval(-2000),
    Date().addingTimeInterval(-4000),
    Date().addingTimeInterval(-6000),
    Date().addingTimeInterval(-8000),
    Date().addingTimeInterval(-10000),
    Date().addingTimeInterval(-12000),
    Date().addingTimeInterval(-14000),
    Date().addingTimeInterval(-16000),
    Date().addingTimeInterval(-18000),
    Date().addingTimeInterval(-20000),
    Date().addingTimeInterval(-22000),
    Date().addingTimeInterval(-24000),
    Date().addingTimeInterval(-26000),
    Date().addingTimeInterval(-28000),
    Date().addingTimeInterval(-30000),
    Date().addingTimeInterval(-86400),
    Date().addingTimeInterval(-86400 * 2),
    Date().addingTimeInterval(-86400 * 3),
    Date().addingTimeInterval(-86400 * 4),
    Date().addingTimeInterval(-86400 * 5),
    Date().addingTimeInterval(-86400 * 6),
]

var previewDataStorage: DataStorage {
    let dataStorage = DataStorage()
    dataStorage.load(previewDates)
    return dataStorage
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListView()
                .environmentObject(previewDataStorage)
                .modifier(AppleWatch3_38())
            ListView()
                .environmentObject(previewDataStorage)
                .modifier(AppleWatch3_42())
            ListView()
                .environmentObject(previewDataStorage)
                .modifier(AppleWatch5_40())
            ListView()
                .environmentObject(previewDataStorage)
                .modifier(AppleWatch5_44())

            ListItem(record: dataStorage.dates.datedRecords()[0])

            RecordDetailView(showing: .constant(true), record: dataStorage.dates.datedRecords()[0])
        }
    }
}

#endif
