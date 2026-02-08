//
//  ChangePINView.swift
//  EverLine
//
//  View for changing the existing PIN
//

import SwiftUI

struct ChangePINView: View {
    var securityManager: SecurityManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPIN = ""
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    @State private var step: Step = .current
    @State private var errorMessage = ""
    @State private var showError = false
    
    enum Step {
        case current
        case new
        case confirm
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.pink.opacity(0.1), .orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 70))
                        .foregroundStyle(.pink.gradient)
                    
                    // Title and subtitle
                    VStack(spacing: 12) {
                        Text(titleText)
                            .font(.title2.bold())
                        
                        Text(subtitleText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // PIN Input
                    VStack(spacing: 20) {
                        SecureField("Enter PIN", text: currentPINBinding)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.background)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            )
                            .padding(.horizontal, 40)
                        
                        // PIN dots indicator
                        HStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { index in
                                Circle()
                                    .fill(index < currentPINBinding.wrappedValue.count ? Color.pink : Color.gray.opacity(0.3))
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            handleContinue()
                        } label: {
                            Text(step == .confirm ? "Save PIN" : "Continue")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isValidInput ? Color.pink : Color.gray)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!isValidInput)
                        .padding(.horizontal)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var titleText: String {
        switch step {
        case .current:
            return "Enter Current PIN"
        case .new:
            return "Enter New PIN"
        case .confirm:
            return "Confirm New PIN"
        }
    }
    
    private var subtitleText: String {
        switch step {
        case .current:
            return "Enter your current 4-digit PIN"
        case .new:
            return "Choose a new 4-digit PIN"
        case .confirm:
            return "Re-enter your new PIN to confirm"
        }
    }
    
    private var currentPINBinding: Binding<String> {
        switch step {
        case .current:
            return $currentPIN
        case .new:
            return $newPIN
        case .confirm:
            return $confirmPIN
        }
    }
    
    private var isValidInput: Bool {
        currentPINBinding.wrappedValue.count == 4
    }
    
    // MARK: - Actions
    
    private func handleContinue() {
        switch step {
        case .current:
            // Verify current PIN
            if securityManager.verifyPIN(currentPIN) {
                withAnimation {
                    step = .new
                }
            } else {
                errorMessage = "Incorrect PIN. Please try again."
                showError = true
                currentPIN = ""
            }
            
        case .new:
            // Validate new PIN
            if newPIN == currentPIN {
                errorMessage = "New PIN must be different from current PIN"
                showError = true
                newPIN = ""
            } else if newPIN.count != 4 {
                errorMessage = "PIN must be exactly 4 digits"
                showError = true
            } else {
                withAnimation {
                    step = .confirm
                }
            }
            
        case .confirm:
            // Confirm and save
            if confirmPIN == newPIN {
                securityManager.savePIN(newPIN)
                
                // Show success and dismiss
                dismiss()
            } else {
                errorMessage = "PINs don't match. Please try again."
                showError = true
                confirmPIN = ""
                
                // Go back to new PIN entry
                withAnimation {
                    step = .new
                    newPIN = ""
                }
            }
        }
    }
}

#Preview {
    ChangePINView(securityManager: SecurityManager())
}
