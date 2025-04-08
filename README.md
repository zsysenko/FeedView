# FeedView

A reusable SwiftUI component that mimics TikTok/Instagram Story vertical scrolling with smooth 3D transitions.

## Features

- Vertical paging with `.scrollTransition`
- 3D rotation and opacity effect
- Tracks currently centered index
- Fully customizable content

## Usage

```swift
FeedView(data: items) { item in
    ZStack {
        Color(item.color)
        Text(item.title)
            .foregroundStyle(.white)
            .font(.largeTitle)
    }
}
