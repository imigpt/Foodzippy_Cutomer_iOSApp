// AuthViewModel.swift
// Handles login, signup, OTP verification, forgot password

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var mobile = ""
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var referralCode = ""
    @Published var selectedCountryCode = "+91"
    @Published var countryCodes: [CountryCodeItem] = []
    
    @Published var otpDigits: [String] = Array(repeating: "", count: 6)
    @Published var otpResendTimer = 60
    @Published var canResendOtp = false
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    // Navigation
    @Published var navigateToOtp = false
    @Published var navigateToSignup = false
    @Published var navigateToForgot = false
    @Published var navigateToHome = false
    
    private var firebaseVerificationID: String {
        get { UserDefaults.standard.string(forKey: "firebase_verification_id") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "firebase_verification_id") }
    }
    
    enum AuthFlow {
        case login
        case signup
        case forgotPassword
        case walletActivation
    }
    
    var currentFlow: AuthFlow = .login
    private var timerCancellable: AnyCancellable?
    
    // MARK: - Load Country Codes
    
    func loadCountryCodes() async {
        do {
            let response = try await APIService.shared.getCountryCodes()
            if let codes = response.countryCode {
                countryCodes = codes.filter { $0.status == "1" }
                if let first = countryCodes.first {
                    selectedCountryCode = first.ccode ?? "+91"
                }
            }
        } catch {
            showErrorMessage("Failed to load country codes")
        }
    }
    
    // MARK: - Login
    
    func checkMobileForLogin() async {
        guard validateMobile() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIService.shared.checkMobile(
                mobile: mobile,
                ccode: selectedCountryCode
            )
            
            if response.isSuccess {
                currentFlow = .login
                navigateToOtp = true
                await sendOtp()
            } else {
                showErrorMessage("Mobile number not registered. Please sign up.")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - Signup
    
    func checkMobileForSignup() async {
        print("🧪 DEBUG: checkMobileForSignup started")
        guard validateSignup() else { 
            print("🧪 DEBUG: validateSignup failed")
            return 
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("🧪 DEBUG: Checking mobile \(selectedCountryCode)\(mobile)")
            let response = try await APIService.shared.checkMobile(
                mobile: mobile,
                ccode: selectedCountryCode
            )
            
            print("🧪 DEBUG: checkMobile response success: \(response.isSuccess), msg: \(response.responseMsg ?? "nil")")
            
            if response.isSuccess {
                showErrorMessage("Mobile number already registered. Please login.")
            } else {
                currentFlow = .signup
                print("🧪 DEBUG: Mobile not registered, proceeding to OTP")
                navigateToOtp = true
                await sendOtp()
            }
        } catch {
            print("🧪 DEBUG: checkMobile error: \(error.localizedDescription)")
            showErrorMessage(error.localizedDescription)
        }
    }
    
    
    // MARK: - OTP
    
    func sendOtp() async {
        isLoading = true
        defer { isLoading = false }
        
        let fullPhone = "\(selectedCountryCode)\(mobile)"
        do {
            // 1. Send OTP via Firebase
            let vID = try await FirebaseAuthHelper.shared.sendVerificationCode(to: fullPhone)
            self.firebaseVerificationID = vID
            
            #if DEBUG
            print("🧪 DEBUG: Received verificationID: \(vID)")
            #endif
            
            // 2. Optional: Notify backend (already done in current flow if needed)
            _ = try? await APIService.shared.sendOtp(
                mobile: mobile,
                ccode: selectedCountryCode
            )
            
            startOtpTimer()
            navigateToOtp = true
        } catch {
            showErrorMessage("Firebase: \(error.localizedDescription)")
        }
    }
    
    func verifyOtp() async {
        let otp = otpDigits.joined()
        guard otp.count == 6 else {
            showErrorMessage("Please enter complete OTP")
            return
        }

        isLoading = true
        defer { isLoading = false }

        #if DEBUG
        // DEBUG bypass: allow development without Firebase setup.
        if otp == "000000" {
            switch currentFlow {
            case .login:
                await performLogin()
            case .signup:
                await performSignup()
            case .forgotPassword:
                navigateToHome = false
                successMessage = "OTP verified (debug). Please set new password."
                showSuccess = true
            case .walletActivation:
                break
            }
            return
        }
        #endif

        do {
            // 1. Verify with Firebase
            let uid = try await FirebaseAuthHelper.shared.signIn(
                verificationID: firebaseVerificationID,
                verificationCode: otp
            )
            print("✅ Firebase Auth success. UID: \(uid)")

            // 2. Proceed with backend login/signup
            switch currentFlow {
            case .login:
                await performLogin()
            case .signup:
                await performSignup()
            case .forgotPassword:
                navigateToHome = false
                successMessage = "OTP verified. Please set new password."
                showSuccess = true
            case .walletActivation:
                break
            }
        } catch {
            // Provide clearer error context
            let message = "Verification Failed: \(error.localizedDescription)"
            print("❌ Firebase verification error: \(message)")
            showErrorMessage(message)
        }
    }
    
    private func performLogin() async {
        do {
            let response = try await APIService.shared.login(
                mobile: mobile,
                ccode: selectedCountryCode
            )
            
            if response.isSuccess, let user = response.userLogin {
                handleAuthSuccess(user)
            } else {
                showErrorMessage(response.responseMsg ?? "Login failed")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    private func performSignup() async {
        print("🧪 DEBUG: Starting performSignup for \(mobile)")
        print("🧪 DEBUG: Signup Data - Name: \(name), Email: \(email), Password: \(password), CCode: \(selectedCountryCode)")
        do {
            let response = try await APIService.shared.register(
                name: name.isEmpty ? "Customer" : name,
                email: email,
                mobile: mobile,
                ccode: selectedCountryCode,
                password: password,
                referCode: referralCode
            )
            
            print("🧪 DEBUG: Registration response success: \(response.isSuccess), message: \(response.responseMsg ?? "N/A")")
            
            if response.isSuccess, let user = response.userLogin {
                print("🧪 DEBUG: Registration successful, handling auth success")
                handleAuthSuccess(user)
            } else if response.responseMsg?.lowercased().contains("already used") == true {
                print("🧪 DEBUG: Mobile already used, falling back to login")
                await performLogin()
            } else {
                print("🧪 DEBUG: Registration failed with message: \(response.responseMsg ?? "unknown")")
                showErrorMessage(response.responseMsg ?? "Registration failed")
            }
        } catch {
            print("🧪 DEBUG: Registration catch error: \(error.localizedDescription)")
            showErrorMessage(error.localizedDescription)
        }
    }
    
    private func handleAuthSuccess(_ user: User) {
        SessionManager.shared.saveUser(user)
        if let wallet = user.wallet {
            SessionManager.shared.walletBalance = wallet.stringValue ?? "0"
        }
        SessionManager.shared.isIntroShown = true
        
        // Sync FCM token
        let token = SessionManager.shared.fcmToken
        if !token.isEmpty {
            Task {
                try? await APIService.shared.saveToken(userId: user.id?.stringValue ?? "", token: token)
            }
        }
        
        AppState.shared.currentScreen = .home
    }
    
    
    // MARK: - Guest Mode
    
    func continueAsGuest() {
        SessionManager.shared.isGuest = true
        SessionManager.shared.isIntroShown = true
        AppState.shared.currentScreen = .guestHome
    }
    
    // MARK: - Timer
    
    private func startOtpTimer() {
        otpResendTimer = 60
        canResendOtp = false
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.otpResendTimer > 0 {
                    self.otpResendTimer -= 1
                } else {
                    self.canResendOtp = true
                    self.timerCancellable?.cancel()
                }
            }
    }
    
    // MARK: - Validation
    
    private func validateMobile() -> Bool {
        if mobile.isEmpty {
            showErrorMessage("Please enter mobile number")
            return false
        }
        if !mobile.isValidPhone {
            showErrorMessage("Please enter a valid 10-digit mobile number")
            return false
        }
        return true
    }
    
    private func validateSignup() -> Bool {
        if name.isEmpty {
            showErrorMessage("Please enter your name")
            return false
        }
        if email.isEmpty {
            showErrorMessage("Please enter your email")
            return false
        }
        if !email.isValidEmail {
            showErrorMessage("Please enter a valid email address")
            return false
        }
        if !validateMobile() { return false }
        if password.isEmpty {
            showErrorMessage("Please enter password")
            return false
        }
        if password.count < 6 {
            showErrorMessage("Password must be at least 6 characters")
            return false
        }
        if password != confirmPassword {
            showErrorMessage("Passwords do not match")
            return false
        }
        return true
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

