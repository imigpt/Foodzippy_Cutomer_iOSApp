// SignupView.swift
// Registration screen matching Android CreateAcountActivity

import SwiftUI

struct SignupView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                    TextField("Full Name", text: $viewModel.name)
                        .textContentType(.name)
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
                                    .foregroundColor(.appBlack)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .background(Color.appGrayBg)
                            .cornerRadius(10)
                        }
                        
                        TextField("Mobile Number", text: $viewModel.mobile)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color.appGrayBg)
                            .cornerRadius(10)
                    }
                    
                    // Password
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.appGrayBg)
                        .cornerRadius(10)
                    
                    // Referral Code
                    TextField("Referral Code (Optional)", text: $viewModel.referralCode)
                        .padding()
                        .background(Color.appGrayBg)
                        .cornerRadius(10)
                    
                    // Sign Up Button
                    Button(action: {
                        Task { await viewModel.checkMobileForSignup() }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            }
                            Text("SIGN UP")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, 24)
                
                // Login Link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Button("Login") {
                        dismiss()
                    }
                    .foregroundColor(.appPrimary)
                    .fontWeight(.semibold)
                }
                .padding(.top, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.navigateToOtp) {
            OtpVerificationView(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
