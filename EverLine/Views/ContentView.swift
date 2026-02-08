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
                // Step 1: PIN Setup (first priority)
                if viewModel.needsPINSetup {
                    OnboardingPINSetupView {
                        viewModel.refreshSetupState()
                    }
                    .environment(viewModel.securityManager)
                    .transition(.asymmetric(insertion: .identity, removal: .move(edge: .leading)))
                }
                // Step 2: Date Picker Setup (after PIN is configured)
                else if viewModel.needsDatePickerSetup {
                    RelationshipStartDatePicker { selectedDate in
                        viewModel.setStartDate(selectedDate)
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
                // Step 3: Normal app flow with lock/unlock
                else if viewModel.isLocked {
                    if viewModel.showingPINEntry {
                        // Show PIN entry for verification
                        PINEntryView(
                            mode: .verify,
                            onSuccess: {
                                viewModel.unlock()
                            }
                        )
                        .environment(viewModel.securityManager)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Show lock screen with unlock button
                        lockedStateView
                            .transition(.opacity)
                    }
                } else {
                    // Step 4: Main app (unlocked)
                    MainTabView(securityManager: viewModel.securityManager)
                        .ignoresSafeArea(.keyboard)
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.needsPINSetup)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.needsDatePickerSetup)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.isLocked)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.showingPINEntry)
        }
        .privacyProtection() // Apply blur when backgrounded
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // Only lock if setup is complete
            if !viewModel.needsPINSetup && !viewModel.needsDatePickerSetup {
                viewModel.lock()
            }
        }
    }

    // MARK: - Sub-Views
    
    // Locked View (only shown after setup is complete)
    private var lockedStateView: some View {
        VStack(spacing: 25) {
            Image(systemName: "lock.heart.fill")
                .font(.system(size: 100))
                .foregroundStyle(.pink.gradient)
            
            Text("Everline is Private")
                .font(.title2)
            
            Text("Your memories are secure.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Unlock Vault") {
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

