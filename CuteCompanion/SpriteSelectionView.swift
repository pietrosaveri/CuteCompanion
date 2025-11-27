import SwiftUI
import AppKit

struct SpritePreviewView: View {
    let frames: [NSImage]
    @State private var currentFrameIndex = 0
    static let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if !frames.isEmpty {
            Image(nsImage: frames[currentFrameIndex])
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
                .onReceive(Self.timer) { _ in
                    currentFrameIndex = (currentFrameIndex + 1) % frames.count
                }
        } else {
            Color.clear
        }
    }
}

struct SpriteGridView: View, Equatable {
    let availableSprites: [SpriteModel]
    let selectedSprite: SpriteModel
    let spriteManager: SpriteManager
    
    static func == (lhs: SpriteGridView, rhs: SpriteGridView) -> Bool {
        return lhs.selectedSprite == rhs.selectedSprite &&
               lhs.availableSprites == rhs.availableSprites
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
            ForEach(availableSprites) { sprite in
                VStack {
                    SpritePreviewView(frames: spriteManager.getPreviewFrames(for: sprite))
                        .frame(width: 64, height: 64)
                        .padding()
                        .background(selectedSprite == sprite ? Color.accentColor.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    
                    Text(sprite.name)
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    if selectedSprite == sprite {
                        Text("Selected")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.top, 2)
                    } else {
                        Button("Select") {
                            spriteManager.changeSprite(to: sprite)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedSprite == sprite ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: 2)
                )
            }
        }
        .padding()
    }
}

struct SpriteSelectionView: View {
    @ObservedObject var spriteManager: SpriteManager
    
    var body: some View {
        VStack {
            ZStack {
                Text("Select Your Companion")
                    .font(.headline)
                    .padding()
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Toggle("", isOn: $spriteManager.alwaysAnimate)
                            .toggleStyle(.switch)
                            .controlSize(.mini)
                            .labelsHidden()
                        Text("Keep Cuteing")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.trailing, 16)
            }
            
            ScrollView {
                SpriteGridView(
                    availableSprites: spriteManager.availableSprites,
                    selectedSprite: spriteManager.currentSprite,
                    spriteManager: spriteManager
                )
                .equatable()
            }
        }
        .frame(width: 400, height: 300)
        .background(WindowAccessor { window in
            guard let window = window else { return }
            window.level = .floating
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        })
    }
}

private final class AccessorView: NSView {
    var callback: ((NSWindow?) -> Void)?
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let window = self.window {
            callback?(window)
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = AccessorView()
        view.callback = callback
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Also trigger on update to catch re-renders or state changes
        if let view = nsView as? AccessorView, let window = view.window {
            view.callback?(window)
        }
    }
}
