// AuthViewModel.swift
// Handles login, signup, OTP verification, forgot password

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var mobile = ""
    @Published var name = ""
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
        guard validateSignup() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIService.shared.checkMobile(
                mobile: mobile,
                ccode: selectedCountryCode
            )
            
            if response.isSuccess {
                showErrorMessage("Mobile number already registered. Please login.")
            } else {
                currentFlow = .signup
                navigateToOtp = true
                await sendOtp()
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - OTP
    
    func sendOtp() async {
        do {
            _ = try await APIService.shared.sendOtp(
                mobile: mobile,
                ccode: selectedCountryCode
            )
            startOtpTimer()
        } catch {
            showErrorMessage("Failed to send OTP")
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
        
        switch currentFlow {
        case .login:
            await performLogin()
        case .signup:
            await performSignup()
        case .forgotPassword:
            navigateToHome = false
            // Navigate to change password
            successMessage = "OTP verified. Please set new password."
            showSuccess = true
        case .walletActivation:
            break
        }
    }
    
    private func performLogin() async {
        do {
            let response = try await APIService.shared.login(
                mobile: mobile,
                ccode: selectedCountryCode
            )
            
            if response.isSuccess, let user = response.userLogin {
                SessionManager.shared.saveUser(user)
                if let wallet = user.wallet {
                    SessionManager.shared.walletBalance = wallet
                }
                SessionManager.shared.isIntroShown = true
                
                // Sync FCM token
                let token = SessionManager.shared.fcmToken
                if !token.isEmpty {
                    try? await APIService.shared.saveToken(userId: user.id ?? "", token: token)
                }
                
                AppState.shared.currentScreen = .home
            } else {
                showErrorMessage(response.responseMsg ?? "Login failed")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    private func performSignup() async {
        do {
            let response = try await APIService.shared.register(
                name: name,
                mobile: mobile,
                ccode: selectedCountryCode,
                password: password,
                referCode: referralCode
            )
            
            if response.isSuccess, let user = response.userLogin {
                SessionManager.shared.saveUser(user)
                if let wallet = user.wallet {
                    SessionManager.shared.walletBalance = wallet
                }
                SessionManager.shared.isIntroShown = true
                AppState.shared.currentScreen = .home
            } else {
                showErrorMessage(response.responseMsg ?? "Registration failed")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    // MARK: - Forgot Password
    
    func requestForgotPassword() async {
        guard validateMobile() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIService.shared.forgotPassword(
                mobile: mobile,
                ccode: selectedCountryCode
            )
            
            if response.isSuccess {
                currentFlow = .forgotPassword
                navigateToOtp = true
                await sendOtp()
            } else {
                showErrorMessage("Mobile number not found")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
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
        if !validateMobile() { return false }
        if password.isEmpty {
            showErrorMessage("Please enter password")
            return false
        }
        if password.count < 6 {
            showErrorMessage("Password must be at least 6 characters")
            return false
        }
        return true
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
