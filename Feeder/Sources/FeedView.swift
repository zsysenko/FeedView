//
//  FeedView.swift
//  Feeder
//
//  Created by EVGENY SYSENKA on 08/04/2025.
//

import SwiftUI

struct FeedView<Data, Content>: View where Data: RandomAccessCollection,
                                           Data.Element: Identifiable,
                                           Content: View {
    
    typealias ContentClosure = (Data.Element) -> Content
    
    private let data: Data
    private let content: ContentClosure
    
    @Binding var currentIndex: Int
    
    init(data: Data, currentIndex: Binding<Int>, @ViewBuilder content: @escaping ContentClosure) {
        self.data = data
        self.content = content
        self._currentIndex = currentIndex
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(data.enumerated()), id: \.0) { index, item in
                        content(item)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background { GeometryReader { geometry in
                                let frame = geometry.frame(in: .global)
                                Color.clear
                                    .preference(
                                        key: ViewOffsetPreferenceKey.self,
                                        value: [index : frame.midY]
                                    )
                            }}
                            .scrollTransition { content, phase in
                                content
                                    .rotation3DEffect(
                                        .degrees(-phase.value * 90),
                                        axis: (x: 1, y: 0, z: 0),
                                        anchor: UnitPoint.anchor(phaseValue: phase.value),
                                        perspective: 1
                                    )
                                    .opacity(1 - abs(phase.value) * 0.5)
                            }
                    }
                }
            }
            .scrollTargetBehavior(.paging)
            .onPreferenceChange(ViewOffsetPreferenceKey.self) { values in
                     let screenCenterY = geometry.frame(in: .global).midY
                     let closest = values.min(by: {
                         abs($0.value - screenCenterY) < abs($1.value - screenCenterY)
                     })
                     if let closestIndex = closest?.key {
                         currentIndex = closestIndex
                     }
                 }
        }
        .ignoresSafeArea()
    }
}

private extension UnitPoint {
    static func anchor(phaseValue: Double) -> UnitPoint {
        if phaseValue < 0 {
            return .bottom
        } else if phaseValue == 0 {
            return .center
        } else if phaseValue > 0 {
            return .top
        }
        return .center
    }
}

private struct ViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct PreviewContent: View {
    @State private var index = 0
    
    let values = [
        FeedItem(title: "One", color: .blue),
        FeedItem(title: "Two", color: .yellow),
        FeedItem(title: "Three", color: .green)
    ]
    
    var body: some View {
        FeedView(data: values, currentIndex: $index) { item in
            ZStack {
                Color(item.color)
                
                Text(item.title)
                    .foregroundStyle(.white)
                    .font(.title)
            }
        }
        .overlay(alignment: .top) {
            Text("Current page: \(index)")
                .font(.headline)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding(.top, 40)
        }
    }
}

#Preview {
    PreviewContent()
}
