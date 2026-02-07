//
//  PrivacyBlurView.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI

/// Blur view that covers the app when it goes to background
struct PrivacyBlurView: View {
    var body: some View {
        ZStack {
            // Blur effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // Lock icon overlay
            VStack(spacing: 20) {
                Image(systemName: "lock.heart.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.pink.gradient)
                
                Text("Everline")
                    .font(.title.bold())
                    .foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - View Modifier for Privacy Protection

struct PrivacyProtectionModifier: ViewModifier {
    @State private var isShowingPrivacyScreen = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowingPrivacyScreen {
                PrivacyBlurView()
                    .transition(.opacity)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowingPrivacyScreen = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowingPrivacyScreen = false
            }
        }
    }
}

extension View {
    /// Apply privacy blur when app goes to background
    func privacyProtection() -> some View {
        modifier(PrivacyProtectionModifier())
    }
}

#Preview {
    VStack {
        Text("Your private content")
    }
    .privacyProtection()
}
