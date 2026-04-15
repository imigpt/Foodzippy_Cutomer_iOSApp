// OtpVerificationView.swift
// OTP verification screen matching Android VerifyPhoneActivity

import SwiftUI

struct OtpVerificationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Int?
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: "lock.shield.fill")
                .resizable()
                .frame(width: 60, height: 70)
                .foregroundColor(.appPrimary)
            
            // Title
            VStack(spacing: 8) {
                Text("Verification")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter the 6-digit code sent to\n\(viewModel.selectedCountryCode) \(viewModel.mobile)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // OTP Fields
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $viewModel.otpDigits[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2.bold())
                        .frame(width: 48, height: 56)
                        .background(Color.appGrayBg)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    focusedField == index ? Color.appPrimary : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .focused($focusedField, equals: index)
                        .onChange(of: viewModel.otpDigits[index]) { newValue in
                            if newValue.count > 1 {
                                viewModel.otpDigits[index] = String(newValue.prefix(1))
                            }
                            if newValue.count == 1 && index < 5 {
                                focusedField = index + 1
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            
            // Verify Button
            Button(action: {
                Task { await viewModel.verifyOtp() }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    }
                    Text("VERIFY")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appPrimary)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal, 24)
            
            // Resend
            HStack {
                if viewModel.canResendOtp {
                    Button("Resend OTP") {
                        Task { await viewModel.sendOtp() }
                    }
                    .foregroundColor(.appPrimary)
                    .fontWeight(.semibold)
                } else {
                    Text("Resend OTP in \(viewModel.otpResendTimer)s")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focusedField = 0
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
