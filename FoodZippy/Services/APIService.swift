// APIService.swift
// Central API service layer replacing Android Retrofit/UserService
// Uses async/await with URLSession

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case networkError(Error)
    case noInternet
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .serverError(let msg): return msg
        case .networkError(let error): return error.localizedDescription
        case .noInternet: return "No internet connection"
        }
    }
}

actor APIService {
    static let shared = APIService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
    }
    
    // MARK: - Core Request Method
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: [String: Any]? = nil,
        fullURL: String? = nil
    ) async throws -> T {
        let urlString = fullURL ?? (Constants.apiBaseURL + endpoint)
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body, method != "GET" {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        #if DEBUG
        print("📡 API Request: \(method) \(urlString)")
        if let body = body {
            print("📦 Body: \(body)")
        }
        #endif
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid response")
        }
        
        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Response (\(httpResponse.statusCode)): \(jsonString.prefix(500))")
        }
        #endif
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            #if DEBUG
            print("❌ Decoding Error in \(endpoint): \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Raw Response: \(jsonString)")
            }
            #endif
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Auth APIs
    
    func login(mobile: String, ccode: String = "+91") async throws -> LoginResponse {
        return try await request(
            endpoint: Constants.Endpoints.login,
            body: ["mobile": mobile, "ccode": ccode]
        )
    }
    
    func register(name: String, email: String, mobile: String, ccode: String, password: String, referCode: String = "") async throws -> LoginResponse {
        return try await request(
            endpoint: Constants.Endpoints.register,
            body: [
                "name": name,
                "email": email,
                "mobile": mobile,
                "ccode": ccode,
                "password": password,
                "refercode": referCode
            ]
        )
    }
    
    func checkMobile(mobile: String, ccode: String) async throws -> MobileCheckResponse {
        return try await request(
            endpoint: Constants.Endpoints.mobileCheck,
            body: ["mobile": mobile, "ccode": ccode]
        )
    }
    
    func forgotPassword(mobile: String, ccode: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.forgotPassword,
            body: ["mobile": mobile, "ccode": ccode]
        )
    }
    
    func sendOtp(mobile: String, ccode: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.sendOtp,
            body: ["mobile": mobile, "ccode": ccode]
        )
    }
    
    func getCountryCodes() async throws -> CountryCodeResponse {
        return try await request(
            endpoint: Constants.Endpoints.countryCode,
            body: [:]
        )
    }
    
    func saveToken(userId: String, token: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.saveToken,
            body: ["uid": userId, "token": token]
        )
    }
    
    func logout(userId: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.logout,
            body: ["uid": userId]
        )
    }
    
    // MARK: - Home APIs
    
    func getHomeData(uid: String, lat: String, lng: String) async throws -> HomeResponse {
        return try await request(
            endpoint: Constants.Endpoints.homeData,
            body: ["uid": uid, "lat": lat, "lng": lng]
        )
    }
    
    func getCategoryData(catId: String, lat: String, lng: String) async throws -> RestaurantListResponse {
        return try await request(
            endpoint: Constants.Endpoints.catData,
            body: ["catid": catId, "lat": lat, "lng": lng]
        )
    }
    
    func getServicesBanner(type: String = "delivery") async throws -> ServicesBannerResponse {
        return try await request(
            endpoint: Constants.Endpoints.servicesBanner,
            body: ["type": type]
        )
    }
    
    func getHomeBanners() async throws -> HomeBannerResponse {
        return try await request(
            endpoint: Constants.Endpoints.bannerApi,
            method: "POST",
            body: [:]
        )
    }
    
    func getHomeOffers() async throws -> HomeOfferResponse {
        return try await request(
            endpoint: Constants.Endpoints.homeOffers,
            method: "GET"
        )
    }
    
    func getHomeOfferRestaurants(offerId: String, lat: String, lng: String) async throws -> RestaurantListResponse {
        return try await request(
            endpoint: Constants.Endpoints.homeOfferRestaurants,
            body: ["offer_id": offerId, "lat": lat, "lng": lng]
        )
    }
    
    func getOfferPopup(uid: String) async throws -> OfferPopupResponse {
        return try await request(
            endpoint: Constants.Endpoints.offerPopup,
            body: ["uid": uid]
        )
    }
    
    func getFacilities() async throws -> FacilityResponse {
        return try await request(
            endpoint: Constants.Endpoints.facilityList,
            method: "GET"
        )
    }
    
    // MARK: - Restaurant APIs
    
    func getRestaurantDetail(restId: String, uid: String, lat: String, lng: String) async throws -> RestaurantDetailResponse {
        return try await request(
            endpoint: Constants.Endpoints.restData,
            body: ["rest_id": restId, "uid": uid, "lat": lat, "lng": lng]
        )
    }
    
    func searchRestaurants(query: String, lat: String, lng: String) async throws -> RestaurantListResponse {
        return try await request(
            endpoint: Constants.Endpoints.restSearch,
            body: ["search": query, "lat": lat, "lng": lng]
        )
    }
    
    func searchProducts(restId: String, query: String) async throws -> RestaurantDetailResponse {
        return try await request(
            endpoint: Constants.Endpoints.restProductSearch,
            body: ["rest_id": restId, "search": query]
        )
    }
    
    func toggleFavourite(restId: String, uid: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.favourite,
            body: ["rest_id": restId, "uid": uid]
        )
    }
    
    func getFavourites(uid: String, lat: String, lng: String) async throws -> FavouriteResponse {
        return try await request(
            endpoint: Constants.Endpoints.favList,
            body: ["uid": uid, "lat": lat, "lng": lng]
        )
    }
    
    // MARK: - Cart & Order APIs
    
    func getCartData(restId: String, uid: String, lat: String, lng: String) async throws -> RestaurantDetailResponse {
        return try await request(
            endpoint: Constants.Endpoints.cartData,
            body: ["rest_id": restId, "uid": uid, "lat": lat, "lng": lng]
        )
    }
    
    func placeOrder(params: [String: Any]) async throws -> OrderPlaceResponse {
        return try await request(
            endpoint: Constants.Endpoints.orderNow,
            body: params
        )
    }
    
    func getOrderHistory(uid: String) async throws -> OrderHistoryResponse {
        return try await request(
            endpoint: Constants.Endpoints.orderHistory,
            body: ["uid": uid]
        )
    }
    
    func getOrderDetail(orderId: String) async throws -> OrderDetailResponse {
        return try await request(
            endpoint: Constants.Endpoints.orderInfo,
            body: ["order_id": orderId]
        )
    }
    
    func cancelOrder(orderId: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.orderCancel,
            body: ["order_id": orderId]
        )
    }
    
    func reorder(orderId: String, uid: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.reorder,
            body: ["order_id": orderId, "uid": uid]
        )
    }
    
    func getMapInfo(orderId: String) async throws -> OrderMapResponse {
        return try await request(
            endpoint: Constants.Endpoints.mapInfo,
            body: ["order_id": orderId]
        )
    }
    
    // MARK: - Address APIs
    
    func addAddress(uid: String, hno: String, address: String, lat: String, lng: String, landmark: String, type: String) async throws -> AddressAddResponse {
        return try await request(
            endpoint: Constants.Endpoints.addressAdd,
            body: [
                "uid": uid,
                "houseno": hno,
                "address": address,
                "lat_map": lat,
                "long_map": lng,
                "landmark": landmark,
                "type": type
            ]
        )
    }
    
    func getAddressList(uid: String) async throws -> AddressListResponse {
        return try await request(
            endpoint: Constants.Endpoints.addressList,
            body: ["uid": uid]
        )
    }
    
    func deleteAddress(addressId: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.addressDeleteLegacy,
            body: ["address_id": addressId]
        )
    }
    
    // MARK: - Coupon APIs
    
    func getCoupons(restId: String) async throws -> CouponListResponse {
        return try await request(
            endpoint: Constants.Endpoints.couponList,
            body: ["rest_id": restId]
        )
    }
    
    func applyCoupon(couponCode: String, uid: String, restId: String, amount: String) async throws -> CouponApplyResponse {
        return try await request(
            endpoint: Constants.Endpoints.checkCoupon,
            body: [
                "coupon_code": couponCode,
                "uid": uid,
                "rest_id": restId,
                "amount": amount
            ]
        )
    }
    
    // MARK: - Payment APIs
    
    func getPaymentGateways() async throws -> PaymentResponse {
        return try await request(
            endpoint: Constants.Endpoints.paymentGateway,
            body: [:]
        )
    }
    
    // MARK: - Wallet APIs
    
    func getWalletReport(uid: String) async throws -> WalletResponse {
        return try await request(
            endpoint: Constants.Endpoints.walletReport,
            body: ["uid": uid]
        )
    }
    
    func activateWallet(uid: String, govId: String, govType: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.walletActivate,
            body: ["uid": uid, "gov_id": govId, "gov_type": govType]
        )
    }
    
    func addMoney(uid: String, amount: String, transactionId: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.walletUp,
            body: ["uid": uid, "wallet": amount, "transaction_id": transactionId]
        )
    }
    
    // MARK: - Profile APIs
    
    func getUserProfile(uid: String) async throws -> ProfileResponse {
        return try await request(
            endpoint: Constants.Endpoints.userProfile,
            body: ["uid": uid]
        )
    }
    
    func editProfile(uid: String, name: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.profileEdit,
            body: ["uid": uid, "name": name]
        )
    }
    
    func getReferralData(uid: String) async throws -> ReferralResponse {
        return try await request(
            endpoint: Constants.Endpoints.getData,
            body: ["uid": uid]
        )
    }
    
    // MARK: - Rating APIs
    
    func getRatingData(orderId: String) async throws -> RatingDataResponse {
        return try await request(
            endpoint: Constants.Endpoints.rateData,
            body: ["orderid": orderId]
        )
    }
    
    func submitRating(orderId: String, restRate: String, restText: String, riderRate: String, riderText: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.rateUpdate,
            body: [
                "orderid": orderId,
                "rest_rate": restRate,
                "rest_text": restText,
                "rider_rate": riderRate,
                "rider_text": riderText
            ]
        )
    }
    
    // MARK: - FAQ & Help APIs
    
    func getFaq() async throws -> FaqResponse {
        return try await request(
            endpoint: Constants.Endpoints.faq,
            body: [:]
        )
    }
    
    func getHelpPages() async throws -> HelpResponse {
        return try await request(
            endpoint: Constants.Endpoints.pageList,
            body: [:]
        )
    }
    
    // MARK: - Offer APIs
    
    func getOfferList() async throws -> OfferListResponse {
        return try await request(
            endpoint: Constants.Endpoints.offerList,
            body: [:]
        )
    }
    
    // MARK: - Subscription APIs
    
    func getSubscriptionPlans(restId: String) async throws -> SubscriptionPlansResponse {
        return try await request(
            endpoint: Constants.Endpoints.subscriptionPlans,
            body: ["rest_id": restId]
        )
    }
    
    // MARK: - Refund APIs
    
    func getRefundList(uid: String) async throws -> RefundListResponse {
        return try await request(
            endpoint: Constants.Endpoints.userRefundList,
            body: ["uid": uid]
        )
    }

    // MARK: - Dine-In APIs

    func getDineSettings(restId: String) async throws -> DineSettingsResponse {
        return try await request(
            endpoint: Constants.Endpoints.dineGetSettings,
            body: ["rest_id": restId]
        )
    }

    /// Phase-2 mock endpoint for Dine-In spotlight banners.
    func getDineInSpotlightBanners() async throws -> [HomeBannerItem] {
        try await Task.sleep(nanoseconds: 450_000_000)

        return [
            HomeBannerItem(
                bannerId: "spotlight_1",
                bannerTitle: "Weekend Chef Specials",
                bannerType: "dine_in",
                bannerImg: "https://picsum.photos/800/360?random=301",
                restaurantId: "101",
                restaurantName: "Dutch Coffee House",
                restaurantImage: nil,
                isClickable: "1"
            ),
            HomeBannerItem(
                bannerId: "spotlight_2",
                bannerTitle: "Live Music Night",
                bannerType: "dine_in",
                bannerImg: "https://picsum.photos/800/360?random=302",
                restaurantId: "102",
                restaurantName: "Skyline Bistro",
                restaurantImage: nil,
                isClickable: "1"
            ),
            HomeBannerItem(
                bannerId: "spotlight_3",
                bannerTitle: "Unlimited Brunch Buffet",
                bannerType: "dine_in",
                bannerImg: "https://picsum.photos/800/360?random=303",
                restaurantId: "103",
                restaurantName: "Olive Terrace",
                restaurantImage: nil,
                isClickable: "1"
            )
        ]
    }

    /// Phase-2 mock endpoint for Dine-In event/experience facilities.
    func getDineInFacilities() async throws -> [Facility] {
        try await Task.sleep(nanoseconds: 520_000_000)

        return [
            Facility(
                facilityId: "f_1",
                name: "Live Music",
                icon: "https://picsum.photos/320/220?random=401",
                description: "Evening performances and acoustic sessions",
                restaurantCount: "12"
            ),
            Facility(
                facilityId: "f_2",
                name: "Family Dining",
                icon: "https://picsum.photos/320/220?random=402",
                description: "Kid-friendly seating and menus",
                restaurantCount: "18"
            ),
            Facility(
                facilityId: "f_3",
                name: "Rooftop Seating",
                icon: "https://picsum.photos/320/220?random=403",
                description: "Open-air premium dining",
                restaurantCount: "8"
            ),
            Facility(
                facilityId: "f_4",
                name: "Fine Dining",
                icon: "https://picsum.photos/320/220?random=404",
                description: "Chef-curated tasting experiences",
                restaurantCount: "9"
            )
        ]
    }

    /// Phase-2 mock endpoint for Dine-In popular brands.
    func getPopularBrands() async throws -> [Restaurant] {
        try await Task.sleep(nanoseconds: 600_000_000)

        return [
            Restaurant(
                restId: "pb_1",
                restTitle: "Urban Tandoor",
                restImg: "https://picsum.photos/240/240?random=501",
                restRating: "4.6",
                restDeliverytime: "25 mins",
                restCostfortwo: "600",
                restIsVeg: 0,
                restDistance: "1.0"
            ),
            Restaurant(
                restId: "pb_2",
                restTitle: "Cedar Grill",
                restImg: "https://picsum.photos/240/240?random=502",
                restRating: "4.4",
                restDeliverytime: "30 mins",
                restCostfortwo: "700",
                restIsVeg: 1,
                restDistance: "1.7"
            ),
            Restaurant(
                restId: "pb_3",
                restTitle: "Mocha District",
                restImg: "https://picsum.photos/240/240?random=503",
                restRating: "4.8",
                restDeliverytime: "20 mins",
                restCostfortwo: "500",
                restIsVeg: 1,
                restDistance: "0.9"
            ),
            Restaurant(
                restId: "pb_4",
                restTitle: "Spice Junction",
                restImg: "https://picsum.photos/240/240?random=504",
                restRating: "4.5",
                restDeliverytime: "28 mins",
                restCostfortwo: "650",
                restIsVeg: 0,
                restDistance: "2.4"
            )
        ]
    }

    func bookDineTable(
        uid: String,
        restId: String,
        numberOfGuests: Int,
        visitingDate: String,
        mealType: String,
        bookingTime: String,
        customerName: String,
        customerPhone: String,
        customerEmail: String,
        specialRequest: String,
        transactionId: String
    ) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.dineBookTable,
            body: [
                "uid": uid,
                "rest_id": restId,
                "number_of_guests": numberOfGuests,
                "visiting_date": visitingDate,
                "meal_type": mealType,
                "booking_time": bookingTime,
                "customer_name": customerName,
                "customer_phone": customerPhone,
                "customer_email": customerEmail,
                "special_request": specialRequest,
                "transaction_id": transactionId
            ]
        )
    }

    // MARK: - Subscription Management APIs

    func createSubscriptionOrder(
        userId: String,
        planId: String,
        restId: String,
        startDate: String,
        transactionId: String?
    ) async throws -> GenericResponse {
        var payload: [String: Any] = [
            "user_id": Int(userId) ?? 0,
            "plan_id": Int(planId) ?? 0,
            "rest_id": Int(restId) ?? 0,
            "start_date": startDate
        ]
        if let transactionId, !transactionId.isEmpty {
            payload["txn_no"] = transactionId
        } else {
            payload["txn_no"] = NSNull()
        }

        return try await request(
            endpoint: Constants.Endpoints.subscriptionOrder,
            body: payload
        )
    }

    func getUserSubscriptions(userId: String) async throws -> MySubscriptionsResponse {
        return try await request(
            endpoint: Constants.Endpoints.userSubscription,
            body: ["user_id": userId]
        )
    }

    func skipMeal(userId: String, orderId: String, mealId: String, mealType: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.skipMeal,
            body: [
                "user_id": userId,
                "order_id": orderId,
                "meal_id": mealId,
                "meal_type": mealType
            ]
        )
    }

    func requestHoliday(userId: String, orderId: String, requestedDate: String, reason: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.requestHoliday,
            body: [
                "user_id": userId,
                "order_id": orderId,
                "requested_date": requestedDate,
                "reason": reason
            ]
        )
    }

    func getHolidayRequests(userId: String) async throws -> HolidayRequestsResponse {
        return try await request(
            endpoint: Constants.Endpoints.holidayRequests,
            body: ["user_id": userId]
        )
    }

    func getSubscriptionBanners() async throws -> SubscriptionBannerResponse {
        return try await request(
            endpoint: Constants.Endpoints.subscriptionBanners,
            method: "GET"
        )
    }

    // MARK: - Rewards OTP APIs

    func sendCorporateOtp(email: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.corporateCashbackSendOtp,
            body: ["email": email]
        )
    }

    func verifyCorporateOtp(email: String, otp: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.corporateCashbackVerifyOtp,
            body: ["email": email, "otp": otp]
        )
    }

    func sendStudentOtp(email: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.studentCashbackSendOtp,
            body: ["email": email]
        )
    }

    func verifyStudentOtp(email: String, otp: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.studentCashbackVerifyOtp,
            body: ["email": email, "otp": otp]
        )
    }

    // MARK: - Membership Service APIs

    func getMembershipPlans() async throws -> MembershipPlansResponse {
        return try await request(
            endpoint: Constants.Endpoints.membershipPlans,
            method: "GET"
        )
    }

    func purchaseMembership(userId: String, planId: String, transactionId: String?) async throws -> GenericResponse {
        var body: [String: Any] = [
            "user_id": userId,
            "plan_id": planId
        ]
        if let txId = transactionId {
            body["transaction_id"] = txId
        }
        return try await request(
            endpoint: Constants.Endpoints.purchaseMembership,
            body: body
        )
    }

    func checkUserMembership(userId: String) async throws -> CheckUserMembershipResponse {
        return try await request(
            endpoint: Constants.Endpoints.checkUserMembership,
            body: ["user_id": userId]
        )
    }

    func getMembershipHistory(userId: String) async throws -> MembershipHistoryResponse {
        return try await request(
            endpoint: Constants.Endpoints.membershipHistory,
            body: ["user_id": userId]
        )
    }

    func cancelMembership(userId: String, orderId: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.cancelMembership,
            body: [
                "user_id": userId,
                "order_id": orderId
            ]
        )
    }

    // MARK: - SBI Payment / Wallet integrations

    func sbiAddMoney(userId: String, amount: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.sbiAddMoney,
            body: [
                "user_id": userId,
                "amount": amount
            ]
        )
    }

    func sbiPaymentVerify(userId: String, paymentId: String, orderId: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.sbiPaymentVerify,
            body: [
                "user_id": userId,
                "payment_id": paymentId,
                "order_id": orderId
            ]
        )
    }

    // MARK: - Miscellaneous

    func getGuestHomeBanners() async throws -> HomeBannerResponse {
        return try await request(
            endpoint: Constants.Endpoints.homeBanners,
            method: "POST"
        )
    }

    func verifyCoupon(userId: String, couponId: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.verifyCoupon,
            body: [
                "user_id": userId,
                "coupon_id": couponId
            ]
        )
    }

    func getRestaurantRegisterLink() async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.registerRestaurantLink,
            method: "GET"
        )
    }

    func trackOfferClick(userId: String, offerId: String) async throws -> GenericResponse {
        return try await request(
            endpoint: Constants.Endpoints.trackOfferClick,
            body: [
                "user_id": userId,
                "offer_id": offerId
            ]
        )
    }

    func getRestaurantOffer(restId: String) async throws -> GenericResponse {
        let endpoint = Constants.Endpoints.restaurantOffer(restId: restId)
        return try await request(
            endpoint: endpoint,
            method: "GET"
        )
    }
}
