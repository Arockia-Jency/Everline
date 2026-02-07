//
//  PanicGestureModifier.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI
import CoreMotion

/// A view modifier that detects panic gestures and locks the app immediately
struct PanicGestureModifier: ViewModifier {
    
    @Binding var isLocked: Bool
    @State private var motionManager = CMMotionManager()
    @State private var isEnabled: Bool = true
    
    let sensitivity: Double = 2.5 // Shake sensitivity threshold
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if isEnabled {
                    startMotionDetection()
                }
            }
            .onDisappear {
                stopMotionDetection()
            }
    }
    
    private func startMotionDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let data = data, error == nil else { return }
            
            let acceleration = data.acceleration
            let magnitude = sqrt(
                pow(acceleration.x, 2) +
                pow(acceleration.y, 2) +
                pow(acceleration.z, 2)
            )
            
            // Detect shake (acceleration spike)
            if magnitude > sensitivity {
                triggerPanicLock()
            }
        }
    }
    
    private func stopMotionDetection() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func triggerPanicLock() {
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        // Lock immediately
        withAnimation {
            isLocked = true
        }
        
        // Stop further detection temporarily to avoid multiple triggers
        stopMotionDetection()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if isEnabled {
                startMotionDetection()
            }
        }
    }
}

extension View {
    /// Enable panic gesture (shake to lock)
    func panicGesture(isLocked: Binding<Bool>) -> some View {
        modifier(PanicGestureModifier(isLocked: isLocked))
    }
}

// MARK: - Panic Settings Storage

class PanicGestureSettings: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "panicGestureEnabled")
        }
    }
    
    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "panicGestureEnabled")
    }
}

// MARK: - Panic Gesture Settings UI

struct PanicGestureSettingsView: View {
    @StateObject private var settings = PanicGestureSettings()
    @State private var showTestAlert = false
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $settings.isEnabled) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Panic Gesture")
                    }
                }
            } header: {
                Text("Emergency Lock")
            } footer: {
                Text("Shake your device firmly to instantly lock the app. Useful in emergency situations.")
            }
            
            if settings.isEnabled {
                Section {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.pink)
                        Text("Gesture")
                        Spacer()
                        Text("Shake Device")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundStyle(.pink)
                        Text("Sensitivity")
                        Spacer()
                        Text("Medium")
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        showTestAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "testtube.2")
                                .foregroundStyle(.pink)
                            Text("Test Panic Gesture")
                            Spacer()
                            Text("Shake Now")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Configuration")
                } footer: {
                    Text("Try shaking your device to test if the sensitivity is comfortable for you.")
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("How it Works", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.pink)
                    
                    Text("When enabled, firmly shaking your device will immediately lock Everline, hiding all content from view.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("This feature uses your device's accelerometer and works even when the app is in the foreground.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Panic Gesture")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Test Mode", isPresented: $showTestAlert) {
            Button("OK") { }
        } message: {
            Text("Shake your device now to test the panic gesture. The app will lock if detected.")
        }
    }
}

// MARK: - Alternative Panic Triggers

/// Face-down detection (place phone face-down to lock)
struct FaceDownDetectionModifier: ViewModifier {
    @Binding var isLocked: Bool
    @State private var motionManager = CMMotionManager()
    
    func body(content: Content) -> some View {
        content
            .onAppear { startDetection() }
            .onDisappear { stopDetection() }
    }
    
    private func startDetection() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.5
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion else { return }
            
            // Check if device is face down (z-axis points up significantly)
            let gravity = motion.gravity
            if gravity.z > 0.75 { // Device is face down
                triggerLock()
            }
        }
    }
    
    private func stopDetection() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func triggerLock() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        withAnimation {
            isLocked = true
        }
        
        stopDetection()
    }
}

extension View {
    /// Lock app when device is placed face down
    func faceDownLock(isLocked: Binding<Bool>) -> some View {
        modifier(FaceDownDetectionModifier(isLocked: isLocked))
    }
}

// MARK: - Triple Tap to Lock

struct TripleTapLockModifier: ViewModifier {
    @Binding var isLocked: Bool
    @State private var tapCount = 0
    @State private var tapTimer: Timer?
    
    func body(content: Content) -> some View {
        content
            .onTapGesture(count: 1) {
                handleTap()
            }
    }
    
    private func handleTap() {
        tapCount += 1
        
        // Reset counter after 1 second
        tapTimer?.invalidate()
        tapTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            tapCount = 0
        }
        
        // Lock on triple tap
        if tapCount >= 3 {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
            withAnimation {
                isLocked = true
            }
            
            tapCount = 0
            tapTimer?.invalidate()
        }
    }
}

extension View {
    /// Lock app on triple tap anywhere
    func tripleTapLock(isLocked: Binding<Bool>) -> some View {
        modifier(TripleTapLockModifier(isLocked: isLocked))
    }
}

// MARK: - Preview

#Preview("Panic Gesture Settings") {
    NavigationStack {
        PanicGestureSettingsView()
    }
}

#Preview("Shake Detection Demo") {
    struct DemoView: View {
        @State private var isLocked = false
        
        var body: some View {
            ZStack {
                if isLocked {
                    VStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.pink)
                        Text("Locked!")
                            .font(.title)
                        Button("Unlock") {
                            isLocked = false
                        }
                    }
                } else {
                    VStack {
                        Text("Shake to Lock")
                            .font(.title)
                        Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                            .font(.system(size: 100))
                            .foregroundStyle(.pink)
                    }
                    .panicGesture(isLocked: $isLocked)
                }
            }
        }
    }
    
    return DemoView()
}
