//
//  PINEntryView.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI

struct PINEntryView: View {
    enum Mode {
        case setup
        case verify
        
        var title: String {
            switch self {
            case .setup: return "Create Your PIN"
            case .verify: return "Enter Your PIN"
            }
        }
        
        var subtitle: String {
            switch self {
            case .setup: return "Choose a 4-digit PIN to secure your memories"
            case .verify: return "Enter your PIN to continue"
            }
        }
    }
    
    let mode: Mode
    let onSuccess: () -> Void
    
    @Environment(SecurityManager.self) private var securityManager
    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var isConfirming = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isShaking = false
    
    private let pinLength = 4
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Lock Icon
            Image(systemName: mode == .setup ? "lock.shield.fill" : "lock.fill")
                .font(.system(size: 80))
                .foregroundStyle(.pink.gradient)
                .padding(.bottom, 20)
            
            // Title
            VStack(spacing: 8) {
                Text(isConfirming ? "Confirm Your PIN" : mode.title)
                    .font(.title2.bold())
                
                Text(isConfirming ? "Enter your PIN again" : mode.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // PIN Dots Display
            HStack(spacing: 20) {
                ForEach(0..<pinLength, id: \.self) { index in
                    Circle()
                        .fill(index < currentPIN.count ? Color.pink : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .scaleEffect(index == currentPIN.count - 1 && !currentPIN.isEmpty ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPIN.count)
                }
            }
            .padding(.vertical, 20)
            .offset(x: isShaking ? -10 : 0)
            .animation(isShaking ? .default.repeatCount(3, autoreverses: true).speed(6) : .default, value: isShaking)
            
            // Error Message
            if showError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
            }
            
            Spacer()
            
            // Number Pad
            VStack(spacing: 15) {
                ForEach(0..<3) { row in
                    HStack(spacing: 15) {
                        ForEach(1...3, id: \.self) { col in
                            let number = row * 3 + col
                            numberButton(number)
                        }
                    }
                }
                
                // Bottom row: blank, 0, delete
                HStack(spacing: 15) {
                    Color.clear
                        .frame(width: 75, height: 75)
                    
                    numberButton(0)
                    
                    Button {
                        deleteDigit()
                    } label: {
                        Image(systemName: "delete.left.fill")
                            .font(.title2)
                            .foregroundStyle(.pink)
                            .frame(width: 75, height: 75)
                            .background(Color.pink.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var currentPIN: String {
        isConfirming ? confirmPin : pin
    }
    
    // MARK: - Number Button
    
    private func numberButton(_ number: Int) -> some View {
        Button {
            addDigit(number)
        } label: {
            Text("\(number)")
                .font(.title.bold())
                .foregroundStyle(.primary)
                .frame(width: 75, height: 75)
                .background(Color.secondary.opacity(0.1))
                .clipShape(Circle())
        }
    }
    
    // MARK: - PIN Input Logic
    
    private func addDigit(_ digit: Int) {
        guard currentPIN.count < pinLength else { return }
        
        if isConfirming {
            confirmPin += "\(digit)"
            if confirmPin.count == pinLength {
                validatePINSetup()
            }
        } else {
            pin += "\(digit)"
            if pin.count == pinLength {
                handlePINComplete()
            }
        }
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func deleteDigit() {
        if isConfirming {
            if !confirmPin.isEmpty {
                confirmPin.removeLast()
            }
        } else {
            if !pin.isEmpty {
                pin.removeLast()
            }
        }
        
        showError = false
    }
    
    // MARK: - PIN Validation
    
    private func handlePINComplete() {
        switch mode {
        case .setup:
            // Move to confirmation step
            withAnimation {
                isConfirming = true
            }
            
        case .verify:
            // Verify the PIN
            if securityManager.verifyPIN(pin) {
                // Success!
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onSuccess()
            } else {
                // Wrong PIN
                showErrorAndReset("Incorrect PIN")
            }
        }
    }
    
    private func validatePINSetup() {
        if pin == confirmPin {
            // PINs match - save it
            securityManager.savePIN(pin)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onSuccess()
        } else {
            // PINs don't match
            showErrorAndReset("PINs don't match. Try again.")
            isConfirming = false
            confirmPin = ""
        }
    }
    
    private func showErrorAndReset(_ message: String) {
        errorMessage = message
        showError = true
        isShaking = true
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        
        // Reset PIN after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShaking = false
            pin = ""
            confirmPin = ""
            
            // Hide error after another delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showError = false
            }
        }
    }
}

#Preview("Setup Mode") {
    PINEntryView(mode: .setup) {
        print("PIN setup complete")
    }
    .environment(SecurityManager())
}

#Preview("Verify Mode") {
    PINEntryView(mode: .verify) {
        print("PIN verified")
    }
    .environment(SecurityManager())
}
