//
//  ComplicationController.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/11/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import ClockKit

// See cheat sheet for all complication style https://theswiftdev.com/2016/04/28/clockkit-complications-cheat-sheet/

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        if dataStorage.isCountingDown {
            handler(dataStorage.end.addingTimeInterval(-limit))
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        if dataStorage.isCountingDown {
            handler(dataStorage.end)
        } else {
            handler(nil)
        }
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry

        if dataStorage.isCountingDown,
            let template = self.currentTemplate(family: complication.family) {
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        } else if let template = self.placeholderTemplate(family: complication.family) {
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        } else {
            handler(nil)
        }
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
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .yellow, fillFraction: 0)
        let tintColor = UIColor.yellow

        switch family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = simpleTextProvider
            template.tintColor = tintColor
            return template

        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = simpleTextProvider
            template.tintColor = tintColor
            return template

        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = simpleTextProvider
            template.tintColor = tintColor
            return template

        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTallBody()
            template.headerTextProvider = appNameTextProvider
            template.bodyTextProvider = simpleTextProvider
            template.tintColor = tintColor
            return template

        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = simpleTextProvider
            template.tintColor = tintColor
            return template

        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = simpleTextProvider
            template.tintColor = tintColor
            return template

        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = appNameTextProvider
            template.tintColor = tintColor
            return template

        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = simpleTextProvider
            template.leadingTextProvider = CLKSimpleTextProvider(text: "0")
            template.trailingTextProvider = CLKSimpleTextProvider(text: "25")
            template.gaugeProvider = gaugeProvider
            return template

        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = simpleTextProvider
            template.gaugeProvider = gaugeProvider
            return template

        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            let circularTemplate = self.placeholderTemplate(family: .graphicCircular)
            template.circularTemplate = circularTemplate as! CLKComplicationTemplateGraphicCircular
            template.textProvider = simpleTextProvider
            return template

        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularTextGauge()
            template.headerTextProvider = appNameTextProvider
            template.body1TextProvider = CLKRelativeDateTextProvider(date: dataStorage.end, style: .naturalFull, units: [.minute, .second])
            template.gaugeProvider = gaugeProvider
            return template

        @unknown default:
            return nil
        }
    }

    func currentTemplate(family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        let appNameTextProvider = CLKSimpleTextProvider(text: "🍍計時器")
        let relativeDateTextProvider = CLKRelativeDateTextProvider(date: dataStorage.end, style: .offsetShort, units: [.minute])
        let longRelativeDateTextProvider = CLKRelativeDateTextProvider(date: dataStorage.end, style: .naturalFull, units: [.minute, .second])
        let simpleTextProvider = CLKSimpleTextProvider(text: "🍍")
        let gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [.green, .yellow, .orange], gaugeColorLocations: [0, 0.2, 0.8], start: dataStorage.end.addingTimeInterval(-limit), end: dataStorage.end)
        let tintColor = UIColor.yellow

        switch family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = simpleTextProvider
            template.line2TextProvider = relativeDateTextProvider
            template.tintColor = tintColor
            return template

        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = simpleTextProvider
            template.line2TextProvider = longRelativeDateTextProvider
            template.tintColor = tintColor
            return template

        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = simpleTextProvider
            template.line2TextProvider = relativeDateTextProvider
            template.tintColor = tintColor
            return template

        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTallBody()
            template.headerTextProvider = appNameTextProvider
            template.bodyTextProvider = longRelativeDateTextProvider
            template.tintColor = tintColor
            return template

        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = relativeDateTextProvider
            template.tintColor = tintColor
            return template

        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = relativeDateTextProvider
            template.tintColor = tintColor
            return template

        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = longRelativeDateTextProvider
            template.tintColor = tintColor
            return template

        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerGaugeText()
            template.outerTextProvider = simpleTextProvider
            template.leadingTextProvider = CLKSimpleTextProvider(text: "0")
            template.trailingTextProvider = CLKSimpleTextProvider(text: "25")
            template.gaugeProvider = gaugeProvider
            return template

        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = simpleTextProvider
            template.gaugeProvider = gaugeProvider
            return template

        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            let circularTemplate = self.currentTemplate(family: .graphicCircular)
            template.circularTemplate = circularTemplate as! CLKComplicationTemplateGraphicCircular
            template.textProvider = longRelativeDateTextProvider
            return template

        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularTextGauge()
            template.headerTextProvider = appNameTextProvider
            template.body1TextProvider = CLKRelativeDateTextProvider(date: dataStorage.end, style: .naturalFull, units: [.minute, .second])
            template.gaugeProvider = gaugeProvider
            return template

        @unknown default:
            return nil
        }
    }
}