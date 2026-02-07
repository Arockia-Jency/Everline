//
//  SecureImageView.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import SwiftUI

/// A view that decrypts and displays encrypted photo data
struct SecureImageView: View {
    let encryptedData: Data?
    let securityManager: SecurityManager
    
    @State private var decryptedImage: UIImage?
    @State private var isLoading = true
    
    var contentMode: ContentMode = .fill
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 15
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(height: height)
            } else if let image = decryptedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .if(height != nil) { view in
                        view.frame(height: height)
                    }
                    .clipped()
                    .cornerRadius(cornerRadius)
            } else {
                Image(systemName: "photo.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .frame(height: height)
            }
        }
        .task {
            await decryptImage()
        }
    }
    
    @MainActor
    private func decryptImage() async {
        isLoading = true
        
        guard let encryptedData else {
            isLoading = false
            return
        }
        
        // Decrypt on background thread
        let image = await Task.detached(priority: .userInitiated) {
            guard let decryptedData = try? securityManager.decryptPhoto(encryptedData),
                  let uiImage = UIImage(data: decryptedData) else {
                return nil
            }
            return uiImage
        }.value
        
        decryptedImage = image
        isLoading = false
    }
}

// MARK: - View Extension for Conditional Modifiers

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    SecureImageView(
        encryptedData: nil,
        securityManager: SecurityManager(),
        height: 200
    )
}
