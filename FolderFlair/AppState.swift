//
//----------------------------------------------
// Original project: FolderFlair
// by  Stewart Lynch on 2025-06-04
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
enum IconType {
    case symbol, image, emoji
}

@Observable
class AppState {
    var symbolName: String = "sparkles"
    var selectedEmoji = "😀"
    var folderTint: Color = .red
    var symbolColor: Color = .white
    var iconSize: Double = 65
    var symbolRotation: Double = 0
    var symbolOffset: CGSize = CGSize(width: 0, height: 10)
    var hasShadow: Bool = true
    var showIcon: Bool = true
    var tintFolder: Bool = true

    // NEW
    var iconType: IconType = .symbol
    var iconImage: NSImage? = nil

    var refreshToken: String {
        let imageIdentifier = iconImage.map { "\($0.hash)" } ?? "nil"
        return "\(symbolName)-\(folderTint.description)-\(symbolColor.description)-\(symbolOffset.width)-\(symbolOffset.height)-\(hasShadow)-\(showIcon)-\(tintFolder)-\(iconType)-\(imageIdentifier)"
    }
}
