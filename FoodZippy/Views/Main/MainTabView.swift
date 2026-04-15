// MainTabView.swift
// Main tab bar matching Android GuestHomeActivity bottom nav

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cartManager: CartManager

    private var topSafeAreaColor: Color {
        appState.selectedTab == .home
            ? Color(red: 0.13, green: 0.02, blue: 0.24)
            : Color.white
    }

    private var statusBarColorScheme: ColorScheme {
        appState.selectedTab == .home ? .dark : .light
    }

    private var selectedTabBinding: Binding<AppState.TabItem> {
        Binding(
            get: { appState.selectedTab },
            set: { appState.selectedTab = $0 }
        )
    }

    private var replaceCartAlertBinding: Binding<Bool> {
        Binding(
            get: { cartManager.showReplaceCartAlert },
            set: { cartManager.showReplaceCartAlert = $0 }
        )
    }

    @ViewBuilder
    private var currentTabContent: some View {
        switch appState.selectedTab {
        case .home:
            HomeView()
        case .dineIn:
            FlashView()
        case .zippy:
            HighProteinView()
        case .takeaway:
            ReorderView()
        }
    }

    var body: some View {
        GeometryReader { geo in
            currentTabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .overlay(alignment: .top) {
                    topSafeAreaColor
                        .frame(height: geo.safeAreaInsets.top)
                        .ignoresSafeArea(.container, edges: .top)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if !appState.hideMainTabBar {
                        VStack(spacing: 0) {

                            // CART BAR
                            if !cartManager.isEmpty {
                                CartBarView()
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 6)
                                    .transition(.move(edge: .bottom))
                            }

                            // TAB BAR
                            CustomBottomTabBar(
                                selectedTab: selectedTabBinding
                            )
                        }
                        .background(Color.white)
                        .background(
                            Color.white
                                .ignoresSafeArea(.container, edges: .bottom)
                        )
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .preferredColorScheme(statusBarColorScheme)
        .alert("Replace Cart?", isPresented: replaceCartAlertBinding) {
            Button("YES, START AFRESH", role: .destructive) {
                cartManager.replaceCartWithPendingItem()
            }
            Button("NO", role: .cancel) {}
        } message: {
            Text("Your cart contains items from \(cartManager.pendingRestaurantName ?? "another restaurant"). Do you want to clear the cart and add items from the new restaurant?")
        }
    }
}

private struct CustomBottomTabBar: View {
    @Binding var selectedTab: AppState.TabItem

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.home)
            tabButton(.dineIn)
            tabButton(.zippy)
            tabButton(.takeaway)
        }
        .padding(.top, 6)
        .padding(.bottom, 0)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.06), radius: 6, y: -2)
        )
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private func tabButton(_ tab: AppState.TabItem) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                tabArtwork(for: tab)

                Text(title(for: tab))
                    .font(.system(size: 10, weight: .medium)) // smaller text
                    .foregroundColor(selectedTab == tab ? Color(hex: "#FF6200") : Color.gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50) // slightly compact
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func tabArtwork(for tab: AppState.TabItem) -> some View {
        switch tab {

        case .home:
            Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                .font(.system(size: 20, weight: .semibold)) // 🔽 reduced
                .foregroundColor(selectedTab == tab ? Color(hex: "#FF6B00") : Color.gray)

        case .dineIn:
            Text("99")
                .font(.system(size: 16, weight: .bold, design: .rounded)) // 🔽 reduced
                .foregroundColor(Color(hex: "#FF6B00"))
                .frame(width: 30, height: 30) // 🔽 smaller circle
                .background(
                    Circle().fill(Color(hex: "#FFF3E8"))
                )

        case .zippy:
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 22)) // 🔽 reduced
                    .foregroundColor(selectedTab == tab ? Color(hex: "#FF6B00") : Color.gray)

                Text("NEW")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(Color.red))
                    .offset(x: 8, y: 6) // adjusted
            }

        case .takeaway:
            VStack(spacing: 1) {
                Text("unlock")
                    .font(.system(size: 7, weight: .bold))
                Text("66%")
                    .font(.system(size: 8, weight: .black))
            }
            .foregroundColor(.white)
            .frame(width: 34, height: 34) // 🔽 reduced
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#2A2E78"), Color(hex: "#1E1F5D")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
    }

    private func title(for tab: AppState.TabItem) -> String {
        switch tab {
        case .home: return "Food"
        case .dineIn: return "99 Store"
        case .zippy: return "EatRight"
        case .takeaway: return "Offers"
        }
    }
}

// MARK: - Cart Bar
struct CartBarView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showCart = false
    
    var body: some View {
        Button(action: { showCart = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(cartManager.itemCount) ITEM\(cartManager.itemCount > 1 ? "S" : "")")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text(cartManager.totalAmount.currencyStringNoDecimal)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("VIEW CART")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Image(systemName: "bag.fill")
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.appGreen)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .fullScreenCover(isPresented: $showCart) {
            NavigationStack {
                CartView()
            }
        }
    }
}
