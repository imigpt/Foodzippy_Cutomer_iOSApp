import SwiftUI

struct RedeemCouponView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.appGrayBg
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HeroBannerView()

                    CouponEntrySectionView()
                        .background(Color.white)

                    DisclaimerFooterView()
                }
            }
            .ignoresSafeArea(edges: .top)

            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.leading, 16)
            .padding(.top, 56)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar) // <-- ADDED: Hides native SwiftUI Tab Bar
        .onAppear {
            appState.hideMainTabBar = true // Keeps your custom state synchronized
        }
        .onDisappear {
            appState.hideMainTabBar = false
        }
    }
}

private struct HeroBannerView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [
                    Color.appPrimary.opacity(0.9),
                    Color.appPrimary.opacity(0.7),
                    Color.appAccent.opacity(0.8),
                    Color.appAccent
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 16) {
                Spacer().frame(height: 60)

                HStack(spacing: 12) {
                    Text("one")
                        .font(.system(size: 24, weight: .black))
                    Text("|")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                    Text("one LITE")
                        .font(.system(size: 22, weight: .bold))
                    Text("|")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                    Text("one BLCK")
                        .font(.system(size: 24, weight: .semibold))
                }
                .foregroundColor(.white)

                Text("Packed with Foodzippy benefits.\nUnlock now!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.bottom, 140)

            Image("coupon_hero_illustration")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .offset(x: 10, y: 18)
        }
        .frame(height: 360)
        .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
    }
}

private struct CouponEntrySectionView: View {
    @State private var couponCode = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Have a Coupon Code?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)

            Text("Redeem your Foodzippy One, One BLCK, or One Lite coupons here to activate your membership now!")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "#666666"))
                .lineSpacing(1.2)
                .fixedSize(horizontal: false, vertical: true)

            TextField("Enter coupon code", text: $couponCode)
                .font(.system(size: 15, weight: .regular))
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#CCCCCC"), lineWidth: 1)
                )

            Button(action: {}) {
                Text("Apply Coupon")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#999999"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#F0F0F0"))
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(true)
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
        .padding(.bottom, 24)
    }
}

private struct DisclaimerFooterView: View {
    private let brandOrange = Color.appAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Rectangle()
                .fill(Color(hex: "#E8E8E8"))
                .frame(height: 6)
                .frame(maxWidth: .infinity)

            Text("Certain membership benefits are offered in select cities only. Please read the FAQs, Terms & Conditions before redeeming your coupon.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "#777777"))
                .lineSpacing(1.2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 28) {
                DashedUnderlineLinkText(title: "FAQs", color: brandOrange)
                DashedUnderlineLinkText(title: "TERMS & CONDITIONS", color: brandOrange)
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appGrayBg)
    }
}

private struct DashedUnderlineLinkText: View {
    let title: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)

            Rectangle()
                .fill(Color.clear)
                .frame(height: 1)
                .overlay(
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [2.5, 2]))
                        .foregroundColor(color)
                )
        }
        .fixedSize()
    }
}

#Preview {
    NavigationStack {
        RedeemCouponView()
    }
}
