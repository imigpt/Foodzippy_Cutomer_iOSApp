// ProfileViewModel.swift
// Handles profile, order history, wallet, favourites, etc.

import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var orderHistory: [OrderHistoryItem] = []
    @Published var walletBalance: String = "0"
    @Published var walletTransactions: [WalletTransaction] = []
    @Published var favouriteRestaurants: [Restaurant] = []
    @Published var faqItems: [FaqItem] = []
    @Published var helpPages: [HelpPage] = []
    @Published var refunds: [RefundItem] = []
    @Published var referralData: ReferralData?
    
    @Published var isLoading = false
    @Published var isLoadingOrders = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var showLogoutConfirm = false
    
    // Updated to match the 11 new menu items requested for Foodzippy
    var profileMenuItems: [ProfileMenuItem] {
        [
            ProfileMenuItem(title: "Foodzippy HDFC Bank Credit Card", subtitle: "", icon: "creditcard", action: .comingSoon),
            ProfileMenuItem(title: "My Vouchers", subtitle: "", icon: "ticket", action: .comingSoon),
            ProfileMenuItem(title: "Account Statement", subtitle: "", icon: "doc.text", action: .comingSoon),
            ProfileMenuItem(title: "Order Food on Train", subtitle: "", icon: "train.side.front.car", action: .comingSoon),
            ProfileMenuItem(title: "Corporate Rewards", subtitle: "", icon: "briefcase", action: .comingSoon),
            ProfileMenuItem(title: "Student Rewards", subtitle: "", icon: "graduationcap", action: .comingSoon),
            ProfileMenuItem(title: "Registered as Restaurant", subtitle: "", icon: "bookmark", action: .comingSoon),
            ProfileMenuItem(title: "Favourites", subtitle: "", icon: "heart", action: .favourites),
            ProfileMenuItem(title: "Partner Rewards", subtitle: "", icon: "crown", action: .comingSoon),
            ProfileMenuItem(title: "Allow restaurants to contact you", subtitle: "", icon: "message", action: .comingSoon),
            ProfileMenuItem(title: "FAQ", subtitle: "", icon: "questionmark.circle", action: .faq)
        ]
    }
    
    // MARK: - Load Profile
    
    func loadProfile() async {
        guard let uid = SessionManager.shared.currentUser?.id else { return }
        
        isLoading = true
        
        do {
            let response = try await APIService.shared.getUserProfile(uid: uid)
            if let userData = response.userData {
                user = userData
                SessionManager.shared.saveUser(userData)
                if let wallet = userData.wallet {
                    SessionManager.shared.walletBalance = wallet
                    walletBalance = wallet
                }
            }
        } catch {
            user = SessionManager.shared.currentUser
        }
        
        isLoading = false
    }
    
    // MARK: - Order History
    
    func loadOrderHistory() async {
        guard let uid = SessionManager.shared.currentUser?.id else { return }
        
        isLoadingOrders = true
        
        do {
            let response = try await APIService.shared.getOrderHistory(uid: uid)
            if response.isSuccess {
                orderHistory = response.orderHistory ?? []
            }
        } catch {
            print("Order history error: \(error)")
        }
        
        isLoadingOrders = false
    }
    
    // MARK: - Cancel Order
    
    func cancelOrder(_ orderId: String) async -> Bool {
        do {
            let response = try await APIService.shared.cancelOrder(orderId: orderId)
            if response.isSuccess {
                // Remove from local list
                orderHistory.removeAll { $0.orderId == orderId }
                return true
            } else {
                showErrorMessage(response.responseMsg ?? "Cannot cancel order")
                return false
            }
        } catch {
            showErrorMessage(error.localizedDescription)
            return false
        }
    }
    
    // MARK: - Wallet
    
    func loadWallet() async {
        guard let uid = SessionManager.shared.currentUser?.id else { return }
        
        do {
            let response = try await APIService.shared.getWalletReport(uid: uid)
            if response.isSuccess {
                walletBalance = response.wallet ?? "0"
                walletTransactions = response.walletItems ?? []
                SessionManager.shared.walletBalance = walletBalance
            }
        } catch {
            print("Wallet error: \(error)")
        }
    }
    
    // MARK: - Favourites
    
    func loadFavourites() async {
        guard let uid = SessionManager.shared.currentUser?.id else { return }
        let lat = SessionManager.shared.currentAddress?.latMap ?? LocationManager.shared.latitude
        let lng = SessionManager.shared.currentAddress?.longMap ?? LocationManager.shared.longitude
        
        do {
            let response = try await APIService.shared.getFavourites(uid: uid, lat: lat, lng: lng)
            favouriteRestaurants = response.favList ?? []
        } catch {
            print("Favourites error: \(error)")
        }
    }
    
    // MARK: - FAQ
    
    func loadFaq() async {
        do {
            let response = try await APIService.shared.getFaq()
            faqItems = response.faqData ?? []
        } catch {
            print("FAQ error: \(error)")
        }
    }
    
    // MARK: - Help
    
    func loadHelp() async {
        do {
            let response = try await APIService.shared.getHelpPages()
            helpPages = response.pageList ?? []
        } catch {
            print("Help error: \(error)")
        }
    }
    
    // MARK: - Referral
    
    func loadReferralData() async {
        guard let uid = SessionManager.shared.currentUser?.id else { return }
        
        do {
            let response = try await APIService.shared.getReferralData(uid: uid)
            referralData = response.referData
        } catch {
            print("Referral error: \(error)")
        }
    }
    
    // MARK: - Refunds
    
    func loadRefunds() async {
        guard let uid = SessionManager.shared.currentUser?.id else { return }
        
        do {
            let response = try await APIService.shared.getRefundList(uid: uid)
            refunds = response.refundList ?? []
        } catch {
            print("Refunds error: \(error)")
        }
    }
    
    // MARK: - Edit Profile
    
    func updateName(_ name: String) async -> Bool {
        guard let uid = SessionManager.shared.currentUser?.id else { return false }
        
        do {
            let response = try await APIService.shared.editProfile(uid: uid, name: name)
            if response.isSuccess {
                await loadProfile()
                return true
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        return false
    }
    
    // MARK: - Logout
    
    func logout() async {
        guard let uid = SessionManager.shared.currentUser?.id else { return }
        
        do {
            _ = try await APIService.shared.logout(userId: uid)
        } catch {
            print("Logout API error: \(error)")
        }
        
        AppState.shared.logout()
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}