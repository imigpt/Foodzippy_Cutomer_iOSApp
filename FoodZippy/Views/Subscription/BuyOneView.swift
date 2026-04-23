import SwiftUI

struct BuyOneView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var navigateToRedeemCoupon = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // Background Color for the rest of the scroll view
            Color(UIColor.systemGroupedBackground)
               // .ignoresSafeArea()
            
            // Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // 1. Top Pink/Red Gradient Banner
                    TopBannerView()
                    
                    // 2. Main Content
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // ONE BENEFITS Header
                        SectionHeaderView(title: "ONE BENEFITS")
                        
                        // Savings Highlight Card
                        SavingsHighlightCard()
                        
                        // Main Benefits Card
                        VStack(alignment: .leading, spacing: 24) {
                            // Food Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Food")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.orange) // Brand orange
                                
                                BenefitRowView(
                                    title: "Unlimited free deliveries",
                                    subtitle: "on all restaurants up to 7 km,\non orders above ₹99",
                                    image: nil
                                )
                                
                                BenefitRowView(
                                    title: "Up to 30% extra discounts",
                                    subtitle: "over & above other offers",
                                    image: nil
                                )
                                
                                BenefitRowView(
                                    title: "No surge fee, ever!",
                                    subtitle: "during peak hours or holidays",
                                    image: Image("food_bowl")
                                )
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Dineout Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Dineout")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.1, green: 0.5, blue: 0.3)) // Dark Green
                                
                                BenefitRowView(
                                    title: "Exclusive Pre-book offers",
                                    subtitle: "Up to 50% off on top restaurants",
                                    image: Image("cloche_icon")
                                )
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)

                        // Promotional Deal Banner
                        DealPromotionalBanner()

                        // HAVE A COUPON CODE? Header
                        SectionHeaderView(title: "HAVE A COUPON CODE?")
                            .padding(.top, 10)
                        
                        // Coupon Card
                        CouponCardView(onRedeemTap: { navigateToRedeemCoupon = true })
                        
                        // Padding at the bottom so content isn't hidden behind sticky bottom bar
                        Spacer().frame(height: 100)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(edges: .top) // Allows the banner to fill the status bar area

            // Fixed Back Button on Top Left
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.15))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            // Push button down into safe area since ScrollView ignores top safe area
            .padding(.top, 50) 

            // Sticky Bottom Bar
            VStack {
                Spacer()
                StickyBottomBar()
            }
             .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToRedeemCoupon) {
            RedeemCouponView()
        }
        .onAppear {
            appState.hideMainTabBar = true
        }
        // .onDisappear {
        //     appState.hideMainTabBar = false
        // }
    }
}

// MARK: - Subviews

struct TopBannerView: View {
    var body: some View {
        VStack(spacing: 12) {
            // Spacer to push content down below the notch/status bar area
            Spacer().frame(height: 80)
            
            // "one" Logo Placeholder (Use your actual white 'one' logo asset here)
            Image("swiggy_one_logo_white") // Replace with your image asset name
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                // Fallback text if the image asset is missing
                .overlay(
                    Text("one")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.white)
                        .opacity(0) // Keep opacity 0 if using image, change to 1 if testing without image
                )
            
            Text("Unlimited Benefits and Savings")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white)
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.29, blue: 0.26), // Orange-Red
                    Color(red: 0.88, green: 0.15, blue: 0.49)  // Magenta-Pink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black.opacity(0.8))
                .tracking(1.5)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
}

struct SavingsHighlightCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // Left Coin Icon
            Image("coin_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(.orange)
                // Fallback icon if image asset doesn't exist
                .background(Circle().fill(Color.orange.opacity(0.2)))
                .clipShape(Circle())
            
            Text("Most customers like you save over ₹400/month with One membership!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .lineSpacing(4)
        }
        .padding(16)
        // Very light orange/peach
        .background(Color(red: 1.0, green: 0.94, blue: 0.90))
        .cornerRadius(16)
    }
}

struct BenefitRowView: View {
    let title: String
    let subtitle: String
    let image: Image?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
        }
    }
}

struct CouponCardView: View {
    let onRedeemTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Redeem Foodzippy One Membership Coupon")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: onRedeemTap) {
                    HStack(spacing: 4) {
                        Text("Redeem now")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.1)) // Orange
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 1.0, green: 0.4, blue: 0.1).opacity(0.1)) // Light orange bg
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Image("coupon_hand")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct DealPromotionalBanner: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Yellow/Orange gradient background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.15), // Bright yellow
                    Color(red: 1.0, green: 0.72, blue: 0.10)  // Gold
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(alignment: .center, spacing: 20) {
                // Left side - Text content
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Best")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#8B4513")) // Brown
                    
                    Text("Deal")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(Color(hex: "#8B4513"))
                    
                    HStack(spacing: 4) {
                        Text("Special Offer")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.95, green: 0.29, blue: 0.26)) // Red
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                    
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Text("ORDER NOW")
                                .font(.system(size: 11, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#FF6B35")) // Orange
                        .cornerRadius(6)
                    }
                    
                    Text("323-543-4145")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#654321"))
                }
                
                Spacer()
                
                // Right side - Images/Icons
                VStack(spacing: 0) {
                    HStack(spacing: -8) {
                        // Fried chicken image placeholder
                        Image("burger")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        // Drink image placeholder
                        Image("burger")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    .padding(.top, 8)
                    
                    // Fries image placeholder
                    Image("burger")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.top, -12)
                }
            }
            .padding(16)
            
            // Discount badge - top right
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.29, blue: 0.26)) // Red
                    .frame(width: 60, height: 60)
                
                VStack(spacing: -2) {
                    Text("85%")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Text("Discount")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(12)
        }
        .frame(height: 130)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

struct StickyBottomBar: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("🎊 LIMITED TIME DISCOUNT 🎊")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.1)) // Brand red/orange
            
            Button(action: {
                // Buy action
            }) {
                VStack(spacing: 2) {
                    Text("Buy One at ₹1")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("for 3 months")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 1.0, green: 0.35, blue: 0.05)) // Bright orange
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 34) // Extra padding for the home indicator
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -4)
        )
    }
}