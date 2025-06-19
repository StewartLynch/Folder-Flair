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

struct EmojiPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var emojiData = EmojiData()
    
    @Binding var selectedEmoji: String
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""

    var filteredEmojis: [Emoji] {
        emojiData.emojis.filter { emoji in
            (selectedCategory == "All" || emoji.category == selectedCategory) &&
            (searchText.isEmpty ||
             emoji.description.localizedCaseInsensitiveContains(searchText) ||
             emoji.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }))
        }
    }
    
    var categories: [String] {
        let allCategories = Set(emojiData.emojis.map { $0.category })
        return ["All"] + allCategories.sorted()
    }

    let columns = [GridItem(.adaptive(minimum: 50))]

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                TextField("Search...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .frame(maxWidth: 200, alignment: .leading)
            .padding()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredEmojis) { emoji in
                        Text(emoji.emoji)
                            .font(.largeTitle)
                            .onTapGesture {
                                selectedEmoji = emoji.emoji
                                dismiss()
                            }
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}

#Preview {
    @Previewable @State var selectedEmoji = "😀"
    @Previewable @State var selectedCategory = "All"
    EmojiPickerView(selectedEmoji: $selectedEmoji)
}
