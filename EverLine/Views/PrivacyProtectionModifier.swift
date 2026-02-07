//
//  PrivacyProtectionModifier.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI
import SwiftData

/// A view modifier that blurs the content when the app goes to the background
struct PrivacyProtectionModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isBlurred = false
    
    func body(content: Content) -> some View {
        content
            .blur(radius: isBlurred ? 20 : 0)
            .overlay {
                if isBlurred {
                    privacyOverlay
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isBlurred = newPhase == .background || newPhase == .inactive
                }
            }
    }
    
    private var privacyOverlay: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "lock.heart.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.pink.gradient)
                
                Text("EverLine")
                    .font(.title.bold())
                    .foregroundStyle(.pink)
            }
        }
        .transition(.opacity)
    }
}

extension View {
    /// Applies privacy protection by blurring content when app is backgrounded
    func privacyProtection() -> some View {
        modifier(PrivacyProtectionModifier())
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Moment.self, inMemory: true)
        .privacyProtection()
}
