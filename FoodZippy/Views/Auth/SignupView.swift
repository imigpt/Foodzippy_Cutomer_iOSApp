// SignupView.swift
// Registration screen matching Android CreateAcountActivity

import SwiftUI

struct SignupView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .frame(width: 70, height: 60)
                        .foregroundColor(.appPrimary)
                    
                    Text("Create Account")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appBlack)
                    
                    Text("Sign up to start ordering")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Form Fields
                VStack(spacing: 16) {
                    // Name
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                        TextField("Full Name", text: $viewModel.name)
                            .textContentType(.name)
                    }
                    .padding()
                    .background(Color.appGrayBg)
                    .cornerRadius(10)
                    
                    // Email
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email Address", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                    .padding()
                    .background(Color.appGrayBg)
                    .cornerRadius(10)
                    
                    // Country Code + Mobile
                    HStack(spacing: 12) {
                        Menu {
                            ForEach(viewModel.countryCodes) { code in
                                Button(code.ccode ?? "+91") {
                                    viewModel.selectedCountryCode = code.ccode ?? "+91"
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedCountryCode)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.appBlack)
                            .padding()
                            .background(Color.appGrayBg)
                            .cornerRadius(10)
                        }
                        
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.gray)
                            TextField("Mobile Number", text: $viewModel.mobile)
                                .keyboardType(.phonePad)
                                .textContentType(.telephoneNumber)
                        }
                        .padding()
                        .background(Color.appGrayBg)
                        .cornerRadius(10)
                    }
                    
                    // Password
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        if isPasswordVisible {
                            TextField("Password", text: $viewModel.password)
                        } else {
                            SecureField("Password", text: $viewModel.password)
                        }
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.appGrayBg)
                    .cornerRadius(10)
                    
                    // Confirm Password
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.gray)
                        if isConfirmPasswordVisible {
                            TextField("Confirm Password", text: $viewModel.confirmPassword)
                        } else {
                            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        }
                        Button(action: { isConfirmPasswordVisible.toggle() }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.appGrayBg)
                    .cornerRadius(10)
                    
                    // Referral Code
                    HStack {
                        Image(systemName: "tag")
                            .foregroundColor(.gray)
                        TextField("Referral Code (Optional)", text: $viewModel.referralCode)
                    }
                    .padding()
                    .background(Color.appGrayBg)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                
                // Signup Button
                Button(action: {
                    Task { await viewModel.checkMobileForSignup() }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appPrimary)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .disabled(viewModel.isLoading)
                
                // Login Link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Button("Login") {
                        dismiss()
                    }
                    .foregroundColor(.appPrimary)
                    .fontWeight(.bold)
                }
                .font(.subheadline)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $viewModel.navigateToOtp) {
            OtpVerificationView(viewModel: viewModel)
        }
        .overlay(
            VStack {
                if viewModel.showError {
                    ToastView(message: viewModel.errorMessage, isError: true) {
                        viewModel.showError = false
                    }
                }
            }
        )
    }
}
