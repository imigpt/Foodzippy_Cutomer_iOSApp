// Order.swift
// Order-related models matching Android OrderDetail.java, OrderHistoryItem.java, etc.

import Foundation

// MARK: - Order History
struct OrderHistoryResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let orderHistory: [OrderHistoryItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case orderHistory = "OrderHistory"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

struct OrderHistoryItem: Codable, Identifiable {
    var id: String { orderId ?? UUID().uuidString }
    
    let orderId: String?
    let oStatus: String?
    let orderCompleteDate: String?
    let orderTotal: String?
    let restName: String?
    let restLandmark: String?
    let restImage: String?
    let orderItems: String?
    let orderThumbnail: String?
    let restRate: Int?
    let riderRate: Int?
    let restText: String?
    let riderText: String?
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case oStatus = "o_status"
        case orderCompleteDate = "order_complete_date"
        case orderTotal = "order_total"
        case restName = "rest_name"
        case restLandmark = "rest_landmark"
        case restImage = "rest_image"
        case orderItems = "order_items"
        case orderThumbnail = "order_thumbnail"
        case restRate = "rest_rate"
        case riderRate = "rider_rate"
        case restText = "rest_text"
        case riderText = "rider_text"
    }
    
    var statusText: String {
        switch oStatus {
        case "Pending": return "Pending"
        case "Completed": return "Completed"
        case "Cancelled": return "Cancelled"
        case "Confirm": return "Confirmed"
        case "Pickup": return "Out for Delivery"
        case "Arrived": return "Arrived"
        default: return oStatus ?? "Unknown"
        }
    }
    
    var statusColor: String {
        switch oStatus {
        case "Completed": return Constants.Colors.green
        case "Cancelled": return Constants.Colors.red
        case "Pending": return Constants.Colors.accent
        default: return Constants.Colors.primary
        }
    }
}

// MARK: - Order Detail
struct OrderDetailResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let orderData: OrderDetail?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case orderData = "OrderData"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

struct OrderDetail: Codable {
    let restaurantId: String?
    let restName: String?
    let restAddress: String?
    let restImg: String?
    let restCharge: String?
    let orderId: String?
    let oStatus: String?
    let orderCompleteDate: String?
    let orderTotal: String?
    let subtotal: String?
    let deliveryCharge: String?
    let tax: String?
    let couAmt: String?
    let couponTitle: String?
    let wallAmt: String?
    let riderTip: String?
    let riderName: String?
    let custAddress: String?
    let addressType: String?
    let pMethodName: String?
    let orderType: String?
    let takeawayTime: String?
    let isPreorder: Int?
    let restOpensAt: String?
    let isScheduled: Int?
    let scheduleDate: String?
    let scheduleTime: String?
    let scheduleDisplayDate: String?
    let scheduleDisplayTime: String?
    let estimatedDeliveryTime: String?
    let orderEndTime: String?
    let currentServerTime: String?
    let orderItemsList: [OrderLineItem]?
    
    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case restName = "rest_name"
        case restAddress = "rest_address"
        case restImg = "rest_img"
        case restCharge = "rest_charge"
        case orderId = "order_id"
        case oStatus = "o_status"
        case orderCompleteDate = "order_complete_date"
        case orderTotal = "order_total"
        case subtotal
        case deliveryCharge = "delivery_charge"
        case tax
        case couAmt = "cou_amt"
        case couponTitle = "coupon_title"
        case wallAmt = "wall_amt"
        case riderTip = "rider_tip"
        case riderName = "rider_name"
        case custAddress = "cust_address"
        case addressType = "address_type"
        case pMethodName = "p_method_name"
        case orderType = "order_type"
        case takeawayTime = "takeaway_time"
        case isPreorder = "is_preorder"
        case restOpensAt = "rest_opens_at"
        case isScheduled = "is_scheduled"
        case scheduleDate = "schedule_date"
        case scheduleTime = "schedule_time"
        case scheduleDisplayDate = "schedule_display_date"
        case scheduleDisplayTime = "schedule_display_time"
        case estimatedDeliveryTime = "estimated_delivery_time"
        case orderEndTime = "order_end_time"
        case currentServerTime = "current_server_time"
        case orderItemsList = "order_items"
    }
}

struct OrderLineItem: Codable, Identifiable {
    var id: String { UUID().uuidString }
    
    let itemName: String?
    let itemAddon: String?
    let itemTotal: AnyCodableValue?
    let isVeg: String?
    
    enum CodingKeys: String, CodingKey {
        case itemName = "item_name"
        case itemAddon = "item_addon"
        case itemTotal = "item_total"
        case isVeg = "is_veg"
    }
    
    var isVegetarian: Bool { isVeg == "1" }
    
    var totalAmount: Double {
        switch itemTotal {
        case .int(let val): return Double(val)
        case .double(let val): return val
        case .string(let val): return Double(val) ?? 0
        default: return 0
        }
    }
}

// MARK: - Order Placement Response
struct OrderPlaceResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let orderId: String?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case orderId = "order_id"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

// MARK: - Map Info (Order Tracking)
struct OrderMapInfo: Codable {
    let riderLat: String?
    let riderLng: String?
    let riderName: String?
    let riderPhone: String?
    let riderImg: String?
    let restLat: String?
    let restLng: String?
    let custLat: String?
    let custLng: String?
    let orderStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case riderLat = "rider_lat"
        case riderLng = "rider_lng"
        case riderName = "rider_name"
        case riderPhone = "rider_phone"
        case riderImg = "rider_img"
        case restLat = "rest_lat"
        case restLng = "rest_lng"
        case custLat = "cust_lat"
        case custLng = "cust_lng"
        case orderStatus = "order_status"
    }
}

struct OrderMapResponse: Codable {
    let responseCode: String?
    let result: String?
    let mapData: OrderMapInfo?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case mapData = "MapData"
    }
}
