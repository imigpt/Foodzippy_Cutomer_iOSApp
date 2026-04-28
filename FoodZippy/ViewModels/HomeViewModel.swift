// HomeViewModel.swift
// Handles home screen data loading, filtering, and state

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Data
    @Published var banners: [BannerItem] = []
    @Published var categories: [CategoryItem] = []
    @Published var allRestaurants: [Restaurant] = []
    @Published var filteredRestaurants: [Restaurant] = []
    @Published var popularRestaurants: [Restaurant] = []
    @Published var importantRestaurants: [Restaurant] = []
    @Published var zippyCafeItems: [ZippyCafeItem] = []
    @Published var zippyCafeRestaurants: [Restaurant] = []
    @Published var homeBanners: [HomeBannerItem] = []
    @Published var homeOffers: [HomeOffer] = []
    @Published var servicesBanner: ServicesBannerItem?
    @Published var offerPopup: OfferPopup?
    @Published var spotlightBanners: [HomeBannerItem] = []
    @Published var facilities: [Facility] = []
    @Published var popularBrands: [Restaurant] = []
    
    // MARK: - UI State
    @Published var isLoading = true
    @Published var isLoadingDineIn = false
    @Published var isRefreshing = false
    @Published var showOfferPopup = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var dineInErrorMessage = ""
    
    // MARK: - Filters
    @Published var selectedCategory: String? = nil
    @Published var vegOnly = false
    @Published var openNow = false
    @Published var hasOffers = false
    @Published var sortBy: SortOption = .relevance
    @Published var searchQuery = ""
    
    enum SortOption: String, CaseIterable {
        case relevance = "Relevance"
        case rating = "Rating"
        case deliveryTime = "Delivery Time"
        case costLowToHigh = "Cost: Low to High"
        case costHighToLow = "Cost: High to Low"
        case distance = "Distance"
    }
    
    // MARK: - Popular Tab
    enum PopularTab: String, CaseIterable {
        case topRated = "Top Rated"
        case fast = "10 Mins"
        case zippyCafe = "ZippyCafe"
    }
    @Published var selectedPopularTab: PopularTab = .topRated
    
    var displayedPopularRestaurants: [Restaurant] {
        switch selectedPopularTab {
        case .topRated:
            return popularRestaurants.sorted { ($0.ratingDouble) > ($1.ratingDouble) }
        case .fast:
            return popularRestaurants.filter { $0.deliveryTimeMinutes <= 10 }
        case .zippyCafe:
            return zippyCafeRestaurants
        }
    }
    
    // MARK: - Load Home Data
    
    func loadHomeData() async {
        let session = SessionManager.shared
        let uid = session.currentUser?.id?.stringValue ?? "0"
        let lat = session.currentAddress?.latMap ?? LocationManager.shared.latitude
        let lng = session.currentAddress?.longMap ?? LocationManager.shared.longitude
        
        isLoading = true
        
        do {
            let response = try await APIService.shared.getHomeData(uid: uid, lat: lat, lng: lng)
            
            if response.isSuccess, let data = response.homeData {
                // Save main config
                if let mainData = data.mainData {
                    session.saveMainData(mainData)
                }
                
                banners = data.banner ?? []
                categories = data.catlist ?? []
                allRestaurants = data.restuarantData ?? []
                popularRestaurants = data.popularRestuarant ?? []
                importantRestaurants = data.importantRestaurant ?? []
                zippyCafeItems = data.zippyCafe ?? []
                zippyCafeRestaurants = zippyCafeItems.compactMap { $0.asRestaurant() }
                
                applyFilters()
            }
            
            // Load additional data in parallel
            async let bannersTask: () = loadHomeBanners()
            async let offersTask: () = loadHomeOffers()
            async let serviceTask: () = loadServicesBanner()
            async let popupTask: () = loadOfferPopup()
            
            _ = await (bannersTask, offersTask, serviceTask, popupTask)
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func refresh() async {
        isRefreshing = true
        async let homeTask: () = loadHomeData()
        async let dineInTask: () = loadDineInData()
        _ = await (homeTask, dineInTask)
        isRefreshing = false
    }

    // MARK: - Dine-In Phase 2 Data

    func loadDineInData() async {
        isLoadingDineIn = true
        dineInErrorMessage = ""

        async let spotlightTask = fetchSpotlightBannersSafely()
        async let facilitiesTask = fetchFacilitiesSafely()
        async let brandsTask = fetchPopularBrandsSafely()

        let (spotlightResult, facilitiesResult, brandsResult) = await (spotlightTask, facilitiesTask, brandsTask)

        spotlightBanners = spotlightResult.data
        facilities = facilitiesResult.data
        popularBrands = brandsResult.data

        let errors = [spotlightResult.error, facilitiesResult.error, brandsResult.error]
            .compactMap { $0?.localizedDescription }

        if !errors.isEmpty {
            // Keep UI functional with partial data while surfacing a non-fatal error.
            dineInErrorMessage = errors.joined(separator: "\n")
        }

        isLoadingDineIn = false
    }

    private func fetchSpotlightBannersSafely() async -> SectionLoadResult<HomeBannerItem> {
        do {
            return SectionLoadResult(data: try await APIService.shared.getDineInSpotlightBanners(), error: nil)
        } catch {
            return SectionLoadResult(data: [], error: error)
        }
    }

    private func fetchFacilitiesSafely() async -> SectionLoadResult<Facility> {
        do {
            return SectionLoadResult(data: try await APIService.shared.getDineInFacilities(), error: nil)
        } catch {
            return SectionLoadResult(data: [], error: error)
        }
    }

    private func fetchPopularBrandsSafely() async -> SectionLoadResult<Restaurant> {
        do {
            return SectionLoadResult(data: try await APIService.shared.getPopularBrands(), error: nil)
        } catch {
            return SectionLoadResult(data: [], error: error)
        }
    }
    
    // MARK: - Load Additional Data
    
    private func loadHomeBanners() async {
        do {
            let response = try await APIService.shared.getHomeBanners()
            homeBanners = response.bannerData ?? []
        } catch {
            print("Failed to load home banners: \(error)")
        }
    }
    
    private func loadHomeOffers() async {
        do {
            let response = try await APIService.shared.getHomeOffers()
            homeOffers = response.offers ?? []
        } catch {
            print("Failed to load home offers: \(error)")
        }
    }
    
    private func loadServicesBanner() async {
        do {
            let response = try await APIService.shared.getServicesBanner()
            servicesBanner = response.bannerData?.first
        } catch {
            print("Failed to load services banner: \(error)")
        }
    }
    
    private func loadOfferPopup() async {
        let uid = SessionManager.shared.currentUser?.id?.stringValue ?? "0"
        do {
            let response = try await APIService.shared.getOfferPopup(uid: uid)
            if let popup = response.offerPopup {
                offerPopup = popup
                showOfferPopup = true
            }
        } catch {
            print("Failed to load offer popup: \(error)")
        }
    }
    
    // MARK: - Category Filter
    
    func selectCategory(_ catId: String?) async {
        selectedCategory = catId
        
        if let catId = catId {
            isLoading = true
            let lat = SessionManager.shared.currentAddress?.latMap ?? LocationManager.shared.latitude
            let lng = SessionManager.shared.currentAddress?.longMap ?? LocationManager.shared.longitude
            
            do {
                let response = try await APIService.shared.getCategoryData(catId: catId, lat: lat, lng: lng)
                if let restaurants = response.restuarantData {
                    filteredRestaurants = restaurants
                }
            } catch {
                print("Category filter error: \(error)")
            }
            isLoading = false
        } else {
            applyFilters()
        }
    }
    
    // MARK: - Apply Filters
    
    func applyFilters() {
        var result = allRestaurants
        
        // Search filter
        if !searchQuery.isEmpty {
            result = result.filter {
                ($0.restTitle ?? "").localizedCaseInsensitiveContains(searchQuery) ||
                ($0.restSdesc ?? "").localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // Veg filter
        if vegOnly {
            result = result.filter { $0.isVeg }
        }
        
        // Open now filter
        if openNow {
            result = result.filter { $0.isOpen }
        }
        
        // Offers filter
        if hasOffers {
            result = result.filter {
                ($0.couTitle != nil && !($0.couTitle?.isEmpty ?? true))
            }
        }
        
        // Sort
        switch sortBy {
        case .relevance:
            break
        case .rating:
            result.sort { $0.ratingDouble > $1.ratingDouble }
        case .deliveryTime:
            result.sort { $0.deliveryTimeMinutes < $1.deliveryTimeMinutes }
        case .costLowToHigh:
            result.sort { ($0.restCostfortwo ?? "0").doubleValue < ($1.restCostfortwo ?? "0").doubleValue }
        case .costHighToLow:
            result.sort { ($0.restCostfortwo ?? "0").doubleValue > ($1.restCostfortwo ?? "0").doubleValue }
        case .distance:
            result.sort { $0.distanceKm < $1.distanceKm }
        }
        
        filteredRestaurants = result
    }
}

private struct SectionLoadResult<T> {
    let data: [T]
    let error: Error?
}
extension ZippyCafeItem {
    func asRestaurant() -> Restaurant? {
        return Restaurant(
            restId: restaurantId ?? foodId,
            restTitle: foodName,
            restImg: foodImage,
            restRating: rating,
            restDeliverytime: "15-20 mins", // Default for Cafe
            restCostfortwo: newPrice,
            restIsVeg: (isVeg == "1" || isVeg == "true") ? 1 : 0,
            restDistance: "0.5 km",
            restIsOpen: 1
        )
    }
}

