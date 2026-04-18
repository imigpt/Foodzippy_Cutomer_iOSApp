import SwiftUI

struct ParityScreensHubView: View {
    var body: some View {
        List {
            Section("Dine-In / Service") {
                NavigationLink("Dine-In Search") { DineInSearchView() }
                NavigationLink("Facility Restaurants") { FacilityRestaurantsView() }
                NavigationLink("Drive-Thru Menu") { DriveThruMenuView() }
                NavigationLink("Takeaway Detail") { TakeawayDetailView() }
                NavigationLink("Bill Details") { BillDetailsView() }
            }

            Section("Offers / Brands / Plus") {
                NavigationLink("Offer Restaurants") { OfferRestaurantsView() }
                NavigationLink("Brand Detail") { BrandDetailView() }
                NavigationLink("Plus Benefits") { PlusBenefitsView() }
                NavigationLink("Coupon Center") { CouponCenterView() }
            }

            Section("Location / Discovery") {
                NavigationLink("Request Address Share") { RequestAddressShareView() }
                NavigationLink("Deep Link Address") { DeepLinkAddressView() }
                NavigationLink("Restaurant Directory") { RestaurantDirectoryView() }
                NavigationLink("Search Product") { SearchProductView() }
                NavigationLink("Search Subscription") { SearchSubscriptionView() }
            }

            Section("Payments") {
                NavigationLink("SBI Credit Card") { }
                NavigationLink("PayPal") { PaypalPaymentView() }
                NavigationLink("Paystack") { PaystackPaymentView() }
                NavigationLink("Razorpay") { RazorpayPaymentView() }
                NavigationLink("Stripe") { StripePaymentView() }
                NavigationLink("Flutterwave") { FlutterwavePaymentView() }
                NavigationLink("Paytm") { PaytmPaymentView() }
                NavigationLink("SenangPay") { SenangpayPaymentView() }
            }

            Section("Order / Tracking / Voice") {
                NavigationLink("Order Tracker Map") { MapTrackerView() }
                NavigationLink("Ratings") { RatesView() }
                NavigationLink("Agora Call") { AgoraCallView() }
            }

            Section("Misc") {
                NavigationLink("Help Details") { HelpDetailsView() }
                NavigationLink("Change Password") { ChangePasswordView() }
                NavigationLink("Coming Soon") { ComingSoonView() }
                NavigationLink("Subscription Plan Detail") { SubscriptionPlanDetailView() }
            }
        }
        .navigationTitle("Missing Screens")
    }
}

private struct PlaceholderScreen: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.stack.badge.person.crop")
                .font(.system(size: 44))
                .foregroundColor(.red)
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.08).ignoresSafeArea())
        .navigationTitle(title)
    }
}

struct DineInSearchView: View { var body: some View { PlaceholderScreen(title: "Dine-In Search", subtitle: "Dedicated dine-in search flow added for Android parity.") } }
struct FacilityRestaurantsView: View { var body: some View { PlaceholderScreen(title: "Facility Restaurants", subtitle: "Facility-based restaurant listing screen.") } }
struct DriveThruMenuView: View { var body: some View { PlaceholderScreen(title: "Drive-Thru Menu", subtitle: "Drive-thru specific menu and slot flow.") } }
struct TakeawayDetailView: View { var body: some View { PlaceholderScreen(title: "Takeaway Detail", subtitle: "Takeaway focused restaurant/order detail screen.") } }
struct BillDetailsView: View { var body: some View { PlaceholderScreen(title: "Bill Details", subtitle: "Dine-in bill confirmation and payment summary.") } }

struct OfferRestaurantsView: View { var body: some View { PlaceholderScreen(title: "Offer Restaurants", subtitle: "Restaurants filtered by selected offer.") } }
struct BrandDetailView: View { var body: some View { PlaceholderScreen(title: "Brand Detail", subtitle: "Brand-focused listing and detail screen.") } }
struct PlusBenefitsView: View { var body: some View { PlaceholderScreen(title: "Plus Benefits", subtitle: "Membership benefits, perks and purchase prompts.") } }
struct CouponCenterView: View { var body: some View { PlaceholderScreen(title: "Coupon Center", subtitle: "Coupon browsing and apply journey.") } }

struct RequestAddressShareView: View { var body: some View { PlaceholderScreen(title: "Request Address Share", subtitle: "Address sharing and permission handoff flow.") } }
struct DeepLinkAddressView: View { var body: some View { PlaceholderScreen(title: "Deep Link Address", subtitle: "Deep link address resolver and selection screen.") } }
struct RestaurantDirectoryView: View { var body: some View { PlaceholderScreen(title: "Restaurant Directory", subtitle: "Legacy restaurants list parity screen.") } }
struct SearchProductView: View { var body: some View { PlaceholderScreen(title: "Search Product", subtitle: "Product-level search entry and results.") } }
struct SearchSubscriptionView: View { var body: some View { PlaceholderScreen(title: "Search Subscription", subtitle: "Search across subscription plans and meals.") } }

struct SbiCreditCardView: View { var body: some View { PlaceholderScreen(title: "SBI Credit Card", subtitle: "SBI specific payment campaign/screen.") } }
struct PaypalPaymentView: View { var body: some View { PlaceholderScreen(title: "PayPal", subtitle: "PayPal payment handoff and callback state.") } }
struct PaystackPaymentView: View { var body: some View { PlaceholderScreen(title: "Paystack", subtitle: "Paystack payment handoff and callback state.") } }
struct RazorpayPaymentView: View { var body: some View { PlaceholderScreen(title: "Razorpay", subtitle: "Razorpay payment handoff and callback state.") } }
struct StripePaymentView: View { var body: some View { PlaceholderScreen(title: "Stripe", subtitle: "Stripe payment handoff and callback state.") } }
struct FlutterwavePaymentView: View { var body: some View { PlaceholderScreen(title: "Flutterwave", subtitle: "Flutterwave payment handoff and callback state.") } }
struct PaytmPaymentView: View { var body: some View { PlaceholderScreen(title: "Paytm", subtitle: "Paytm payment handoff and callback state.") } }
struct SenangpayPaymentView: View { var body: some View { PlaceholderScreen(title: "SenangPay", subtitle: "SenangPay payment handoff and callback state.") } }

struct MapTrackerView: View { var body: some View { PlaceholderScreen(title: "Order Tracker", subtitle: "Dedicated map tracker parity screen.") } }
struct RatesView: View { var body: some View { PlaceholderScreen(title: "Ratings", subtitle: "Standalone ratings history/details screen.") } }
struct AgoraCallView: View { var body: some View { PlaceholderScreen(title: "Agora Call", subtitle: "Voice call UI parity screen.") } }

struct HelpDetailsView: View { var body: some View { PlaceholderScreen(title: "Help Details", subtitle: "Detail page for selected help topic.") } }
struct ChangePasswordView: View { var body: some View { PlaceholderScreen(title: "Change Password", subtitle: "Profile password update screen.") } }
struct ComingSoonView: View { var body: some View { PlaceholderScreen(title: "Coming Soon", subtitle: "Future feature holding screen.") } }
struct SubscriptionPlanDetailView: View { var body: some View { PlaceholderScreen(title: "Subscription Plan Detail", subtitle: "Detailed plan benefits and meal breakdown.") } }
