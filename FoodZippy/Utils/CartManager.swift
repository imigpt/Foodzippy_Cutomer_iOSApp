// CartManager.swift
// Local cart management replacing Android MyHelper SQLite database
// Uses UserDefaults for persistence (could migrate to CoreData for larger datasets)

import Foundation
import Combine

@MainActor
class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var cartItems: [CartItem] = []
    @Published var showReplaceCartAlert = false
    
    var pendingItem: CartItem?
    var pendingRestaurantName: String?
    
    private let cartKey = "cart_items"
    
    private init() {
        loadCart()
    }
    
    // MARK: - Cart Properties
    
    var itemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var currentRestaurantId: String? {
        cartItems.first?.restaurantId
    }
    
    var isEmpty: Bool {
        cartItems.isEmpty
    }
    
    // MARK: - Add Item
    
    func addItem(
        _ item: CartItem,
        restaurantName: String = ""
    ) {
        // Check if cart has items from a different restaurant
        if let existingRestId = currentRestaurantId,
           existingRestId != item.restaurantId,
           !cartItems.isEmpty {
            pendingItem = item
            pendingRestaurantName = restaurantName
            showReplaceCartAlert = true
            return
        }
        
        // Check if same product with same addon already exists
        if let index = cartItems.firstIndex(where: {
            $0.productId == item.productId && $0.addonId == item.addonId
        }) {
            cartItems[index].quantity += item.quantity
        } else {
            cartItems.append(item)
        }
        
        saveCart()
        notifyCartUpdate()
    }
    
    // MARK: - Replace Cart (Different Restaurant)
    
    func replaceCartWithPendingItem() {
        guard let item = pendingItem else { return }
        cartItems.removeAll()
        cartItems.append(item)
        pendingItem = nil
        pendingRestaurantName = nil
        saveCart()
        notifyCartUpdate()
    }
    
    // MARK: - Update Quantity
    
    func updateQuantity(for itemId: UUID, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == itemId }) {
            if quantity <= 0 {
                cartItems.remove(at: index)
            } else {
                cartItems[index].quantity = quantity
            }
            saveCart()
            notifyCartUpdate()
        }
    }
    
    func incrementQuantity(for itemId: UUID) {
        if let index = cartItems.firstIndex(where: { $0.id == itemId }) {
            cartItems[index].quantity += 1
            saveCart()
            notifyCartUpdate()
        }
    }
    
    func decrementQuantity(for itemId: UUID) {
        if let index = cartItems.firstIndex(where: { $0.id == itemId }) {
            if cartItems[index].quantity <= 1 {
                cartItems.remove(at: index)
            } else {
                cartItems[index].quantity -= 1
            }
            saveCart()
            notifyCartUpdate()
        }
    }
    
    // MARK: - Remove Item
    
    func removeItem(_ itemId: UUID) {
        cartItems.removeAll { $0.id == itemId }
        saveCart()
        notifyCartUpdate()
    }
    
    // MARK: - Clear Cart
    
    func clearCart() {
        cartItems.removeAll()
        saveCart()
        notifyCartUpdate()
    }
    
    // MARK: - Query Methods
    
    func getQuantity(productId: String) -> Int {
        cartItems.filter { $0.productId == productId }.reduce(0) { $0 + $1.quantity }
    }
    
    func hasProduct(productId: String) -> Bool {
        cartItems.contains { $0.productId == productId }
    }
    
    func isSameRestaurant(restId: String) -> Bool {
        guard let currentId = currentRestaurantId else { return true }
        return currentId == restId
    }
    
    // MARK: - Persistence
    
    private func saveCart() {
        if let data = try? JSONEncoder().encode(cartItems) {
            UserDefaults.standard.set(data, forKey: cartKey)
        }
    }
    
    private func loadCart() {
        guard let data = UserDefaults.standard.data(forKey: cartKey),
              let items = try? JSONDecoder().decode([CartItem].self, from: data) else {
            return
        }
        cartItems = items
    }
    
    private func notifyCartUpdate() {
        NotificationCenter.default.post(
            name: Notification.Name(Constants.NotificationKeys.cartUpdated),
            object: nil
        )
        AppState.shared.updateCartBadge()
    }
}
