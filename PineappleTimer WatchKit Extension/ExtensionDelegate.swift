//
//  ExtensionDelegate.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/11/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import UserNotifications
import WatchKit

let userStatus = UserStatus()

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        UNUserNotificationCenter.current().delegate = self

        let dates: [Date] = (UserDefaults.standard.array(forKey: datesKey) as? [Date]) ?? []
        userStatus.load(dates)

        #if DEBUG
//        dataStorage.load(previewDates)
        #endif
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        cancelLocalNotifications()
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        scheduleLocalNotifications()
        scheduleBackgroundRefreshTask()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                reloadComplications()
                print("backgroundTask completed")
                backgroundTask.setTaskCompletedWithSnapshot(true)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                print("snapshotTask completed. reasonForSnapshot: \(snapshotTask.reasonForSnapshot.rawValue)")
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "startTimer" {
            userStatus.status = .countingDown

            let timeInterval = limit
            let now = Date()
            userStatus.end = now.addingTimeInterval(timeInterval)

            WKInterfaceDevice.current().play(.start)

            switch WKExtension.shared().applicationState {
            case .active:
                reloadComplications()
            case .background, .inactive:
                reloadComplicationsInBackground()
            @unknown default:
                reloadComplicationsInBackground()
            }
        }
    }
}

func requestNotificationPermissions() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { allow, error in
        guard allow else {
            return
        }
    }
}

private func scheduleLocalNotifications() {
    guard userStatus.status == .countingDown else {
        return
    }

    func scheduleTakeABreak() {
        let timeInterval = userStatus.end.timeIntervalSince(Date())
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Time is up", comment: "")
        content.body = NSLocalizedString("Take a break, then start another one.", comment: "")
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "stopTimer", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleStartNext() {
        let startTimerAction = UNNotificationAction(identifier: "startTimer", title: NSLocalizedString("Start", comment: "Start"), options: [])
        let category = UNNotificationCategory(identifier: "startTimer", actions: [startTimerAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])

        let timeInterval: TimeInterval = userStatus.end.timeIntervalSince(Date()) + 60 * 5
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "startTimer"
        content.title = NSLocalizedString("Let's 🍍", comment: "")
        content.body = NSLocalizedString("Start another 🍍 if you are ready.", comment: "")
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "startTimer", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    switch userStatus.status {
    case .idle:
        break
    case .countingDown:
        scheduleTakeABreak()
        scheduleStartNext()
    }
}

private func scheduleBackgroundRefreshTask() {
    guard userStatus.status == .countingDown else {
        return
    }

    WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: userStatus.end.addingTimeInterval(1), userInfo: nil) { error in }
}

func cancelLocalNotifications() {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["stopTimer", "startTimer"])
}

func reloadComplications() {
    let server = CLKComplicationServer.sharedInstance()
    for complication in server.activeComplications ?? [] {
        server.reloadTimeline(for: complication)
        print("Reload complication: \(complication.family.rawValue)")
    }
}

func reloadComplicationsInBackground() {
    WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(), userInfo: nil) { error in }
}
