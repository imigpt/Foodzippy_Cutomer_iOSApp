// ProfileView.swift
// Replicates the requested Foodzippy account screen UI

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showEditProfile = false
    @State private var showLogoutConfirm = false
    @State private var isMembershipExpanded = false
    @State private var restaurantRegisterURL: URL?
    @State private var isLoadingRestaurantLink = false
    @State private var navigateToBuyOne = false
    @State private var navigateToRedeemCoupon = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // 1 & 2. Navigation Bar + Profile Info Section (Top Area)
                    headerSection
                    
                    VStack(spacing: 16) {
                        // 3. Membership Banner
                        membershipBanner
                            .padding(.top, 8)
                        
                        // 4. Quick Links Grid
                        quickActionCards
                        
                        // 5. Menu List Options
                        menuItemsSection
                    }
                    .padding(.bottom, 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).opacity(0.3).ignoresSafeArea()) // Light off-white base
            .toolbar(.hidden, for: .navigationBar) // Hide default nav bar to use custom top section
            .refreshable {
                await viewModel.loadProfile()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .alert("Logout", isPresented: $showLogoutConfirm) {
                Button("Logout", role: .destructive) {
                    Task {
                        await viewModel.logout()
                        appState.currentScreen = .login
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to logout?")
            }
            .navigationDestination(isPresented: $navigateToBuyOne) {
                BuyOneView()
            }
            .navigationDestination(isPresented: $navigateToRedeemCoupon) {
                RedeemCouponView()
            }
            .task {
                await viewModel.loadProfile()
                // Order history removed from UI per prompt, but you can keep the data load
                await viewModel.loadOrderHistory() 
            }
        }
    }
    
    // MARK: - 1 & 2: Header Section (Nav + Profile)
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Custom Navigation Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                // Empty right side as requested (Removed 'Help' and '3 dots')
            }
            
            // Profile Information
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.user?.name ?? "Rahul Gupta")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(viewModel.user?.mobile ?? "+91 - 7014922901")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(viewModel.user?.email ?? "7014rahul@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color(red: 1.0, green: 0.92, blue: 0.88)) // Light pastel peach/pink
        .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
    }
    
    // MARK: - 3: Membership Banner
    private var membershipBanner: some View {
        VStack(spacing: 0) {
            // Header Toggle Section
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMembershipExpanded.toggle()
                }
            }) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("one")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                            
                            Text("Join now")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.red.opacity(0.8)))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unlimited free deliveries, extra discounts\n& more!")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            
                            Text("Join now to unlock exclusive benefits")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    
                    Image(systemName: isMembershipExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                .padding()
            }
            .buttonStyle(.plain)
            
            // Expanded Content
            if isMembershipExpanded {
                VStack(spacing: 0) {
                    // Dashed Line
                    DashedLine()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    
                    // Option 1
                    Button(action: {
                        navigateToBuyOne = true
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text("Join Foodzippy One")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    // Option 2
                    Button(action: {
                        navigateToRedeemCoupon = true
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "ticket")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text("Redeem Membership Coupon")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.02), radius: 5, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - 4: Quick Action Cards
    private var quickActionCards: some View {
        HStack(spacing: 10) {
            NavigationLink(destination: AddressListView(selectionMode: false)) {
                QuickLinkCard(icon: "mappin.circle", title: "Saved\nAddress")
            }
            .frame(maxWidth: .infinity)
            
            NavigationLink(destination: SubscriptionHistoryView()) {
                QuickLinkCard(icon: "wallet.pass", title: "My\nSubscriptions")
            }
            .frame(maxWidth: .infinity)
            
            NavigationLink(destination: RefundsView()) {
                QuickLinkCard(icon: "arrow.counterclockwise.circle", title: "My\nRefunds")
            }
            .frame(maxWidth: .infinity)
            
            NavigationLink(destination: WalletView()) {
                QuickLinkCard(icon: "creditcard", title: "Foodzippy\nMoney")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Restaurant Registration
    private func fetchRestaurantRegistrationLink() {
        // This would call your API service to get the restaurant registration link
        // Similar to the Android implementation in ProfileActivity.java
        
        // For now, using a placeholder - replace with your actual API call
        let urlString = "https://foodzippy.co/"
        
        if let url = URL(string: urlString) {
            restaurantRegisterURL = url
            // The Link view will handle opening this URL
            isLoadingRestaurantLink = false
            
            // Trigger the link opening
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let url = restaurantRegisterURL {
                    UIApplication.shared.open(url)
                }
            }
        } else {
            isLoadingRestaurantLink = false
        }
    }
    private var menuItemsSection: some View {
        VStack(spacing: 0) {
            // 1 - SBI Credit Card (Navigable)
            NavigationLink(destination: SbiCreditCardView()) {
                HStack(spacing: 16) {
                    Image(systemName: "creditcard")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: 24)
                    
                    Text("Foodzippy SBI Bank Credit Card")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            
            Divider()
                .padding(.leading, 56)
                .padding(.trailing, 16)
            
            // 2
            MenuListRow(icon: "ticket", title: "My Vouchers")
            // 3
            MenuListRow(icon: "doc.text", title: "Account Statement")
            // 4
            MenuListRow(icon: "train.side.front.car", title: "Order Food on Train")
            // 5
            NavigationLink(destination: CorporateRewardsView()) {
                HStack(spacing: 16) {
                    Image(systemName: "briefcase")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: 24)
                    
                    Text("Corporate Rewards")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            
            Divider()
                .padding(.leading, 56)
                .padding(.trailing, 16)
            
            // 6 - Student Rewards (Navigable)
            NavigationLink(destination: StudentRewardsView()) {
                HStack(spacing: 16) {
                    Image(systemName: "graduationcap")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: 24)
                    
                    Text("Student Rewards")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            
            Divider()
                .padding(.leading, 56)
                .padding(.trailing, 16)
            // 7
            Button(action: {
                isLoadingRestaurantLink = true
                fetchRestaurantRegistrationLink()
            }) {
                MenuListRow(icon: "bookmark", title: "Registered as Restaurant")
            }
            .disabled(isLoadingRestaurantLink)
            // 8
            NavigationLink(destination: FavoritesView()) {
                MenuListRow(icon: "heart", title: "Favourites")
            }
            // 9
            MenuListRow(icon: "crown", title: "Partner Rewards")
            // 10
            MenuListRow(icon: "message", title: "Allow restaurants to contact you")
            // 11
            NavigationLink(destination: ProfileFAQView()) {
                MenuListRow(icon: "questionmark.circle", title: "FAQ")
            }
            
            // 12. Logout
            Button {
                showLogoutConfirm = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.body)
                        .frame(width: 24)
                    
                    Text("Logout")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.red) // Red text to indicate a destructive action
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - Supporting Sub-Views

struct QuickLinkCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .padding(10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct MenuListRow: View {
    let icon: String
    let title: String
    var showDivider: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.black)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            if showDivider {
                Divider()
                    .padding(.leading, 56)
                    .padding(.trailing, 16)
            }
        }
        .background(Color.white)
    }
}

struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Edit Profile View (Retained from original)
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Text(String(name.prefix(1)).uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    ProfileTextField(label: "Name", text: $name, icon: "person")
                    ProfileTextField(label: "Email", text: $email, icon: "envelope")
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    ProfileTextField(label: "Phone", text: $phone, icon: "phone")
                        .keyboardType(.phonePad)
                        .disabled(true)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Save Changes") { dismiss() }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                // Populate default fallbacks to match mock UI if empty
                name = "Rahul Gupta"
                email = "7014rahul@gmail.com"
                phone = "+91 - 7014922901"
            }
        }
    }
}

struct ProfileTextField: View {
    let label: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField(label, text: $text)
                    .font(.subheadline)
            }
            .padding()
            .background(Color.gray.opacity(0.06))
            .cornerRadius(10)
        }
    }
}
