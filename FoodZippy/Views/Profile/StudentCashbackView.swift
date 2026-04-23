import SwiftUI

struct StudentRewardsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var emailAddress = ""
    
    // Data for Steps
    let howItWorksSteps = [
        "Enter your student email ID & click \"Get OTP.\"",
        "Check your email for the OTP.",
        "Enter OTP to verify & enjoy your offers! 🎉"
    ]
    
    // Data for Benefits
    let benefits = [
        "one year free subscription",
        "20% discount on all orders",
        "Free delivery on every order",
        "Exclusive student-only deals"
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Root scrollable view
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // 1. Student Cashback Image Banner
                        Image("student_cashback")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 220 + geo.safeAreaInsets.top) // Adjust height to include notch
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // 2. VERIFY YOUR STUDENT EMAIL
                            StudentVerificationSection(
                                emailAddress: $emailAddress,
                                cardTextGray: Color.gray,
                                grayButtonBG: Color.appGrayBg // Ensure this color exists in your assets/extensions
                            )
                            
                            // 3. BENEFITS
                            BenefitsSection(
                                benefits: benefits,
                                oneOrange: Color.appAccent,
                                cardTextGray: Color.gray
                            )
                            
                            // 4. HOW IT WORKS
                            StudentHowItWorksSection(
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
                .ignoresSafeArea(edges: .top)
                
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
                        .padding(.top, geo.safeAreaInsets.top + 8)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            appState.hideMainTabBar = true
        }
    }
}

// MARK: - Sub-Views

struct StudentSectionHeaderLabel: View {
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

struct StudentVerificationSection: View {
    @Binding var emailAddress: String
    let cardTextGray: Color
    let grayButtonBG: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StudentSectionHeaderLabel(title: "VERIFY YOUR COLLEGE EMAIL", color: cardTextGray)
            
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

struct BenefitsSection: View {
    let benefits: [String]
    let oneOrange: Color
    let cardTextGray: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BENEFITS")
                .font(.headline)
                .foregroundColor(cardTextGray)
                .tracking(1.0)
            
            HStack(alignment: .center, spacing: 0) {
                // Left text list
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(benefits.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 12) {
                            // Circular line point with dashed line connecting
                            ZStack(alignment: .top) {
                                VerticalDashedLine(isLast: index == benefits.count - 1)
                                    .stroke(cardTextGray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                    .frame(width: 1, height: 36)
                                    .offset(x: 8)
                                
                                Circle()
                                    .fill(Color(hex: "D9D9D9"))
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 1.5)
                                    )
                            }
                            
                            // Text point
                            Text(formatBenefitText(benefits[index], oneOrange: oneOrange))
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 1)
                    }
                }
                
                Spacer(minLength: 20)
                
                // --- GIFT ILLUSTRATION PLACEHOLDER ---
                // Image("your_gift_box_asset_name") // Insert asset
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(Text("Gift Box").font(.caption).foregroundColor(.gray))
                // ------------------------------------------
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
            )
        }
    }
    
    // Helper to color 'one' in orange
    func formatBenefitText(_ text: String, oneOrange: Color) -> AttributedString {
        var attributed = AttributedString(text)
        if let range = attributed.range(of: "one") {
            attributed[range].foregroundColor = oneOrange
            attributed[range].font = .subheadline.weight(.bold)
        }
        return attributed
    }
}

struct StudentHowItWorksSection: View {
    let steps: [String]
    let themePurple: Color
    let cardTextGray: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StudentSectionHeaderLabel(title: "HOW IT WORKS", color: cardTextGray)
            
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

struct VerticalDashedLine: Shape {
    let isLast: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if !isLast {
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
        return path
    }
}
