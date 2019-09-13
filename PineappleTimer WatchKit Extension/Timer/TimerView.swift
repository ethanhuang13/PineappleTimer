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

#if DEBUG
let limit: Double = 25 * 60
#else
let limit: Double = 25 * 60
#endif

struct TimerView: View {
    @EnvironmentObject var dataStorage: DataStorage
    @State private var time: TimeInterval = 0
    @State private var now = Date()
    @State private var end = Date()
    @State private var isCountingDown = false
    @State private var showingInfoAlert = false
    @State private var showingResetTimerAlert = false

    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var topText: some View {
        if isCountingDown {
            return Text("倒數中，專心做事")
        } else if time == 0 {
            return Text("轉動錶冠來開始 👉")
        } else if time > 0 && time < limit {
            return Text("繼續轉動錶冠 👉")
        } else if time == limit {
            return Text("放開錶冠，開始倒數 👌")
        } else {
            return Text(" ")
        }
    }

    var timeText: some View {
        Text(isCountingDown ? end.timeIntervalSince(now).minuteSecondString : time.minuteSecondString)
    }

    var body: some View {
        VStack {
            topText
                .padding(.top)

            Spacer()

            timeText
                .font(.largeTitle)
                .onReceive(timer) { _ in
                    guard self.isCountingDown else {
                        return
                    }
                    self.now = Date()

                    if self.now >= self.end {
                        self.finishTimer()
                    }
            }

            Spacer()

            if isCountingDown {
                Button(action: {
                    self.showingResetTimerAlert = true
                }) {
                    HStack {
                        Image(systemName: "hand.raised") //"arrow.clockwise")
                        Text("取消計時")
                    }
                }
                .alert(isPresented: $showingResetTimerAlert) {
                    Alert(title: Text("取消計時？🤔"),
                          message: Text("這個🍍會作廢喔"),
                          primaryButton: .destructive(Text("取消計時"), action: {
                            self.cancelTimer()
                          }),
                          secondaryButton: .cancel(Text("我不要取消"))
                    )
                }
            } else {
                Button(action: {
                    self.showingInfoAlert = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("說明")
                    }
                }
                .alert(isPresented: $showingInfoAlert) {
                    Alert(title: Text("關於🍍計時器"),
                          message: Text("🍍計時器採用簡化版的「番茄鐘工作法」，以每 25 分鐘為工作計時單位。期間必須保持專注。轉動錶冠來開始倒數～"),
                          dismissButton: .cancel(Text("我明白了")))
                }
            }
        }
        .navigationBarTitle("🍍計時器")
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
        isCountingDown = true

        let timeInterval = limit
        now = Date()
        end = now.addingTimeInterval(timeInterval)

        WKInterfaceDevice.current().play(.start)

        setupLocalNotification(timeInterval: timeInterval)
    }

    func cancelTimer() {
        isCountingDown = false
        time = 0
        WKInterfaceDevice.current().play(.failure)
    }

    func finishTimer() {
        isCountingDown = false
        time = 0
        WKInterfaceDevice.current().play(.success)

        dataStorage.dates.append(Date())
    }

    func setupLocalNotification(timeInterval: TimeInterval) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { allow, error in
            guard allow else {
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "🍍計時器"
            content.body = "休息一下，你的時辰到了～"
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: "stopTimer", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
                .modifier(AppleWatch4_40())
            TimerView()
                .modifier(AppleWatch4_44())
        }
    }
}
