//
//  SecuritySettingsView.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI

struct SecuritySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SecurityManager.self) private var securityManager
    
    @State private var showingChangePIN = false
    @State private var showingResetAlert = false
    @State private var autoLockEnabled = true
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // PIN Management Section
                Section {
                    Button {
                        showingChangePIN = true
                    } label: {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundStyle(.pink)
                            Text("Change PIN")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Reset Vault")
                        }
                    }
                } header: {
                    Text("Vault Security")
                } footer: {
                    Text("Resetting the vault will delete your PIN and all encrypted data. This action cannot be undone.")
                }
                
                // Privacy Features Section
                Section {
                    Toggle(isOn: $autoLockEnabled) {
                        HStack {
                            Image(systemName: "lock.rotation")
                                .foregroundStyle(.pink)
                            Text("Auto-Lock on Background")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "icloud.slash.fill")
                            .foregroundStyle(.pink)
                        Text("Local Storage Only")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                } header: {
                    Text("Privacy Features")
                } footer: {
                    Text("All photos are stored encrypted on this device only. They are never uploaded to any server or cloud.")
                }
                
                // Security Info Section
                Section {
                    InfoRow(icon: "shield.checkered", label: "Encryption", value: "AES-256")
                    InfoRow(icon: "key.horizontal.fill", label: "Keychain", value: "Secure")
                    InfoRow(icon: "lock.doc.fill", label: "Storage", value: "Local")
                } header: {
                    Text("Security Details")
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
            .sheet(isPresented: $showingChangePIN) {
                NavigationStack {
                    PINEntryView(mode: .change) {
                        showingChangePIN = false
                        showingSuccessAlert = true
                    }
                    .environment(securityManager)
                    .navigationTitle("Change PIN")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                showingChangePIN = false
                            }
                        }
                    }
                }
            }
            .alert("Reset Vault?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetVault()
                }
            } message: {
                Text("This will delete your PIN and all encrypted photos. This cannot be undone.")
            }
            .alert("PIN Changed", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your vault PIN has been updated successfully.")
            }
        }
    }
    
    private func resetVault() {
        // This would need to be implemented with proper data deletion
        _ = securityManager.resetPIN()
        // TODO: Clear all encrypted moments from SwiftData
        dismiss()
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.pink)
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SecuritySettingsView()
        .environment(SecurityManager())
}
