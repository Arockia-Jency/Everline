//
//  EverLineApp.swift
//  EverLine
//
//  Created by Jen on 06/02/26.
//

import SwiftUI
import SwiftData

@main
struct EverLineApp: App {
  
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Moment.self)
    }
}
