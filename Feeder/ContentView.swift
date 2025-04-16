//
//  ContentView.swift
//  Feeder
//
//  Created by EVGENY SYSENKA on 07/04/2025.
//

import SwiftUI

struct FeedItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
    let trackURL: URL? = nil
    let gif: [UIImage]? = nil
}

struct ContentView: View {
    
    @State private var index = 0
    
    let values = [
        FeedItem(title: "First", color: .blue),
        FeedItem(title: "Second", color: .yellow),
        FeedItem(title: "Third", color: .green)
    ]
    
    var body: some View {
        FeedView(data: values, currentIndex: $index, style: .rotation) { item in
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
    ContentView()
}
