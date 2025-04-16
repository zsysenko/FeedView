//
//  FeedView.swift
//  Feeder
//
//  Created by EVGENY SYSENKA on 08/04/2025.
//

import SwiftUI


enum FeedViewStyle {
    case plain
    case rotation
    case cardFlip
}

struct FeedView<Data, Content>: View where Data: RandomAccessCollection,
                                           Data.Element: Identifiable,
                                           Content: View {
    
    typealias ContentClosure = (Data.Element) -> Content
    
    private let data: Data
    private let content: ContentClosure
    private let style: FeedViewStyle
    
    @Binding var pageIndex: Int
    
    init(
        data: Data,
        currentIndex: Binding<Int>,
        style: FeedViewStyle = .cardFlip,
        @ViewBuilder content: @escaping ContentClosure
    ) {
        self.data = data
        self.content = content
        self.style = style
        
        self._pageIndex = currentIndex
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(data.enumerated()), id: \.0) { index, item in
                        content(item)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .trackScrollOffset(index: index)
                            .applyScrollTransitionStyle(style)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .onIndexChange(geometry: geometry) { index in
                pageIndex = index
            }
        }
        .ignoresSafeArea()
    }
}

private extension View {
    
    @ViewBuilder
    func applyScrollTransitionStyle(_ style: FeedViewStyle) -> some View {
        switch style {
            case .plain:
                self.scrollTransition { content, phase in
                    content
                        .blur(radius: abs(phase.value) * 7)
                        .opacity(1 - abs(phase.value) * 0.25)
                }
                
            case .rotation:
                self.scrollTransition { content, phase in
                    content
                        .rotation3DEffect(
                            .degrees(-phase.value * 90),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: UnitPoint(x: 0.5, y: 0.5 - phase.value * 0.5),
                            perspective: 1.5
                        )
                        .opacity(1 - abs(phase.value) * 0.25)
                }
            case .cardFlip:
                self.scrollTransition { content, phase in
                    content
                        .rotation3DEffect(
                            .degrees(-phase.value * 180),
                            axis: (x: 0, y: 1, z: 0),
                            anchor: .center
                        )
                        .opacity(1 - abs(phase.value) * 0.25)
                }
        }
        
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
                    .font(.system(size: 50, weight: .bold))
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
        .background(Color.black)
}
