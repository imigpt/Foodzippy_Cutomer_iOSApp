// MenuItem.swift
// Food/Menu item models matching Android MenuitemDatum.java, ProductDatum.java, etc.

import Foundation

// MARK: - Product Category (Menu Section)
struct ProductCategory: Codable, Identifiable {
    var id: String { catId ?? UUID().uuidString }
    
    let catId: String?
    let title: String?
    let menuitemData: [MenuItem]?
    
    enum CodingKeys: String, CodingKey {
        case catId = "cat_id"
        case title
        case menuitemData = "Menuitem_Data"
    }
}

// MARK: - Menu Item
struct MenuItem: Codable, Identifiable {
    let id: String?
    let title: String?
    let itemImg: String?
    let price: FlexibleNumber?
    let originalPrice: String?
    let offerPercentage: Int?
    let offerPercentageText: String?
    let discountAmount: String?
    let finalPrice: String?
    let isCustomize: Int?
    let requiredStep: Int?
    let cdesc: String?
    let isQuantity: String?
    let isVeg: Int?
    let isSubscription: String?
    let addondata: [AddonCategory]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, cdesc, addondata
        case itemImg = "item_img"
        case originalPrice = "original_price"
        case offerPercentage = "offer_percentage"
        case offerPercentageText = "offer_percentage_text"
        case discountAmount = "discount_amount"
        case finalPrice = "final_price"
        case isCustomize = "is_customize"
        case requiredStep = "required_step"
        case isQuantity = "is_quantity"
        case isVeg = "is_veg"
        case isSubscription = "is_subscription"
    }
    
    var isVegetarian: Bool { isVeg == 1 }
    var hasCustomization: Bool { isCustomize == 1 }
    
    var effectivePrice: Double {
        if let fp = finalPrice, let p = Double(fp), p > 0 {
            return p
        }
        return price?.doubleValue ?? 0
    }
    
    var hasDiscount: Bool {
        guard let pct = offerPercentage else { return false }
        return pct > 0
    }
}

// MARK: - Addon Category
struct AddonCategory: Codable, Identifiable {
    var id: String { addonId ?? UUID().uuidString }
    
    let addonId: String?
    let addonTitle: String?
    let addonIsRadio: Int?
    let addonIsQuantity: Int?
    let addonLimit: Int?
    let addonIsRequired: String?
    let addonItemData: [AddonItem]?
    
    enum CodingKeys: String, CodingKey {
        case addonId = "addon_id"
        case addonTitle = "addon_title"
        case addonIsRadio = "addon_is_radio"
        case addonIsQuantity = "addon_is_quantity"
        case addonLimit = "addon_limit"
        case addonIsRequired = "addon_is_required"
        case addonItemData = "addon_item_data"
    }
    
    var isRequired: Bool { addonIsRequired == "1" }
    var isRadioSelection: Bool { addonIsRadio == 1 }
}

// MARK: - Addon Item
struct AddonItem: Codable, Identifiable {
    var id: String { subId ?? UUID().uuidString }
    
    let subId: String?
    let title: String?
    let price: String?
    let subaddondata: [SubAddonItem]?
    
    enum CodingKeys: String, CodingKey {
        case subId = "sub_id"
        case title, price, subaddondata
    }
    
    var priceDouble: Double {
        Double(price ?? "0") ?? 0
    }
}

struct SubAddonItem: Codable, Identifiable {
    var id: String { subId ?? UUID().uuidString }
    
    let subId: String?
    let title: String?
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case subId = "sub_id"
        case title, price
    }
}

// MARK: - Flexible Number (handles price as String or Number)
struct FlexibleNumber: Codable {
    let doubleValue: Double
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let doubleVal = try? container.decode(Double.self) {
            doubleValue = doubleVal
        } else if let stringVal = try? container.decode(String.self),
                  let parsed = Double(stringVal) {
            doubleValue = parsed
        } else if let intVal = try? container.decode(Int.self) {
            doubleValue = Double(intVal)
        } else {
            doubleValue = 0
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(doubleValue)
    }
    
    init(_ value: Double) {
        self.doubleValue = value
    }
}
