//
//  PINSetupOnboardingView.swift
//  EverLine
//
//  First-launch PIN setup screen
//

import SwiftUI

struct PINSetupOnboardingView: View {
    let onComplete: () -> Void
    @Environment(SecurityManager.self) private var securityManager
    
    var body: some View {
        PINEntryView(mode: .setup, onSuccess: onComplete)
            .environment(securityManager)
    }
}

#Preview {
    PINSetupOnboardingView {
        print("PIN setup complete")
    }
    .environment(SecurityManager())
}
