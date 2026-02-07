//
//  SecureImageView.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI

/// A view that displays an encrypted image by decrypting it on-the-fly
struct SecureImageView: View {
    let encryptedData: Data?
    let securityManager: SecurityManager
    var contentMode: ContentMode = .fill
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 12
    
    var body: some View {
        Group {
            if let encryptedData = encryptedData,
               let decryptedImage = securityManager.decryptImage(encryptedData) {
                Image(uiImage: decryptedImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(height: height)
                    .cornerRadius(cornerRadius)
                    .clipped()
            } else {
                // Placeholder for failed decryption
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.2))
                    
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Image unavailable")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: height)
            }
        }
    }
}

/// Content mode for image rendering
enum ContentMode {
    case fill
    case fit
}

#Preview {
    let manager = SecurityManager()
    let sampleImage = UIImage(systemName: "heart.fill")!
    let encrypted = manager.encryptImage(sampleImage)
    
    return VStack {
        SecureImageView(
            encryptedData: encrypted,
            securityManager: manager,
            contentMode: .fit,
            height: 200
        )
        .padding()
    }
}
