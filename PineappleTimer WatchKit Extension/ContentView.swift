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
let limit: Double = 25
#else
let limit: Double = 25
#endif

struct ContentView: View {
    @State var minutes: Double = 0
    @State var isCountingDown = false
    @State var now = Date()
    @State var end = Date()

    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var body: some View {
        VStack {
            if isCountingDown {
                Text("倒數中，專心做事")
            } else {
                if minutes == 0 {
                    Text("捲動錶冠來開始👉")
                }
                if minutes > 0 && minutes < limit {
                    Text("繼續捲動錶冠👉")
                }
                if minutes == limit {
                    Text("放開錶冠，開始倒數👌")
                }
            }

            Spacer()

            if isCountingDown {
                Text(end.timeIntervalSince(now).string)
                    .font(.title)
            } else {
                Text(String(Int(minutes)) + " 分鐘")
                    .font(.title)
            }

            Spacer()

            Text("我是 🍍 計時器")
                .font(.headline)
        }
        .focusable(minutes < limit) { isFocus in
            if isFocus == false,
                self.minutes == limit {
                self.startTimer()
            }
        }
        .digitalCrownRotation($minutes, from: 0, through: limit, by: limit / 25, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
        .onReceive(timer) { _ in
            if self.isCountingDown == true {
                self.now = Date()
            }

            if self.now >= self.end {
                self.stopTimer()
            }
        }
    }

    func startTimer() {
        print("Go!")
        isCountingDown = true

        let interval = limit * 60
        now = Date()
        end = Date().addingTimeInterval(interval)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { allow, error in
            guard allow else {
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "🍍 計時器"
            content.body = "時辰到了～"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: "stopTimer", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    func stopTimer() {
        isCountingDown = false
        minutes = 0
    }
}

var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "mm:ss"
    return dateFormatter
}()

extension TimeInterval {
    var string: String {
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
