// CartItem.swift
// Cart model matching Android MyCart.java / MyHelper SQLite

import Foundation

struct CartItem: Codable, Identifiable {
    let id: UUID
    let restaurantId: String
    let productId: String
    let title: String
    let itemImg: String
    let cdesc: String
    let price: Double
    var quantity: Int
    let isCustomize: Int
    let isQuantity: Int
    let isVeg: Int
    let addonId: String
    let addonTitle: String
    let addonPrice: String
    
    var isVegetarian: Bool { isVeg == 1 }
    var hasCustomization: Bool { isCustomize == 1 }
    
    var totalPrice: Double {
        let addonTotal = addonPrice.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }.reduce(0, +)
        return (price + addonTotal) * Double(quantity)
    }
    
    init(
        restaurantId: String,
        productId: String,
        title: String,
        itemImg: String = "",
        cdesc: String = "",
        price: Double,
        quantity: Int = 1,
        isCustomize: Int = 0,
        isQuantity: Int = 0,
        isVeg: Int = 0,
        addonId: String = "",
        addonTitle: String = "",
        addonPrice: String = ""
    ) {
        self.id = UUID()
        self.restaurantId = restaurantId
        self.productId = productId
        self.title = title
        self.itemImg = itemImg
        self.cdesc = cdesc
        self.price = price
        self.quantity = quantity
        self.isCustomize = isCustomize
        self.isQuantity = isQuantity
        self.isVeg = isVeg
        self.addonId = addonId
        self.addonTitle = addonTitle
        self.addonPrice = addonPrice
    }
}
