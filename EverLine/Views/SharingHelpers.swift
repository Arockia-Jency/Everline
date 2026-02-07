// SharingHelpers.swift
// Everline

import SwiftUI
import UIKit

// Helper to render the moment as an image
struct ShareImageRenderer {
    var securityManager: SecurityManager?
    
    @MainActor
    func render(moment: Moment) -> UIImage? {
        // Decrypt the photo if available
        var photoImage: UIImage? = nil
        if let encryptedData = moment.encryptedPhotoData,
           let manager = securityManager {
            photoImage = manager.decryptImage(encryptedData)
        }
        
        let renderer = ImageRenderer(content:
            VStack(spacing: 20) {
                if let uiImage = photoImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 400, height: 400)
                        .clipped()
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text(moment.title).font(.largeTitle.bold())
                    Text(moment.date.formatted(date: .long, time: .omitted)).font(.title2)
                    Text(moment.notes).font(.body)
                }
                .padding()
                .frame(width: 400)
                .background(Color.white)
            }
        )
        return renderer.uiImage
    }
}

// Standard Share Sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiController: UIActivityViewController, context: Context) {}
}
