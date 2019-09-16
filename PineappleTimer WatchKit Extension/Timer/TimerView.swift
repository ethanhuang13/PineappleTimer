//
//  TimerView.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/11/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import Combine
import SwiftUI
import UserNotifications

struct TimerView: View {
    @EnvironmentObject var dataStorage: DataStorage
    @State private var time: TimeInterval = 0
    @State private var now = Date()
    @State private var showingInfoAlert = false
    @State private var showingResetTimerAlert = false

    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var topText: some View {
        if dataStorage.isCountingDown {
            return Text("Counting down. Focus.") // TODO: 調整不同倒數階段顯示的文字
        } else if time == 0 {
            return Text("Rotate Digital Crown 👉")
        } else if time > 0 && time < limit {
            return Text("Keep rotating 👉")
        } else if time == limit {
            return Text("Release it👌")
        } else {
            return Text(" ")
        }
    }

    var timeText: some View {
        Text(dataStorage.isCountingDown ? dataStorage.end.timeIntervalSince(now).minuteSecondString : time.minuteSecondString)
    }

    var body: some View {
        VStack {
            topText
                .padding(.top)

            Spacer()

            timeText
                .font(.largeTitle)
                .onReceive(timer) { _ in
                    guard self.dataStorage.isCountingDown else {
                        return
                    }
                    self.now = Date()

                    if self.now >= self.dataStorage.end {
                        self.finishTimer()
                    }
            }

            Spacer()

            if dataStorage.isCountingDown {
                Button(action: {
                    self.showingResetTimerAlert = true
                }) {
                    HStack {
                        Image(systemName: "hand.raised") //"arrow.clockwise")
                        Text("Cancel Timer")
                    }
                }
                .alert(isPresented: $showingResetTimerAlert) {
                    Alert(title: Text("Cancel Timer?"),
                          message: Text("This 🍍 will be cancelled."),
                          primaryButton: .destructive(Text("Cancel 🍍"), action: {
                            self.cancelTimer()
                          }),
                          secondaryButton: .cancel(Text("Don't Cancel"))
                    )
                }
            } else {
                Button(action: {
                    self.showingInfoAlert = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Information")
                    }
                }
                .alert(isPresented: $showingInfoAlert) {
                    Alert(title: Text("About 🍍Timer"),
                          message: Text("Every 🍍 is...")
                            .font(.caption),
                          dismissButton: .cancel(Text("I See")))
                }
            }
        }
        .navigationBarTitle("🍍Timer")
        .focusable(time < limit) { isFocus in
            guard isFocus == false,
                self.time == limit else {
                    return
            }
            self.startTimer()
        }
        .digitalCrownRotation($time, from: 0, through: limit, by: limit / 25, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true)
//        .contextMenu { // This is not working
//            if isCountingDown {
//                Button(action: {
//                    WKInterfaceDevice.current().play(.failure)
//                    self.cancelTimer()
//                }) {
//                    VStack {
//                        Image(systemName: "arrow.clockwise")
//                        Text("取消計時")
//                    }
//                }
//            }
//        }
    }

    func startTimer() {
        print("Go!")
        dataStorage.isCountingDown = true

        let timeInterval = limit
        now = Date()
        dataStorage.end = now.addingTimeInterval(timeInterval)

        WKInterfaceDevice.current().play(.start)

        requestNotificationPermissions()

        reloadComplications()
    }

    func cancelTimer() {
        dataStorage.isCountingDown = false
        time = 0
        WKInterfaceDevice.current().play(.failure)
        cancelLocalNotification()

        reloadComplications()
    }

    func finishTimer() {
        dataStorage.isCountingDown = false
        time = 0
        WKInterfaceDevice.current().play(.success)

        dataStorage.dates.append(Date())

        if WKExtension.shared().applicationState == .active {
            reloadComplications()
        }
    }
}

extension TimeInterval {
    var minuteSecondString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: self) ?? ""
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimerView()
                .modifier(AppleWatch3_38())
            TimerView()
                .modifier(AppleWatch3_42())
            TimerView()
                .modifier(AppleWatch5_40())
            TimerView()
                .modifier(AppleWatch5_44())
        }
    }
}
