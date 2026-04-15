// Payment.swift
// Payment-related models matching Android Payment.java, PaymentItem.java

import Foundation

struct PaymentItem: Codable, Identifiable {
    var id: String { mId ?? UUID().uuidString }
    
    let mId: String?
    let mTitle: String?
    let subtitle: String?
    let mImg: String?
    let mStatus: String?
    let mAttributes: String?
    let pShow: String?
    
    enum CodingKeys: String, CodingKey {
        case mId = "m_id"
        case mTitle = "m_title"
        case subtitle
        case mImg = "m_img"
        case mStatus = "m_status"
        case mAttributes = "attributes"
        case pShow = "p_show"
    }
    
    var isActive: Bool { mStatus == "1" }
    var isVisible: Bool { pShow == "1" }
}

struct PaymentResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let paymentData: [PaymentItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case paymentData = "PaymentData"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

// MARK: - Coupon
struct Coupon: Codable, Identifiable {
    var id: String { couponId ?? UUID().uuidString }
    
    let couponId: String?
    let couponTitle: String?
    let couponCode: String?
    let cDesc: String?
    let cValue: String?
    let minAmt: String?
    let cImg: String?
    let subtitle: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case couponId = "coupon_id"
        case couponTitle = "coupon_title"
        case couponCode = "coupon_code"
        case cDesc = "c_desc"
        case cValue = "c_value"
        case minAmt = "min_amt"
        case cImg = "c_img"
        case subtitle, status
    }
    
    var minimumAmount: Double { Double(minAmt ?? "0") ?? 0 }
    var discountValue: Double { Double(cValue ?? "0") ?? 0 }
}

struct CouponListResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let couponList: [Coupon]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case couponList = "CouponList"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

struct CouponApplyResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let couponValue: String?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case couponValue = "coupon_value"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

// MARK: - Wallet
struct WalletResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let wallet: String?
    let walletItems: [WalletTransaction]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case wallet
        case walletItems = "Walletitem"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

struct WalletTransaction: Codable, Identifiable {
    var id: String { UUID().uuidString }
    
    let tdate: String?
    let message: String?
    let status: String?
    let amt: String?
    
    var isCredit: Bool { status == "Credit" }
    var amount: Double { Double(amt ?? "0") ?? 0 }
}

// MARK: - Tips
struct TipItem: Identifiable {
    let id = UUID()
    let amount: Double
    var isSelected: Bool = false
}
