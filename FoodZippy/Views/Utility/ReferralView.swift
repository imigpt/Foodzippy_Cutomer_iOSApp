// ReferralView.swift
// Matches Android ReferlActivity

import SwiftUI

struct ReferralView: View {
    @State private var referralCode = ""
    @State private var referCredit = ""
    @State private var signupCredit = ""
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
                // Illustration
                Image(systemName: "person.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appPrimary)
                
                Text("Refer & Earn")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !signupCredit.isEmpty {
                    Text("Earn \(SessionManager.shared.currency)\(signupCredit) for every friend you refer!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Referral code card
                VStack(spacing: 12) {
                    Text("Your Referral Code")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(referralCode)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appPrimary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundColor(.appPrimary.opacity(0.3))
                            )
                        
                        // Copy button
                        Button {
                            UIPasteboard.general.string = referralCode
                        } label: {
                            Label("Copy Code", systemImage: "doc.on.doc")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
                .padding()
                .background(Color.appPrimary.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Share button
                Button {
                    shareReferral()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share with Friends")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appPrimary)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // How it works
                VStack(alignment: .leading, spacing: 16) {
                    Text("How it works")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    HowItWorksStep(number: "1", title: "Share your code", description: "Share your referral code with friends")
                    HowItWorksStep(number: "2", title: "Friend signs up", description: "Your friend signs up using your code")
                    HowItWorksStep(number: "3", title: "Both earn rewards", description: "You both get wallet credits!")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Refer & Earn")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let uid = SessionManager.shared.currentUser?.id ?? ""
            do {
                let response = try await APIService.shared.getReferralData(uid: uid)
                referralCode = response.referData?.referCode ?? ""
                referCredit = response.referData?.referCredit ?? ""
                signupCredit = response.referData?.signupCredit ?? ""
            } catch {}
            isLoading = false
        }
    }
    
    private func shareReferral() {
        let message = "Use my referral code \(referralCode) to sign up on FoodZippy and get rewards!"
        
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct HowItWorksStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.appPrimary)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}
