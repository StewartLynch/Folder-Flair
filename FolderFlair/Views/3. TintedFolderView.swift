//
//----------------------------------------------
// Original project: ColoredFolder
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



import SwiftUI

struct TintedFolderView: View {
    let folderTint: Color
    let tintFolder: Bool
    var body: some View {
        if let nsImage = NSImage(named: "DefaultIcon") {
            if tintFolder {
                if let tinted = nsImage.tintedWithShading(using: NSColor(folderTint)) {
                    Image(nsImage: tinted)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } else {
                    Text("Could not tint folder")
                }
            } else {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        else {
            Text("Image not found")
        }
    }
}

#Preview {
    TintedFolderView(folderTint: .green, tintFolder: true)
}
