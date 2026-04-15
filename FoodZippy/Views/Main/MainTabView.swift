// MainTabView.swift
// Main tab bar matching Android GuestHomeActivity bottom nav

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cartManager: CartManager

    private var bottomSafeInset: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: { $0.isKeyWindow })?
            .safeAreaInsets.bottom ?? 0)
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
        ZStack {
            currentTabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.white)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                if !cartManager.isEmpty {
                    CartBarView()
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                        .transition(.move(edge: .bottom))
                }

                CustomBottomTabBar(
                    selectedTab: selectedTabBinding,
                    bottomInset: bottomSafeInset
                )
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .background(Color.white.ignoresSafeArea(.container, edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
    let bottomInset: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.home)
            tabButton(.dineIn)
            tabButton(.zippy)
            tabButton(.takeaway)
        }
        .padding(.horizontal, 0)
        .padding(.top, 8)
        .padding(.bottom, bottomInset)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.08), radius: 8, y: -2)
        )
    }

    @ViewBuilder
    private func tabButton(_ tab: AppState.TabItem) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                tabArtwork(for: tab)

                Text(title(for: tab))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(selectedTab == tab ? Color(hex: "#FF6200") : Color(hex: "#707070"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func tabArtwork(for tab: AppState.TabItem) -> some View {
        switch tab {
        case .home:
            Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                .font(.system(size: 23, weight: .semibold))
                .foregroundColor(selectedTab == tab ? Color(hex: "#FF6B00") : Color(hex: "#9A9A9A"))

        case .dineIn:
            Text("99")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(selectedTab == tab ? Color(hex: "#FF6B00") : Color(hex: "#FF6B00"))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color(hex: "#FFF3E8"))
                )

        case .zippy:
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(selectedTab == tab ? Color(hex: "#FF6B00") : Color(hex: "#9A9A9A"))

                if let badge = badge(for: tab) {
                    Text(badge)
                        .font(.system(size: 8, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(hex: "#E23744")))
                        .offset(x: 12, y: 8)
                }
            }

        case .takeaway:
            VStack(spacing: 2) {
                Text("unlock")
                    .font(.system(size: 8, weight: .bold))
                Text("66% OFF")
                    .font(.system(size: 9, weight: .black))
            }
            .foregroundColor(.white)
            .frame(width: 42, height: 42)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
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

    private func badge(for tab: AppState.TabItem) -> String? {
        switch tab {
        case .zippy: return "NEW"
        default: return nil
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
            .padding(.horizontal, 16)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .fullScreenCover(isPresented: $showCart) {
            NavigationStack {
                CartView()
            }
        }	
    }
}
