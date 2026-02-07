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
        case change
    }
    
    let mode: Mode
    let onSuccess: () -> Void
    
    @State private var pin: String = ""
    @State private var confirmPIN: String = ""
    @State private var isConfirming: Bool = false
    @State private var errorMessage: String?
    @State private var shakeOffset: CGFloat = 0
    
    @Environment(SecurityManager.self) private var securityManager
    
    private let pinLength = 6
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.pink.opacity(0.15), .orange.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.pink.gradient)
                    
                    Text(headerText)
                        .font(.title2.bold())
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    } else if securityManager.isLockedOut {
                        lockoutView
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // PIN dots display
                pinDotsView
                    .offset(x: shakeOffset)
                
                // Number pad
                numberPadView
                    .padding(.bottom, 40)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Sub Views
    
    private var headerText: String {
        if securityManager.isLockedOut {
            return "Too Many Attempts"
        }
        
        switch mode {
        case .setup:
            return isConfirming ? "Confirm Your PIN" : "Create Your PIN"
        case .verify:
            return "Enter Your PIN"
        case .change:
            return "Enter New PIN"
        }
    }
    
    private var lockoutView: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            
            Text("Please wait 60 seconds")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var pinDotsView: some View {
        HStack(spacing: 20) {
            ForEach(0..<pinLength, id: \.self) { index in
                Circle()
                    .fill(index < currentPIN.count ? Color.pink : Color.gray.opacity(0.3))
                    .frame(width: 18, height: 18)
                    .scaleEffect(index < currentPIN.count ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentPIN.count)
            }
        }
    }
    
    private var numberPadView: some View {
        VStack(spacing: 16) {
            // Rows 1-3
            ForEach(0..<3) { row in
                HStack(spacing: 16) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        numberButton("\(number)")
                    }
                }
            }
            
            // Bottom row: blank, 0, delete
            HStack(spacing: 16) {
                Color.clear
                    .frame(width: 80, height: 80)
                
                numberButton("0")
                
                Button {
                    deleteDigit()
                } label: {
                    Image(systemName: "delete.left.fill")
                        .font(.title2)
                        .foregroundStyle(.pink)
                        .frame(width: 80, height: 80)
                        .background(Color.pink.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func numberButton(_ number: String) -> some View {
        Button {
            addDigit(number)
        } label: {
            Text(number)
                .font(.title.bold())
                .foregroundStyle(.primary)
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
        .disabled(securityManager.isLockedOut)
    }
    
    // MARK: - Computed
    
    private var currentPIN: String {
        isConfirming ? confirmPIN : pin
    }
    
    // MARK: - Actions
    
    private func addDigit(_ digit: String) {
        guard currentPIN.count < pinLength else { return }
        
        if isConfirming {
            confirmPIN += digit
            if confirmPIN.count == pinLength {
                validateConfirmation()
            }
        } else {
            pin += digit
            if pin.count == pinLength {
                handlePINComplete()
            }
        }
    }
    
    private func deleteDigit() {
        if isConfirming && !confirmPIN.isEmpty {
            confirmPIN.removeLast()
        } else if !pin.isEmpty {
            pin.removeLast()
        }
    }
    
    private func handlePINComplete() {
        switch mode {
        case .setup:
            // Move to confirmation
            isConfirming = true
            errorMessage = nil
            
        case .verify:
            if securityManager.verifyPIN(pin) {
                onSuccess()
            } else {
                showError("Incorrect PIN")
            }
            
        case .change:
            if securityManager.setupPIN(pin) {
                onSuccess()
            } else {
                showError("Failed to set PIN")
            }
        }
    }
    
    private func validateConfirmation() {
        if pin == confirmPIN {
            // PINs match - save it
            if securityManager.setupPIN(pin) {
                onSuccess()
            } else {
                showError("Failed to save PIN")
            }
        } else {
            showError("PINs don't match")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        
        // Shake animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
            shakeOffset = 10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                shakeOffset = -10
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                shakeOffset = 0
            }
        }
        
        // Clear PIN after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pin = ""
            confirmPIN = ""
            isConfirming = false
            errorMessage = nil
        }
    }
}

#Preview {
    PINEntryView(mode: .setup) {
        print("PIN setup complete")
    }
    .environment(SecurityManager())
}
