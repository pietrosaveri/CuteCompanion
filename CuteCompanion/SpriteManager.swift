import SwiftUI
import AppKit

struct SpriteModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let assetName: String
    var frameWidth: CGFloat?
    var frameHeight: CGFloat?
    var scale: CGFloat = 1.0
}

class SpriteManager: ObservableObject {
    @Published var currentFrame: NSImage?
    @Published var currentSprite: SpriteModel
    
    let availableSprites = [
        SpriteModel(name: "Mushy", assetName: "mushroom", frameWidth: 48, frameHeight: 48, scale: 0.6),
        SpriteModel(name: "Mort", assetName: "DinoSprites-mort", scale: 1.2),
        SpriteModel(name: "Doux", assetName: "DinoSprites-doux", scale: 1.2),
        SpriteModel(name: "tard", assetName: "DinoSprites-tard", scale: 1.2),
        SpriteModel(name: "knight", assetName: "Kinght", frameWidth: 22, frameHeight: 24, scale: 1.2), //the framewidth is the width of the image/number of frames
        SpriteModel(name: "Bob", assetName: "GreenFrog", frameWidth: 48, frameHeight: 48),
        SpriteModel(name: "Cherry", assetName: "cat", frameWidth: 80, frameHeight: 64),
        SpriteModel(name: "Jonathan", assetName: "Stickman", frameWidth: 64, frameHeight: 64, scale: 0.6),
        SpriteModel(name: "Vampy The Bat", assetName: "bat", frameWidth: 32, frameHeight: 32, scale: 1.8)
        
    ]
    
    private var frames: [NSImage] = []
    private var timer: Timer?
    private var frameIndex = 0
    private var isAnimating = false
    
    init() {
        let defaultSprite = availableSprites[0]
        self.currentSprite = defaultSprite
        loadSprites(for: defaultSprite)
    }
    
    func changeSprite(to sprite: SpriteModel) {
        stopAnimation()
        currentSprite = sprite
        loadSprites(for: sprite)
    }
    
    private func loadSprites(for sprite: SpriteModel) {
        frames.removeAll()
        guard let image = NSImage(named: sprite.assetName) else {
            print("Error: Could not load \(sprite.assetName) image")
            return
        }
        
        // Use provided dimensions or fallback to image height (assuming single row strip)
        let frameHeight = sprite.frameHeight ?? image.size.height
        let frameWidth = sprite.frameWidth ?? frameHeight // Default to square if width not provided
        
        let totalWidth = image.size.width
        let frameCount = Int(totalWidth / frameWidth)
        
        for i in 0..<frameCount {
            let x = CGFloat(i) * frameWidth
            let rect = CGRect(x: x, y: 0, width: frameWidth, height: frameHeight)
            
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                if let cropped = cgImage.cropping(to: rect) {
                    let scaledSize = NSSize(width: frameWidth * sprite.scale, height: frameHeight * sprite.scale)
                    let nsImage = NSImage(cgImage: cropped, size: scaledSize)
                    frames.append(nsImage)
                }
            }
        }
        
        if !frames.isEmpty {
            currentFrame = frames[0]
        }
    }
    
    func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Invalidate existing timer just in case
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.nextFrame()
        }
    }
    
    func stopAnimation() {
        isAnimating = false
        timer?.invalidate()
        timer = nil
        frameIndex = 0
        if !frames.isEmpty {
            currentFrame = frames[0]
        }
    }
    
    private func nextFrame() {
        guard !frames.isEmpty else { return }
        frameIndex = (frameIndex + 1) % frames.count
        currentFrame = frames[frameIndex]
    }
    
    // Helper for previewing other sprites without changing the main one
    func getPreviewFrames(for sprite: SpriteModel) -> [NSImage] {
        guard let image = NSImage(named: sprite.assetName) else { return [] }
        var previewFrames: [NSImage] = []
        
        let frameHeight = sprite.frameHeight ?? image.size.height
        let frameWidth = sprite.frameWidth ?? frameHeight
        let totalWidth = image.size.width
        let frameCount = Int(totalWidth / frameWidth)
        
        for i in 0..<frameCount {
            let x = CGFloat(i) * frameWidth
            let rect = CGRect(x: x, y: 0, width: frameWidth, height: frameHeight)
            
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                if let cropped = cgImage.cropping(to: rect) {
                    let nsImage = NSImage(cgImage: cropped, size: NSSize(width: frameWidth, height: frameHeight))
                    previewFrames.append(nsImage)
                }
            }
        }
        return previewFrames
    }
}
