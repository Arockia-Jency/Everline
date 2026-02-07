//
//  Mood.swift
//  EverLine
//
//  Created by Jen on 06/02/26.
//

import Foundation
import SwiftUI

enum Mood: String, CaseIterable, Codable {
    case love = "Love", happy = "Happy", sad = "Sad", fight = "Argument", milestone = "Milestone"
    
    var icon: String {
        switch self {
        case .love: return "heart.fill"
        case .happy: return "sun.max.fill"
        case .sad: return "cloud.rain.fill"
        case .fight: return "bolt.fill"
        case .milestone: return "trophy.fill"
        }
    }
}
