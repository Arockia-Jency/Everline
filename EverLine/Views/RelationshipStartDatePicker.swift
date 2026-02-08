//
//  RelationshipStartDatePicker.swift
//  EverLine
//
//  First-launch date picker for relationship start date
//

import SwiftUI

struct RelationshipStartDatePicker: View {
    @State private var selectedDate: Date = Date()
    let onComplete: (Date) -> Void
    
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
                
                // Icon
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.pink.gradient)
                
                // Title
                VStack(spacing: 12) {
                    Text("When Did Your Story Begin?")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Choose the date you and your partner started your journey together")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Date Picker
                VStack(spacing: 16) {
                    DatePicker(
                        "Start Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.background)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // Days calculation preview
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.pink)
                        Text("\(daysSince(selectedDate)) days together")
                            .font(.headline)
                            .foregroundStyle(.pink)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(.pink.opacity(0.1))
                    )
                }
                
                Spacer()
                
                // Continue Button
                Button {
                    onComplete(selectedDate)
                } label: {
                    HStack {
                        Text("Continue")
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
    
    private func daysSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
    }
}

#Preview {
    RelationshipStartDatePicker { date in
        print("Selected date: \(date)")
    }
}
