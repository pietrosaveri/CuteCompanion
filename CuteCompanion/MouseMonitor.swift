import AppKit

class MouseMonitor: ObservableObject {
    var onMouseMove: (() -> Void)?
    var onMouseStop: (() -> Void)?
    
    private var timer: Timer?
    private var lastLocation: NSPoint = .zero
    private var isMoving = false
    private var stopDebounceTimer: Timer?
    
    func startMonitoring() {
        lastLocation = NSEvent.mouseLocation
        
        // Poll mouse location every 0.1s to detect movement without needing Accessibility permissions
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkMouse()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        stopDebounceTimer?.invalidate()
        stopDebounceTimer = nil
    }
    
    private func checkMouse() {
        let currentLocation = NSEvent.mouseLocation
        
        if currentLocation != lastLocation {
            // Mouse moved
            lastLocation = currentLocation
            if !isMoving {
                isMoving = true
                onMouseMove?()
            }
            
            // Reset stop timer
            stopDebounceTimer?.invalidate()
            stopDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
                self?.isMoving = false
                self?.onMouseStop?()
            }
        }
    }
}
