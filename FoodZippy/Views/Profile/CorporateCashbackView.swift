import SwiftUI

struct CorporateRewardsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var emailAddress = ""
    
    // Data for Steps
    let howItWorksSteps = [
        "Enter your work email ID & click \"Get OTP.\"",
        "Check your email for the OTP.",
        "Enter OTP to verify & enjoy your offers! 🎉"
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Root scrollable view
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 1. Corporate Cashback Image Banner
                    Image("corporate_cashback")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260) // Adjust the height as needed for your banner
                        .clipped()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 2. VERIFY YOUR WORK EMAIL
                        VerificationSection(
                            emailAddress: $emailAddress,
                            cardTextGray: Color.gray,
                            grayButtonBG: Color.appGrayBg // Ensure this color exists in your assets/extensions
                        )
                        
                        // 3. HOW IT WORKS
                        HowItWorksSection(
                            steps: howItWorksSteps,
                            themePurple: Color.appPrimary, // Ensure this color exists in your assets/extensions
                            cardTextGray: Color.gray
                        )
                        
                        // FAQ link
                        Button(action: {
                            // FAQ action
                        }) {
                            HStack(spacing: 4) {
                                Text("Frequently Asked Questions")
                                    .font(.system(size: 15, weight: .bold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(Color.appPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40) // Bottom padding for content
                }
            }
           // .ignoresSafeArea(edges: .top) // Allows the image banner to reach the very top of the screen
            
            // Fixed Back Button on Top
            VStack {
                HStack {
                    Button(action: {
                        appState.hideMainTabBar = false
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary) // Changed to primary (black/dark) for contrast
                            .padding(10)
                            .background(Color.white) // Solid white background so it's always visible over the image
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
                    }
                    .padding(.top, 50) // Space for status bar / notch
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .tabBar)
        // 2. Add this to keep your custom tab bar hidden
        .onAppear {
            AppState.shared.hideMainTabBar = true 
        }
    }
}

// MARK: - Sub-Views

struct SectionHeaderLabel: View {
    let title: String
    let color: Color
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.black.opacity(0.7))
                .tracking(1.5)
            
            Rectangle()
                .fill(color.opacity(0.3))
                .frame(height: 1)
        }
    }
}

struct VerificationSection: View {
    @Binding var emailAddress: String
    let cardTextGray: Color
    let grayButtonBG: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderLabel(title: "VERIFY YOUR WORK EMAIL", color: cardTextGray)
            
            VStack(spacing: 16) {
                // Email input card
                HStack {
                    TextField("Enter your email ID", text: $emailAddress)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(cardTextGray.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Get OTP Button
                Button(action: {
                    // Verify action
                }) {
                    Text("Get OTP")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.black.opacity(0.08)) // Light grey bg
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(emailAddress.isEmpty)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
        }
    }
}

struct HowItWorksSection: View {
    let steps: [String]
    let themePurple: Color
    let cardTextGray: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderLabel(title: "HOW IT WORKS", color: cardTextGray)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(steps.indices, id: \.self) { index in
                    HStack(alignment: .center, spacing: 16) {
                        // Custom path to draw the numbered points and line connection
                        ZStack(alignment: .center) {
                            if index != steps.count - 1 {
                                Rectangle()
                                    .fill(themePurple.opacity(0.1))
                                    .frame(width: 2, height: 45)
                                    .offset(y: 22)
                            }
                            
                            Circle()
                                .fill(themePurple.opacity(0.1))
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Text("\(index + 1)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(themePurple)
                                )
                        }
                        
                        Text(steps[index])
                            .font(.system(size: 15))
                            .foregroundColor(Color.black.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
        }
    }
}