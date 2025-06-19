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
import SFSymbolPicker

struct InspectorView: View {
    @Binding var appState: AppState
    @Binding var previewImage: NSImage?
    @State private var loader = SymbolLoader()
    @State private var changeSymbol = false
    @State private var changeEmoji = false
    var body: some View {
        Form {
            Picker("Icon Type", selection: $appState.iconType) {
                Text("SF Symbol").tag(IconType.symbol)
                Text("Emoji").tag(IconType.emoji)
                Text("PNG Image").tag(IconType.image)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)

            LabeledContent("Tint Folder") {
                Toggle(isOn: $appState.tintFolder) {}
                    .toggleStyle(.checkbox)
            }
            if appState.tintFolder {
                LabeledContent("Tint Folder") {
                    ColorPicker("Tint Color", selection: $appState.folderTint)
                        .labelsHidden()
                }
            }
            let label = switch appState.iconType {
            case .symbol: "Display Symbol"
            case .image: "Display Image"
            case .emoji: "Display Emoji"
            }
                LabeledContent(label) {
                    Toggle(isOn: $appState.showIcon) {
                    }
                    .toggleStyle(.checkbox)
                    .onChange(of: appState.showIcon) { _, newValue in
                        if appState.iconType == .image && !newValue {
                            appState.iconImage = nil
                        }
                    }
                }
                .padding(.bottom)
//            }
            if appState.iconType == .symbol {
                if appState.showIcon {
                    ColorPicker("Symbol Color", selection: $appState.symbolColor)
                    LabeledContent {
                        Button {
                            changeSymbol.toggle()
                        } label: {
                            Image(systemName: appState.symbolName)
                                .font(.system(size: 30))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    } label: {
                        VStack(alignment: .leading){
                            Text("Symbol")
                            Text("Tap to change")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .popover(isPresented: $changeSymbol) {
                        SymbolView(
                            loader: loader,
                            selectedSymbol: $appState.symbolName
                        )
                        .frame(width: 300, height: 300)
                        .presentationCompactAdaptation(.popover)
                    }
                }
            }
            if appState.iconType == .emoji {
                if appState.showIcon {
                    LabeledContent {
                        Button {
                            changeEmoji.toggle()
                        } label: {
                            Text(appState.selectedEmoji)
                                .font(.system(size: 30))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    } label: {
                        VStack(alignment: .leading){
                            Text("Emoji")
                            Text("Tap to change")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    .popover(isPresented: $changeEmoji) {
                        EmojiPickerView(selectedEmoji: $appState.selectedEmoji)
                        .frame(width: 400, height: 400)
                        .presentationCompactAdaptation(.popover)
                    }
                }
            }
            if appState.iconType == .image || appState.iconType == .emoji || (appState.iconType == .symbol && appState.showIcon) {
                VStack {
                    LabeledContent("Size") {
                        let maxIcon:Double = appState.iconType == .symbol ? 90 : 150
                        Slider(value: $appState.iconSize, in: 20...maxIcon, onEditingChanged: { editing in
                            if !editing {
                                updatePreview()
                            }
                        })
                    }
                    LabeledContent("Rotation:") {
                        VStack {
                            Slider(value: $appState.symbolRotation, in: -180...180, onEditingChanged: { editing in
                                if !editing {
                                    updatePreview()
                                }
                            })
                            Text("\(Int(appState.symbolRotation))°")
                        }
                    }
                }
            }
            LabeledContent("Add Shadow") {
                Toggle(isOn: $appState.hasShadow) {}
                    .toggleStyle(.checkbox)
            }
        }
    }
    func updatePreview() {
        let content = FolderIconView(appState: appState)
        previewImage = ImageRendererHelper.renderIconImage(from: content, size: CGSize(width: 512, height: 512))!
    }
}

#Preview {
    InspectorView(appState: .constant(AppState()), previewImage: .constant(nil))
}
