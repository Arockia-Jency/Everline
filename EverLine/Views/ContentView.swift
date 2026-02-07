//
//  ContentView.swift
//  EverLine
//
//  Created by Jen on 06/02/26.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @State private var viewModel = EverLineViewModel()
    @Query(sort: \Moment.date, order: .reverse) private var moments: [Moment]
    @State private var isShowingAdd = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [.pink.opacity(0.1), .orange.opacity(0.1)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack {
                if viewModel.isLocked {
                    if viewModel.showingPINEntry {
                        // Show PIN entry (setup or verify)
                        PINEntryView(
                            mode: viewModel.isFirstLaunch ? .setup : .verify,
                            onSuccess: {
                                viewModel.unlock()
                            }
                        )
                        .environment(viewModel.securityManager)
                    } else {
                        // Show lock screen with unlock button
                        lockedStateView
                    }
                } else {
                    MainTabView(securityManager: viewModel.securityManager)
                        .ignoresSafeArea(.keyboard)
                }
            }
        }
        .privacyProtection() // Apply blur when backgrounded
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.lock()
        }
    }

    // MARK: - Sub-Views
    
    // 1. Extracted Locked View
    private var lockedStateView: some View {
        VStack(spacing: 25) {
            Image(systemName: "lock.heart.fill")
                .font(.system(size: 100))
                .foregroundStyle(.pink.gradient)
            
            Text("Everline is Private")
                .font(.title2)
            
            Text(viewModel.isFirstLaunch ? "Welcome! Set up your vault PIN to get started." : "Your memories are secure.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(viewModel.isFirstLaunch ? "Set Up PIN" : "Unlock Vault") {
                viewModel.authenticate()
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Moment.self)
}

