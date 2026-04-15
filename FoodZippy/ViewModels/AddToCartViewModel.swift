import SwiftUI
import Combine
import UIKit

struct DishCustomisationOption: Identifiable, Hashable {
    let id: String
    let title: String
    let additionalPrice: Double
    let isVeg: Bool

    var additionalPriceText: String {
        if additionalPrice == floor(additionalPrice) {
            return "+ ₹\(Int(additionalPrice))"
        }
        return "+ ₹\(String(format: "%.2f", additionalPrice))"
    }
}

struct AddToCartDish: Identifiable, Hashable {
    let id: String
    let restaurantId: String
    let restaurantName: String
    let title: String
    let imageURL: String
    let description: String
    let basePrice: Double
    let oldPrice: Double
    let rating: Double
    let ratingCount: Int
    let isVeg: Bool
    let isCustomizable: Bool
    let customisationOptions: [DishCustomisationOption]

    var ratingText: String { String(format: "%.1f", rating) }

    func finalPrice(for option: DishCustomisationOption?) -> Double {
        basePrice + (option?.additionalPrice ?? 0)
    }

    func finalPriceText(for option: DishCustomisationOption?) -> String {
        let finalValue = finalPrice(for: option)
        if finalValue == floor(finalValue) {
            return "₹\(Int(finalValue))"
        }
        return "₹\(String(format: "%.2f", finalValue))"
    }

    var oldPriceText: String {
        if oldPrice == floor(oldPrice) {
            return "₹\(Int(oldPrice))"
        }
        return "₹\(String(format: "%.2f", oldPrice))"
    }
}

@MainActor
final class AddToCartViewModel: ObservableObject {
    static let shared = AddToCartViewModel()

    @Published var itemQuantities: [String: Int] = [:]
    @Published var selectedCustomizations: [String: DishCustomisationOption] = [:]
    @Published var recentlyAddedItemId: String?

    private var cancellables = Set<AnyCancellable>()

    private init() {
        refreshStateFromCart()

        NotificationCenter.default.publisher(for: Notification.Name(Constants.NotificationKeys.cartUpdated))
            .sink { [weak self] _ in
                self?.refreshStateFromCart()
            }
            .store(in: &cancellables)
    }

    func quantity(for itemId: String) -> Int {
        itemQuantities[itemId, default: 0]
    }

    func selectedCustomization(for itemId: String) -> DishCustomisationOption? {
        selectedCustomizations[itemId]
    }

    func setSelectedCustomization(_ option: DishCustomisationOption, for itemId: String) {
        selectedCustomizations[itemId] = option
    }

    func setQuantity(for dish: AddToCartDish, quantity: Int) {
        let target = max(0, quantity)
        let existing = CartManager.shared.cartItems.filter { $0.productId == dish.id && $0.addonId.isEmpty }
        let currentQty = existing.reduce(0) { $0 + $1.quantity }

        if target > currentQty {
            addDish(dish, customization: nil, quantity: target - currentQty)
            return
        }

        if target < currentQty {
            var diff = currentQty - target
            for item in existing {
                guard diff > 0 else { break }
                let reduceBy = min(item.quantity, diff)
                CartManager.shared.updateQuantity(for: item.id, quantity: item.quantity - reduceBy)
                diff -= reduceBy
            }
        }

        refreshStateFromCart()
    }

    func increment(dish: AddToCartDish, customization: DishCustomisationOption? = nil) {
        addDish(dish, customization: customization, quantity: 1)
    }

    func decrement(dish: AddToCartDish, customization: DishCustomisationOption? = nil) {
        let matching = CartManager.shared.cartItems.first {
            $0.productId == dish.id && $0.addonId == (customization?.id ?? "")
        }
        guard let item = matching else { return }

        CartManager.shared.decrementQuantity(for: item.id)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        refreshStateFromCart()
    }

    func addDish(
        _ dish: AddToCartDish,
        customization: DishCustomisationOption? = nil,
        quantity: Int = 1
    ) {
        let addQty = max(1, quantity)
        let cartItem = CartItem(
            restaurantId: dish.restaurantId,
            productId: dish.id,
            title: dish.title,
            itemImg: dish.imageURL,
            cdesc: dish.description,
            price: dish.basePrice,
            quantity: addQty,
            isCustomize: dish.isCustomizable ? 1 : 0,
            isQuantity: 1,
            isVeg: dish.isVeg ? 1 : 0,
            addonId: customization?.id ?? "",
            addonTitle: customization?.title ?? "",
            addonPrice: customization == nil ? "" : String(customization?.additionalPrice ?? 0)
        )

        CartManager.shared.addItem(cartItem, restaurantName: dish.restaurantName)

        if let customization {
            selectedCustomizations[dish.id] = customization
        }

        recentlyAddedItemId = dish.id
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            refreshStateFromCart()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.recentlyAddedItemId = nil
        }
    }

    private func refreshStateFromCart() {
        var quantityMap: [String: Int] = [:]
        for item in CartManager.shared.cartItems {
            quantityMap[item.productId, default: 0] += item.quantity
        }
        itemQuantities = quantityMap
    }
}
