// ForgotPasswordView.swift
// Forgot password screen matching Android ForgotActivity

import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "key.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.appAccent)
            
            Text("Forgot Password?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter your registered mobile number\nto reset your password")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
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
                
                Button(action: {
                    Task { await viewModel.requestForgotPassword() }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        }
                        Text("SUBMIT")
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
            
            Spacer()
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
