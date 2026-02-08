//
//  PINSetupOnboardingView.swift
//  EverLine
//
//  First-launch PIN setup with welcome screen
//

import SwiftUI

struct PINSetupOnboardingView: View {
    let onComplete: () -> Void
    @Environment(SecurityManager.self) private var securityManager
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.pink.opacity(0.1), .orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Lock Icon
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.pink.gradient)
                
                // Welcome Title
                VStack(spacing: 12) {
                    Text("Welcome to EverLine")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Let's secure your private memories")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Feature highlights
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(
                        icon: "lock.fill",
                        text: "End-to-end encrypted"
                    )
                    
                    FeatureRow(
                        icon: "heart.fill",
                        text: "Track your relationship moments"
                    )
                    
                    FeatureRow(
                        icon: "eye.slash.fill",
                        text: "Only you can access your photos"
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Embedded PIN Entry
                PINEntryView(mode: .setup, onSuccess: onComplete)
                    .environment(securityManager)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.pink)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    PINSetupOnboardingView {
        print("PIN setup complete")
    }
    .environment(SecurityManager())
}
