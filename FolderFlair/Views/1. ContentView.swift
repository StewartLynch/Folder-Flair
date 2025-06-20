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

import SwiftUI
import AppKit
import SFSymbolPicker
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var appState = AppState()
    @State private var folderURL: URL?
    @State private var statusMessage = ""
    @State private var isTargeted = false
    @State private var previewImage: NSImage?
    @State var isPresented: Bool = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isTargeted ? Color.accentColor : Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(height: 350)
                        .overlay(
                            VStack {
                                HStack(alignment: .top) {
                                    Image(systemName: "plus.rectangle.fill.on.folder.fill")
                                    if appState.iconType == .image {
                                        Image(systemName: "photo.badge.plus")
                                    }
                                }
                                .font(.system(size: 18))
                                .padding(.top)
                                let text = appState.iconType == .symbol || appState.iconType == .emoji ? "Drag a folder here or" : "Drag a folder or PNG image here"
                                Text(text)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Button("Choose a folder") {
                                        let panel = NSOpenPanel()
                                        panel.canChooseDirectories = true
                                        panel.canChooseFiles = false
                                        panel.allowsMultipleSelection = false
                                        panel.begin { response in
                                            if response == .OK, let selectedURL = panel.url, isDirectory(selectedURL) {
                                                do {
                                                    let bookmarkData = try selectedURL.bookmarkData(
                                                        options: .withSecurityScope,
                                                        includingResourceValuesForKeys: nil,
                                                        relativeTo: nil
                                                    )
                                                    var isStale = false
                                                    let resolvedURL = try URL(
                                                        resolvingBookmarkData: bookmarkData,
                                                        options: .withSecurityScope,
                                                        relativeTo: nil,
                                                        bookmarkDataIsStale: &isStale
                                                    )
                                                    if resolvedURL.startAccessingSecurityScopedResource() {
                                                        folderURL = resolvedURL
                                                        statusMessage = ""
                                                    } else {
                                                        statusMessage = "❌ Could not access resolved folder with security scope."
                                                    }
                                                } catch {
                                                    statusMessage = "❌ Failed to resolve bookmark: \(error.localizedDescription)"
                                                }
                                            } else {
                                                statusMessage = "❌ Not a folder."
                                            }
                                        }
                                    }
                                    
                                    if appState.iconType == .image {
                                        Button("Choose a PNG Image") {
                                            let panel = NSOpenPanel()
                                            panel.allowedContentTypes = [.png]
                                            panel.canChooseDirectories = false
                                            panel.canChooseFiles = true
                                            panel.allowsMultipleSelection = false
                                            panel.begin { response in
                                                if response == .OK, let selectedURL = panel.url {
                                                    if let image = NSImage(contentsOf: selectedURL) {
                                                        appState.iconType = .image
                                                        appState.iconImage = image
                                                        statusMessage = "✅ PNG image loaded."
                                                    } else {
                                                        statusMessage = "❌ Failed to load PNG image."
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                Text(folderURL?.path(percentEncoded: false) ?? "")
                                    .font(.caption)
                                FolderIconView(appState: appState)
                                if let folderURL {
                                    Text(folderURL.lastPathComponent)
                                }
                                Text(statusMessage)
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                                Spacer()
                            }
                        )
                        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                            handleDrop(providers: providers)
                        }
                }
                
                .onChange(of: appState.refreshToken) {
                    updatePreview()
                }
                
                HStack {
                    Button("Apply Custom View as Icon") {
                        applyCustomViewAsIcon()
                    }
                    .disabled(folderURL == nil || previewImage == nil)
                    
                    Button("Remove Custom Icon") {
                        if let folderURL = folderURL {
                            _ = NSWorkspace.shared.setIcon(nil, forFile: folderURL.path, options: [])
                            NSWorkspace.shared.noteFileSystemChanged(folderURL.path)
                            statusMessage = "✅ Custom icon removed."
                        }
                    }
                    .disabled(folderURL == nil)
                }
                
                if folderURL != nil {
                    Button {
                        folderURL = nil
                        appState.reset()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
                Spacer()
            }
            .padding()
            .frame(width: 500)
            .navigationTitle("Folder Icon Setter")
        }
        .inspector(isPresented: $isPresented) {
            InspectorView(appState: $appState, previewImage: $previewImage)
        }
        .toolbar {
            Button {
                isPresented.toggle()
            } label: {
                Image(systemName: "sidebar.right")
            }
        }
        .onAppear {
            updatePreview()
        }
    }

    func updatePreview() {
        let content = FolderIconView(appState: appState)
        previewImage = ImageRendererHelper.renderIconImage(from: content, size: CGSize(width: 512, height: 512))!
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        statusMessage = ""
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                    DispatchQueue.main.async {
                        if let data = item as? Data,
                           let url = URL(dataRepresentation: data, relativeTo: nil) {
                            var isDir: ObjCBool = false
                            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
                            if appState.iconType == .image {
                                // Check if we are trying to add a PNG Image
                                if url.pathExtension.lowercased() == "png" {
                                    if let image = NSImage(contentsOf: url) {
                                        appState.iconType = .image
                                        appState.iconImage = image
                                        statusMessage = "✅ PNG image loaded."
                                    } else {
                                        statusMessage = "❌ Failed to load PNG image."
                                    }
                                    
                                } else {
                                    // Check if we are adding a folder
                                    if isDir.boolValue {
                                        folderURL = url
                                    } else {
                                        statusMessage = "❌ This is not a PNG Image."

                                    }
                                }
                            } else {
                                // Must be on other tabs so just check to see if it is a folder
                                if isDir.boolValue {
                                    folderURL = url
                                } else {
                                    folderURL = nil
                                    statusMessage = "❌ This is not a folder"
                                    appState.reset()
                                }
                            }
                        }
                    }
                }
                return true
            }
        }
        return false
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }

    private func applyCustomViewAsIcon() {
        guard let folderURL = folderURL, let image = previewImage else {
            statusMessage = "❌ Missing folder or image."
            return
        }

        let iconPath = folderURL.appendingPathComponent("Icon\r").path
        if FileManager.default.fileExists(atPath: iconPath) {
            do {
                try FileManager.default.removeItem(atPath: iconPath)
                statusMessage = "✅ Old icon removed."
            } catch {
                print("Could not remove")
            }
        }

        _ = NSWorkspace.shared.setIcon(nil, forFile: folderURL.path, options: [])

        if appState.showIcon || appState.tintFolder {
            let targetSize = NSSize(width: 512, height: 512)
            let rep = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(targetSize.width),
                pixelsHigh: Int(targetSize.height),
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bytesPerRow: 0,
                bitsPerPixel: 0
            )
            rep?.size = targetSize

            NSGraphicsContext.saveGraphicsState()
            if let rep = rep, let context = NSGraphicsContext(bitmapImageRep: rep) {
                NSGraphicsContext.current = context
                context.imageInterpolation = .high
                image.draw(in: NSRect(origin: .zero, size: targetSize),
                           from: NSRect(origin: .zero, size: image.size),
                           operation: .copy,
                           fraction: 1.0)
                context.flushGraphics()
            }
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: targetSize)
            if let rep = rep {
                resizedImage.addRepresentation(rep)
            }

            let success = NSWorkspace.shared.setIcon(resizedImage, forFile: folderURL.path, options: [])
            NSWorkspace.shared.noteFileSystemChanged(folderURL.path)
            statusMessage = success ? "✅ Custom icon applied." : "❌ Failed to apply icon."
        }
    }
}

#Preview {
    ContentView()
        .frame(height: 450)
}
