//
//  OffsertPreferenceModifier.swift
//  Feeder
//
//  Created by EVGENY SYSENKA on 15/04/2025.
//

import SwiftUI

struct ViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}

struct OffsetPreferenceModifier: ViewModifier {
    let index: Int
    
    func body(content: Content) -> some View {
        content
             .background(GeometryReader { geometry in
                     let frame = geometry.frame(in: .global)
                     Color.clear.preference(
                         key: ViewOffsetPreferenceKey.self,
                         value: [index : frame.midY]
                     )
                 })
    }
}

extension View {
    func trackScrollOffset(index: Int) -> some View {
        self.modifier(OffsetPreferenceModifier(index: index))
    }
}

extension View {
    func onIndexChange(geometry: GeometryProxy, perform: @escaping (Int) -> Void) -> some View {
        self.onPreferenceChange(ViewOffsetPreferenceKey.self) { values in
            let screenCenterY = geometry.frame(in: .global).midY
            let closest = values.min(by: {
                abs($0.value - screenCenterY) < abs($1.value - screenCenterY)
            })
            if let closestIndex = closest?.key {
                perform(closestIndex)
            }
        }
    }
}


