import SwiftUI

struct CorporateRewardsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var emailAddress = ""
    @State private var showingHeaderBadge = true
    
    // Data for Benefits and Steps
    let benefits = [
        "one - Free Delivery at Discounted Price",
        "Flat 67% OFF on Food",
        "Additional ₹100 OFF on Instamart",
        "Up to ₹2000 OFF on Dineout & more!"
    ]
    
    let howItWorksSteps = [
        "Enter your work email ID & click \"Get OTP.\"",
        "Check your email for the OTP.",
        "Enter OTP to verify & enjoy your offers! 🎉#
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Root scrollable view
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 1. Hero Header Section
                    VStack(spacing: 0) {
                        HeroHeaderContent(
                            showingHeaderBadge: $showingHeaderBadge,
                            themePurple: Color.appPrimary,
                            themePurpleLight: Color.appAccent.opacity(0.8),
                            badgeText: Color.white
                        )
                        
                        // Wave separator
                        WaveHeaderShape()
                            .fill(LinearGradient(colors: [Color.appPrimary, Color.appPrimary.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                            .frame(height: 50)
                            .offset(u: -1) // to prevent gaps
                    }
                    .background(Color(.systemGroupedBackground))
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 2. VERIFY YOUR WORK EMAIL
                        VerificationSection(
                            emailAddress: $emailAddress,
                            cardTextGray: Color.gray,
                            grayButtonBG: Color.appGrayBg
                        )
                        
                        // 3. BENEFITS
                        BenefitsSection(
                            benefits: benefits,
                            oneOrange: Color.app(ex,
                            cardTextGray: Color.gray
                        )
                        
                        // 4. HOW IT WORKS
                        HowItWorksSection(
                            steps: howItWorksSteps,
                            themePurple: Color.appPrimary,
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
                            .foregroundColor(Color.appOrange)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40) // Bottom padding for content
                }
            }
            .ignoresSafeArea()
            
            // Fixed Back Button on Top
            HStack {
                Button(action: {
                    appState.hideMainTabBar = false
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.leading, 16)
                .padding(.top, 56) // Simulate safe area for notch
                
                Spacer()
            }
            .padding(.top, 4)
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            appState.hideMainTabBar = true
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

struct HeroHeaderContent: View {
    @Binding var showingHeaderBadge: Bool
    let themePurple: Color
    let themePurpleLight: Color
    let badgeText: Color
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Text
            VStack(spacing: 8) {
                Text("Corporate Rewards")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Verify your corporate email address to unlock\nexclusive Swiggy rewards!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.top, 100)
            
            // Placeholder for illustration
            ZStack {
                // Background stars/sparkles
                HStack(spacing: 120) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .offset(y: -40)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .offset(y: 30)
                }
                
                VStack {
                    Spacer().frame(height: 20)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.clear)
                        .frame(width: 250, height: 160)
                        .overlay(Text("[Illustration Placeholder]").foregroundColor(.white.opacity(0.5)))
                }
            }
            .padding(.vertical, 16)
            
            // Verification Badge
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .foregroundColor(themePurpleLight)
                    .font(.system(size: 12))
                
                Text("SECURE & PRIVATE. JUST FOR VERIFICATION")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(badgeText)
                    .tracking(0.5)
                
                Image(systemName: "sparkle")
                    .foregroundColor(themePurpleLight)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.black.opacity(0.15)).overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 0.5)))
            .padding(.top, 0)
            .padding(.bottom, 4)
            
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 0)
        .background(
            LinearGradient(colors: [Color.appPrimary.opacity(0.8), Color.appPrimary], startPoint: .top, endPoint: .bottom)
        )
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

struct BenefitsSection: View {
    let benefits: [String]
    let oneOrange: Color
    let cardTextGray: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderLabel(title: "BENEFITS", color: cardTextGray)
            
            HStack(alignment: .center, spacing: 0) {
                // Left text list
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(benefits.indices, id: \.self) { index in
                        HStack(alignment: .center, spacing: 12) {
                            // Circular line point with dashed line connecting
                            ZStack(alignment: .center) {
                                if index != benefits.count - 1 {
                                    Rectangle()
                                        .fill(Color.appPrimary.opacity(0.1))
                                        .frame(width: 2, height: 35)
                                        .offset(y: 18)
                                }
                                
                                Circle()
                                    .fill(Color.appPrimary.opacity(0.1))
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(Color.appPrimary)
                                    )
                            }
                            
                            // Text point
                            Text(formatBenefitText(benefits[index], oneOrange: oneOrange))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                Spacer(minLength: 12)
                
                // --- GIFT ILLUSTRATION PLACEHOLDER ---
                Image(systemName: "gift.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.appPrimary.opacity(0.6))
                    .padding(.trailing, 8)
                // ------------------------------------------
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
        }
    }
    
    // Helper to color 'one' in orange
    func formatBenefitText(text: String, oneOrange: Color) -> AttributedString {
        var attributed = AttributedString(text)
        if let range = attributed.range(of: "one") {
            attributed[range].foregroundColor = oneOrange
            attributed[range].font = .system(size: 14, weight: .heavy)
        }
        return attributed
    }
}

struct HowItWorksSection: View {
    let steps: [StringU
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

// Wave Shape for header bottom separator
struct WaveHeaderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        let curveHeight: CGFloat = 12
        var isDown = true
        let sections = 6
        let widthPerSection = rect.width / CGFloat(sections)
        
        var x: CGFloat = 0
        path.addLine(to: CGPoint(x: 0, y: rect.height - curveHeight))
        
        for _ in 0..<sections {
            let nextX = x + widthPerSection
            path.addQuadCurve(to: CGPoint(x: nextX, y: rect.height - curveHeight),
                              control: CGPoint(x: x + widthPerSection/2, y: isDown ? rect.height : rect.height - curveHeight - curveHeight))
            x = nextX
            isDown.toggle()
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.closeSubpath()
        return path
    }
}

