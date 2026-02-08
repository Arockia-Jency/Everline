//
//  OnboardingPINSetupView.swift
//  EverLine
//
//  Onboarding PIN setup screen with welcome message
//

import SwiftUI

struct OnboardingPINSetupView: View {
    let onComplete: () -> Void
    @Environment(SecurityManager.self) private var securityManager
    @State private var showPINEntry = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.pink.opacity(0.1), .orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showPINEntry {
                // Show PIN entry screen
                PINEntryView(mode: .setup, onSuccess: onComplete)
                    .environment(securityManager)
                    .transition(.move(edge: .trailing))
            } else {
                // Welcome screen
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "lock.heart.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.pink.gradient)
                        .symbolEffect(.bounce, value: showPINEntry)
                    
                    // Title
                    VStack(spacing: 12) {
                        Text("Welcome to EverLine")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        
                        Text("Your Private Relationship Timeline")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureRow(
                            icon: "lock.shield.fill",
                            title: "End-to-End Encrypted",
                            description: "Your photos are secured with AES-256 encryption"
                        )
                        
                        FeatureRow(
                            icon: "heart.fill",
                            title: "Track Your Journey",
                            description: "Capture and cherish every special moment together"
                        )
                        
                        FeatureRow(
                            icon: "eye.slash.fill",
                            title: "Completely Private",
                            description: "Only you can access your memories"
                        )
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 30)
                    
                    Spacer()
                    
                    // Get Started Button
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            showPINEntry = true
                        }
                    } label: {
                        HStack {
                            Text("Get Started")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.pink.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.pink)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingPINSetupView {
        print("PIN setup complete")
    }
    .environment(SecurityManager())
}
