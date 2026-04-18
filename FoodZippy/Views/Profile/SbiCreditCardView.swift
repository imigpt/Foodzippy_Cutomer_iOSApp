import SwiftUI

struct SbiCreditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var amount: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 1. Top Promotional Banner
                ZStack(alignment: .topLeading) {
                    Color.appGreen // App theme green
                    
                    // IF YOU HAVE THE IMAGE ASSET, UNCOMMENT THIS:
                    // Image("sbi_banner")
                    //     .resizable()
                    //     .scaledToFill()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Custom Back Button
                        Button(action: {
                            appState.hideMainTabBar = false
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .padding(.top, 50) // Space for status bar / notch
                        .padding(.bottom, 4)
                        
                        Image(systemName: "creditcard.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Text("Earn 10X\nRewards on\nTop Brands*")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("(Apollo 24*7, Myntra, Cleartrip,\nBookMyShow, Dominos & more)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                        
                        Spacer()
                        
                        Text("*T&Cs Apply")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 320) // Slightly taller to accommodate the back button
                .clipShape(CustomCorner(radius: 20, corners: [.bottomLeft, .bottomRight]))
                .ignoresSafeArea(.all, edges: .top)
                
                VStack(spacing: 24) {
                    // 2. Offer Card
                    offerCard
                        .padding(.top, 8)
                    
                    // 3. Add Money to Zippy Wallet Section
                    addMoneySection
                    
                    // 4. Choose Payment Method Section
                    paymentMethodSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color.appGrayBg.opacity(0.55).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar) // Hides the default top navigation bar
        .onAppear {
            appState.hideMainTabBar = true
        }
    }
    
    // MARK: - 2. Offer Card
    private var offerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: 56, height: 56)
                
                Image(systemName: "creditcard")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("SBI Credit Card Offer")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("Get cashback & exclusive discounts\non Foodzippy")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 3. Add Money Section
    private var addMoneySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Money to Zippy Wallet")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.appBlack)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Amount")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        Text("₹")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.appBlack)
                        
                        TextField("0", text: $amount)
                            .font(.title2)
                            .foregroundColor(.primary)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.appGrayBg)
                    .cornerRadius(10)
                }
                
                HStack(spacing: 12) {
                    QuickAmountButton(amountText: "+₹100", boundAmount: $amount)
                    QuickAmountButton(amountText: "+₹500", boundAmount: $amount)
                    QuickAmountButton(amountText: "+₹1000", boundAmount: $amount)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - 4. Payment Method Section
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Payment Method")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.appBlack)
            
            VStack(spacing: 12) {
                // Razorpay Card
                Button(action: {}) {
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appPrimary)
                            .frame(width: 36, height: 24)
                        
                        Text("Razorpay")
                            .font(.body)
                            .foregroundColor(Color.appBlack)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .fontWeight(.medium)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                }
                
                // Stripe Card
                Button(action: {}) {
                    HStack(spacing: 16) {
                        Image(systemName: "creditcard")
                            .font(.title2)
                            .foregroundColor(Color.appPrimary)
                            .frame(width: 36)
                        
                        Text("Stripe")
                            .font(.body)
                            .foregroundColor(Color.appBlack)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .fontWeight(.medium)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
}

// MARK: - Reusable Components

struct QuickAmountButton: View {
    let amountText: String
    @Binding var boundAmount: String
    
    var body: some View {
        Button {
            let numericValue = amountText.replacingOccurrences(of: "+₹", with: "")
            if let currentAmount = Int(boundAmount) {
                boundAmount = String(currentAmount + (Int(numericValue) ?? 0))
            } else {
                boundAmount = numericValue
            }
        } label: {
            Text(amountText)
                .font(.subheadline)
                .foregroundColor(Color.appPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.appPrimary, lineWidth: 1)
                )
        }
    }
}

// Custom Shape for bottom rounded corners
struct CustomCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}