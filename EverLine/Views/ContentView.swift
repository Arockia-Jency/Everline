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
                    lockedStateView
                } else {
                    MainTabView()
                        .ignoresSafeArea(.keyboard)
                }
            }
        }
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
            
            Button("Unlock Gallery") {
                viewModel.authenticate()
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
    }
}
