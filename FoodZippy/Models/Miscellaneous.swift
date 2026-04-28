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

// MARK: - Holiday Requests
struct HolidayRequestItem: Codable, Identifiable {
    var id: String { requestId ?? UUID().uuidString }
    
    let requestId: String?
    let orderId: String?
    let startDate: String?
    let endDate: String?
    let status: String?
    let requestDate: String?
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case orderId = "order_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case status
        case requestDate = "request_date"
    }
}

struct HolidayRequestsResponse: Codable {
    let responseCode: String?
    let result: String?
    let requests: [HolidayRequestItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case requests = "HolidayRequests"
    }
}

// MARK: - Subscription Banners
struct SubscriptionBannerResponse: Codable {
    let responseCode: String?
    let result: String?
    let banners: [HomeBannerItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case banners = "Banners"
    }
}

// MARK: - Membership
struct MembershipPlan: Codable, Identifiable {
    var id: String { String(planId ?? 0) }
    
    let planId: Int?
    let planName: String?
    let planSubtitle: String?
    let durationMonths: Int?
    let originalPrice: Int?
    let offerPrice: Int?
    let savings: Int?
    let freeDelivery: Bool?
    let minOrderAmount: Int?
    let discountPercentage: Int?
    let maxDiscount: Int?
    let noSurgeFee: Bool?
    let prebookOffer: PrebookOffer?
    let hasCoupon: Bool?
    let couponText: String?
    let colorStart: String?
    let colorEnd: String?
    let icon: String?
    let benefitsByCategory: [BenefitsByCategory]?
    
    enum CodingKeys: String, CodingKey {
        case planId = "id"
        case planName = "plan_name"
        case planSubtitle = "plan_subtitle"
        case durationMonths = "duration_months"
        case originalPrice = "original_price"
        case offerPrice = "offer_price"
        case savings
        case freeDelivery = "free_delivery"
        case minOrderAmount = "min_order_amount"
        case discountPercentage = "discount_percentage"
        case maxDiscount = "max_discount"
        case noSurgeFee = "no_surge_fee"
        case prebookOffer = "prebook_offer"
        case hasCoupon = "has_coupon"
        case couponText = "coupon_text"
        case colorStart = "color_start"
        case colorEnd = "color_end"
        case icon
        case benefitsByCategory = "benefits_by_category"
    }
}

struct MembershipPlansResponse: Codable {
    let responseCode: String?
    let result: String?
    let responseMsg: String?
    let plans: [MembershipPlan]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case responseMsg = "ResponseMsg"
        case plans = "MembershipPlans"
    }
}

struct CheckUserMembershipResponse: Codable {
    let responseCode: String?
    let result: String?
    let hasMembership: Bool?
    let membershipDetails: UserMembershipDetails?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case hasMembership = "has_membership"
        case membershipDetails = "membership_details"
    }
}

struct UserMembershipDetails: Codable {
    let planId: String?
    let planTitle: String?
    let startDate: String?
    let endDate: String?
    let daysRemaining: Int?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case planTitle = "plan_title"
        case startDate = "start_date"
        case endDate = "end_date"
        case daysRemaining = "days_remaining"
        case status
    }
}

struct MembershipHistoryItem: Codable, Identifiable {
    var id: String { orderId ?? UUID().uuidString }
    
    let orderId: String?
    let planTitle: String?
    let amount: String?
    let purchaseDate: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case planTitle = "plan_title"
        case amount
        case purchaseDate = "purchase_date"
        case status
    }
}

struct MembershipHistoryResponse: Codable {
    let responseCode: String?
    let result: String?
    let history: [MembershipHistoryItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case history = "MembershipHistory"
    }
}

// MARK: - Coupon Item
struct CouponItem: Codable, Identifiable {
    var id: String { couponId ?? UUID().uuidString }
    
    let couponId: String?
    let couponTitle: String?
    let subtitle: String?
    let couponCode: String?
    let couponDescription: String?
    let couponValue: String?
    let minAmount: String?
    let couponImg: String?
    let cdate: String?
    
    enum CodingKeys: String, CodingKey {
        case couponId = "id"
        case couponTitle = "coupon_title"
        case subtitle
        case couponCode = "coupon_code"
        case couponDescription = "c_desc"
        case couponValue = "c_value"
        case minAmount = "min_amt"
        case couponImg = "c_img"
        case cdate
    }
}

// MARK: - Meal Card
struct MealCard: Codable, Identifiable {
    var id: String { mealId ?? UUID().uuidString }
    
    let mealId: String?
    let mealName: String?
    let description: String?
    let backgroundColor: String?
    let imageUrl: String?
    let mealType: String?
    
    enum CodingKeys: String, CodingKey {
        case mealId = "id"
        case mealName = "meal_name"
        case description
        case backgroundColor = "background_color"
        case imageUrl = "image_url"
        case mealType = "meal_type"
    }
}

struct MealCardsResponse: Codable {
    let responseCode: String?
    let result: String?
    let mealCards: [MealCard]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case mealCards = "MealCards"
    }
}

// MARK: - Membership Benefits
struct MembershipBenefit: Codable, Identifiable {
    var id: Int { benefitId ?? 0 }
    
    let benefitId: Int?
    let title: String?
    let description: String?
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case benefitId = "id"
        case title, description, icon
    }
}

struct BenefitsByCategory: Codable {
    let category: String?
    let benefits: [MembershipBenefit]?
}

struct PrebookOffer: Codable {
    let title: String?
    let description: String?
    let icon: String?
}

// MARK: - Affected Models (for Holidays)
struct AffectedMeal: Codable, Identifiable {
    var id: String { mealId ?? UUID().uuidString }
    let mealId: String?
    let mealName: String?
    let date: String?
    
    enum CodingKeys: String, CodingKey {
        case mealId = "meal_id"
        case mealName = "meal_name"
        case date
    }
}
