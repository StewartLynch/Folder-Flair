//
//----------------------------------------------
// Original project: FolderFlair
// by  Stewart Lynch on 2025-06-03
//
// Follow me on Mastodon: https://iosdev.space/@StewartLynch
// Follow me on Threads: https://www.threads.net/@stewartlynch
// Follow me on Bluesky: https://bsky.app/profile/stewartlynch.bsky.social
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Email: slynch@createchsol.com
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2025 CreaTECH Solutions. All rights reserved.

import SwiftUI

struct DraggableSymbolView: View {
    @Bindable var appState: AppState
    var maxOffsetX: CGFloat
    var maxOffsetY: CGFloat

    @State private var tempOffset: CGSize = .zero

    var body: some View {
        Image(systemName: appState.symbolName)
            .font(.system(size: appState.iconSize))
            .foregroundStyle(appState.symbolColor)
            .rotationEffect(.degrees(appState.symbolRotation))
            .shadow(color: appState.hasShadow ? .black.opacity(0.4) : Color.clear, radius: 5, x: 1, y: 5)
            .offset(x: appState.symbolOffset.width + tempOffset.width, y:  appState.symbolOffset.height + tempOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let clampedX = min(max(value.translation.width +  appState.symbolOffset.width, -maxOffsetX), maxOffsetX) - appState.symbolOffset.width
                        let clampedY = min(max(value.translation.height + appState.symbolOffset.height, -maxOffsetY), maxOffsetY) - appState.symbolOffset.height
                        tempOffset = CGSize(width: clampedX, height: clampedY)
                    }
                    .onEnded { _ in
                        appState.symbolOffset.width += tempOffset.width
                        appState.symbolOffset.height += tempOffset.height
                        tempOffset = .zero
                    }
            )
    }
}
