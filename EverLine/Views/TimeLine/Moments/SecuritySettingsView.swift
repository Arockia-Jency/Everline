//
//  SecuritySettingsView.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {
    var securityManager: SecurityManager
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("requireBiometrics") private var requireBiometrics = false
    @AppStorage("autoLockEnabled") private var autoLockEnabled = false
    @AppStorage("autoLockMinutes") private var autoLockMinutes = 5
    
    @State private var showBiometricError = false
    @State private var biometricErrorMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.pink)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("End-to-End Encryption")
                                .font(.headline)
                            Text("Your photos are encrypted on device")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("All photos are encrypted using AES-256 and stored securely on your device. No one, not even us, can access your photos.")
                }
                
                Section {
                    Toggle(isOn: $requireBiometrics) {
                        HStack {
                            Image(systemName: biometricIcon)
                                .foregroundStyle(.pink)
                            Text("Require \(biometricType)")
                        }
                    }
                    .onChange(of: requireBiometrics) { _, newValue in
                        if newValue {
                            authenticateBiometric()
                        }
                    }
                } header: {
                    Text("Authentication")
                } footer: {
                    Text("Require \(biometricType) to unlock EverLine and view your moments.")
                }
                
                Section {
                    Toggle(isOn: $autoLockEnabled) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.pink)
                            Text("Auto-Lock")
                        }
                    }
                    
                    if autoLockEnabled {
                        Picker("Lock After", selection: $autoLockMinutes) {
                            Text("1 minute").tag(1)
                            Text("5 minutes").tag(5)
                            Text("15 minutes").tag(15)
                            Text("30 minutes").tag(30)
                        }
                    }
                } header: {
                    Text("Auto-Lock")
                } footer: {
                    Text("Automatically lock the app after a period of inactivity.")
                }
                
                Section {
                    Button(role: .destructive) {
                        // Future: Implement key rotation
                    } label: {
                        Label("Reset Encryption Key", systemImage: "key.fill")
                    }
                    .disabled(true) // Disabled for now
                } footer: {
                    Text("Resetting the encryption key will make all existing photos inaccessible. This action cannot be undone.")
                }
            }
            .navigationTitle("Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Authentication Error", isPresented: $showBiometricError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(biometricErrorMessage)
            }
        }
    }
    
    // MARK: - Biometric Authentication
    
    private var biometricType: String {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Passcode"
        }
        
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "Biometrics"
        }
    }
    
    private var biometricIcon: String {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "lock.fill"
        }
        
        switch context.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        default:
            return "lock.fill"
        }
    }
    
    private func authenticateBiometric() {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            requireBiometrics = false
            biometricErrorMessage = error?.localizedDescription ?? "Biometric authentication is not available on this device."
            showBiometricError = true
            return
        }
        
        // Perform authentication
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to enable biometric lock") { success, authError in
            DispatchQueue.main.async {
                if !success {
                    requireBiometrics = false
                    biometricErrorMessage = authError?.localizedDescription ?? "Authentication failed."
                    showBiometricError = true
                }
            }
        }
    }
}

#Preview {
    SecuritySettingsView(securityManager: SecurityManager())
}
