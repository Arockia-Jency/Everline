//
//  DataMigrationHelper.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import Foundation
import SwiftData

/// Helper for migrating unencrypted photos to encrypted storage
class DataMigrationHelper {
    
    private let securityManager: SecurityManager
    
    init(securityManager: SecurityManager) {
        self.securityManager = securityManager
    }
    
    // MARK: - Migration Status
    
    struct MigrationResult {
        let totalMoments: Int
        let successfullyEncrypted: Int
        let alreadyEncrypted: Int
        let failed: Int
        let errors: [String]
        
        var needsMigration: Bool {
            return totalMoments > 0 && successfullyEncrypted == 0 && alreadyEncrypted == 0
        }
    }
    
    // MARK: - Check Migration Status
    
    /// Check if any moments need encryption
    func needsMigration(moments: [Moment]) -> Bool {
        // Check if we have the old photoData property
        // Since we renamed it to encryptedPhotoData, old data would need migration
        
        for moment in moments {
            // If encryptedPhotoData is nil but we suspect there might be old data
            // This is a simplified check - adjust based on your actual migration needs
            if moment.encryptedPhotoData == nil {
                // Could have old unencrypted data or no photo at all
                // Need more sophisticated check here
                continue
            }
        }
        
        return false
    }
    
    // MARK: - Migrate All Moments
    
    /// Encrypt all unencrypted photos in the database
    func migrateAllMoments(
        moments: [Moment],
        modelContext: ModelContext,
        progressCallback: ((Double) -> Void)? = nil
    ) async -> MigrationResult {
        
        var totalMoments = moments.count
        var successCount = 0
        var alreadyEncrypted = 0
        var failedCount = 0
        var errors: [String] = []
        
        for (index, moment) in moments.enumerated() {
            // Update progress
            let progress = Double(index) / Double(totalMoments)
            await MainActor.run {
                progressCallback?(progress)
            }
            
            // Check if already encrypted
            if moment.encryptedPhotoData != nil {
                alreadyEncrypted += 1
                continue
            }
            
            // Note: Since we renamed photoData to encryptedPhotoData,
            // you'll need to handle the old property differently.
            // This is a template - adjust based on your actual data structure.
            
            // If you kept the old property temporarily for migration:
            // if let oldPhotoData = moment.photoData {
            //     do {
            //         let encrypted = try securityManager.encryptPhoto(oldPhotoData)
            //         moment.encryptedPhotoData = encrypted
            //         moment.photoData = nil  // Clear old field
            //         successCount += 1
            //     } catch {
            //         failedCount += 1
            //         errors.append("Failed to encrypt moment '\(moment.title)': \(error.localizedDescription)")
            //     }
            // }
        }
        
        // Save changes
        do {
            try modelContext.save()
        } catch {
            errors.append("Failed to save migrated data: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            progressCallback?(1.0)
        }
        
        return MigrationResult(
            totalMoments: totalMoments,
            successfullyEncrypted: successCount,
            alreadyEncrypted: alreadyEncrypted,
            failed: failedCount,
            errors: errors
        )
    }
    
    // MARK: - Migrate Single Moment
    
    /// Encrypt a single moment's photo
    func migrateMoment(_ moment: Moment, photoData: Data) throws {
        let encrypted = try securityManager.encryptPhoto(photoData)
        moment.encryptedPhotoData = encrypted
    }
}

// MARK: - Migration UI

import SwiftUI

struct MigrationView: View {
    let moments: [Moment]
    let securityManager: SecurityManager
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var isProcessing = false
    @State private var progress: Double = 0
    @State private var result: DataMigrationHelper.MigrationResult?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(.pink.gradient)
            
            Text("Data Migration Required")
                .font(.title2.bold())
            
            Text("Your photos need to be encrypted for security. This is a one-time process.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if isProcessing {
                VStack(spacing: 16) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal, 40)
                    
                    Text("\(Int(progress * 100))% Complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let result = result {
                migrationResultView(result)
            } else {
                Button("Start Migration") {
                    startMigration()
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(isProcessing)
            }
        }
        .padding()
        .alert("Migration Errors", isPresented: $showError) {
            Button("OK") { }
        } message: {
            if let errors = result?.errors, !errors.isEmpty {
                Text(errors.joined(separator: "\n"))
            }
        }
    }
    
    @ViewBuilder
    private func migrationResultView(_ result: DataMigrationHelper.MigrationResult) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("Migration Complete!")
                .font(.title3.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                resultRow(label: "Total Moments", value: "\(result.totalMoments)")
                resultRow(label: "Encrypted", value: "\(result.successfullyEncrypted)", color: .green)
                resultRow(label: "Already Secure", value: "\(result.alreadyEncrypted)", color: .blue)
                if result.failed > 0 {
                    resultRow(label: "Failed", value: "\(result.failed)", color: .red)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            if !result.errors.isEmpty {
                Button("View Errors") {
                    showError = true
                }
                .foregroundStyle(.red)
            }
            
            Button("Continue") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
    }
    
    private func resultRow(label: String, value: String, color: Color = .primary) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundStyle(color)
        }
    }
    
    private func startMigration() {
        isProcessing = true
        
        Task {
            let helper = DataMigrationHelper(securityManager: securityManager)
            
            let migrationResult = await helper.migrateAllMoments(
                moments: moments,
                modelContext: modelContext
            ) { newProgress in
                await MainActor.run {
                    progress = newProgress
                }
            }
            
            await MainActor.run {
                result = migrationResult
                isProcessing = false
            }
        }
    }
}

// MARK: - Migration Check Extension

extension View {
    /// Check if migration is needed and show migration view
    func checkMigration(
        moments: [Moment],
        securityManager: SecurityManager,
        isCompleted: Binding<Bool>
    ) -> some View {
        modifier(MigrationCheckModifier(
            moments: moments,
            securityManager: securityManager,
            isCompleted: isCompleted
        ))
    }
}

struct MigrationCheckModifier: ViewModifier {
    let moments: [Moment]
    let securityManager: SecurityManager
    @Binding var isCompleted: Bool
    
    @State private var showMigration = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                checkIfMigrationNeeded()
            }
            .sheet(isPresented: $showMigration) {
                MigrationView(
                    moments: moments,
                    securityManager: securityManager
                ) {
                    showMigration = false
                    isCompleted = true
                }
                .interactiveDismissDisabled()
            }
    }
    
    private func checkIfMigrationNeeded() {
        let helper = DataMigrationHelper(securityManager: securityManager)
        showMigration = helper.needsMigration(moments: moments)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var moments: [Moment] = []
        
        var body: some View {
            MigrationView(
                moments: moments,
                securityManager: SecurityManager()
            ) {
                print("Migration complete")
            }
            .modelContainer(for: Moment.self, inMemory: true)
        }
    }
    
    return PreviewWrapper()
}
