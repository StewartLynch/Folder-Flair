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


import Foundation
import AppKit

extension NSImage {
    
    func tinted(with color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        return image
    }
    
    func tintedWithShading(using tintColor: NSColor) -> NSImage? {
        guard let tiffData = self.tiffRepresentation,
              let ciImage = CIImage(data: tiffData) else { return nil }
        
        // Adjust shadows, highlights, brightness, contrast, and desaturate
        let adjusted = ciImage
//            .applyingFilter("CIHighlightShadowAdjust", parameters: [
//                "inputShadowAmount": 0.4,
//                "inputHighlightAmount": 1.0
//            ])
            .applyingFilter("CIColorControls", parameters: [
                "inputBrightness": 0.4,
                "inputContrast": 1.0,
                "inputSaturation": 0.0
            ])
        
        let colorFilter = CIFilter(name: "CIColorMatrix")!
        colorFilter.setValue(adjusted, forKey: kCIInputImageKey)
        
        let rgb = tintColor.usingColorSpace(.deviceRGB)!
        colorFilter.setValue(CIVector(x: rgb.redComponent, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorFilter.setValue(CIVector(x: 0, y: rgb.greenComponent, z: 0, w: 0), forKey: "inputGVector")
        colorFilter.setValue(CIVector(x: 0, y: 0, z: rgb.blueComponent, w: 0), forKey: "inputBVector")
        colorFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        
        let context = CIContext()
        guard let output = colorFilter.outputImage else { return nil }
        
        let gammaAdjusted = output.applyingFilter("CIGammaAdjust", parameters: [
            "inputPower": 0.85
        ])
        
        guard let cgImage = context.createCGImage(gammaAdjusted, from: gammaAdjusted.extent) else {
            return nil
        }
        
        return NSImage(cgImage: cgImage, size: self.size)
    }
}

