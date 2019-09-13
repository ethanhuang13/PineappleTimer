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
            return AnyView(Text("沒有歷史紀錄"))
        } else {
            return AnyView(
                List(dataStorage.dates.datedRecords(), id: \.date) { record in
                    VStack(alignment: .leading) {
                        Text(record.dateString)
                            .font(.headline)

                        Text(record.🍍String)
                            .font(.subheadline)
                            .lineLimit(3)
                    }
                    .padding(.vertical)
                }
                .contextMenu(menuItems: {
                    Button(action: {
                        WKInterfaceDevice.current().play(.success)
                        self.dataStorage.load([])
                    }) {
                        VStack {
                            Image(systemName: "trash")
                            Text("清除所有紀錄")
                        }
                    }
                })
                .navigationBarTitle("🍍歷史紀錄")
            )
        }
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
    Date().addingTimeInterval(-32000),
    Date().addingTimeInterval(-34000),
    Date().addingTimeInterval(-36000),
    Date().addingTimeInterval(-38000),
    Date().addingTimeInterval(-40000),
    Date().addingTimeInterval(-42000),
    Date().addingTimeInterval(-44000),
    Date().addingTimeInterval(-46000),
    Date().addingTimeInterval(-48000),
    Date().addingTimeInterval(-50000),
    Date().addingTimeInterval(-52000),
    Date().addingTimeInterval(-54000),
    Date().addingTimeInterval(-56000),
    Date().addingTimeInterval(-58000)
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
                .modifier(AppleWatch4_40())
            ListView()
                .environmentObject(previewDataStorage)
                .modifier(AppleWatch4_44())
        }
    }
}

#endif
