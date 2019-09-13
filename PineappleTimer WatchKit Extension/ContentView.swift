//
//  ContentView.swift
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

struct ContentView: View {
    @State var time: TimeInterval = 0
    @State var isCountingDown = false
    @State var now = Date()
    @State var end = Date()

    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var topText: some View {
        if time == 0 {
            return Text("轉動錶冠來開始 👉")
        } else if time > 0 && time < limit {
            return Text("繼續轉動錶冠 👉")
        } else if time == limit {
            return Text("放開錶冠，開始倒數 👌")
        } else {
            return Text(" ")
        }
    }

    var bottomText: some View {
        if isCountingDown {
            return Text("倒數中，專心做事")
        } else {
            return Text("25 分鐘為一個 🍍")
        }
    }

    var body: some View {
        VStack {
            if isCountingDown {
                Button(action: {
                    self.stopTimer()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("取消計時")
                    }
                }
            } else {
                topText
                    .padding(.top)
            }

            Spacer()

            Text(isCountingDown ? end.timeIntervalSince(now).minuteSecondString : time.minuteSecondString)
                .font(.largeTitle)
                .onReceive(timer) { _ in
                    guard self.isCountingDown else {
                        return
                    }
                    self.now = Date()

                    if self.now >= self.end {
                        WKInterfaceDevice.current().play(.success)
                        self.stopTimer()
                    }
            }

            Spacer()

            bottomText
                .lineLimit(3)
                .multilineTextAlignment(.center)
        }
        .focusable(time < limit) { isFocus in
            if isFocus == false,
                self.time == limit {
                self.startTimer()
            }
        }
        .digitalCrownRotation($time, from: 0, through: limit, by: limit / 25, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true)
        .contextMenu {
            if isCountingDown {
                Button(action: {
                    WKInterfaceDevice.current().play(.failure)
                    self.stopTimer()
                }) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                        Text("取消計時")
                    }
                }
            }
        }
        .navigationBarTitle("🍍 計時器")
    }

    func startTimer() {
        print("Go!")
        isCountingDown = true

        let interval = limit
        now = Date()
        end = now.addingTimeInterval(interval)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { allow, error in
            guard allow else {
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "🍍 計時器"
            content.body = "休息一下，你的時辰到了～"
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: "stopTimer", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    func stopTimer() {
        isCountingDown = false
        time = 0
    }
}

extension TimeInterval {
    var minuteSecondString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: self) ?? ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
