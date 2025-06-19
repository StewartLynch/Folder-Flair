//
//----------------------------------------------
// Original project: EmojiPicker
// by  Stewart Lynch on 2025-06-18
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

@Observable
class EmojiData {
    var emojis: [Emoji] = []
    
    init() {
        loadEmojis()
    }
    
    private func loadEmojis() {
        guard let url = Bundle.main.url(forResource: "Emoji", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Emoji].self, from: data) else {
            print("Failed to load emojis.")
            return
        }
        emojis = decoded
    }
}
