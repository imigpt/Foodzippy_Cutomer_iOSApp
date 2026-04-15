// ProfileView.swift
// Matches Android ProfileActivity - user info, order history, menu items

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showLogoutConfirm = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // User info card
                    userInfoCard
                    
                    // Quick action cards
                    quickActionCards
                    
                    // Recent orders
                    recentOrdersSection
                    
                    // Menu items
                    menuItemsSection
                    
                    // Logout
                    logoutButton
                    
                    // App version
                    Text("Version 1.0.0")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
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
            .task {
                await viewModel.loadProfile()
                await viewModel.loadOrderHistory()
            }
        }
    }
    
    // MARK: - User Info Card
    
    private var userInfoCard: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Text(String((viewModel.user?.name ?? "U").prefix(1)).uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.appPrimary)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.user?.name ?? "User")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(viewModel.user?.mobile ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button {
                showEditProfile = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.appPrimary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Action Cards
    
    private var quickActionCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                NavigationLink {
                    WalletView()
                } label: {
                    QuickActionCard(icon: "wallet.pass.fill", title: "Zippy Money", subtitle: "Wallet", color: .appAccent)
                }
                
                NavigationLink {
                    FavouritesView()
                } label: {
                    QuickActionCard(icon: "heart.fill", title: "Favourites", subtitle: "Your picks", color: .appPrimary)
                }
                
                NavigationLink {
                    AddressListView()
                } label: {
                    QuickActionCard(icon: "mappin.circle.fill", title: "Addresses", subtitle: "Saved", color: .appGreen)
                }
                
                NavigationLink {
                    SubscriptionPlansView()
                } label: {
                    QuickActionCard(icon: "crown.fill", title: "Plus", subtitle: "Membership", color: .purple)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Orders
    
    private var recentOrdersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Orders")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink {
                    OrderHistoryView()
                } label: {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.appPrimary)
                }
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if viewModel.orderHistory.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "bag")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No orders yet")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Spacer()
                }
            } else {
                ForEach(Array(viewModel.orderHistory.prefix(3)), id: \.orderId) { order in
                    NavigationLink {
                        OrderDetailView(orderId: order.orderId ?? "")
                    } label: {
                        OrderHistoryRow(order: order)
                            .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                    
                    if order.orderId != viewModel.orderHistory.prefix(3).last?.orderId {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Menu Items
    
    private var menuItemsSection: some View {
        VStack(spacing: 0) {
            ProfileMenuRow(icon: "bag.fill", title: "Order History", color: .blue) {
                OrderHistoryView()
            }
            
            ProfileMenuRow(icon: "heart.fill", title: "Favourites", color: .appPrimary) {
                FavouritesView()
            }
            
            ProfileMenuRow(icon: "wallet.pass.fill", title: "Zippy Money", color: .appAccent) {
                WalletView()
            }
            
            ProfileMenuRow(icon: "arrow.uturn.left.circle.fill", title: "Refunds", color: .orange) {
                RefundsView()
            }
            
            ProfileMenuRow(icon: "crown.fill", title: "Subscription Plans", color: .purple) {
                SubscriptionPlansView()
            }
            
            ProfileMenuRow(icon: "clock.arrow.circlepath", title: "Subscription History", color: .indigo) {
                SubscriptionHistoryView()
            }

            ProfileMenuRow(icon: "ticket.fill", title: "Offers", color: .orange) {
                // OffersView()
            }

            ProfileMenuRow(icon: "graduationcap.fill", title: "Student Rewards", color: .blue) {
                // RewardsOtpView(defaultType: .student)
            }

            ProfileMenuRow(icon: "building.2.fill", title: "Corporate Rewards", color: .cyan) {
                // RewardsOtpView(defaultType: .corporate)
            }
            
            ProfileMenuRow(icon: "person.2.fill", title: "Refer & Earn", color: .appGreen) {
                ReferralView()
            }
            
            Divider().padding(.horizontal)
            
            ProfileMenuRow(icon: "questionmark.circle.fill", title: "FAQ", color: .teal) {
                FaqView()
            }
            
            ProfileMenuRow(icon: "headphones.circle.fill", title: "Help & Support", color: .cyan) {
                HelpView()
            }

            ProfileMenuRow(icon: "globe", title: "Language", color: .indigo) {
                // LanguageSettingsView()
            }
            
            ProfileMenuRow(icon: "doc.text.fill", title: "Privacy Policy", color: .gray) {
                PrivacyPolicyView()
            }

            ProfileMenuRow(icon: "square.grid.2x2.fill", title: "More Missing Screens", color: .purple) {
                // ParityScreensHubView()
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Logout
    
    private var logoutButton: some View {
        Button {
            showLogoutConfirm = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Logout")
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .foregroundColor(.appRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.appRed.opacity(0.08))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.appBlack)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(12)
        .frame(width: 110, alignment: .leading)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

struct ProfileMenuRow<Destination: View>: View {
    let icon: String
    let title: String
    let color: Color
    @ViewBuilder let destination: () -> Destination
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
                    .frame(width: 28)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.appBlack)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Text(String(name.prefix(1)).uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.appPrimary)
                }
                .padding(.top, 20)
                
                // Fields
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
                
                // Save
                        Button {
                    Task {
                        isSaving = true
                        let uid = SessionManager.shared.currentUser?.id ?? ""
                        do {
                            let _ = try await APIService.shared.editProfile(
                                uid: uid, name: name
                            )
                            // TODO: Update session with new profile data (requires API refetch)
                        } catch {}
                        isSaving = false
                        dismiss()
                    }
                } label: {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save Changes")
                            .fontWeight(.bold)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.appPrimary)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(isSaving)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                let user = SessionManager.shared.currentUser
                name = user?.name ?? ""
                email = ""
                phone = "\(user?.ccode ?? "") \(user?.mobile ?? "")"
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

// MARK: - Privacy Policy

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your privacy is important to us. This privacy policy explains how FoodZippy collects, uses, and protects your personal information.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Group {
                    Text("Information We Collect")
                        .font(.headline)
                    Text("We collect information you provide directly, such as your name, phone number, email, and delivery address when you create an account and place orders.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("How We Use Your Information")
                        .font(.headline)
                    Text("We use your information to process orders, deliver food, send order updates, improve our services, and provide customer support.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Data Security")
                        .font(.headline)
                    Text("We implement appropriate security measures to protect your personal information against unauthorized access, alteration, or disclosure.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
