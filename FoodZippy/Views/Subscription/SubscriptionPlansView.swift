import SwiftUI

// MARK: - Subscription Plan Item Model
struct SubscriptionPlanItem: Identifiable {
    let id = UUID()
    let imageName: String
    let isSubscribed: Bool
    let duration: String
    let title: String
    let subtitle: String
    let features: String
    let price: Double
    let pricePerDay: Int
}

// MARK: - Subscription Plans View
struct SubscriptionPlansView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var selectedPlanId: UUID?
    
    private let plans = [
        SubscriptionPlanItem(
            imageName: "burger",
            isSubscribed: true,
            duration: "7 Days",
            title: "Fast Food",
            subtitle: "This Plan is for Fast Food",
            features: "Hotel • Hotel • Hotel +6 more",
            price: 2700.00,
            pricePerDay: 386
        ),
        SubscriptionPlanItem(
            imageName: "burger",
            isSubscribed: true,
            duration: "7 Days",
            title: "Fast Food",
            subtitle: "This Plan is for Fast Food",
            features: "Hotel • Hotel • Hotel +6 more",
            price: 2700.00,
            pricePerDay: 386
        )
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#FFF8E7").ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 0) {
                // Custom Navigation Bar
                customNavigationBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                // Restaurant Info Card (Fixed)
                restaurantInfoCard
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Plan Cards
                        ForEach(plans) { plan in
                            NavigationLink(destination: SubscriptionPlanDetailsView()) {
                                PlanCardView(
                                    plan: plan,
                                    onBuyNowTapped: {
                                        selectedPlanId = plan.id
                                        showDatePicker = true
                                    }
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            
            // Calendar Dialog Box - Overlaid on entire view
            if showDatePicker {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showDatePicker = false
                        }
                    
                    // Dialog popup
                    VStack(spacing: 16) {
                        Text("Select Start Date")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 16)
                        
                        DatePicker(
                            "Start Date",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        
                        HStack(spacing: 12) {
                            Button {
                                showDatePicker = false
                            } label: {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Button {
                                // Handle purchase with selected date
                                showDatePicker = false
                            } label: {
                                Text("Confirm")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#158C31"))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(16)
                    .frame(maxHeight: .infinity, alignment: .center)
                }
            }
            }
            .navigationViewStyle(.stack)
        }
        .navigationBarHidden(true)
        .onAppear {
            appState.hideMainTabBar = true
        }
    }
    
    // MARK: - Custom Navigation Bar
    private var customNavigationBar: some View {
        HStack(spacing: 12) {
            Button {
                appState.hideMainTabBar = false
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
            
            Text("Subscription Plans")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
        }
    }
    
    // MARK: - Restaurant Info Card
    private var restaurantInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image("burger")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Delicious Yard")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Jaipur, Rajasthan")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Plan Card View
struct PlanCardView: View {
    let plan: SubscriptionPlanItem
    let onBuyNowTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Image with Badges
            ZStack(alignment: .top) {
                Image(plan.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                
                HStack(spacing: 12) {
                    Text(plan.duration)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#158C31"))
                        .clipShape(Capsule())
                    
                    Spacer()
                }
                .padding(16)
            }
            
            // Details Section
            VStack(alignment: .leading, spacing: 12) {
                Text(plan.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(plan.subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(plan.features)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer(minLength: 8)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "₹%.2f", plan.price))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#1E8E2D"))
                        
                        Text(String(format: "₹%d/day", plan.pricePerDay))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: onBuyNowTapped) {
                        Text("Buy Now")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#158C31"))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

// MARK: - Preview
#Preview {
    SubscriptionPlansView()
        .environmentObject(AppState.shared)
}
