//
//  ComplicationController.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/11/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import ClockKit

let startDate = Date().addingTimeInterval(-15 * 60)
let endDate = Date().addingTimeInterval(10 * 60)

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
//        handler([.forward, .backward])
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
//        handler(stardDate)
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
//        handler(endDate)
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry

        if let template = self.currentTemplate(family: complication.family) {
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached

        let template = self.placeholderTemplate(family: complication.family)
        handler(template)
    }

    func placeholderTemplate(family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        let appNameTextProvider = CLKSimpleTextProvider(text: "🍍計時器")
        let simpleTextProvider = CLKSimpleTextProvider(text: "🍍")
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .yellow, fillFraction: 1)

        switch family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = simpleTextProvider
            template.tintColor = .yellow
            template.ringStyle = .closed
            return template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTallBody()
            template.headerTextProvider = appNameTextProvider
            template.bodyTextProvider = simpleTextProvider
            return template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = simpleTextProvider
            return template
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = simpleTextProvider
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = simpleTextProvider
            return template
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = simpleTextProvider
            return template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeRingText()
            template.textProvider = simpleTextProvider
            return template
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = simpleTextProvider
            template.leadingTextProvider = CLKSimpleTextProvider(text: "0")
            template.trailingTextProvider = CLKSimpleTextProvider(text: "25")
            template.gaugeProvider = gaugeProvider
            return template
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            let circularTemplate = self.currentTemplate(family: .graphicCircular)
            template.circularTemplate = circularTemplate as! CLKComplicationTemplateGraphicCircular
            template.textProvider = simpleTextProvider
            return template
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = simpleTextProvider
            template.gaugeProvider = gaugeProvider
            return template
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularTextGauge()
            template.headerTextProvider = appNameTextProvider
            template.body1TextProvider = CLKRelativeDateTextProvider(date: endDate, style: .naturalFull, units: [.minute, .second])
            template.gaugeProvider = gaugeProvider
            return template
        @unknown default:
            return nil
        }
    }

    func currentTemplate(family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        let appNameTextProvider = CLKSimpleTextProvider(text: "🍍計時器")
        let relativeDateTextProvider = CLKRelativeDateTextProvider(date: endDate, style: .offsetShort, units: [.minute])
        let longRelativeDateTextProvider = CLKRelativeDateTextProvider(date: endDate, style: .naturalFull, units: [.minute, .second])
        let simpleTextProvider = CLKSimpleTextProvider(text: "🍍")
        let gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [.green, .yellow, .orange], gaugeColorLocations: [0, 0.2, 0.8], start: startDate, end: endDate)
        let fillFraction = Float(endDate.timeIntervalSince(Date()) / endDate.timeIntervalSince(startDate))

        switch family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = relativeDateTextProvider
            template.fillFraction = fillFraction
            template.tintColor = .yellow
            template.ringStyle = .closed
            return template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTallBody()
            template.headerTextProvider = appNameTextProvider
            template.bodyTextProvider = longRelativeDateTextProvider
            return template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = relativeDateTextProvider
            template.fillFraction = fillFraction
            return template
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = relativeDateTextProvider
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = longRelativeDateTextProvider
            return template
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = relativeDateTextProvider
            template.fillFraction = fillFraction
            return template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeRingText()
            template.textProvider = relativeDateTextProvider
            return template
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = simpleTextProvider
            template.leadingTextProvider = CLKSimpleTextProvider(text: "0")
            template.trailingTextProvider = CLKSimpleTextProvider(text: "25")
            template.gaugeProvider = gaugeProvider
            return template
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            let circularTemplate = self.currentTemplate(family: .graphicCircular)
            template.circularTemplate = circularTemplate as! CLKComplicationTemplateGraphicCircular
            template.textProvider = longRelativeDateTextProvider
            return template
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = simpleTextProvider
            template.gaugeProvider = gaugeProvider
            return template
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularTextGauge()
            template.headerTextProvider = appNameTextProvider
            template.body1TextProvider = CLKRelativeDateTextProvider(date: endDate, style: .naturalFull, units: [.minute, .second])
            template.gaugeProvider = gaugeProvider
            return template
        @unknown default:
            return nil
        }
    }
}
