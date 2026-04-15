// Constants.swift
// App-wide constants matching Android base URL and endpoints

import Foundation

struct Constants {
    
    // MARK: - API Configuration
    static let baseURL = "https://zippy.truebasket.in/"
    static let apiPrefix = "eapi/"
    
    static var apiBaseURL: String {
        return baseURL + apiPrefix
    }
    
    // MARK: - API Endpoints
    struct Endpoints {
        // Auth
        static let register = "e_reg_user.php"
        static let login = "e_login_user.php"
        static let mobileCheck = "e_mobile_check.php"
        static let forgotPassword = "e_forget_password.php"
        static let sendOtp = "send_otp.php"
        static let countryCode = "e_country_code.php"
        static let saveToken = "save_token.php"
        static let logout = "eapi/user_logout.php"  // Note: double eapi in Android
        
        // Home
        static let homeData = "e_home_data.php"
        static let catData = "e_cat_data.php"
        static let servicesBanner = "e_services_banner.php"
        static let bannerApi = "e_banner_api.php"
        static let homeOffers = "e_home_offers.php"
        static let homeOfferRestaurants = "e_home_offer_restaurants.php"
        static let offerPopup = "e_get_offer_popup.php"
        static let trackOfferClick = "e_track_offer_click.php"
        static let homeBanners = "e_home_banners.php"
        
        // Restaurant
        static let restData = "e_rest_data.php"
        static let restSearch = "e_rest_search.php"
        static let restProductSearch = "e_rest_product_search.php"
        static let favourite = "e_fav.php"
        static let favList = "e_fav_list.php"
        static let rateData = "e_rate_data.php"
        static let rateUpdate = "e_rate_update.php"
        static let facilityList = "e_facility_list.php"
        
        // Cart & Orders
        static let cartData = "e_cart_data.php"
        static let orderNow = "e_order_now.php"
        static let orderHistory = "e_order_history.php"
        static let orderInfo = "e_order_information.php"
        static let reorder = "e_reorder.php"
        static let orderCancel = "e_order_cancle.php"
        static let mapInfo = "e_map_info.php"
        
        // Address
        static let addressAdd = "e_address_user.php"
        static let addressList = "e_address_list.php"
        static let addressDelete = "e_address_delete.php"
        static let addressDeleteLegacy = "e_add_delete.php"
        
        // Coupons
        static let checkCoupon = "e_check_coupon.php"
        static let couponList = "e_couponlist.php"
        static let verifyCoupon = "e_verify_coupon.php"
        
        // Wallet
        static let walletActivate = "e_wallet_activate.php"
        static let walletReport = "e_wallet_report.php"
        static let walletUp = "e_wallet_up.php"
        
        // Payment
        static let paymentGateway = "e_paymentgateway.php"
        
        // Profile
        static let profileEdit = "e_profile_edit.php"
        static let userProfile = "e_user_profile.php"
        static let getData = "e_getdata.php"
        static let pageList = "e_pagelist.php"
        
        // Offers
        static let offerList = "e_offerlist.php"
        
        // FAQ & Help
        static let faq = "e_faq.php"
        
        // Subscription
        static let subscriptionPlans = "e_subscription_plans.php"
        static let subscriptionOrder = "e_subscription_order.php"
        static let userSubscription = "e_user_subscription.php"
        static let skipMeal = "e_skip_meal.php"
        static let requestHoliday = "e_request_holiday.php"
        static let holidayRequests = "e_holiday_requests.php"
        static let subscriptionBanners = "e_subscription_banners.php"
        
        // Membership / Plus
        static let membershipPlans = "e_membership_plans.php"
        static let purchaseMembership = "e_purchase_membership.php"
        static let checkUserMembership = "e_check_user_membership.php"
        static let membershipHistory = "e_membership_history.php"
        static let cancelMembership = "e_cancel_membership.php"
        
        // Dine-In
        static let dineGetSettings = "e_dine_get_settings.php"
        static let dineBookTable = "e_dine_book_table.php"
        
        // Cashback
        static let corporateCashbackSendOtp = "e_corporate_cashback_send_otp.php"
        static let corporateCashbackVerifyOtp = "e_corporate_cashback_verify_otp.php"
        static let studentCashbackSendOtp = "e_student_cashback_send_otp.php"
        static let studentCashbackVerifyOtp = "e_student_cashback_verify_otp.php"
        
        // SBI
        static let sbiAddMoney = "e_sbi_add_money.php"
        static let sbiPaymentVerify = "e_sbi_payment_verify.php"
        
        // Refunds
        static let userRefundList = "e_user_refund_list.php"
        
        // Restaurant registration
        static let registerRestaurantLink = "e_register_restaurant_link.php"
        
        // Restaurant-specific offer (sapi)
        static func restaurantOffer(restId: String) -> String {
            return "sapi/get_offer.php?rest_id=\(restId)"
        }
    }
    
    // MARK: - App Colors
    struct Colors {
        static let primary = "#F72437"
        static let primaryDark = "#D41F31"
        static let accent = "#FC791A"
        static let green = "#098430"
        static let red = "#DD2020"
        static let black = "#171A29"
        static let gray = "#CFCFCF"
        static let grayBg = "#F0EFF4"
        static let yellow = "#FFC107"
    }
    
    // MARK: - Notification Keys
    struct NotificationKeys {
        static let cartUpdated = "cartUpdated"
        static let addressSelected = "addressSelected"
        static let orderPlaced = "orderPlaced"
        static let couponApplied = "couponApplied"
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let isIntroShown = "IS_INTRO"
        static let isLoggedIn = "IS_LOGIN"
        static let isGuest = "IS_GUEST"
        static let userData = "users"
        static let deliveryCharge = "deliverycharge"
        static let mainData = "MAINDATA"
        static let walletBalance = "WALLET"
        static let tipEnabled = "IS_TIP"
        static let tipValues = "TIP"
        static let taxEnabled = "IS_TAX"
        static let taxValue = "TAX"
        static let walletName = "walletname"
        static let currency = "CURRENCY"
        static let pincode = "pincode"
        static let pincodeData = "pincode_data"
        static let couponCode = "COUPONCODE"
        static let couponId = "COUPONID"
        static let restaurantName = "RESNAME"
        static let restaurantId = "RESID"
        static let orderType = "order_type"
        static let takeawayTime = "takeaway_time"
        static let savedPaymentId = "saved_payment_id"
        static let savedPaymentName = "saved_payment_name"
        static let language = "language"
        static let fcmToken = "fcm_token"
        static let addressData = "ADDRESS_DATA"
    }
}
