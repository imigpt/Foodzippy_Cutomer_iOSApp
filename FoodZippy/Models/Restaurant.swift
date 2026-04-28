// Restaurant.swift
// Restaurant models matching Android Restorent.java, RestaurantData.java, etc.

import Foundation

struct Restaurant: Codable, Identifiable {
    var id: String { restId ?? UUID().uuidString }
    
    let restId: String?
    let restTitle: String?
    let restImg: String?
    let restImg1: String?
    let restImg2: String?
    let restImg3: String?
    let restLogo: String?
    let restRating: String?
    let restDeliverytime: String?
    let restCostfortwo: String?
    let restIsVeg: Int?
    let restFullAddress: String?
    let restLandmark: String?
    let restMobile: String?
    let restLats: String?
    let restLongs: String?
    let restCharge: String?
    let restLicence: String?
    let restDcharge: String?
    let restMorder: String?
    let restIsOpen: Int?
    let restIsDeliver: Int?
    let restSdesc: String?
    let restDistance: String?
    let isFavourite: Int?
    let couTitle: String?
    let couSubtitle: String?
    let isPreorder: Int?
    let openTime: String?
    let closeTime: String?
    let deliveryTypes: [String]?
    let deliveryTypesLabels: [DeliveryTypeLabel]?
    
    enum CodingKeys: String, CodingKey {
        case restId = "rest_id"
        case restTitle = "rest_title"
        case restImg = "rest_img"
        case restImg1 = "rest_img1"
        case restImg2 = "rest_img2"
        case restImg3 = "rest_img3"
        case restLogo = "rest_logo"
        case restRating = "rest_rating"
        case restDeliverytime = "rest_deliverytime"
        case restCostfortwo = "rest_costfortwo"
        case restIsVeg = "rest_is_veg"
        case restFullAddress = "rest_full_address"
        case restLandmark = "rest_landmark"
        case restMobile = "rest_mobile"
        case restLats = "rest_lats"
        case restLongs = "rest_longs"
        case restCharge = "rest_charge"
        case restLicence = "rest_licence"
        case restDcharge = "rest_dcharge"
        case restMorder = "rest_morder"
        case restIsOpen = "rest_is_open"
        case restIsDeliver = "rest_is_deliver"
        case restSdesc = "rest_sdesc"
        case restDistance = "rest_distance"
        case isFavourite = "IS_FAVOURITE"
        case couTitle = "cou_title"
        case couSubtitle = "cou_subtitle"
        case isPreorder = "is_preorder"
        case openTime = "open_time"
        case closeTime = "close_time"
        case deliveryTypes = "delivery_types"
        case deliveryTypesLabels = "delivery_types_labels"
    }
    
    var isOpen: Bool { restIsOpen == 1 }
    var isVeg: Bool { restIsVeg == 1 }
    var canPreorder: Bool { isPreorder == 1 }
    var isFav: Bool { isFavourite == 1 }
    
    var ratingDouble: Double {
        Double(restRating ?? "0") ?? 0
    }
    
    var deliveryTimeMinutes: Int {
        guard let time = restDeliverytime else { return 0 }
        let digits = time.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(digits) ?? 0
    }
    
    var distanceKm: Double {
        guard let dist = restDistance else { return 0 }
        let cleaned = dist.replacingOccurrences(of: " km", with: "")
            .replacingOccurrences(of: " Km", with: "")
            .replacingOccurrences(of: "km", with: "")
        return Double(cleaned) ?? 0
    }

    init(
        restId: String?,
        restTitle: String?,
        restImg: String?,
        restImg1: String?,
        restImg2: String?,
        restImg3: String?,
        restLogo: String?,
        restRating: String?,
        restDeliverytime: String?,
        restCostfortwo: String?,
        restIsVeg: Int?,
        restFullAddress: String?,
        restLandmark: String?,
        restMobile: String?,
        restLats: String?,
        restLongs: String?,
        restCharge: String?,
        restLicence: String?,
        restDcharge: String?,
        restMorder: String?,
        restIsOpen: Int?,
        restIsDeliver: Int?,
        restSdesc: String?,
        restDistance: String?,
        isFavourite: Int?,
        couTitle: String?,
        couSubtitle: String?,
        isPreorder: Int?,
        openTime: String?,
        closeTime: String?,
        deliveryTypes: [String]?,
        deliveryTypesLabels: [DeliveryTypeLabel]?
    ) {
        self.restId = restId
        self.restTitle = restTitle
        self.restImg = restImg
        self.restImg1 = restImg1
        self.restImg2 = restImg2
        self.restImg3 = restImg3
        self.restLogo = restLogo
        self.restRating = restRating
        self.restDeliverytime = restDeliverytime
        self.restCostfortwo = restCostfortwo
        self.restIsVeg = restIsVeg
        self.restFullAddress = restFullAddress
        self.restLandmark = restLandmark
        self.restMobile = restMobile
        self.restLats = restLats
        self.restLongs = restLongs
        self.restCharge = restCharge
        self.restLicence = restLicence
        self.restDcharge = restDcharge
        self.restMorder = restMorder
        self.restIsOpen = restIsOpen
        self.restIsDeliver = restIsDeliver
        self.restSdesc = restSdesc
        self.restDistance = restDistance
        self.isFavourite = isFavourite
        self.couTitle = couTitle
        self.couSubtitle = couSubtitle
        self.isPreorder = isPreorder
        self.openTime = openTime
        self.closeTime = closeTime
        self.deliveryTypes = deliveryTypes
        self.deliveryTypesLabels = deliveryTypesLabels
    }

