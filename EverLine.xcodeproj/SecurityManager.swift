//
//  SecurityManager.swift
//  EverLine
//
//  Created by Jen on 07/02/26.
//

import Foundation
import Security
import CryptoKit

/// Manages app-level security including PIN authentication and encryption
@Observable
class SecurityManager {
    
    // MARK: - Properties
    
    private let keychainService = "com.everline.vault"
    private let pinKey = "vault_pin_hash"
    private let encryptionKeyKey = "vault_encryption_key"
    
    var failedAttempts: Int = 0
    var lockoutUntil: Date?
    
    var isLockedOut: Bool {
        guard let lockoutDate = lockoutUntil else { return false }
        return Date() < lockoutDate
    }
    
    // MARK: - PIN Management
    
    /// Check if a PIN has been set up
    func isPINConfigured() -> Bool {
        return getKeychainData(key: pinKey) != nil
    }
    
    /// Set up a new PIN (hashed with SHA256)
    func setupPIN(_ pin: String) -> Bool {
        let pinHash = hashPIN(pin)
        return saveToKeychain(data: pinHash, key: pinKey)
    }
    
    /// Verify the entered PIN
    func verifyPIN(_ pin: String) -> Bool {
        // Check lockout
        if isLockedOut {
            return false
        }
        
        guard let storedHash = getKeychainData(key: pinKey) else {
            return false
        }
        
        let enteredHash = hashPIN(pin)
        
        if storedHash == enteredHash {
            // Success - reset attempts
            failedAttempts = 0
            lockoutUntil = nil
            return true
        } else {
            // Failed attempt
            failedAttempts += 1
            
            // Lock out after 5 failed attempts for 1 minute
            if failedAttempts >= 5 {
                lockoutUntil = Date().addingTimeInterval(60) // 1 minute
                failedAttempts = 0
            }
            
            return false
        }
    }
    
    /// Change existing PIN
    func changePIN(oldPIN: String, newPIN: String) -> Bool {
        guard verifyPIN(oldPIN) else { return false }
        return setupPIN(newPIN)
    }
    
    /// Reset PIN (requires re-authentication or device wipe)
    func resetPIN() -> Bool {
        return deleteFromKeychain(key: pinKey)
    }
    
    // MARK: - Encryption Key Management
    
    /// Get or create encryption key for photo data
    func getEncryptionKey() -> SymmetricKey {
        if let existingKey = getKeychainData(key: encryptionKeyKey) {
            return SymmetricKey(data: existingKey)
        }
        
        // Generate new key
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        _ = saveToKeychain(data: keyData, key: encryptionKeyKey)
        
        return newKey
    }
    
    /// Encrypt photo data using AES-GCM
    func encryptPhoto(_ photoData: Data) throws -> Data {
        let key = getEncryptionKey()
        let sealedBox = try AES.GCM.seal(photoData, using: key)
        
        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }
        
        return combined
    }
    
    /// Decrypt photo data
    func decryptPhoto(_ encryptedData: Data) throws -> Data {
        let key = getEncryptionKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        return decryptedData
    }
    
    // MARK: - Keychain Helpers
    
    private func hashPIN(_ pin: String) -> Data {
        let pinData = Data(pin.utf8)
        let hash = SHA256.hash(data: pinData)
        return Data(hash)
    }
    
    private func saveToKeychain(data: Data, key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing
        SecItemDelete(query as CFDictionary)
        
        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func getKeychainData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess ? (result as? Data) : nil
    }
    
    private func deleteFromKeychain(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Errors

enum EncryptionError: Error {
    case encryptionFailed
    case decryptionFailed
}
