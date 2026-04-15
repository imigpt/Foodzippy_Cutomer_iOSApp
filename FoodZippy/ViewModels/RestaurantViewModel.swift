// RestaurantViewModel.swift
// Handles restaurant detail, menu display, and product interactions

import Foundation

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var restaurant: Restaurant?
    @Published var productCategories: [ProductCategory] = []
    @Published var gallery: [GalleryImage] = []
    @Published var reviews: [Review] = []
    @Published var offers: [RestaurantOffer] = []
    
    @Published var isLoading = true
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isFavourite = false
    @Published var vegOnly = false
    
    var filteredCategories: [ProductCategory] {
        if vegOnly {
            return productCategories.compactMap { category in
                let filteredItems = category.menuitemData?.filter { $0.isVegetarian } ?? []
                if filteredItems.isEmpty { return nil }
                return ProductCategory(
                    catId: category.catId,
                    title: category.title,
                    menuitemData: filteredItems
                )
            }
        }
        return productCategories
    }
    
    var totalMenuItems: Int {
        productCategories.reduce(0) { $0 + ($1.menuitemData?.count ?? 0) }
    }
    
    // MARK: - Load Restaurant Detail
    
    func loadRestaurant(restId: String) async {
        isLoading = true
        let session = SessionManager.shared
        let uid = session.currentUser?.id ?? "0"
        let lat = session.currentAddress?.latMap ?? LocationManager.shared.latitude
        let lng = session.currentAddress?.longMap ?? LocationManager.shared.longitude
        
        do {
            let response = try await APIService.shared.getRestaurantDetail(
                restId: restId, uid: uid, lat: lat, lng: lng
            )
            
            if response.isSuccess, let data = response.restData {
                restaurant = data.restuarantData?.first
                productCategories = data.productData ?? []
                gallery = data.galleryData ?? []
                reviews = data.reviewData ?? []
                isFavourite = restaurant?.isFav ?? false
                
                // Save restaurant context
                session.restaurantId = restId
                session.restaurantName = restaurant?.restTitle ?? ""
                session.deliveryCharge = restaurant?.restDcharge ?? "0"
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Toggle Favourite
    
    func toggleFavourite() async {
        guard let restId = restaurant?.restId,
              let uid = SessionManager.shared.currentUser?.id else { return }
        
        isFavourite.toggle()
        
        do {
            _ = try await APIService.shared.toggleFavourite(restId: restId, uid: uid)
        } catch {
            isFavourite.toggle() // Revert on failure
            print("Toggle favourite error: \(error)")
        }
    }
    
    // MARK: - Search Products
    
    func searchProducts(query: String) async {
        guard let restId = restaurant?.restId, !query.isEmpty else {
            return
        }
        
        do {
            let response = try await APIService.shared.searchProducts(restId: restId, query: query)
            if let data = response.restData {
                productCategories = data.productData ?? []
            }
        } catch {
            print("Search error: \(error)")
        }
    }
}
