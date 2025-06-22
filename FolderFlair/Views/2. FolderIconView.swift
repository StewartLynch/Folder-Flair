//
//----------------------------------------------
// Original project: FolderFlair
// by  Stewart Lynch on 2025-06-02
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



// IconView.swift
import SwiftUI
struct FolderIconView: View {
    @Bindable var appState: AppState
    var body: some View {
        ZStack {
            TintedFolderView(folderTint: appState.folderTint, tintFolder: appState.tintFolder, isNew: appState.isNew)
            switch appState.iconType {
            case .symbol:
                if appState.showIcon {
                    DraggableSymbolView(
                        appState: appState,
                        maxOffsetX: 90,
                        maxOffsetY: 50
                    )
                }
            case .image:
                if let iconImage = appState.iconImage {
                    DraggableImageView(
                        image: iconImage,
                        appState: appState,
                        maxOffsetX: 90,
                        maxOffsetY: 50
                    )
                }
            case .emoji:
                if appState.showIcon {
                    DraggableEmojiView(
                        appState: appState,
                        maxOffsetX: 90,
                        maxOffsetY: 50
                    )
                }
            }

        }
        .mask(
            Image(appState.isNew ? .defaultIcon26 : .defaultIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
        )
    }
}

#Preview {
    FolderIconView(appState: AppState())
}
