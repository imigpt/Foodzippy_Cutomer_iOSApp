// LoginView.swift
// Login screen matching Android LoginActivity

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Logo
                VStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.appPrimary)
                    
                    Text("FoodZippy")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.appPrimary)
                }
                .padding(.top, 60)
                
                Text("Login to your account")
                    .font(.headline)
                    .foregroundColor(.appBlack)
                    .padding(.top, 20)
                
                // Country Code + Mobile
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        // Country Code Picker
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
                        
                        // Mobile Number
                        TextField("Enter Mobile Number", text: $viewModel.mobile)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color.appGrayBg)
                            .cornerRadius(10)
                    }
                    
                    // Login Button
                    Button(action: {
                        Task { await viewModel.checkMobileForLogin() }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("LOGIN")
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
                
                // Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.appGray)
                    Text("OR").font(.caption).foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(.appGray)
                }
                .padding(.horizontal, 24)
                
                // Create Account
                NavigationLink(destination: SignupView(viewModel: viewModel)) {
                    Text("Create New Account")
                        .fontWeight(.semibold)
                        .foregroundColor(.appPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appPrimary, lineWidth: 1.5)
                        )
                }
                .padding(.horizontal, 24)
                
                
                // Guest Mode
                Button("Continue as Guest") {
                    viewModel.continueAsGuest()
                }
                .foregroundColor(.gray)
                .padding(.top, 8)
                
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $viewModel.navigateToOtp) {
            OtpVerificationView(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .task {
            await viewModel.loadCountryCodes()
        }
    }
}
