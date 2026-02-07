//
//  Moment.swift
//  EverLine
//
//  Created by Jen on 06/02/26.
//

import Foundation
import SwiftData

@Model
final class Moment {
    var id: UUID
    var title: String
    var notes: String
    var date: Date
    var mood: String
    var latitude: Double?
    var longitude: Double?
    
    // Store encrypted photo data
    @Attribute(.externalStorage) var encryptedPhotoData: Data?
    
    init(title: String = "", notes: String = "", date: Date = .now, mood: String = "Love", encryptedPhotoData: Data? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.date = date
        self.mood = mood
        self.encryptedPhotoData = encryptedPhotoData
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Moment {
    var moodEmoji: String {
        switch mood.lowercased() {
        case let m where m.contains("happy"): return "😊"
        case let m where m.contains("sad"):    return "😢"
        case let m where m.contains("love"):   return "❤️"
        case let m where m.contains("angry"):  return "😡"
        case let m where m.contains("excited"):return "🤩"
        default: return "📝"
        }
    }
}

