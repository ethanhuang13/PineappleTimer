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

private var isCrownAtRight: Bool {
    return WKInterfaceDevice.current().crownOrientation == .right
}

struct TimerView: View {
    @EnvironmentObject var dataStorage: UserStatus
    @State private var time: TimeInterval = 0
    @State private var now = Date()
    @State private var showingInfoAlert = false
    @State private var showingResetTimerAlert = false

    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var mainText: some View {
        if dataStorage.status == .countingDown {
            return Text("Counting down. Focus.") // TODO: 調整不同倒數階段顯示的文字
        } else if time == 0 {
            return Text(isCrownAtRight ? "Rotate Digital Crown 👉" : "Rotate Digital Crown 👉 Reversed")
        } else if time > 0 && time < limit {
            return Text(isCrownAtRight ? "Keep rotating 👉" : "Keep rotating 👉 Reversed")
        } else if time == limit {
            return Text("Release it👌")
        } else {
            return Text(" ")
        }
    }

    var timeText: some View {
        Text(dataStorage.status == .countingDown ? dataStorage.end.timeIntervalSince(now).minuteSecondString : time.minuteSecondString)
    }

    var mainButton: some View {
        if dataStorage.status == .countingDown {
            return Button(action: {
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
            return Button(action: {
                self.showingInfoAlert = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Information")
                }
            }
            .alert(isPresented: $showingInfoAlert) {
                Alert(title: Text("About 🍍Timer"),
                      message: Text(NSLocalizedString("Every 🍍 is...", comment: "") + "\n\n" + appVersionString)
                        .font(.caption),
                      dismissButton: .cancel(Text("I See")))
            }
        }
    }

    var body: some View {
        VStack {
            if isCrownAtRight {
                self.mainText
                    .padding(.top)
            }

            Spacer()

            timeText
                .font(.largeTitle)
                .onReceive(timer) { _ in
                    guard self.dataStorage.status == .countingDown else {
                        return
                    }
                    self.now = Date()

                    if self.now >= self.dataStorage.end {
                        self.finishTimer()
                    }
            }

            Spacer()

            if isCrownAtRight {
                self.mainButton
            } else {
                self.mainText
                    .padding(.top)

                self.mainButton
                    .padding(.bottom)
            }
        }
        .navigationBarTitle("🍍Timer")
        .focusable(time < limit && dataStorage.currentPage == .timer) { isFocus in
            guard isFocus == false,
                self.time == limit else {
                    return
            }
            self.startTimer()
        }
        .digitalCrownRotation($time, from: 0, through: limit, by: limit / 16.67, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true)
    }

    func startTimer() {
        print("Go!")
        dataStorage.status = .countingDown

        let timeInterval = limit
        now = Date()
        dataStorage.end = now.addingTimeInterval(timeInterval)

        WKInterfaceDevice.current().play(.start)

        requestNotificationPermissions()

        reloadComplications()
    }

    func cancelTimer() {
        dataStorage.status = .idle
        time = 0
        WKInterfaceDevice.current().play(.failure)
        cancelLocalNotifications()

        reloadComplications()
    }

    func finishTimer() {
        dataStorage.status = .idle
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

private var appVersion: String = {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
}()

private var buildVersion: String = {
    return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
}()

private var appVersionString: String = {
    return "v\(appVersion)(\(buildVersion))"
}()
