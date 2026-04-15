// Miscellaneous.swift
// Supporting models: FAQ, Help, Rate, Referral, Subscription, etc.

import Foundation

// MARK: - Generic API Response
struct GenericResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

// MARK: - FAQ
struct FaqItem: Codable, Identifiable {
    var id: String { UUID().uuidString }
    
    let question: String?
    let answer: String?
}

struct FaqResponse: Codable {
    let responseCode: String?
    let result: String?
    let faqData: [FaqItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case faqData = "FaqData"
    }
}

// MARK: - Help Page
struct HelpPage: Codable, Identifiable {
    var id: String { UUID().uuidString }
    
    let title: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description
    }
}

struct HelpResponse: Codable {
    let responseCode: String?
    let result: String?
    let pageList: [HelpPage]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case pageList = "PageList"
    }
}

// MARK: - Rating
struct RatingData: Codable {
    let restName: String?
    let restImg: String?
    let riderName: String?
    let riderImg: String?
    let orderDate: String?
    let orderItems: [OrderLineItem]?
    
    enum CodingKeys: String, CodingKey {
        case restName = "rest_name"
        case restImg = "rest_img"
        case riderName = "rider_name"
        case riderImg = "rider_img"
        case orderDate = "order_date"
        case orderItems = "order_items"
    }
}

struct RatingDataResponse: Codable {
    let responseCode: String?
    let result: String?
    let rateData: RatingData?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case rateData = "RateData"
    }
}

// MARK: - Referral
struct ReferralData: Codable {
    let referCode: String?
    let referCredit: String?
    let signupCredit: String?
    
    enum CodingKeys: String, CodingKey {
        case referCode = "refer_code"
        case referCredit = "refercredit"
        case signupCredit = "signupcredit"
    }
}

struct ReferralResponse: Codable {
    let responseCode: String?
    let result: String?
    let referData: ReferralData?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case referData = "ReferData"
    }
}

// MARK: - Subscription
struct SubscriptionPlan: Codable, Identifiable {
    var id: String { planId ?? UUID().uuidString }
    
    let planId: String?
    let planName: String?
    let planDescription: String?
    let planPrice: String?
    let planDuration: String?
    let planImg: String?
    let planMeals: [SubscriptionMealItem]?
    
    enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case planName = "plan_name"
        case planDescription = "plan_description"
        case planPrice = "plan_price"
        case planDuration = "plan_duration"
        case planImg = "plan_img"
        case planMeals = "plan_meals"
    }
}

struct SubscriptionMealItem: Codable, Identifiable {
    var id: String { mealId ?? UUID().uuidString }
    
    let mealId: String?
    let mealName: String?
    let mealDescription: String?
    let mealImg: String?
    
    enum CodingKeys: String, CodingKey {
        case mealId = "meal_id"
        case mealName = "meal_name"
        case mealDescription = "meal_description"
        case mealImg = "meal_img"
    }
}

struct SubscriptionPlansResponse: Codable {
    let responseCode: String?
    let result: String?
    let plans: [SubscriptionPlan]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case plans = "SubscriptionPlans"
    }
}

// MARK: - Active Subscriptions / Schedule

struct MySubscriptionsResponse: Codable {
    let responseCode: String?
    let result: String?
    let responseMsg: String?
    let hasActiveSubscription: Bool?
    let totalActiveOrders: Int?
    let activeOrders: [ActiveSubscriptionItem]?

    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case responseMsg = "ResponseMsg"
        case hasActiveSubscription = "has_active_subscription"
        case totalActiveOrders = "total_active_orders"
        case activeOrders = "active_orders"
    }
}

struct ActiveSubscriptionItem: Codable, Identifiable {
    var id: String { orderId ?? UUID().uuidString }

    let orderId: String?
    let subscriptionId: String?
    let planTitle: String?
    let planDescription: String?
    let planDays: String?
    let amount: String?
    let status: String?
    let startDateFormatted: String?
    let endDateFormatted: String?
    let daysRemaining: Int?
    let dailySchedule: [SubscriptionDailyMeal]?

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case subscriptionId = "subscription_id"
        case planTitle = "plan_title"
        case planDescription = "plan_description"
        case planDays = "plan_days"
        case amount
        case status
        case startDateFormatted = "start_date_formatted"
        case endDateFormatted = "end_date_formatted"
        case daysRemaining = "days_remaining"
        case dailySchedule = "daily_schedule"
    }
}

