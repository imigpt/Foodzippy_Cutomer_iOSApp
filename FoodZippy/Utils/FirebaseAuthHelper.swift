// FirebaseAuthHelper.swift
// Helper for Firebase Phone and Social Authentication

import Foundation
import FirebaseAuth

class FirebaseAuthHelper {
    static let shared = FirebaseAuthHelper()
    
    private init() {}
    
    /// Sends an SMS verification code to the specified phone number.
    /// Returns the verification ID needed for sign-in.
    func sendVerificationCode(to phoneNumber: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: verificationID ?? "")
                }
            }
        }
    }
    
    /// Signs in with the verification ID and the OTP code entered by the user.
    /// Returns the Firebase User UID.
    func signIn(verificationID: String, verificationCode: String) async throws -> String {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = authResult?.user {
                    continuation.resume(returning: user.uid)
                } else {
                    continuation.resume(throwing: NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user"]))
                }
            }
        }
    }
}
