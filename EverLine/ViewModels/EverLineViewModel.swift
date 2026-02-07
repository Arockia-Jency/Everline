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
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: 1)) ?? .now
    
    var daysTogether:Int {
        Calendar.current.dateComponents([.day],from: startDate,to: .now).day ?? 0
    }
        func authenticate() {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access your memories") { success, _ in
                    if success {
                        DispatchQueue.main.async {
                            withAnimation { self.isLocked = false }
                        }
                    }
                }
            } else {
                // For Simulator/No FaceID
                self.isLocked = false
            }
        }
        
        func lock() {
            isLocked = true
        }
}
