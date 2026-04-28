// HomeModels.swift
// Home screen data models matching Android Home.java, HomeData.java, etc.

import Foundation

// MARK: - Home Response
struct HomeResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let homeData: HomeData?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case homeData = "HomeData"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

struct HomeData: Codable {
    let total: Int?
    let mainData: MainData?
    let banner: [BannerItem]?
    let catlist: [CategoryItem]?
    let restuarantData: [Restaurant]?
    let popularRestuarant: [Restaurant]?
    let importantRestaurant: [Restaurant]?
    let zippyCafe: [ZippyCafeItem]?
    
    enum CodingKeys: String, CodingKey {
        case total
        case mainData = "Main_Data"
        case banner = "Banner"
        case catlist = "Catlist"
        case restuarantData = "restuarant_data"
        case popularRestuarant = "popular_restuarant"
        case importantRestaurant = "ImportantRestaurant"
        case zippyCafe = "ZippyCafe"
    }
}

// MARK: - Zippy Cafe Item
struct ZippyCafeItem: Codable, Identifiable {
    var id: String { foodId ?? UUID().uuidString }
    
    let foodId: String?
    let foodName: String?
    let foodImage: String?
    let oldPrice: String?
    let newPrice: String?
    let rating: String?
    let reviews: String?
    let restaurantName: String?
    let restaurantId: String?
    let isVeg: String?
    
    enum CodingKeys: String, CodingKey {
        case foodId = "id"
        case foodName = "name"
        case foodImage = "image"
        case oldPrice = "old_price"
        case newPrice = "new_price"
        case rating, reviews
        case restaurantName = "restaurant_name"
        case restaurantId = "restaurant_id"
        case isVeg = "is_veg"
    }
}

// MARK: - Main Data (App Config from backend)
struct MainData: Codable {
    let id: String?
    let currency: String?
    let tax: String?
    let isTax: Int?
    let tip: String?
    let isTip: Int?
    let webname: String?
    let weblogo: String?
    let wname: String?
    let oneKey: String?
    let oneHash: String?
    let dKey: String?
    let dHash: String?
    let timezone: String?
    let rcredit: String?
    let scredit: String?
    let pdboy: String?
    let pstore: String?
    let isDmode: String?
    let snote: String?
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case id, currency, tax, tip, webname, weblogo, wname, timezone, rcredit, scredit, pdboy, pstore, note
        case isTax = "is_tax"
        case isTip = "is_tip"
        case oneKey = "one_key"
        case oneHash = "one_hash"
        case dKey = "d_key"
        case dHash = "d_hash"
        case isDmode = "is_dmode"
        case snote = "s_note"
    }
}

// MARK: - Banner
struct BannerItem: Codable, Identifiable {
    var id: String { bannerId ?? UUID().uuidString }
    
    let bannerId: String?
    let bannerTitle: String?
    let bannerType: String?
    let bannerImg: String?
    let restaurantId: String?
    let restaurantName: String?
    let isClickable: String?
    
    enum CodingKeys: String, CodingKey {
        case bannerId = "banner_id"
        case bannerTitle = "banner_title"
        case bannerType = "banner_type"
        case bannerImg = "banner_img"
        case restaurantId = "restaurant_id"
        case restaurantName = "restaurant_name"
        case isClickable = "is_clickable"
    }
    
    var clickable: Bool { isClickable == "1" }
}

// MARK: - Category
struct CategoryItem: Codable, Identifiable {
    var id: String { catId ?? UUID().uuidString }
    
    let catId: String?
    let title: String?
    let catImg: String?
    
    enum CodingKeys: String, CodingKey {
        case catId = "cat_id"
        case title
        case catImg = "cat_img"
    }
}

// MARK: - Home Banner (Slider)
struct HomeBannerItem: Codable, Identifiable {
    var id: String { bannerId ?? UUID().uuidString }
    
    let bannerId: String?
    let bannerTitle: String?
    let bannerType: String?
    let bannerImg: String?
    let restaurantId: String?
    let restaurantName: String?
    let restaurantImage: String?
    let isClickable: String?
    
    enum CodingKeys: String, CodingKey {
        case bannerId = "banner_id"
        case bannerTitle = "banner_title"
        case bannerType = "banner_type"
        case bannerImg = "banner_img"
        case restaurantId = "restaurant_id"
        case restaurantName = "restaurant_name"
        case restaurantImage = "restaurant_image"
        case isClickable = "is_clickable"
    }
}

struct HomeBannerResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let bannerData: [HomeBannerItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case bannerData = "BannerData"
    }
}

// MARK: - Home Offer
struct HomeOffer: Codable, Identifiable {
    var id: String { offerId ?? UUID().uuidString }
    
    let offerId: String?
    let title: String?
    let subtitle: String?
    let discountText: String?
    let offerImg: String?
    let offerType: String?
    let actionType: String?
    let typeId: String?
    let externalLink: String?
    let targetData: String?
    let displayOrder: String?
    
    enum CodingKeys: String, CodingKey {
        case offerId = "offer_id"
        case title, subtitle
        case discountText = "discount_text"
        case offerImg = "offer_img"
        case offerType = "offer_type"
        case actionType = "action_type"
        case typeId = "type_id"
        case externalLink = "external_link"
        case targetData = "target_data"
        case displayOrder = "display_order"
    }
}

struct HomeOfferResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let offers: [HomeOffer]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case offers = "HomeOffers"
    }
}

// MARK: - Offer Popup
struct OfferPopup: Codable {
    let offerId: String?
    let title: String?
    let subtitle: String?
    let offerImg: String?
    let actionType: String?
    let typeId: String?
    
    enum CodingKeys: String, CodingKey {
        case offerId = "offer_id"
        case title, subtitle
        case offerImg = "offer_img"
        case actionType = "action_type"
        case typeId = "type_id"
    }
}

struct OfferPopupResponse: Codable {
    let responseCode: String?
    let result: String?
    let offerPopup: OfferPopup?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case offerPopup = "OfferPopup"
    }
}

// MARK: - Services Banner
struct ServicesBannerItem: Codable, Identifiable {
    var id: String { bannerId ?? UUID().uuidString }
    
    let bannerId: String?
    let bannerTitle: String?
    let bannerImg: String?
    let bannerType: String?
    let videoUrl: String?
    let isVideo: Int?
    let restaurantId: String?
    let isClickable: String?
    
    enum CodingKeys: String, CodingKey {
        case bannerId = "banner_id"
        case bannerTitle = "banner_title"
        case bannerImg = "banner_img"
        case bannerType = "banner_type"
        case videoUrl = "video_url"
        case isVideo = "is_video"
        case restaurantId = "restaurant_id"
        case isClickable = "is_clickable"
    }
}

struct ServicesBannerResponse: Codable {
    let responseCode: String?
    let result: String?
    let bannerData: [ServicesBannerItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case bannerData = "BannerData"
    }
}

// MARK: - Facility
struct Facility: Codable, Identifiable {
    var id: String { facilityId ?? UUID().uuidString }
    
    let facilityId: String?
    let name: String?
    let icon: String?
    let description: String?
    let restaurantCount: String?
    
    enum CodingKeys: String, CodingKey {
        case facilityId = "id"
        case name, icon, description
        case restaurantCount = "restaurant_count"
    }
}

struct FacilityResponse: Codable {
    let responseCode: String?
    let result: String?
    let facilities: [Facility]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case result = "Result"
        case facilities = "FacilityList"
    }
}
