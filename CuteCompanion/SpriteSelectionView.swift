import SwiftUI
import AppKit

struct SpritePreviewView: View {
    let frames: [NSImage]
    @State private var currentFrameIndex = 0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if !frames.isEmpty {
            Image(nsImage: frames[currentFrameIndex])
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
                .onReceive(timer) { _ in
                    currentFrameIndex = (currentFrameIndex + 1) % frames.count
                }
        } else {
            Color.clear
        }
    }
}

struct SpriteSelectionView: View {
    @ObservedObject var spriteManager: SpriteManager
    
    var body: some View {
        VStack {
            Text("Select Your Companion")
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                    ForEach(spriteManager.availableSprites) { sprite in
                        VStack {
                            SpritePreviewView(frames: spriteManager.getPreviewFrames(for: sprite))
                                .frame(width: 64, height: 64)
                                .padding()
                                .background(spriteManager.currentSprite == sprite ? Color.accentColor.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            
                            Text(sprite.name)
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            if spriteManager.currentSprite == sprite {
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
                                .stroke(spriteManager.currentSprite == sprite ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: 2)
                        )
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 300)
        .background(WindowAccessor { window in
            window?.level = .floating
            window?.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        })
    }
}

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
