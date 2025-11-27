//
//  CuteCompanionApp.swift
//  CuteCompanion
//
//  Created by Pietro Saveri on 26/11/25.
//

import SwiftUI


class AppCoordinator {
    static let shared = AppCoordinator()
    let spriteManager = SpriteManager()
    let mouseMonitor = MouseMonitor()

    
    private init() {
        mouseMonitor.onMouseMove = { [weak self] in
            DispatchQueue.main.async {
                self?.spriteManager.startAnimation()
            }
        }
        
        mouseMonitor.onMouseStop = { [weak self] in
            DispatchQueue.main.async {
                self?.spriteManager.stopAnimation()
            }
        }
        
        mouseMonitor.startMonitoring()
    }
}



@main
struct CuteCompanionApp: App {
    @ObservedObject var spriteManager = AppCoordinator.shared.spriteManager
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        MenuBarExtra {
            Button("Change Companion") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                openWindow(id: "companion-selector")
            }
            Divider()
            Button("Stop The Cuteness") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            if let frame = spriteManager.currentFrame {
                Image(nsImage: frame)
            } else {
                Image(systemName: "pawprint.fill")
            }
        }
        .menuBarExtraStyle(.menu)
        
        Window("Companion Selector", id: "companion-selector") {
            SpriteSelectionView(spriteManager: spriteManager)
                .onAppear {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
        .windowResizability(.contentSize)
    }
}
