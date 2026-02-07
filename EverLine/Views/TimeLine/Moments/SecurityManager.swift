//
//  SecurityManager.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import Foundation
import CryptoKit
import UIKit

@Observable
final class SecurityManager {
    private let keychain = KeychainHelper()
    
    // The encryption key is stored securely in the keychain
    private var encryptionKey: SymmetricKey {
        if let keyData = keychain.read(service: "com.everline.encryption", account: "master-key") {
            return SymmetricKey(data: keyData)
        } else {
            // Generate a new key if one doesn't exist
            let newKey = SymmetricKey(size: .bits256)
            keychain.save(newKey.withUnsafeBytes { Data($0) }, service: "com.everline.encryption", account: "master-key")
            return newKey
        }
    }
    
    /// Check if a PIN has been configured
    func isPINConfigured() -> Bool {
        return keychain.read(service: "com.everline.pin", account: "user-pin") != nil
    }
    
    /// Save a PIN securely
    func savePIN(_ pin: String) {
        guard let pinData = pin.data(using: .utf8) else { return }
        keychain.save(pinData, service: "com.everline.pin", account: "user-pin")
    }
    
    /// Verify a PIN
    func verifyPIN(_ pin: String) -> Bool {
        guard let storedPINData = keychain.read(service: "com.everline.pin", account: "user-pin"),
              let storedPIN = String(data: storedPINData, encoding: .utf8) else {
            return false
        }
        return storedPIN == pin
    }
    
    /// Delete the stored PIN
    func deletePIN() {
        keychain.delete(service: "com.everline.pin", account: "user-pin")
    }
    
    /// Encrypts image data
    func encrypt(_ imageData: Data) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(imageData, using: encryptionKey)
            return sealedBox.combined
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    /// Decrypts image data
    func decrypt(_ encryptedData: Data?) -> Data? {
        guard let encryptedData = encryptedData else { return nil }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
            return decryptedData
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
    
    /// Encrypts a UIImage
    func encryptImage(_ image: UIImage) -> Data? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return encrypt(imageData)
    }
    
    /// Decrypts data and returns a UIImage
    func decryptImage(_ encryptedData: Data?) -> UIImage? {
        guard let decryptedData = decrypt(encryptedData) else { return nil }
        return UIImage(data: decryptedData)
    }
}

// MARK: - Keychain Helper
private class KeychainHelper {
    func save(_ data: Data, service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain save error: \(status)")
        }
    }
    
    func read(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else {
            return nil
        }
    }
    
    func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