struct SubscriptionDailyMeal: Codable, Identifiable {
    var id: String { mealId ?? internalId ?? UUID().uuidString }

    let internalId: String?
    let mealId: String?
    let mealType: String?
    let deliveryDate: String?
    let dayName: String?
    let dateFormatted: String?
    let itemTitle: String?
    let itemPrice: String?
    let status: String?
    let isHoliday: Bool?

    enum CodingKeys: String, CodingKey {
        case internalId = "id"
        case mealId = "meal_id"
        case mealType = "meal_type"
        case deliveryDate = "delivery_date"
        case dayName = "day_name"
        case dateFormatted = "date_formatted"
        case itemTitle = "item_title"
        case itemPrice = "item_price"
        case status
        case isHoliday = "is_holiday"
    }
}

// MARK: - Dine-In Settings

struct DineSettingsResponse: Codable {
    let responseCode: String?
    let result: String?
    let responseMsg: String?
    let settingsData: DineSettingsData?

    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case responseMsg = "ResponseMsg"
        case settingsData = "SettingsData"
    }
}

struct DineSettingsData: Codable {
    let bookingSettings: DineBookingSettings?
    let timeSlots: DineTimeSlots?
    let lunchSettings: DineSlotWindow?
    let dinnerSettings: DineSlotWindow?

    enum CodingKeys: String, CodingKey {
        case bookingSettings = "booking_settings"
        case timeSlots = "time_slots"
        case lunchSettings = "lunch_settings"
        case dinnerSettings = "dinner_settings"
    }
}

struct DineBookingSettings: Codable {
    let maxGuestsPerBooking: Int?
    let advanceBookingDays: Int?

    enum CodingKeys: String, CodingKey {
        case maxGuestsPerBooking = "max_guests_per_booking"
        case advanceBookingDays = "advance_booking_days"
    }
}

struct DineTimeSlots: Codable {
    let lunch: DineSlotWindow?
    let dinner: DineSlotWindow?
}

struct DineSlotWindow: Codable {
    let startTime: String?
    let endTime: String?
    let perGuestAmount: Double?

    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case perGuestAmount = "per_guest_amount"
    }
}

// MARK: - Offer Detail
struct OfferDetail: Codable, Identifiable {
    var id: String { offerId ?? UUID().uuidString }
    
    let offerId: String?
    let title: String?
    let offerText: String?
    let offerImg: String?
    
    enum CodingKeys: String, CodingKey {
        case offerId = "offer_id"
        case title
        case offerText = "offer_text"
        case offerImg = "offer_img"
    }
}

struct OfferListResponse: Codable {
    let responseCode: String?
    let result: String?
    let offerData: [OfferDetail]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case offerData = "OfferData"
    }
}

// MARK: - Restaurant Offer
struct RestaurantOffer: Codable {
    let couTitle: String?
    let couSubtitle: String?
    let couCode: String?
    let couImg: String?
    
    enum CodingKeys: String, CodingKey {
        case couTitle = "cou_title"
        case couSubtitle = "cou_subtitle"
        case couCode = "cou_code"
        case couImg = "cou_img"
    }
}

// MARK: - Refund
struct RefundItem: Codable, Identifiable {
    var id: String { refundId ?? UUID().uuidString }
    
    let refundId: String?
    let orderId: String?
    let amount: String?
    let status: String?
    let rdate: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case refundId = "refund_id"
        case orderId = "order_id"
        case amount, status, rdate, message
    }
}

struct RefundListResponse: Codable {
    let responseCode: String?
    let result: String?
    let refundList: [RefundItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case refundList = "RefundList"
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let action: ProfileMenuAction
}

enum ProfileMenuAction {
    case wallet
    case plus
    case refunds
    case subscriptionHistory
    case savedAddresses
    case favourites
    case sbiCard
    case corporateCashback
    case studentCashback
    case faq
    case help
    case comingSoon
    case registerRestaurant
    case language
}