    init(
        restId: String?,
        restTitle: String?,
        restImg: String?,
        restRating: String? = nil,
        restDeliverytime: String? = nil,
        restCostfortwo: String? = nil,
        restIsVeg: Int? = nil,
        restDistance: String? = nil,
        restIsOpen: Int? = 1
    ) {
        self.restId = restId
        self.restTitle = restTitle
        self.restImg = restImg
        self.restImg1 = nil
        self.restImg2 = nil
        self.restImg3 = nil
        self.restLogo = nil
        self.restRating = restRating
        self.restDeliverytime = restDeliverytime
        self.restCostfortwo = restCostfortwo
        self.restIsVeg = restIsVeg
        self.restFullAddress = nil
        self.restLandmark = nil
        self.restMobile = nil
        self.restLats = nil
        self.restLongs = nil
        self.restCharge = nil
        self.restLicence = nil
        self.restDcharge = nil
        self.restMorder = nil
        self.restIsOpen = restIsOpen
        self.restIsDeliver = nil
        self.restSdesc = nil
        self.restDistance = restDistance
        self.isFavourite = 0
        self.couTitle = nil
        self.couSubtitle = nil
        self.isPreorder = nil
        self.openTime = nil
        self.closeTime = nil
        self.deliveryTypes = nil
        self.deliveryTypesLabels = nil
    }
}

struct DeliveryTypeLabel: Codable {
    let type: String?
    let label: String?
    let icon: String?
}

// MARK: - Restaurant List Responses

struct RestaurantListResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let restuarantData: [Restaurant]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case restuarantData = "restuarant_data"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

// MARK: - Restaurant Detail

struct RestaurantDetailResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let restData: RestaurantDetailData?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case restData = "RestData"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

struct RestaurantDetailData: Codable {
    let catlist: [CategoryItem]?
    let productData: [ProductCategory]?
    let restuarantData: [Restaurant]?
    let galleryData: [GalleryImage]?
    let reviewData: [Review]?
    let menuImages: [String]?
    let menuitemData: [MenuItem]?
    let offersData: [OffersDatum]?
    let coupon: [CouponItem]?
    
    enum CodingKeys: String, CodingKey {
        case catlist = "Catlist"
        case productData = "Product_Data"
        case restuarantData = "restuarant_data"
        case galleryData = "Gallery_Data"
        case reviewData = "Review_Data"
        case menuImages = "Menu_Images"
        case menuitemData = "Menuitem_Data"
        case offersData = "Offers_Data"
        case coupon = "Coupon"
    }
}

struct OffersDatum: Codable, Identifiable {
    var id: String { offerId ?? UUID().uuidString }
    
    let offerId: String?
    let restId: String?
    let title: String?
    let description: String?
    let image: String?
    let startDate: String?
    let endDate: String?
    let isGlobal: Int?
    
    enum CodingKeys: String, CodingKey {
        case offerId = "id"
        case restId = "rest_id"
        case title, description, image
        case startDate = "start_date"
        case endDate = "end_date"
        case isGlobal = "is_global"
    }
}

struct GalleryImage: Codable, Identifiable {
    var id: String { img ?? UUID().uuidString }
    let img: String?
}

struct Review: Codable, Identifiable {
    var id: String { UUID().uuidString }
    let userName: String?
    let userImg: String?
    let rating: String?
    let review: String?
    let rdate: String?
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case userImg = "user_img"
        case rating, review, rdate
    }
}

// MARK: - Favourite

struct FavouriteResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let favList: [Restaurant]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case favList = "FavouriteList"
    }
}
