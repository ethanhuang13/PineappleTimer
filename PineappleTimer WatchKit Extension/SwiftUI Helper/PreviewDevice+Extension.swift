//
//  PreviewDevice+Extension.swift
//  PineappleTimer WatchKit Extension
//
//  Created by Ethanhuang on 9/8/19.
//  Copyright © 2019 Elaborapp Co., Ltd. All rights reserved.
//

import SwiftUI

/// See spec here https://developer.apple.com/documentation/swiftui/view/3278637-previewdevice
extension PreviewDevice {
    static let watch3_38 = PreviewDevice(rawValue: "Apple Watch Series 3 - 38mm")
    static let watch3_42 = PreviewDevice(rawValue: "Apple Watch Series 3 - 42mm")
    static let watch4_40 = PreviewDevice(rawValue: "Apple Watch Series 4 - 40mm")
    static let watch4_44 = PreviewDevice(rawValue: "Apple Watch Series 4 - 44mm")
    static let watch5_40 = PreviewDevice(rawValue: "Apple Watch Series 5 - 40mm")
    static let watch5_44 = PreviewDevice(rawValue: "Apple Watch Series 5 - 44mm")
}

struct AppleWatch3_38: ViewModifier {
    func body(content: _ViewModifier_Content<AppleWatch3_38>) -> some View {
        content
            .previewDevice(.watch3_38)
            .previewDisplayName("Series 3 38mm")
    }
}

struct AppleWatch3_42: ViewModifier {
    func body(content: _ViewModifier_Content<AppleWatch3_42>) -> some View {
        content
            .previewDevice(.watch3_42)
            .previewDisplayName("Series 3 42mm")
    }
}

struct AppleWatch4_40: ViewModifier {
    func body(content: _ViewModifier_Content<AppleWatch4_40>) -> some View {
        content
            .previewDevice(.watch4_40)
            .previewDisplayName("Series 4 40mm")
    }
}

struct AppleWatch4_44: ViewModifier {
    func body(content: _ViewModifier_Content<AppleWatch4_44>) -> some View {
        content
            .previewDevice(.watch4_44)
            .previewDisplayName("Series 4 44mm")
    }
}

struct AppleWatch5_40: ViewModifier {
    func body(content: _ViewModifier_Content<AppleWatch5_40>) -> some View {
        content
            .previewDevice(.watch5_40)
            .previewDisplayName("Series 5 40mm")
    }
}

struct AppleWatch5_44: ViewModifier {
    func body(content: _ViewModifier_Content<AppleWatch5_44>) -> some View {
        content
            .previewDevice(.watch4_44)
            .previewDisplayName("Series 5 44mm")
    }
}
