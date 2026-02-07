//
//  InfoPlistConfiguration.swift
//  EverLine
//
//  Info.plist Configuration Guide
//

/*
 
 📱 Required Info.plist Entries for Everline Security
 ====================================================
 
 Add these entries to your Info.plist to ensure proper privacy descriptions
 and security functionality:
 
 
 1. PHOTO LIBRARY ACCESS
 ------------------------
 Key: NSPhotoLibraryUsageDescription
 Value: "Everline needs access to your photos to save your precious memories securely in your private vault."
 
 Key: NSPhotoLibraryAddUsageDescription  
 Value: "Everline saves your couple moments to your photo library so you can cherish them forever."
 
 
 2. FACE ID USAGE (Optional, for biometric unlock)
 --------------------------------------------------
 Key: NSFaceIDUsageDescription
 Value: "Everline uses Face ID to quickly and securely unlock your private memory vault."
 
 
 3. LOCATION SERVICES (Optional, for memory location tagging)
 ------------------------------------------------------------
 Key: NSLocationWhenInUseUsageDescription
 Value: "Everline can tag your memories with location to remember where special moments happened."
 
 
 4. PREVENT SCREENSHOTS (Advanced - Optional)
 --------------------------------------------
 To prevent screenshots of sensitive content, you can use:
 
 Key: UIApplicationSupportsSecureDrawing
 Value: YES
 
 Note: This is not a standard iOS feature. For true screenshot prevention,
 you'll need to implement a custom solution using UITextField's
 isSecureTextEntry or similar techniques.
 
 
 5. BACKGROUND MODES (Optional, for advanced features)
 -----------------------------------------------------
 If you want to implement background encryption or data processing:
 
 Key: UIBackgroundModes
 Array value:
   - "processing" (for background tasks)
   - "fetch" (for background refresh)
 
 
 6. APP ICON ALTERNATES (For Disguise Mode - Future Feature)
 ------------------------------------------------------------
 Key: CFBundleIcons
 Dictionary containing alternate icon configurations
 
 Key: CFBundleAlternateIcons
 Dictionary with:
   - "Calculator" (icon set name)
   - "Notes" (icon set name)
   etc.
 
 
 EXAMPLE Info.plist XML:
 =======================
 
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
     <!-- Photo Library Access -->
     <key>NSPhotoLibraryUsageDescription</key>
     <string>Everline needs access to your photos to save your precious memories securely in your private vault.</string>
     
     <key>NSPhotoLibraryAddUsageDescription</key>
     <string>Everline saves your couple moments to your photo library so you can cherish them forever.</string>
     
     <!-- Face ID Access -->
     <key>NSFaceIDUsageDescription</key>
     <string>Everline uses Face ID to quickly and securely unlock your private memory vault.</string>
     
     <!-- Location Services -->
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>Everline can tag your memories with location to remember where special moments happened.</string>
     
     <!-- Privacy -->
     <key>ITSAppUsesNonExemptEncryption</key>
     <false/>
     
     <!-- App Transport Security (if using any networking) -->
     <key>NSAppTransportSecurity</key>
     <dict>
         <key>NSAllowsArbitraryLoads</key>
         <false/>
     </dict>
 </dict>
 </plist>
 
 
 PRIVACY MANIFEST (Privacy Nutrition Label)
 ==========================================
 
 Create a file named PrivacyInfo.xcprivacy in your project with:
 
 {
   "NSPrivacyTracking": false,
   "NSPrivacyTrackingDomains": [],
   "NSPrivacyCollectedDataTypes": [],
   "NSPrivacyAccessedAPITypes": [
     {
       "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
       "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]
     },
     {
       "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryFileTimestamp",
       "NSPrivacyAccessedAPITypeReasons": ["C617.1"]
     }
   ]
 }
 
 
 APP STORE DESCRIPTION RECOMMENDATIONS
 =====================================
 
 Privacy Highlights to mention:
 
 • All photos are encrypted with AES-256 encryption
 • Custom PIN protection separate from your device passcode
 • Data stored locally only - never uploaded to any server
 • No analytics, no tracking, no third-party services
 • App locks automatically when backgrounded
 • Privacy blur in app switcher protects your content
 • Open source security implementation
 
 
 TESTING YOUR PRIVACY SETTINGS
 ==============================
 
 1. Clean install app
 2. Grant photo access - verify description is clear and trustworthy
 3. Attempt Face ID - verify description explains the purpose
 4. Try location - verify optional and clear reasoning
 5. Check App Store Connect privacy questionnaire matches reality
 
 
 COMPLIANCE NOTES
 ================
 
 ✅ GDPR Compliant - All data local, no servers
 ✅ CCPA Compliant - No data collection or sale
 ✅ App Store Privacy Requirements - Full transparency
 ✅ Export Compliance - Encryption is standard iOS APIs
 
 */

// MARK: - Privacy Configuration Helper

import Foundation

struct PrivacyConfiguration {
    static let photoLibraryUsage = "Everline needs access to your photos to save your precious memories securely in your private vault."
    static let faceIDUsage = "Everline uses Face ID to quickly and securely unlock your private memory vault."
    static let locationUsage = "Everline can tag your memories with location to remember where special moments happened."
}
