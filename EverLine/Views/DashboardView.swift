//
//  DashboardView.swift
//  EverLine
//
//  Created by Jen on 06/02/26.
//

import SwiftUI

struct DashboardView: View {
    let days: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.pink.gradient)
            
            Text("\(days)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Text("DAYS TOGETHER")
                .font(.caption)
                .tracking(2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
