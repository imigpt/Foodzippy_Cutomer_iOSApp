// SessionManager.swift
// Manages user session, preferences, and stored data
// Replaces Android SharedPreferences

import Foundation
import Combine

@MainActor
class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var currentAddress: Address?
    @Published var mainData: MainData?
    
    // MARK: - Session Flags
    var isIntroShown: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.isIntroShown) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.isIntroShown) }
    }
    
    var isLoggedIn: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.isLoggedIn) }
        set {
            defaults.set(newValue, forKey: Constants.UserDefaultsKeys.isLoggedIn)
            objectWillChange.send()
        }
    }
    
    var isGuest: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.isGuest) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.isGuest) }
    }
    
    // MARK: - FCM Token
    var fcmToken: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.fcmToken) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.fcmToken) }
    }
    
    // MARK: - Currency
    var currency: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.currency) ?? "₹" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.currency) }
    }
    
    // MARK: - Wallet
    var walletBalance: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.walletBalance) ?? "0" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.walletBalance) }
    }
    
    var walletName: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.walletName) ?? "FoodZippy Money" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.walletName) }
    }
    
    // MARK: - Tax & Tip
    var isTaxEnabled: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.taxEnabled) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.taxEnabled) }
    }
    
    var taxValue: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.taxValue) ?? "0" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.taxValue) }
    }
    
    var isTipEnabled: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.tipEnabled) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.tipEnabled) }
    }
    
    var tipValues: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.tipValues) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.tipValues) }
    }
    
    // MARK: - Delivery
    var deliveryCharge: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.deliveryCharge) ?? "0" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.deliveryCharge) }
    }
    
    // MARK: - Coupon
    var couponCode: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.couponCode) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.couponCode) }
    }
    
    var couponId: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.couponId) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.couponId) }
    }
    
    // MARK: - Restaurant Context
    var restaurantName: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.restaurantName) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.restaurantName) }
    }
    
    var restaurantId: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.restaurantId) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.restaurantId) }
    }
    
    // MARK: - Order Type
    var orderType: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.orderType) ?? "delivery" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.orderType) }
    }
    
    var takeawayTime: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.takeawayTime) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.takeawayTime) }
    }
    
    // MARK: - Saved Payment
    var savedPaymentId: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.savedPaymentId) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.savedPaymentId) }
    }
    
    var savedPaymentName: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.savedPaymentName) ?? "" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.savedPaymentName) }
    }
    
    // MARK: - Language
    var language: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.language) ?? "en" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.language) }
    }
    
    // MARK: - Init
    private init() {
        loadUser()
        loadAddress()
        loadMainData()
    }
    
    // MARK: - User Management
    func saveUser(_ user: User) {
        currentUser = user
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: Constants.UserDefaultsKeys.userData)
        }
        isLoggedIn = true
        isGuest = false
    }
    
    func loadUser() {
        guard let data = defaults.data(forKey: Constants.UserDefaultsKeys.userData),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        currentUser = user
    }
    
    // MARK: - Address Management
    func saveAddress(_ address: Address) {
        currentAddress = address
        if let data = try? JSONEncoder().encode(address) {
            defaults.set(data, forKey: Constants.UserDefaultsKeys.addressData)
        }
    }
    
    func loadAddress() {
        guard let data = defaults.data(forKey: Constants.UserDefaultsKeys.addressData),
              let address = try? JSONDecoder().decode(Address.self, from: data) else {
            return
        }
        currentAddress = address
    }
    
    // MARK: - Main Data (App Config)
    func saveMainData(_ data: MainData) {
        mainData = data
        currency = data.currency ?? "₹"
        isTaxEnabled = (data.isTax ?? 0) == 1
        taxValue = data.tax ?? "0"
        isTipEnabled = (data.isTip ?? 0) == 1
        tipValues = data.tip ?? ""
        walletName = data.wname ?? "FoodZippy Money"
        
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: Constants.UserDefaultsKeys.mainData)
        }
    }
    
    func loadMainData() {
        guard let data = defaults.data(forKey: Constants.UserDefaultsKeys.mainData),
              let mainData = try? JSONDecoder().decode(MainData.self, from: data) else {
            return
        }
        self.mainData = mainData
    }
    
    // MARK: - Clear Session
    func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        currentUser = nil
        currentAddress = nil
        mainData = nil
        isLoggedIn = false
        isGuest = false
    }
}
