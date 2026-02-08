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
    var showingDatePicker = false
    var securityManager = SecurityManager()
    
    // Store the relationship start date in UserDefaults for persistence
    var startDate: Date {
        get {
            if let saved = UserDefaults.standard.object(forKey: "relationshipStartDate") as? Date {
                return saved
            }
            // Default to January 2021
            return Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: 1)) ?? .now
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "relationshipStartDate")
            UserDefaults.standard.set(true, forKey: "hasSetStartDate")
        }
    }
    
    var daysTogether: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: .now).day ?? 0
    }
    
    /// Check if the start date has been configured
    var hasSetStartDate: Bool {
        UserDefaults.standard.bool(forKey: "hasSetStartDate")
    }
    
    /// Check if we need to show PIN setup first (highest priority)
    var needsPINSetup: Bool {
        !securityManager.isPINConfigured()
    }
    
    /// Check if we need to show the date picker (after PIN is set)
    var needsDatePickerSetup: Bool {
        // Only show date picker setup if PIN is configured but date is not
        !needsPINSetup && !hasSetStartDate
    }
    
    func setStartDate(_ date: Date) {
        startDate = date
        showingDatePicker = false
        // Trigger a refresh of the setup state
        refreshSetupState()
        // After setting the date, unlock the app
        unlock()
    }
    
    /// Manually trigger a refresh for computed properties during setup
    func refreshSetupState() {
        // Changing a stored property will trigger observers of the @Observable class
        isLocked = isLocked 
    }
    
    func authenticate() {
        // If no PIN is set, require setup
        if needsPINSetup {
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
