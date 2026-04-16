// AppState.swift
// Global app state management

import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    enum AppScreen {
        case splash
        case intro
        case login
        case guestHome
        case home
    }
    
    @Published var currentScreen: AppScreen = .splash
    @Published var isLoading = false	
    @Published var selectedTab: TabItem = .home
    @Published var showGlobalLoader = false
    @Published var cartBadgeCount: Int = 0
    @Published var hideMainTabBar: Bool = false
    
    enum TabItem: Int, CaseIterable {
        case home = 0
        case flash = 1
        case zippy = 2
        case takeaway = 3
        case dineIn = 4
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .flash: return "Flash"
            case .zippy: return "Zippy"
            case .takeaway: return "Takeaway"
            case .dineIn: return "Dine-In"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .flash: return "bolt.fill"
            case .zippy: return "bolt.fill"
            case .takeaway: return "bag.fill"
            case .dineIn: return "fork.knife"
            }
        }
    }
    
    private init() {
        updateCartBadge()
    }
    
    func determineInitialScreen() {
        let session = SessionManager.shared
        if session.isLoggedIn {
            currentScreen = .home
        } else if session.isGuest {
            currentScreen = .guestHome
        } else if session.isIntroShown {
            currentScreen = .login
        } else {
            currentScreen = .intro
        }
    }
    
    func updateCartBadge() {
        cartBadgeCount = CartManager.shared.cartItems.count
    }
    
    func logout() {
        SessionManager.shared.clearAll()
        CartManager.shared.clearCart()
        currentScreen = .login
    }
}
