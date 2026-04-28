// CartViewModel.swift
// Handles cart display, bill calculation, coupon, tip, and order placement

import Foundation
import Combine

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var addresses: [Address] = []
    @Published var selectedAddress: Address?
    @Published var paymentMethods: [PaymentItem] = []
    @Published var selectedPaymentMethod: PaymentItem?
    
    // Bill Details
    @Published var itemTotal: Double = 0
    @Published var deliveryCharge: Double = 0
    @Published var storeCharge: Double = 0
    @Published var taxAmount: Double = 0
    @Published var tipAmount: Double = 0
    @Published var couponDiscount: Double = 0
    @Published var walletAmount: Double = 0
    @Published var grandTotal: Double = 0
    
    @Published var useWallet = false
    @Published var tipItems: [TipItem] = []
    @Published var appliedCoupon: Coupon?
    
    // Schedule
    @Published var isScheduled = false
    @Published var scheduleDate = Date()
    @Published var scheduleTime = ""
    
    // State
    @Published var isLoading = false
    @Published var isPlacingOrder = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var orderPlaced = false
    @Published var placedOrderId = ""
    @Published var showCouponSheet = false
    @Published var showAddressSheet = false
    @Published var showPaymentSheet = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCart()
        setupTips()
        
        // Listen for cart updates
        NotificationCenter.default.publisher(for: Notification.Name(Constants.NotificationKeys.cartUpdated))
            .sink { [weak self] _ in
                self?.loadCart()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Cart
    
    func loadCart() {
        cartItems = CartManager.shared.cartItems
        calculateBill()
    }
    
    // MARK: - Load Data
    
    func loadCartData() async {
        isLoading = true
        
        // Load addresses
        let uid = SessionManager.shared.currentUser?.id?.stringValue ?? ""; if !uid.isEmpty {
            do {
                let addressResponse = try await APIService.shared.getAddressList(uid: uid)
                if let list = addressResponse.addressList {
                    addresses = list
                    if selectedAddress == nil {
                        selectedAddress = SessionManager.shared.currentAddress ?? list.first
                    }
                }
            } catch {
                print("Address load error: \(error)")
            }
            
            // Load payment methods
            do {
                let paymentResponse = try await APIService.shared.getPaymentGateways()
                if let methods = paymentResponse.paymentData {
                    paymentMethods = methods.filter { $0.isActive && $0.isVisible }
                    
                    // Restore saved payment
                    let savedId = SessionManager.shared.savedPaymentId
                    if !savedId.isEmpty {
                        selectedPaymentMethod = paymentMethods.first { $0.mId == savedId }
                    }
                    if selectedPaymentMethod == nil {
                        selectedPaymentMethod = paymentMethods.first
                    }
                }
            } catch {
                print("Payment load error: \(error)")
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Bill Calculation
    
    func calculateBill() {
        let session = SessionManager.shared
        
        // Item total
        itemTotal = cartItems.reduce(0) { $0 + $1.totalPrice }
        
        // Delivery charge
        deliveryCharge = Double(session.deliveryCharge) ?? 0
        
        // Store charge
        storeCharge = 0 // From restaurant data
        
        // Tax
        if session.isTaxEnabled {
            let taxPercent = Double(session.taxValue) ?? 0
            taxAmount = itemTotal * taxPercent / 100
        } else {
            taxAmount = 0
        }
        
        // Coupon discount
        if appliedCoupon != nil {
            // couponDiscount is set by applyCoupon
        }
        
        // Wallet
        if useWallet {
            let walletBal = Double(session.walletBalance) ?? 0
            let remaining = itemTotal + deliveryCharge + storeCharge + taxAmount + tipAmount - couponDiscount
            walletAmount = min(walletBal, remaining)
        } else {
            walletAmount = 0
        }
        
        // Grand total
        grandTotal = itemTotal + deliveryCharge + storeCharge + taxAmount + tipAmount - couponDiscount - walletAmount
        if grandTotal < 0 { grandTotal = 0 }
    }
    
    // MARK: - Tips
    
    private func setupTips() {
        let session = SessionManager.shared
        guard session.isTipEnabled else { return }
        
        let tipStr = session.tipValues
        let values = tipStr.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        tipItems = values.map { TipItem(amount: $0) }
    }
    
    func selectTip(_ amount: Double) {
        for i in tipItems.indices {
            tipItems[i].isSelected = tipItems[i].amount == amount
        }
        tipAmount = amount
        calculateBill()
    }
    
    func clearTip() {
        for i in tipItems.indices {
            tipItems[i].isSelected = false
        }
        tipAmount = 0
        calculateBill()
    }
    
    // MARK: - Coupon
    
    func applyCouponCode(_ code: String) async {
        guard let uid = SessionManager.shared.currentUser?.id?.stringValue else { return }
        let restId = CartManager.shared.currentRestaurantId ?? ""
        
        do {
            let response = try await APIService.shared.applyCoupon(
                couponCode: code,
                uid: uid,
                restId: restId,
                amount: String(itemTotal)
            )
            
            if response.isSuccess {
                couponDiscount = Double(response.couponValue ?? "0") ?? 0
                SessionManager.shared.couponCode = code
                calculateBill()
            } else {
                showErrorMessage(response.responseMsg ?? "Coupon not applicable")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    func removeCoupon() {
        appliedCoupon = nil
        couponDiscount = 0
        SessionManager.shared.couponCode = ""
        SessionManager.shared.couponId = ""
        calculateBill()
    }
    
    // MARK: - Place Order
    
    func placeOrder() async {
        guard let uid = SessionManager.shared.currentUser?.id?.stringValue else {
            showErrorMessage("Please login to place order")
            return
        }
        
        guard selectedAddress != nil || SessionManager.shared.orderType == "takeaway" else {
            showErrorMessage("Please select a delivery address")
            return
        }
        
        guard selectedPaymentMethod != nil else {
            showErrorMessage("Please select a payment method")
            return
        }
        
        isPlacingOrder = true
        
        // Build order items JSON
        var orderItems: [[String: Any]] = []
        for item in cartItems {
            orderItems.append([
                "item_id": item.productId,
                "item_name": item.title,
                "item_price": item.price,
                "item_qty": item.quantity,
                "addon_id": item.addonId,
                "addon_title": item.addonTitle,
                "addon_price": item.addonPrice
            ])
        }
        
        let orderItemsJSON = (try? JSONSerialization.data(withJSONObject: orderItems))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        
        var params: [String: Any] = [
            "uid": uid,
            "rest_id": CartManager.shared.currentRestaurantId ?? "",
            "o_total": String(grandTotal),
            "subtotal": String(itemTotal),
            "d_charge": String(deliveryCharge),
            "tax": String(taxAmount),
            "cou_amt": String(couponDiscount),
            "wall_amt": String(walletAmount),
            "tip": String(tipAmount),
            "store_charge": String(storeCharge),
            "coupon_code": SessionManager.shared.couponCode,
            "p_method": selectedPaymentMethod?.mId ?? "",
            "p_method_name": selectedPaymentMethod?.mTitle ?? "",
            "order_type": SessionManager.shared.orderType,
            "a_id": selectedAddress?.id ?? "",
            "order_items": orderItemsJSON
        ]
        
        if SessionManager.shared.orderType == "takeaway" {
            params["takeaway_time"] = SessionManager.shared.takeawayTime
        }
        
        if isScheduled {
            params["is_scheduled"] = "1"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            params["schedule_date"] = dateFormatter.string(from: scheduleDate)
            params["schedule_time"] = scheduleTime
        }
        
        do {
            let response = try await APIService.shared.placeOrder(params: params)
            
            if response.isSuccess {
                placedOrderId = response.orderId ?? ""
                orderPlaced = true
                
                // Clear cart
                CartManager.shared.clearCart()
                SessionManager.shared.couponCode = ""
                SessionManager.shared.couponId = ""
                
                // Save payment preference
                if let method = selectedPaymentMethod {
                    SessionManager.shared.savedPaymentId = method.mId ?? ""
                    SessionManager.shared.savedPaymentName = method.mTitle ?? ""
                }
            } else {
                showErrorMessage(response.responseMsg ?? "Failed to place order")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        
        isPlacingOrder = false
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
