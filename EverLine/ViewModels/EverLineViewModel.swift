//
//  EverLineViewModel.swift
//  EverLine
//
//  Created by Jen on 06/02/26.
//

import Foundation
import Observation
import LocalAuthentication
import SwiftUI


@Observable
class EverLineViewModel {
    
    var isLocked = true
    var searchText = ""
    var showingPINEntry = false
    var securityManager = SecurityManager()
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: 1)) ?? .now
    
    var daysTogether: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: .now).day ?? 0
    }
    
    /// Check if this is first launch (no PIN configured)
    var isFirstLaunch: Bool {
        !securityManager.isPINConfigured()
    }
    
    func authenticate() {
        // If no PIN is set, require setup
        if isFirstLaunch {
            showingPINEntry = true
            return
        }
        
        // Try biometrics first (optional fallback)
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Quick access to your memories") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        withAnimation { self.isLocked = false }
                    } else {
                        // Biometrics failed, show PIN entry
                        self.showingPINEntry = true
                    }
                }
            }
        } else {
            // No biometrics available, show PIN entry
            showingPINEntry = true
        }
    }
    
    func unlock() {
        withAnimation {
            isLocked = false
            showingPINEntry = false
        }
    }
    
    func lock() {
        withAnimation {
            isLocked = true
            showingPINEntry = false
        }
    }
}
