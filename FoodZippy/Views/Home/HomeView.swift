// HomeView.swift
// Pixel-perfect match of reference screenshot:
// Deep purple gradient header with category tabs, search, CRAVE banner,
// yellow offer cards, filter row, horizontal restaurant cards.

import SwiftUI

// MARK: - Colour tokens (reference image)
// Additional imports
// (DishDetailSheetView and CustomisationSheetView are imported from Views)
extension Color {
    static let hPurpleDark   = Color(hex: "#3D13A4")
    static let hPurpleMid    = Color(hex: "#7B1FA2")
    static let hPurpleLight  = Color(hex: "#9C27B0")
    static let hYellow       = Color(hex: "#FFC107")
    static let hPink         = Color(hex: "#D81B60")
    static let hOrange       = Color(hex: "#FF5722")
    static let hGreen        = Color(hex: "#098430")
    static let hBg           = Color(hex: "#F5F5F5")
}

// MARK: - Root view

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var appState: AppState
    @State private var selectedRestaurant: Restaurant?
    @State private var navigateToRestaurant = false
    @State private var navigateToProfile = false
    @State private var navigateToRestaurantView = false
    @State private var navigateToDineIn = false
    @State private var navigateToFlash = false
    @State private var navigateToAddressList = false
    @State private var navigateToBuyOne = false
    @State private var navigateToPastBookings = false
    @State private var scrollResetToken = UUID()
    @State private var selectedDishForDetail: AddToCartDish?
    @State private var selectedDishForCustomization: AddToCartDish?
    @StateObject private var cartViewModel = AddToCartViewModel.shared
    @State private var selectedTopMode: HomeTopMode = .food
    private let topAnchorId = "home_top_anchor"
    
    private var topModeTheme: HomeTopModeTheme {
        selectedTopMode.theme
    }
    
    private var topPromoContent: HomeTopPromoContent {
        selectedTopMode.promo
    }
    
    private var sourceRestaurants: [Restaurant] {
        if !viewModel.displayedPopularRestaurants.isEmpty {
            return viewModel.displayedPopularRestaurants
        }
        if !viewModel.filteredRestaurants.isEmpty {
            return viewModel.filteredRestaurants
        }
        if !viewModel.allRestaurants.isEmpty {
            return viewModel.allRestaurants
        }
        return []
    }
    
    private var horizontalRestaurants: [HorizontalRestaurantListView.Restaurant] {
        if !sourceRestaurants.isEmpty {
            return sourceRestaurants.map { item in
                HorizontalRestaurantListView.Restaurant(
                    id: item.restId ?? UUID().uuidString,
                    name: item.restTitle ?? "Restaurant",
                    image: "burger",
                    offer: "\(horizontalOfferPrefix) ₹\(item.restCostfortwo ?? "99")",
                    rating: Double(item.restRating ?? "4.5") ?? 4.5,
                    deliveryTime: item.restDeliverytime ?? "15-20 mins",
                    category: item.restSdesc ?? "Snacks, Bakery",
                    isFavorite: item.isFav
                )
            }
        }
        
        switch selectedTopMode {
        case .food:
            return [
                HorizontalRestaurantListView.Restaurant(id: "demo-f-1", name: "Falahaar & Kitchen", image: "burger", offer: "AT ₹29", rating: 4.3, deliveryTime: "15-20 mins", category: "Snacks, Bakery", isFavorite: false),
                HorizontalRestaurantListView.Restaurant(id: "demo-f-2", name: "Shri Shyam Bakers", image: "burger", offer: "AT ₹129", rating: 4.5, deliveryTime: "10-15 mins", category: "Bakery, Fast Food", isFavorite: false),
                HorizontalRestaurantListView.Restaurant(id: "demo-f-3", name: "Burger Farm", image: "burger", offer: "AT ₹84", rating: 4.4, deliveryTime: "20-25 mins", category: "American, Burgers", isFavorite: true)
            ]
        case .takeAway:
            return [
                HorizontalRestaurantListView.Restaurant(id: "demo-t-1", name: "Pickup Point", image: "burger", offer: "PICKUP ₹49", rating: 4.4, deliveryTime: "Ready in 10 mins", category: "Combo, Snacks", isFavorite: false),
                HorizontalRestaurantListView.Restaurant(id: "demo-t-2", name: "Counter Express", image: "burger", offer: "PICKUP ₹89", rating: 4.3, deliveryTime: "Ready in 8 mins", category: "Wraps, Fast Food", isFavorite: false),
                HorizontalRestaurantListView.Restaurant(id: "demo-t-3", name: "Grab & Go Cafe", image: "burger", offer: "PICKUP ₹99", rating: 4.5, deliveryTime: "Ready in 12 mins", category: "Coffee, Bakery", isFavorite: true)
            ]
        case .dineIn:
            return [
                HorizontalRestaurantListView.Restaurant(id: "demo-d-1", name: "Royal Table", image: "burger", offer: "DINE ₹249", rating: 4.6, deliveryTime: "Book in 5 mins", category: "North Indian", isFavorite: false),
                HorizontalRestaurantListView.Restaurant(id: "demo-d-2", name: "Family Feast Hub", image: "burger", offer: "DINE ₹399", rating: 4.5, deliveryTime: "Seats Available", category: "Family Dining", isFavorite: false),
                HorizontalRestaurantListView.Restaurant(id: "demo-d-3", name: "Fine Dine Grill", image: "burger", offer: "DINE ₹299", rating: 4.7, deliveryTime: "Priority Booking", category: "Continental", isFavorite: true)
            ]
        case .driveThru:
            return [
                HorizontalRestaurantListView.Restaurant(id: "demo-dr-1", name: "Fast Lane Bites", image: "burger", offer: "LANE ₹99", rating: 4.2, deliveryTime: "5-10 mins", category: "Combos, Burgers", isFavorite: false),
                HorizontalRestaurantListView.Restaurant(id: "demo-dr-2", name: "Window Meals", image: "burger", offer: "LANE ₹79", rating: 4.1, deliveryTime: "4-8 mins", category: "Wraps, Fries", isFavorite: false),
                HorizontalRestaurantListView.Restaurant(id: "demo-dr-3", name: "Turbo Snacks", image: "burger", offer: "LANE ₹119", rating: 4.3, deliveryTime: "6-9 mins", category: "Quick Bites", isFavorite: true)
            ]
        }
    }
    
    private var horizontalOfferPrefix: String {
        switch selectedTopMode {
        case .food: return "AT"
        case .takeAway: return "PICKUP"
        case .dineIn: return "DINE"
        case .driveThru: return "LANE"
        }
    }
    
    private var searchBarPlaceholder: String {
        switch selectedTopMode {
        case .food: return "Search for 'EatRight'"
        case .takeAway: return "Search restaurants or cuisines"
        case .dineIn: return "Search restaurants or cuisines"
        case .driveThru: return "Search restaurants or cuisines"
        }
    }
    
    private var restaurantCards: [ExploreRestaurantListView.Restaurant] {
        switch selectedTopMode {
        case .food:
            return [
                ExploreRestaurantListView.Restaurant(id: "demo-1", name: "Burger Farm", image: "burger", offer: "₹84", rating: 4.5, reviews: "8.1K+", deliveryTime: "20–25 mins", cuisine: "American, Italian", location: "Jagatpura", distance: "0.9 km", isFavorite: false),
                ExploreRestaurantListView.Restaurant(id: "demo-2", name: "Theobroma", image: "burger", offer: "₹48", rating: 4.6, reviews: "168", deliveryTime: "10–15 mins", cuisine: "Bakery, Desserts", location: "Sector-23", distance: "0.1 km", isFavorite: false),
                ExploreRestaurantListView.Restaurant(id: "demo-3", name: "NBC - Nothing Before Coffee", image: "burger", offer: "₹69", rating: 4.4, reviews: "474", deliveryTime: "15–20 mins", cuisine: "Coffee, Fast Food, Cafe", location: "Jagatpura", distance: "0.1 km", isFavorite: true)
            ]
        case .takeAway:
            return [
                ExploreRestaurantListView.Restaurant(id: "demo-take-1", name: "Counter Express", image: "burger", offer: "₹99", rating: 4.3, reviews: "2.4K+", deliveryTime: "Ready in 10 mins", cuisine: "Grab & Go, Wraps", location: "Malviya Nagar", distance: "0.7 km", isFavorite: false),
                ExploreRestaurantListView.Restaurant(id: "demo-take-2", name: "Pickup Point", image: "burger", offer: "₹89", rating: 4.2, reviews: "1.1K+", deliveryTime: "Ready in 8 mins", cuisine: "Fast Food, Combos", location: "Jagatpura", distance: "0.3 km", isFavorite: false),
                ExploreRestaurantListView.Restaurant(id: "demo-take-3", name: "Bite Counter", image: "burger", offer: "₹79", rating: 4.4, reviews: "3.8K+", deliveryTime: "Ready in 12 mins", cuisine: "Snacks, Beverages", location: "Pratap Nagar", distance: "1.2 km", isFavorite: true)
            ]
        case .dineIn:
            return [
                ExploreRestaurantListView.Restaurant(id: "demo-dine-1", name: "Royal Table", image: "burger", offer: "₹249", rating: 4.6, reviews: "5.6K+", deliveryTime: "Book table in 5 mins", cuisine: "Fine Dining, North Indian", location: "C-Scheme", distance: "2.2 km", isFavorite: false),
                ExploreRestaurantListView.Restaurant(id: "demo-dine-2", name: "Family Feast Hall", image: "burger", offer: "₹399", rating: 4.5, reviews: "2.9K+", deliveryTime: "Seats Available", cuisine: "Family Dining, Multi Cuisine", location: "Vaishali Nagar", distance: "3.1 km", isFavorite: false),
                ExploreRestaurantListView.Restaurant(id: "demo-dine-3", name: "Chef's Room", image: "burger", offer: "₹299", rating: 4.7, reviews: "1.8K+", deliveryTime: "Priority Booking", cuisine: "Continental, Grill", location: "Bani Park", distance: "2.5 km", isFavorite: true)
            ]
        case .driveThru:
            return [
                ExploreRestaurantListView.Restaurant(id: "demo-drive-1", name: "Fast Lane Bites", image: "burger", offer: "₹119", rating: 4.2, reviews: "6.1K+", deliveryTime: "5–10 mins", cuisine: "Burgers, Combos", location: "Tonk Road", distance: "1.6 km", isFavorite: false),
                ExploreRestaurantListView.Restaurant(id: "demo-drive-2", name: "Window Meals", image: "burger", offer: "₹99", rating: 4.1, reviews: "3.4K+", deliveryTime: "4–8 mins", cuisine: "Wraps, Fries", location: "Airport Road", distance: "2.0 km", isFavorite: false),
                ExploreRestaurantListView.Restaurant(id: "demo-drive-3", name: "Turbo Stop", image: "burger", offer: "₹129", rating: 4.3, reviews: "4.7K+", deliveryTime: "6–9 mins", cuisine: "Quick Bites, Drinks", location: "JLN Marg", distance: "1.4 km", isFavorite: true)
            ]
        }
    }
    
    private var storeProducts: [Product] {
        switch selectedTopMode {
        case .food:
            return [
                Product(name: "Paneer Onion Pizza", image: "burger", price: 79, oldPrice: 160, rating: 4.1, ratingCount: 136, restaurant: "Crazy Pizza Hot", isVeg: true),
                Product(name: "Egg Curry", image: "burger", price: 69, oldPrice: 190, rating: 3.7, ratingCount: 158, restaurant: "The Royal Mult...", isVeg: false),
                Product(name: "Pyaz Kachori", image: "burger", price: 59, oldPrice: 60, rating: 4.2, ratingCount: 634, restaurant: "Rawat Mishth...", isVeg: true)
            ]
        case .takeAway:
            return [
                Product(name: "Pickup Combo Box", image: "burger", price: 99, oldPrice: 170, rating: 4.3, ratingCount: 201, restaurant: "Express Kitchen", isVeg: true),
                Product(name: "Grab Noodles", image: "burger", price: 89, oldPrice: 149, rating: 4.0, ratingCount: 165, restaurant: "TakeAway Hub", isVeg: false),
                Product(name: "Pocket Burger", image: "burger", price: 69, oldPrice: 120, rating: 4.1, ratingCount: 442, restaurant: "Bite Point", isVeg: true)
            ]
        case .dineIn:
            return [
                Product(name: "Signature Sizzler", image: "burger", price: 249, oldPrice: 349, rating: 4.5, ratingCount: 98, restaurant: "Royal Dine", isVeg: false),
                Product(name: "Family Platter", image: "burger", price: 399, oldPrice: 550, rating: 4.4, ratingCount: 144, restaurant: "Table Treats", isVeg: true),
                Product(name: "Chef Special Soup", image: "burger", price: 129, oldPrice: 199, rating: 4.2, ratingCount: 212, restaurant: "Fine Bowl", isVeg: true)
            ]
        case .driveThru:
            return [
                Product(name: "Drive Combo Meal", image: "burger", price: 129, oldPrice: 189, rating: 4.2, ratingCount: 335, restaurant: "Fast Lane Eats", isVeg: false),
                Product(name: "Quick Wrap", image: "burger", price: 79, oldPrice: 119, rating: 4.1, ratingCount: 271, restaurant: "Window Bites", isVeg: true),
                Product(name: "Turbo Fries", image: "burger", price: 59, oldPrice: 99, rating: 4.0, ratingCount: 390, restaurant: "Drive Spot", isVeg: true)
            ]
        }
    }
    
    private func showDishDetail(for product: Product) {
        let isCustomizable = true // Make products customizable for demo purposes
        let dish = AddToCartDish(
            id: product.id.uuidString,
            restaurantId: UUID().uuidString,
            restaurantName: product.restaurant,
            title: product.name,
            imageURL: product.image,
            description: "Delicious \(product.name) prepared fresh with high-quality ingredients.",
            basePrice: Double(product.price),
            oldPrice: Double(product.oldPrice ?? product.price),
            rating: product.rating,
            ratingCount: product.ratingCount,
            isVeg: product.isVeg,
            isCustomizable: isCustomizable,
            customisationOptions: isCustomizable ? [
                DishCustomisationOption(id: "half", title: "Half", additionalPrice: 0.0, isVeg: product.isVeg),
                DishCustomisationOption(id: "full", title: "Full", additionalPrice: 40.0, isVeg: product.isVeg)
            ] : []
        )
        selectedDishForDetail = dish
    }
    
    private func createMockRestaurant(from card: ExploreRestaurantListView.Restaurant) -> Restaurant {
        let costForTwo = card.offer.replacingOccurrences(of: "₹", with: "").trimmingCharacters(in: .whitespaces)
        return Restaurant(
            restId: card.id,
            restTitle: card.name,
            restImg: "burger",
            restImg1: nil,
            restImg2: nil,
            restImg3: nil,
            restLogo: "burger",
            restRating: String(format: "%.1f", card.rating),
            restDeliverytime: card.deliveryTime,
            restCostfortwo: costForTwo,
            restIsVeg: nil,
            restFullAddress: card.location,
            restLandmark: card.location,
            restMobile: nil,
            restLats: "26.9124",
            restLongs: "75.7873",
            restCharge: nil,
            restLicence: nil,
            restDcharge: nil,
            restMorder: nil,
            restIsOpen: nil,
            restIsDeliver: nil,
            restSdesc: card.cuisine,
            restDistance: card.distance,
            isFavourite: card.isFavorite ? 1 : 0,
            couTitle: nil,
            couSubtitle: nil,
            isPreorder: nil,
            openTime: nil,
            closeTime: nil,
            deliveryTypes: nil,
            deliveryTypesLabels: nil
        )
    }

    private var dineInNavigationRestaurant: Restaurant {
        selectedRestaurant ?? Restaurant(
            restId: "dine_in_default",
            restTitle: "Dine-In Restaurant",
            restImg: nil
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#E3F2FD"),
                        Color(hex: "#F8FAFB")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.container, edges: .top)
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: 0)
                                .id(topAnchorId)
                            
                            // ── Purple header block (gradient + tabs) ──────────────────
                            HeaderView(
                                viewModel: viewModel,
                                topSafeInset: geo.safeAreaInsets.top,
                                onAddressTap: { navigateToAddressList = true },
                                onProfileTap: { navigateToProfile = true },
                                onBuyOneTap: { navigateToBuyOne = true },
                                selectedMode: selectedTopMode,
                                theme: topModeTheme,
                                onTopTabSelected: { mode in
                                    selectedTopMode = mode
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        proxy.scrollTo(topAnchorId, anchor: .top)
                                    }
                                }
                            )
                            
                            // ── White content area ─────────────────────────────────────
                            VStack(spacing: 0) {
                                
                                SearchBarView(viewModel: viewModel, placeholder: searchBarPlaceholder)
                                    .padding(.horizontal, 12)
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                
                                BannerView(content: topPromoContent)
                                    .padding(.horizontal, 12)
                                    .padding(.top, 2)
                                    .padding(.bottom, 0)
                                
                                if selectedTopMode != .dineIn {
                                    // Offer text below banner (inside purple area continues)
                                    OfferTextRow(content: topPromoContent)
                                        .padding(.horizontal, 12)
                                        .padding(.top, 10)
                                    
                                    // 3 yellow offer cards
                                    OfferCardsRow(content: topPromoContent)
                                        .padding(.top, 12)
                                        .padding(.bottom, 14)
                                }
                            }
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        topModeTheme.promoStart,
                                        topModeTheme.promoEnd
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // ── White body ─────────────────────────────────────────────
                            VStack(spacing: 0) {
                                switch selectedTopMode {
                                case .food:
                                    // Filter chips (MIN Rs. 100 OFF / FAST DELIVERY)
                                    FilterRow(viewModel: viewModel)
                                        .padding(.top, 16)
                                        .padding(.bottom, 12)
                                    
                                    // Restaurant cards horizontal scroll
                                    HorizontalRestaurantListView(
                                        restaurants: horizontalRestaurants,
                                        onCardTap: { card in
                                            if let selected = sourceRestaurants.first(where: { ($0.restId ?? "") == card.id }) {
                                                selectedRestaurant = selected
                                                navigateToRestaurant = true
                                            }
                                        }
                                    )
                                    .padding(.bottom, 18)
                                    
                                    // Divider
                                    Rectangle()
                                        .fill(Color.hBg)
                                        .frame(height: 8)
                                    
                                    // Cuisines
                                    if !viewModel.categories.isEmpty {
                                        CuisinesSection(
                                            categories: viewModel.categories,
                                            selectedId: viewModel.selectedCategory,
                                            onSelect: { id in Task { await viewModel.selectCategory(id) } }
                                        )
                                        .padding(.bottom, 8)
                                    }
                                    
                                    Rectangle()
                                        .fill(Color.hBg)
                                        .frame(height: 8)
                                    
                                    // All Restaurants list
                                    AllRestaurantsSection(
                                        viewModel: viewModel,
                                        selectedMode: selectedTopMode,
                                        onOpenRestaurantView: {
                                            navigateToRestaurantView = true
                                        },
                                        onOpenFlash: {
                                            navigateToFlash = true
                                        },
                                        onShowDishDetail: { product in
                                            showDishDetail(for: product)
                                        }
                                    )
                                    .padding(.bottom, 24)
                                    
                                case .takeAway:
                                    // Take Away: Filter Chips + Restaurant Cards
                                    VStack(spacing: 0) {
                                        // Filter Chips - HomeView Style
                                        HStack(spacing: 0) {
                                            FilterChip(
                                                title: "📍 NEARBY",
                                                isActive: false,
                                                action: {}
                                            )
                                            
                                            FilterChip(
                                                title: "🕐 OPEN NOW",
                                                isActive: false,
                                                action: {}
                                            )
                                            
                                            FilterChip(
                                                title: "⚡ FAST PICKUP",
                                                isActive: false,
                                                action: {}
                                            )
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color(hex: "#F2F2F7"))
                                        )
                                        .padding(.horizontal, 12)
                                        .padding(.top, 16)
                                        .padding(.bottom, 12)
                                        
                                        // Divider
                                        Rectangle()
                                            .fill(Color.hBg)
                                            .frame(height: 8)
                                        
                                        // Restaurant Cards with Consistent Spacing
                                        VStack(alignment: .leading, spacing: 16) {
                                            Text("Quick Pickup Restaurants")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 16)
                                            
                                            VStack(spacing: 12) {
                                                ForEach(restaurantCards, id: \.id) { restaurant in
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        ZStack(alignment: .topTrailing) {
                                                            // Image
                                                            Image("burger")
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(height: 160)
                                                                .clipped()
                                                            
                                                            // Distance Badge
                                                            Text(restaurant.distance)
                                                                .font(.system(size: 11, weight: .bold))
                                                                .foregroundColor(.white)
                                                                .padding(.horizontal, 10)
                                                                .padding(.vertical, 6)
                                                                .background(.ultraThinMaterial)
                                                                .environment(\.colorScheme, .dark)
                                                                .cornerRadius(6)
                                                                .padding(10)
                                                        }
                                                        
                                                        VStack(alignment: .leading, spacing: 8) {
                                                            HStack {
                                                                Text(restaurant.name)
                                                                    .font(.system(size: 16, weight: .semibold))
                                                                    .foregroundColor(.black)
                                                                
                                                                Spacer()
                                                                
                                                                // Veg Indicator
                                                                ZStack {
                                                                    RoundedRectangle(cornerRadius: 3)
                                                                        .stroke(Color(hex: "#22A45D"), lineWidth: 1)
                                                                        .frame(width: 14, height: 14)
                                                                    
                                                                    Circle()
                                                                        .fill(Color(hex: "#22A45D"))
                                                                        .frame(width: 6, height: 6)
                                                                }
                                                            }
                                                            
                                                            HStack(spacing: 6) {
                                                                HStack(spacing: 2) {
                                                                    Image(systemName: "star.fill")
                                                                        .font(.system(size: 9))
                                                                    Text(String(format: "%.1f", restaurant.rating))
                                                                        .font(.system(size: 11, weight: .semibold))
                                                                }
                                                                .foregroundColor(.white)
                                                                .padding(.horizontal, 5)
                                                                .padding(.vertical, 3)
                                                                .background(Color(hex: "#22A45D"))
                                                                .cornerRadius(4)
                                                                
                                                                Text("•").foregroundColor(.gray).font(.system(size: 10))
                                                                Text(restaurant.reviews)
                                                                    .font(.system(size: 12, weight: .medium))
                                                                    .foregroundColor(.gray)
                                                                Text("•").foregroundColor(.gray).font(.system(size: 10))
                                                                Text(restaurant.offer)
                                                                    .font(.system(size: 12, weight: .medium))
                                                                    .foregroundColor(.gray)
                                                            }
                                                            
                                                            HStack {
                                                                Text(restaurant.location)
                                                                    .font(.system(size: 12, weight: .medium))
                                                                    .foregroundColor(.gray)
                                                                    .lineLimit(1)
                                                                
                                                                Spacer()
                                                                
                                                                Text(restaurant.deliveryTime)
                                                                    .font(.system(size: 12, weight: .semibold))
                                                                    .foregroundColor(Color(hex: "#22A45D"))
                                                            }
                                                        }
                                                        .padding(12)
                                                        .background(Color.white)
                                                    }
                                                    .cornerRadius(12)
                                                    .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
                                                    .onTapGesture {
                                                        let mockRestaurant = createMockRestaurant(from: restaurant)
                                                        selectedRestaurant = mockRestaurant
                                                        navigateToRestaurant = true
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.bottom, 16)
                                        }
                                        .background(Color.white)
                                    }
                                    
                                case .dineIn:
                                    // Dine-In: Full layout matching Android screenshots exactly
                                    VStack(spacing: 0) {

                                        // ── Your Dine-In Bookings ─────────────────────────
                                        VStack(spacing: 0) {
                                            HStack {
                                                Text("Your Dine-In Bookings")
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundColor(.black)
                                                Spacer()
                                                Button(action: { navigateToPastBookings = true }) {
                                                    Text("View all past")
                                                        .font(.system(size: 13, weight: .semibold))
                                                        .foregroundColor(Color(hex: "#E23744"))
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.top, 16)
                                            .padding(.bottom, 10)

                                            let upcomingBookings = viewModel.allRestaurants.isEmpty
                                                ? Array(repeating: nil as Restaurant?, count: 2)
                                                : viewModel.allRestaurants.prefix(2).map { Optional($0) }
                                                
                                            VStack(spacing: 12) {
                                                ForEach(Array(upcomingBookings.enumerated()), id: \.offset) { idx, restaurant in
                                                    DineInBookingCard(
                                                        restaurant: restaurant,
                                                        bookingTime: idx == 0 ? "Today, 8:00 PM | 2 Guests" : "Tomorrow, 1:00 PM | 4 Guests",
                                                        bookingStatus: "Confirmed",
                                                        onTap: {
                                                            selectedRestaurant = restaurant
                                                            navigateToRestaurantView = true
                                                        }
                                                    )
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 16)
                                        }
                                        .background(Color.white)

                                        Rectangle()
                                            .fill(Color(hex: "#F0EFF4"))
                                            .frame(height: 8)

                                        // ── Walk-in Restaurants Nearby ──────────────────
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("Walk-in restaurants nearby")
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 16)
                                                .padding(.bottom, 12)

                                            let walkInRestaurants = viewModel.allRestaurants.isEmpty
                                                ? Array(repeating: nil as Restaurant?, count: 3)
                                                : viewModel.allRestaurants.prefix(6).map { Optional($0) }

                                            ScrollView(.horizontal, showsIndicators: false) {
                                                LazyHStack(spacing: 12) {
                                                    ForEach(Array(walkInRestaurants.enumerated()), id: \.offset) { idx, restaurant in
                                                        DineInWalkInCard(
                                                            restaurant: restaurant,
                                                            actionLabel: idx == 0 ? "Book Table" : "Pay Bill",
                                                            onTap: {
                                                                selectedRestaurant = restaurant
                                                                navigateToRestaurantView = true
                                                            }
                                                        )
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.bottom, 16)
                                            }
                                        }
                                        .background(Color.white)

                                        Rectangle()
                                            .fill(Color(hex: "#F0EFF4"))
                                            .frame(height: 8)

                                        // ── In the Spotlight ───────────────────────────
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("In the spotlight")
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 16)
                                                .padding(.bottom, 12)

                                            if viewModel.isLoadingDineIn && viewModel.spotlightBanners.isEmpty {
                                                // Skeleton placeholders
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    LazyHStack(spacing: 12) {
                                                        ForEach(0..<3, id: \.self) { _ in
                                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                                .fill(Color(hex: "#F0F0F0"))
                                                                .frame(width: UIScreen.main.bounds.width - 52, height: 130)
                                                                .overlay(ProgressView().tint(.gray))
                                                        }
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .padding(.bottom, 16)
                                                }
                                            } else if viewModel.spotlightBanners.isEmpty {
                                                Text("No spotlight banners available")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color(hex: "#9E9E9E"))
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .padding(.bottom, 20)
                                            } else {
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    LazyHStack(spacing: 12) {
                                                        ForEach(viewModel.spotlightBanners.prefix(5), id: \.id) { banner in
                                                            DineInSpotlightBannerCard(banner: banner)
                                                        }
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .padding(.bottom, 16)
                                                }
                                            }
                                        }
                                        .background(Color.white)

                                        Rectangle()
                                            .fill(Color(hex: "#F0EFF4"))
                                            .frame(height: 8)

                                        // ── Events & Experiences ───────────────────────
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("Events & Experiences")
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 16)
                                                .padding(.bottom, 12)

                                            if viewModel.isLoadingDineIn && viewModel.facilities.isEmpty {
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    LazyHStack(spacing: 12) {
                                                        ForEach(0..<4, id: \.self) { _ in
                                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                                .fill(Color(hex: "#F0F0F0"))
                                                                .frame(width: 120, height: 96)
                                                                .overlay(ProgressView().tint(.gray))
                                                        }
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .padding(.bottom, 20)
                                                }
                                            } else if viewModel.facilities.isEmpty {
                                                Text("No facilities available")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color(hex: "#9E9E9E"))
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .padding(.bottom, 20)
                                            } else {
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    LazyHStack(spacing: 12) {
                                                        ForEach(viewModel.facilities.prefix(8), id: \.id) { facility in
                                                            DineInFacilityCard(facility: facility)
                                                        }
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .padding(.bottom, 20)
                                                }
                                            }
                                        }
                                        .background(Color.white)

                                        // ── Popular Brands ──────────────────────────────
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("POPULAR BRANDS")
                                                .font(.system(size: 18, weight: .heavy))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 18)
                                                .padding(.bottom, 14)

                                            let brandRestaurants = viewModel.popularBrands.isEmpty
                                                ? Array(repeating: nil as Restaurant?, count: 4)
                                                : viewModel.popularBrands.prefix(8).map { Optional($0) }

                                            ScrollView(.horizontal, showsIndicators: false) {
                                                LazyHStack(spacing: 20) {
                                                    ForEach(Array(brandRestaurants.enumerated()), id: \.offset) { _, restaurant in
                                                        DineInBrandCircle(restaurant: restaurant)
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.bottom, 20)
                                            }
                                        }
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color(hex: "#2D5A27"), location: 0),
                                                    .init(color: Color(hex: "#8B1A1A"), location: 1)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )

                                        Rectangle()
                                            .fill(Color(hex: "#F0EFF4"))
                                            .frame(height: 8)

                                        // ── Restaurants to Explore ─────────────────────
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text("Restaurants to explore")
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 16)
                                                .padding(.bottom, 4)

                                            let exploreRestaurants = viewModel.allRestaurants.isEmpty 
                                                ? restaurantCards.map { createMockRestaurant(from: $0) }
                                                : viewModel.allRestaurants

                                            if viewModel.isLoading {
                                                VStack(spacing: 0) {
                                                    ForEach(0..<3, id: \.self) { _ in
                                                        ListShimmerRow()
                                                    }
                                                }
                                            } else {
                                                LazyVStack(spacing: 0) {
                                                    ForEach(exploreRestaurants, id: \.id) { restaurant in
                                                        DineInRestaurantExploreCard(restaurant: restaurant)
                                                            .onTapGesture {
                                                                selectedRestaurant = restaurant
                                                                navigateToRestaurant = true
                                                            }
                                                        Divider()
                                                            .padding(.horizontal, 16)
                                                    }
                                                }
                                            }
                                        }
                                        .background(Color.white)
                                        .padding(.bottom, 24)
                                    }
                                    .background(Color(hex: "#F0EFF4"))
                                    
                                case .driveThru:
                                    // Drive-Thru: Filter Chips + Restaurant Cards (Same as Take Away but Drive-Thru themed)
                                    VStack(spacing: 0) {
                                        // Filter Chips - HomeView Style
                                        HStack(spacing: 0) {
                                            FilterChip(
                                                title: "📍 NEARBY",
                                                isActive: false,
                                                action: {}
                                            )
                                            
                                            FilterChip(
                                                title: "🚗 QUICK LANE",
                                                isActive: false,
                                                action: {}
                                            )
                                            
                                            FilterChip(
                                                title: "⚡ READY NOW",
                                                isActive: false,
                                                action: {}
                                            )
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color(hex: "#F2F2F7"))
                                        )
                                        .padding(.horizontal, 12)
                                        .padding(.top, 16)
                                        .padding(.bottom, 12)
                                        
                                        // Divider
                                        Rectangle()
                                            .fill(Color.hBg)
                                            .frame(height: 8)
                                        
                                        // Restaurant Cards with Consistent Spacing
                                        VStack(alignment: .leading, spacing: 16) {
                                            Text("Fast Lane Drive-Thru Spots")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.black)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 16)
                                            
                                            VStack(spacing: 12) {
                                                ForEach(restaurantCards, id: \.id) { restaurant in
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        ZStack(alignment: .topTrailing) {
                                                            // Image
                                                            Image("burger")
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(height: 160)
                                                                .clipped()
                                                            
                                                            // Distance Badge
                                                            Text(restaurant.distance)
                                                                .font(.system(size: 11, weight: .bold))
                                                                .foregroundColor(.white)
                                                                .padding(.horizontal, 10)
                                                                .padding(.vertical, 6)
                                                                .background(.ultraThinMaterial)
                                                                .environment(\.colorScheme, .dark)
                                                                .cornerRadius(6)
                                                                .padding(10)
                                                        }
                                                        
                                                        VStack(alignment: .leading, spacing: 8) {
                                                            HStack {
                                                                Text(restaurant.name)
                                                                    .font(.system(size: 16, weight: .semibold))
                                                                    .foregroundColor(.black)
                                                                
                                                                Spacer()
                                                                
                                                                // Veg Indicator
                                                                ZStack {
                                                                    RoundedRectangle(cornerRadius: 3)
                                                                        .stroke(Color(hex: "#22A45D"), lineWidth: 1)
                                                                        .frame(width: 14, height: 14)
                                                                    
                                                                    Circle()
                                                                        .fill(Color(hex: "#22A45D"))
                                                                        .frame(width: 6, height: 6)
                                                                }
                                                            }
                                                            
                                                            HStack(spacing: 8) {
                                                                HStack(spacing: 3) {
                                                                    Image(systemName: "star.fill")
                                                                        .font(.system(size: 12, weight: .bold))
                                                                        .foregroundColor(Color(hex: "#FF9500"))
                                                                    
                                                                    Text("\(String(format: "%.1f", restaurant.rating))")
                                                                        .font(.system(size: 13, weight: .semibold))
                                                                        .foregroundColor(.black)
                                                                    
                                                                    Text("(\(restaurant.offer))")
                                                                        .font(.system(size: 11))
                                                                        .foregroundColor(.gray)
                                                                }
                                                                
                                                                Spacer()
                                                                
                                                                HStack(spacing: 3) {
                                                                    Image(systemName: "clock")
                                                                        .font(.system(size: 11))
                                                                        .foregroundColor(.gray)
                                                                    
                                                                    Text(restaurant.deliveryTime)
                                                                        .font(.system(size: 11))
                                                                        .foregroundColor(.gray)
                                                                }
                                                            }
                                                            
                                                            Text(restaurant.cuisine)
                                                                .font(.system(size: 12))
                                                                .foregroundColor(Color(hex: "#666666"))
                                                        }
                                                        .padding(12)
                                                    }
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                                    .onTapGesture {
                                                        let mockRestaurant = createMockRestaurant(from: restaurant)
                                                        selectedRestaurant = mockRestaurant
                                                        navigateToRestaurant = true
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.bottom, 16)
                                        }
                                        .background(Color.white)
                                    }
                                }
                            }
                            .background(Color.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                        .frame(minHeight: geo.size.height, alignment: .top)
                    }
                    .id(scrollResetToken)
                    .background(Color.hBg)
                    .ignoresSafeArea(edges: .top)
                    .onAppear {
                        scrollResetToken = UUID()
                        DispatchQueue.main.async {
                            proxy.scrollTo(topAnchorId, anchor: .top)
                        }
                    }
                    .onChange(of: viewModel.isLoading) { loading in
                        if !loading {
                            scrollResetToken = UUID()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo(topAnchorId, anchor: .top)
                            }
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .task {
            async let homeTask: () = viewModel.loadHomeData()
            async let dineInTask: () = viewModel.loadDineInData()
            _ = await (homeTask, dineInTask)
        }
        .refreshable { await viewModel.refresh() }
        .onAppear { appState.hideMainTabBar = false }
        .navigationDestination(isPresented: $navigateToRestaurant) {
            if let r = selectedRestaurant {
                if selectedTopMode == .takeAway || selectedTopMode == .driveThru {
                    TakeAwaysDetailsView(restaurant: r).environmentObject(cartManager).environmentObject(AppState.shared)
                } else {
                    RestaurantDetailView(restaurant: r).environmentObject(cartManager)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToDineIn) {
            DineInMainView()
        }
        .navigationDestination(isPresented: $navigateToRestaurantView) {
            DineInRestaurentDetailsView(restaurant: dineInNavigationRestaurant)
        }
        .navigationDestination(isPresented: $navigateToFlash) {
            FlashView()
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView()
        }
        .navigationDestination(isPresented: $navigateToBuyOne) {
            BuyOneView()
        }
        .navigationDestination(isPresented: $navigateToAddressList) {
            AddressListView(selectionMode: true) { selectedAddress in
                SessionManager.shared.saveAddress(selectedAddress)
                Task { await viewModel.refresh() }
            }
        }
        .navigationDestination(isPresented: $navigateToPastBookings) {
            PastDineInBookingsView()
                .environmentObject(appState)
        }
        // 1. Attach the first sheet to your main view
        .sheet(item: $selectedDishForDetail) { dish in
            DishDetailSheetView(
                dish: dish,
                cartViewModel: cartViewModel,
                onClose: {
                    selectedDishForDetail = nil
                },
                onRequestCustomization: { customDish in
                    // Close the first sheet
                    selectedDishForDetail = nil
                    
                    // 2. Increase the delay to allow the dismissal animation to finish (~0.4 seconds)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        selectedDishForCustomization = customDish
                    }
                }
            )
            .presentationDetents([.medium, .large])
        }
        // 3. Attach the second sheet to an invisible background element to prevent modifier conflicts
        .background {
            Color.clear
                .sheet(item: $selectedDishForCustomization) { dish in
                    CustomisationSheetView(
                        dish: dish,
                        cartViewModel: cartViewModel,
                        onClose: {
                            selectedDishForCustomization = nil
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
        }
    }
    
    // MARK: - Header section (purple gradient + location + category tabs)
    
    private struct HeaderView: View {
        @ObservedObject var viewModel: HomeViewModel
        let topSafeInset: CGFloat
        let onAddressTap: () -> Void
        let onProfileTap: () -> Void
        let onBuyOneTap: () -> Void
        let selectedMode: HomeTopMode
        let theme: HomeTopModeTheme
        let onTopTabSelected: (HomeTopMode) -> Void
        
        var body: some View {
            ZStack(alignment: .top) {
                LinearGradient(
                    gradient: Gradient(colors: [theme.headerStart, theme.headerEnd]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.container, edges: .top)
                
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: topSafeInset)
                    
                    // ── Location row ──────────────────────────────────────────────
                    HStack(alignment: .center, spacing: 0) {
                        // Location
                        Button(action: onAddressTap) {
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.top, 2)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text(locationTitle)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    Text(locationSubtitle)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.58))
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // BUY one badge
                        Button(action: onBuyOneTap) {
                            ZStack {
                                Capsule(style: .continuous)
                                    .fill(Color.white)
                                    .frame(width: 77, height: 37)
                                VStack(spacing: -3) {
                                    Text("BUY")
                                        .font(.system(size: 9.5, weight: .bold))
                                        .foregroundColor(Color(hex: "#7B7B7B"))
                                    Text("one")
                                        .font(.system(size: 22, weight: .heavy))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(hex: "#FF7A45"), Color(hex: "#F24B2E")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                            }
                        }
                        .padding(.trailing, 12)
                        
                        // Profile circle -> tappable to open ProfileView
                        Button(action: onProfileTap) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#E9E9EE"))
                                    .frame(width: 38, height: 38)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#505056"))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    
                    // ── Category tabs ──────────────────────────────────────────────
                    CategoryTabView(
                        selectedMode: selectedMode,
                        theme: theme,
                        onSelect: onTopTabSelected
                    )
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        
        private var locationTitle: String {
            if let addr = SessionManager.shared.currentAddress {
                return addr.hno ?? addr.type ?? "Home"
            }
            return "Jaipur"
        }
        
        private var locationSubtitle: String {
            if let addr = SessionManager.shared.currentAddress {
                return addr.fullAddress
            }
            return "Sector 23, Tilawala, Jaipur, Rajasthan..."
        }
    }
    
    // MARK: - Category tab row (Food / Take Away / Dine In / Subscription / Drive-thru)
    
    // MARK: - Category tab row — pixel-perfect match of reference screenshot
    
    private struct CategoryTabView: View {
        let selectedMode: HomeTopMode
        let theme: HomeTopModeTheme
        let onSelect: (HomeTopMode) -> Void
        
        @Namespace private var animation
        
        private let inactiveColor = Color.white.opacity(0.04)
        private let categories: [HomeTopMode] = [.food, .takeAway, .dineIn, .driveThru]
        
        var body: some View {
            VStack(spacing: 0) {
                
                // ── Tab row ────────────────────────────────────────────────────
                HStack(alignment: .bottom, spacing: -14) {
                    ForEach(Array(categories.enumerated()), id: \.element.rawValue) { index, category in
                        TabCell(
                            mode: category,
                            emoji: category.emoji,
                            isSelected: selectedMode == category,
                            activeColor: theme.activeTab,
                            inactiveColor: inactiveColor,
                            animation: animation
                        )
                        // The left-most tab has the highest natural zIndex, except for the selected tab which is forcefully pushed to the very front
                        .zIndex(selectedMode == category ? 100 : Double(categories.count - index))
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                onSelect(category)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 0)
                .background(theme.tabBackground)
                
                // ── Bottom connector strip ─────────
                Rectangle()
                    .fill(theme.connector)
                    .frame(height: 4)
            }
            .background(theme.tabBackground)
        }
    }
    
    // ── Single tab cell ──────────────────────────────────────────────────────────
    
    private struct TabCell: View {
        let mode: HomeTopMode
        let emoji: String
        let isSelected: Bool
        let activeColor: Color
        let inactiveColor: Color
        var animation: Namespace.ID
        
        // Dimensions exactly matching the provided image
        private var cardHeight: CGFloat { 82 }
        private var emojiSize:  CGFloat { isSelected ? 36 : 30  }
        
        // Soft glass / neumorphic lighting
        private var tabBaseGradient: LinearGradient {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#101633"),
                    Color(hex: "#0A0E26")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        private var tabHighlightGradient: RadialGradient {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.08),
                    Color.clear
                ]),
                center: UnitPoint(x: 0.2, y: 0.12),
                startRadius: 0,
                endRadius: 90
            )
        }
        
        var body: some View {
            VStack(spacing: 0) {
                
                // ── Emoji + optional badge ────────────────────────────────────
                ZStack(alignment: .bottom) {
                    Text(emoji)
                        .font(.system(size: emojiSize))
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSelected)
                }
                .frame(height: 40)                    // fixed zone so label stays aligned
                
                // ── Label ─────────────────────────────────────────────────────
                Text(mode.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? .white : Color(hex: "#B0AEC0"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.bottom, 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)
            .background {
                if isSelected {
                    ZStack {
                        PlateauTabShape()
                            .fill(tabBaseGradient)
                        
                        PlateauTabShape()
                            .fill(activeColor.opacity(0.52))
                        
                        PlateauTabShape()
                            .fill(tabHighlightGradient)
                        
                        PlateauTabShape()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.12), Color.clear]),
                                    center: UnitPoint(x: 0.35, y: 0.05),
                                    startRadius: 0,
                                    endRadius: 110
                                )
                            )
                    }
                    .overlay(
                        PlateauTabShape(isOpen: true)
                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.26), radius: 10, y: 4)
                    .matchedGeometryEffect(id: "activeTab", in: animation)
                } else {
                    ZStack {
                        PlateauTabShape()
                            .fill(tabBaseGradient)
                        
                        PlateauTabShape()
                            .fill(inactiveColor)
                        
                        PlateauTabShape()
                            .fill(tabHighlightGradient)
                    }
                    .overlay(
                        PlateauTabShape(isOpen: true)
                            .stroke(Color.white.opacity(0.09), lineWidth: 0.8)
                    )
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSelected)
        }
    }
    
    private struct PlateauTabShape: Shape {
        var isOpen: Bool = false
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let w = rect.width
            let h = rect.height
            
            let topInset = w * 0.11
            let topCornerRadius: CGFloat = 20
            
            // Bottom-left
            path.move(to: CGPoint(x: 0, y: h))
            
            // Left slanted straight edge up to curve
            path.addLine(to: CGPoint(x: topInset, y: topCornerRadius))
            
            // Top-left corner
            path.addArc(
                center: CGPoint(x: topInset + topCornerRadius, y: topCornerRadius),
                radius: topCornerRadius,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
            
            // Flat top edge
            path.addLine(to: CGPoint(x: w - topInset - topCornerRadius, y: 0))
            
            // Top-right corner
            path.addArc(
                center: CGPoint(x: w - topInset - topCornerRadius, y: topCornerRadius),
                radius: topCornerRadius,
                startAngle: .degrees(270),
                endAngle: .degrees(0),
                clockwise: false
            )
            
            // Right slanted straight edge back to bottom
            path.addLine(to: CGPoint(x: w, y: h))
            
            if !isOpen {
                path.closeSubpath()
            }
            return path
        }
    }
    
    // MARK: - Search row + VEG toggle
    
    private struct SearchBarView: View {
        @ObservedObject var viewModel: HomeViewModel
        let placeholder: String
        @State private var searchText = ""
        @State private var vegOnly   = false
        
        var body: some View {
            HStack(spacing: 10) {
                // Search field
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#999999"))
                    
                    TextField(placeholder, text: $searchText)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .submitLabel(.search)
                        .onSubmit {
                            viewModel.searchQuery = searchText
                            viewModel.applyFilters()
                        }
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#E23744"))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.07), lineWidth: 1)
                )
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                
                // VEG toggle box
                VStack(spacing: 2) {
                    Text("VEG")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.hGreen)
                    Toggle("", isOn: $vegOnly)
                        .labelsHidden()
                        .tint(Color.hGreen)
                        .scaleEffect(0.8)
                        .onChange(of: vegOnly) { v in
                            viewModel.vegOnly = v
                            viewModel.applyFilters()
                        }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            }
        }
    }
    
    // MARK: - Promo banner
    
    private struct BannerView: View {
        let content: HomeTopPromoContent
        
        var body: some View {
            HStack(spacing: 0) {
                HStack(spacing: 2) {
                    Text(content.bannerLead)
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .italic()
                        .foregroundColor(Color.hYellow)
                    
                    Text(content.bannerTrail)
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                
                Spacer(minLength: 8)
                
                HStack(spacing: 3) {
                    Text(content.ctaText)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(Color.hYellow)
                    Text("»")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(Color.hYellow)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(hex: "#4F178F").opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.hYellow.opacity(0.9), lineWidth: 1.7)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .frame(height: 98)
        }
    }
    
    // MARK: - Offer text row  ("--- MIN 150 OFF + ₹100 CASHBACK ---")
    
    private struct OfferTextRow: View {
        let content: HomeTopPromoContent
        
        var body: some View {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(height: 1)
                Text(content.offerLineText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.88)
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(height: 1)
            }
        }
    }
    
    // MARK: - 3 Offer cards row (yellow, full width inside purple area)
    
    private struct OfferCardsRow: View {
        let content: HomeTopPromoContent
        
        var body: some View {
            HStack(spacing: 8) {
                // Card 1 – ₹150 OFF
                OfferCardView(
                    title: content.card1Title,
                    badgeTopText: content.card1Top,
                    badgeMainText: content.card1Main,
                    badgeSubText: content.card1Sub
                )
                
                // Card 2 – ₹300 FREE CASH
                OfferCardView(
                    title: content.card2Title,
                    badgeTopText: content.card2Top,
                    badgeMainText: content.card2Main,
                    badgeSubText: content.card2Sub
                )
                
                // Card 3 – LARGE ORDERS (image card)
                LargeOrderCard(title: content.card3Title)
            }
            .padding(.horizontal, 12)
        }
    }
    
    private struct OfferCardView: View {
        let title: String
        let badgeTopText: String
        let badgeMainText: String
        let badgeSubText: String
        
        var body: some View {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.hYellow)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(Color(hex: "#5B3300"))
                        .multilineTextAlignment(.leading)
                        .padding(.top, 10)
                        .padding(.horizontal, 8)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    // Pink starburst badge
                    ZStack {
                        Image(systemName: "seal.fill")
                            .font(.system(size: 74))
                            .foregroundColor(Color(hex: "#B11456"))
                        
                        Image(systemName: "seal.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#FF3E98"),
                                        Color(hex: "#C8166D")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 1) {
                            Text(badgeTopText)
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(.white)
                            Text(badgeMainText)
                                .font(.system(size: 21, weight: .heavy))
                                .foregroundColor(.white)
                            Text(badgeSubText)
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
                }
            }
            .frame(height: 148)
            .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
        }
    }
    
    private struct LargeOrderCard: View {
        let title: String
        
        var body: some View {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.hYellow)
                
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(Color(hex: "#5B3300"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(hex: "#D79A4A"))
                            .frame(width: 86, height: 40)
                            .offset(y: 16)
                        
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(hex: "#C48134"))
                            .frame(width: 92, height: 48)
                        
                        Group {
                            if UIImage(named: "burger") != nil {
                                Image("burger")
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(hex: "#6B3F0A"))
                            }
                        }
                        .frame(width: 78, height: 48)
                        .offset(y: -6)
                    }
                    .padding(.bottom, 12)
                }
            }
            .frame(height: 148)
            .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
        }
    }
    
    // MARK: - Filter row  (TOP RATED  |  FOOD IN 10 MINS  |  ZIPPYCAFE)
    
    private struct FilterRow: View {
        @ObservedObject var viewModel: HomeViewModel
        @State private var activeFilter: String = "TOP RATED"
        
        var body: some View {
            HStack(spacing: 0) {
                // Filter chip 1: TOP RATED
                FilterChip(
                    title: "TOP RATED",
                    isActive: activeFilter == "TOP RATED",
                    action: {
                        activeFilter = "TOP RATED"
                        viewModel.sortBy = .rating
                        viewModel.applyFilters()
                    }
                )
                
                // Filter chip 2: FOOD IN 10 MINS
                FilterChip(
                    title: "FOOD IN 10 MINS",
                    isActive: activeFilter == "FOOD IN 10 MINS",
                    action: {
                        activeFilter = "FOOD IN 10 MINS"
                        viewModel.sortBy = .deliveryTime
                        viewModel.applyFilters()
                    }
                )
                
                // Filter chip 3: ZIPPYCAFE
                FilterChip(
                    title: "ZIPPYCAFE",
                    isActive: activeFilter == "ZIPPYCAFE",
                    action: {
                        activeFilter = "ZIPPYCAFE"
                        viewModel.hasOffers = true
                        viewModel.applyFilters()
                    }
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(hex: "#F2F2F7"))
            )
            .padding(.horizontal, 12)
        }
    }
    
    private struct FilterChip: View {
        let title: String
        let isActive: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isActive ? Color(hex: "#E65100") : Color(hex: "#424242"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(
                        Capsule()
                            .fill(isActive ? Color.white : Color(hex: "#F2F2F7"))
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Horizontal restaurant carousel (pixel-focused)
    
    private struct HorizontalRestaurantListView: View {
        struct Restaurant: Identifiable {
            let id: String
            let name: String
            let image: String
            let offer: String
            let rating: Double
            let deliveryTime: String
            let category: String
            let isFavorite: Bool
        }
        
        let restaurants: [Restaurant]
        let onCardTap: (Restaurant) -> Void
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(restaurants) { restaurant in
                        HorizontalRestaurantCardView(restaurant: restaurant, onTap: onCardTap)
                    }
                    
                    if restaurants.isEmpty {
                        ForEach(0..<3, id: \.self) { _ in
                            CarouselSkeletonCard()
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
            }
        }
    }
    
    private struct HorizontalRestaurantCardView: View {
        let restaurant: HorizontalRestaurantListView.Restaurant
        let onTap: (HorizontalRestaurantListView.Restaurant) -> Void
        @State private var isFavorite: Bool
        
        init(
            restaurant: HorizontalRestaurantListView.Restaurant,
            onTap: @escaping (HorizontalRestaurantListView.Restaurant) -> Void
        ) {
            self.restaurant = restaurant
            self.onTap = onTap
            _isFavorite = State(initialValue: restaurant.isFavorite)
        }
        
        var body: some View {
            Button {
                onTap(restaurant)
            } label: {
                VStack(alignment: .leading, spacing: 7) {
                    ZStack(alignment: .topTrailing) {
                        Group {
                            if UIImage(named: restaurant.image) != nil {
                                Image(restaurant.image)
                                    .resizable()
                                    .scaledToFill()
                            } else if UIImage(named: "burger") != nil {
                                Image("burger")
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                ZStack {
                                    Color.gray.opacity(0.15)
                                    Image(systemName: "photo")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .frame(width: 156, height: 138)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: 156, height: 138)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        VStack {
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(isFavorite ? Color(hex: "#E23744") : Color(hex: "#5F5F5F"))
                                .frame(width: 28, height: 28)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                    
                    Text(restaurant.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "#198A3C"))
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#198A3C"))
                        
                        Text("•")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#8A8A8A"))
                        
                        Text(restaurant.deliveryTime)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "#5E5E5E"))
                            .lineLimit(1)
                    }
                    
                    Text(restaurant.category)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .lineLimit(1)
                }
                .frame(width: 156, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct CarouselSkeletonCard: View {
        @State private var pulse = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 156, height: 138)
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.gray.opacity(0.16))
                    .frame(width: 122, height: 11)
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 106, height: 10)
            }
            .frame(width: 156, alignment: .leading)
            .opacity(pulse ? 0.55 : 1)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
        }
    }
    
    // MARK: - Cuisines horizontal scroll
    
    private struct CuisinesSection: View {
        let categories: [CategoryItem]
        let selectedId: String?
        let onSelect: (String) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("WHAT'S ON YOUR MIND")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(categories) { cat in
                            let sel = selectedId == cat.catId
                            Button { onSelect(cat.catId ?? "") } label: {
                                VStack(spacing: 5) {
                                    ZStack {
                                        Circle()
                                            .fill(sel
                                                  ? Color(hex: "#E23744").opacity(0.12)
                                                  : Color(hex: "#F5F5F5"))
                                            .frame(width: 50, height: 50)
                                        
                                        if let img = cat.catImg, let url = URL(string: img) {
                                            AsyncImage(url: url) { i in i.resizable().scaledToFill() }
                                            placeholder: {
                                                Image(systemName: "fork.knife")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(width: 38, height: 38)
                                            .clipShape(Circle())
                                        } else {
                                            Image(systemName: "fork.knife")
                                                .font(.system(size: 20))
                                                .foregroundColor(sel ? Color(hex: "#E23744") : .gray)
                                        }
                                    }
                                    Text(cat.title ?? "")
                                        .font(.system(size: 11, weight: sel ? .bold : .medium))
                                        .foregroundColor(sel ? Color(hex: "#E23744") : .black)
                                        .lineLimit(1)
                                }
                                .frame(width: 70)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    // MARK: - All Restaurants vertical list
    
    private struct AllRestaurantsSection: View {
        @ObservedObject var viewModel: HomeViewModel
        let selectedMode: HomeTopMode
        let onOpenRestaurantView: () -> Void
        let onOpenFlash: () -> Void
        let onShowDishDetail: (Product) -> Void
        
        @State private var favoriteIds: Set<String> = []
        
        private var sourceRestaurants: [Restaurant] {
            if !viewModel.filteredRestaurants.isEmpty {
                return viewModel.filteredRestaurants
            }
            if !viewModel.allRestaurants.isEmpty {
                return viewModel.allRestaurants
            }
            return []
        }
        
        private var categoryItems: [Category] {
            if !viewModel.categories.isEmpty {
                return viewModel.categories.prefix(8).map { category in
                    Category(
                        name: category.title ?? "Category",
                        image: category.catImg ?? "burger",
                        isSelected: false
                    )
                }
            }
            
            switch selectedMode {
            case .food:
                return [
                    Category(name: "Rasgulla", image: "burger", isSelected: true),
                    Category(name: "Gulab Jamun", image: "burger", isSelected: false),
                    Category(name: "Rasmalai", image: "burger", isSelected: false),
                    Category(name: "Jalebi", image: "burger", isSelected: false),
                    Category(name: "North Indian", image: "burger", isSelected: false)
                ]
            case .takeAway:
                return [
                    Category(name: "Pickup Combos", image: "burger", isSelected: true),
                    Category(name: "Wraps", image: "burger", isSelected: false),
                    Category(name: "Burgers", image: "burger", isSelected: false),
                    Category(name: "Coffee", image: "burger", isSelected: false),
                    Category(name: "Quick Snacks", image: "burger", isSelected: false)
                ]
            case .dineIn:
                return [
                    Category(name: "Fine Dining", image: "burger", isSelected: true),
                    Category(name: "Family Meals", image: "burger", isSelected: false),
                    Category(name: "Buffet", image: "burger", isSelected: false),
                    Category(name: "Chef Special", image: "burger", isSelected: false),
                    Category(name: "Desserts", image: "burger", isSelected: false)
                ]
            case .driveThru:
                return [
                    Category(name: "Quick Combos", image: "burger", isSelected: true),
                    Category(name: "Fries", image: "burger", isSelected: false),
                    Category(name: "Wraps", image: "burger", isSelected: false),
                    Category(name: "Milkshakes", image: "burger", isSelected: false),
                    Category(name: "Value Meals", image: "burger", isSelected: false)
                ]
            }
        }
        
        private var restaurants: [ExploreRestaurantListView.Restaurant] {
            // Only use API data for Food tab; other tabs use mode-specific fallback data
            if selectedMode == .food && !sourceRestaurants.isEmpty {
                return sourceRestaurants.map { item in
                    ExploreRestaurantListView.Restaurant(
                        id: item.restId ?? UUID().uuidString,
                        name: item.restTitle ?? "Restaurant",
                        image: item.restImg ?? "burger",
                        offer: "₹\(item.restCostfortwo ?? "99")",
                        rating: Double(item.restRating ?? "4.5") ?? 4.5,
                        reviews: "8.1K+",
                        deliveryTime: item.restDeliverytime ?? "10–15 mins",
                        cuisine: item.restSdesc ?? "American, Italian",
                        location: item.restLandmark ?? item.restFullAddress ?? "Jagatpura",
                        distance: item.restDistance ?? "0.9 km",
                        isFavorite: item.isFav
                    )
                }
            }
            
            switch selectedMode {
            case .food:
                return [
                    ExploreRestaurantListView.Restaurant(id: "demo-1", name: "Burger Farm", image: "burger", offer: "₹84", rating: 4.5, reviews: "8.1K+", deliveryTime: "20–25 mins", cuisine: "American, Italian", location: "Jagatpura", distance: "0.9 km", isFavorite: false),
                    ExploreRestaurantListView.Restaurant(id: "demo-2", name: "Theobroma", image: "burger", offer: "₹48", rating: 4.6, reviews: "168", deliveryTime: "10–15 mins", cuisine: "Bakery, Desserts", location: "Sector-23", distance: "0.1 km", isFavorite: false),
                    ExploreRestaurantListView.Restaurant(id: "demo-3", name: "NBC - Nothing Before Coffee", image: "burger", offer: "₹69", rating: 4.4, reviews: "474", deliveryTime: "15–20 mins", cuisine: "Coffee, Fast Food, Cafe", location: "Jagatpura", distance: "0.1 km", isFavorite: true)
                ]
            case .takeAway:
                return [
                    ExploreRestaurantListView.Restaurant(id: "demo-take-1", name: "Counter Express", image: "burger", offer: "₹99", rating: 4.3, reviews: "2.4K+", deliveryTime: "Ready in 10 mins", cuisine: "Grab & Go, Wraps", location: "Malviya Nagar", distance: "0.7 km", isFavorite: false),
                    ExploreRestaurantListView.Restaurant(id: "demo-take-2", name: "Pickup Point", image: "burger", offer: "₹89", rating: 4.2, reviews: "1.1K+", deliveryTime: "Ready in 8 mins", cuisine: "Fast Food, Combos", location: "Jagatpura", distance: "0.3 km", isFavorite: false),
                    ExploreRestaurantListView.Restaurant(id: "demo-take-3", name: "Bite Counter", image: "burger", offer: "₹79", rating: 4.4, reviews: "3.8K+", deliveryTime: "Ready in 12 mins", cuisine: "Snacks, Beverages", location: "Pratap Nagar", distance: "1.2 km", isFavorite: true)
                ]
            case .dineIn:
                return [
                    ExploreRestaurantListView.Restaurant(id: "demo-dine-1", name: "Royal Table", image: "burger", offer: "₹249", rating: 4.6, reviews: "5.6K+", deliveryTime: "Book table in 5 mins", cuisine: "Fine Dining, North Indian", location: "C-Scheme", distance: "2.2 km", isFavorite: false),
                    ExploreRestaurantListView.Restaurant(id: "demo-dine-2", name: "Family Feast Hall", image: "burger", offer: "₹399", rating: 4.5, reviews: "2.9K+", deliveryTime: "Seats Available", cuisine: "Family Dining, Multi Cuisine", location: "Vaishali Nagar", distance: "3.1 km", isFavorite: false),
                    ExploreRestaurantListView.Restaurant(id: "demo-dine-3", name: "Chef's Room", image: "burger", offer: "₹299", rating: 4.7, reviews: "1.8K+", deliveryTime: "Priority Booking", cuisine: "Continental, Grill", location: "Bani Park", distance: "2.5 km", isFavorite: true)
                ]
            case .driveThru:
                return [
                    ExploreRestaurantListView.Restaurant(id: "demo-drive-1", name: "Fast Lane Bites", image: "burger", offer: "₹119", rating: 4.2, reviews: "6.1K+", deliveryTime: "5–10 mins", cuisine: "Burgers, Combos", location: "Tonk Road", distance: "1.6 km", isFavorite: false),
                    ExploreRestaurantListView.Restaurant(id: "demo-drive-2", name: "Window Meals", image: "burger", offer: "₹99", rating: 4.1, reviews: "3.4K+", deliveryTime: "4–8 mins", cuisine: "Wraps, Fries", location: "Airport Road", distance: "2.0 km", isFavorite: false),
                    ExploreRestaurantListView.Restaurant(id: "demo-drive-3", name: "Turbo Stop", image: "burger", offer: "₹129", rating: 4.3, reviews: "4.7K+", deliveryTime: "6–9 mins", cuisine: "Quick Bites, Drinks", location: "JLN Marg", distance: "1.4 km", isFavorite: true)
                ]
            }
        }
        
        private var storeProducts: [Product] {
            switch selectedMode {
            case .food:
                return [
                    Product(name: "Paneer Onion Pizza", image: "burger", price: 79, oldPrice: 160, rating: 4.1, ratingCount: 136, restaurant: "Crazy Pizza Hot", isVeg: true),
                    Product(name: "Egg Curry", image: "burger", price: 69, oldPrice: 190, rating: 3.7, ratingCount: 158, restaurant: "The Royal Mult...", isVeg: false),
                    Product(name: "Pyaz Kachori", image: "burger", price: 59, oldPrice: 60, rating: 4.2, ratingCount: 634, restaurant: "Rawat Mishth...", isVeg: true)
                ]
            case .takeAway:
                return [
                    Product(name: "Pickup Combo Box", image: "burger", price: 99, oldPrice: 170, rating: 4.3, ratingCount: 201, restaurant: "Express Kitchen", isVeg: true),
                    Product(name: "Grab Noodles", image: "burger", price: 89, oldPrice: 149, rating: 4.0, ratingCount: 165, restaurant: "TakeAway Hub", isVeg: false),
                    Product(name: "Pocket Burger", image: "burger", price: 69, oldPrice: 120, rating: 4.1, ratingCount: 442, restaurant: "Bite Point", isVeg: true)
                ]
            case .dineIn:
                return [
                    Product(name: "Signature Sizzler", image: "burger", price: 249, oldPrice: 349, rating: 4.5, ratingCount: 98, restaurant: "Royal Dine", isVeg: false),
                    Product(name: "Family Platter", image: "burger", price: 399, oldPrice: 550, rating: 4.4, ratingCount: 144, restaurant: "Table Treats", isVeg: true),
                    Product(name: "Chef Special Soup", image: "burger", price: 129, oldPrice: 199, rating: 4.2, ratingCount: 212, restaurant: "Fine Bowl", isVeg: true)
                ]
            case .driveThru:
                return [
                    Product(name: "Drive Combo Meal", image: "burger", price: 129, oldPrice: 189, rating: 4.2, ratingCount: 335, restaurant: "Fast Lane Eats", isVeg: false),
                    Product(name: "Quick Wrap", image: "burger", price: 79, oldPrice: 119, rating: 4.1, ratingCount: 271, restaurant: "Window Bites", isVeg: true),
                    Product(name: "Turbo Fries", image: "burger", price: 59, oldPrice: 99, rating: 4.0, ratingCount: 390, restaurant: "Drive Spot", isVeg: true)
                ]
            }
        }
        
        private var swiggyHighlights: [MoreOnSwiggyCard] {
            switch selectedMode {
            case .food:
                return [
                    MoreOnSwiggyCard(title: "FLASH", image: "burger"),
                    MoreOnSwiggyCard(title: "HIGH", image: "burger"),
                    MoreOnSwiggyCard(title: "REORDER", image: "burger"),
                ]
            case .takeAway:
                return [
                    MoreOnSwiggyCard(title: "PICKUP\nPOINT", image: "burger"),
                    MoreOnSwiggyCard(title: "READY\nNOW", image: "burger"),
                    MoreOnSwiggyCard(title: "GRAB\nDEAL", image: "burger"),
                ]
            case .dineIn:
                return [
                    MoreOnSwiggyCard(title: "TABLE\nBOOK", image: "burger"),
                    MoreOnSwiggyCard(title: "FAMILY\nDINING", image: "burger"),
                    MoreOnSwiggyCard(title: "CHEF\nSPECIAL", image: "burger"),
                ]
            case .driveThru:
                return [
                    MoreOnSwiggyCard(title: "FAST\nLANE", image: "burger"),
                    MoreOnSwiggyCard(title: "CAR\nPICKUP", image: "burger"),
                    MoreOnSwiggyCard(title: "QUICK\nCOMBO", image: "burger"),
                ]
            }
        }
        
        private var deliciousYardProducts: [Product] {
            switch selectedMode {
            case .food:
                return [
                    Product(name: "Grilled Chicken Skewers", image: "burger", price: 149, oldPrice: 299, rating: 4.3, ratingCount: 245, restaurant: "Yard Kitchen", isVeg: false),
                    Product(name: "Garden Fresh Salad", image: "burger", price: 89, oldPrice: 180, rating: 4.4, ratingCount: 187, restaurant: "Green Yard Cafe", isVeg: true),
                    Product(name: "Herb Butter Naan", image: "burger", price: 79, oldPrice: 120, rating: 4.2, ratingCount: 412, restaurant: "Yard Bakers", isVeg: true)
                ]
            case .takeAway:
                return [
                    Product(name: "Quick Pickup Pasta", image: "burger", price: 129, oldPrice: 220, rating: 4.2, ratingCount: 198, restaurant: "Pickup Kitchen", isVeg: true),
                    Product(name: "Counter Club Sandwich", image: "burger", price: 99, oldPrice: 160, rating: 4.1, ratingCount: 276, restaurant: "Counter Cafe", isVeg: true),
                    Product(name: "Express Chicken Roll", image: "burger", price: 119, oldPrice: 190, rating: 4.3, ratingCount: 332, restaurant: "Grab Box", isVeg: false)
                ]
            case .dineIn:
                return [
                    Product(name: "Chef Platter", image: "burger", price: 329, oldPrice: 499, rating: 4.6, ratingCount: 142, restaurant: "Royal Table", isVeg: false),
                    Product(name: "Creamy Mushroom Soup", image: "burger", price: 169, oldPrice: 249, rating: 4.4, ratingCount: 188, restaurant: "Dine House", isVeg: true),
                    Product(name: "Baked Lasagna", image: "burger", price: 259, oldPrice: 390, rating: 4.5, ratingCount: 223, restaurant: "Family Feast", isVeg: true)
                ]
            case .driveThru:
                return [
                    Product(name: "Turbo Burger Combo", image: "burger", price: 149, oldPrice: 229, rating: 4.2, ratingCount: 402, restaurant: "Fast Lane", isVeg: false),
                    Product(name: "Drive Wrap Meal", image: "burger", price: 129, oldPrice: 199, rating: 4.1, ratingCount: 355, restaurant: "Window Meals", isVeg: true),
                    Product(name: "Quick Shake + Fries", image: "burger", price: 109, oldPrice: 169, rating: 4.0, ratingCount: 498, restaurant: "Turbo Stop", isVeg: true)
                ]
            }
        }
        
        private var deliciousYardCards: [MoreOnSwiggyCard] {
            switch selectedMode {
            case .food:
                return [
                    MoreOnSwiggyCard(title: "DELICIOUS\nYARD SPECIALS", image: "burger"),
                    MoreOnSwiggyCard(title: "FRESH\nVEGETABLES", image: "burger"),
                    MoreOnSwiggyCard(title: "GRILLED\nDELICACIES", image: "burger"),
                    MoreOnSwiggyCard(title: "SEASONAL\nFAVORITES", image: "burger")
                ]
            case .takeAway:
                return [
                    MoreOnSwiggyCard(title: "PICKUP\nFAST PICKS", image: "burger"),
                    MoreOnSwiggyCard(title: "READY\nIN 10", image: "burger"),
                    MoreOnSwiggyCard(title: "ON-THE-GO\nSNACKS", image: "burger"),
                    MoreOnSwiggyCard(title: "COUNTER\nSPECIALS", image: "burger")
                ]
            case .dineIn:
                return [
                    MoreOnSwiggyCard(title: "DINE\nSIGNATURES", image: "burger"),
                    MoreOnSwiggyCard(title: "FAMILY\nTABLE SET", image: "burger"),
                    MoreOnSwiggyCard(title: "CHEF\nRECOMMENDS", image: "burger"),
                    MoreOnSwiggyCard(title: "DINNER\nSPECIALS", image: "burger")
                ]
            case .driveThru:
                return [
                    MoreOnSwiggyCard(title: "DRIVE\nFAST DEALS", image: "burger"),
                    MoreOnSwiggyCard(title: "WINDOW\nCOMBOS", image: "burger"),
                    MoreOnSwiggyCard(title: "GRAB\n& RIDE", image: "burger"),
                    MoreOnSwiggyCard(title: "LANE\nFAVORITES", image: "burger")
                ]
            }
        }
        
        private var promotionalBanners: [PromotionalBanner] {
            switch selectedMode {
            case .food:
                return [
                    PromotionalBanner(
                        id: "banner-food-1",
                        backgroundColor: Color(hex: "#FFC107"),
                        accentColor: Color(hex: "#FF9800"),
                        mainTitle: "Fresh year.",
                        subtitle: "Fresh cravings.",
                        image: "burger",
                        bannerImage: nil
                    ),
                    PromotionalBanner(
                        id: "banner-food-2",
                        backgroundColor: Color(hex: "#FF9800"),
                        accentColor: Color(hex: "#FF7043"),
                        mainTitle: "Special Noodle",
                        subtitle: "Best Noodle Ever",
                        image: "burger",
                        bannerImage: nil
                    ),
                    PromotionalBanner(
                        id: "banner-food-3",
                        backgroundColor: Color(hex: "#F5E6E0"),
                        accentColor: Color(hex: "#8B4754"),
                        mainTitle: "Special Menu",
                        subtitle: "SWEET DESSERTS",
                        image: "burger",
                        restaurantName: "PANKH RESTAURANT",
                        discount: "50%",
                        bannerImage: nil
                    )
                ]
            case .takeAway:
                return [
                    PromotionalBanner(
                        id: "banner-takeaway-1",
                        backgroundColor: Color(hex: "#B3E5FC"),
                        accentColor: Color(hex: "#0288D1"),
                        mainTitle: "Pick up.",
                        subtitle: "Skip the wait.",
                        image: "burger",
                        bannerImage: nil
                    ),
                    PromotionalBanner(
                        id: "banner-takeaway-2",
                        backgroundColor: Color(hex: "#81D4FA"),
                        accentColor: Color(hex: "#0277BD"),
                        mainTitle: "Counter Ready",
                        subtitle: "In under 10 mins",
                        image: "burger",
                        bannerImage: nil
                    ),
                    PromotionalBanner(
                        id: "banner-takeaway-3",
                        backgroundColor: Color(hex: "#E1F5FE"),
                        accentColor: Color(hex: "#01579B"),
                        mainTitle: "Take Away Pass",
                        subtitle: "Extra 20% Off",
                        image: "burger",
                        restaurantName: "FOODZIPPY PICKUP",
                        discount: "20%",
                        bannerImage: nil
                    )
                ]
            case .dineIn:
                return [
                    PromotionalBanner(
                        id: "banner-dinein-1",
                        backgroundColor: Color(hex: "#FFE0B2"),
                        accentColor: Color(hex: "#EF6C00"),
                        mainTitle: "Dine royal.",
                        subtitle: "Comfort seating.",
                        image: "burger",
                        bannerImage: nil
                    ),
                    PromotionalBanner(
                        id: "banner-dinein-2",
                        backgroundColor: Color(hex: "#FFCC80"),
                        accentColor: Color(hex: "#E65100"),
                        mainTitle: "Table for Two",
                        subtitle: "Reserve instantly",
                        image: "burger",
                        bannerImage: nil
                    ),
                    PromotionalBanner(
                        id: "banner-dinein-3",
                        backgroundColor: Color(hex: "#FFF3E0"),
                        accentColor: Color(hex: "#BF360C"),
                        mainTitle: "Chef's Menu",
                        subtitle: "Family Specials",
                        image: "burger",
                        restaurantName: "PANKH DINE-IN",
                        discount: "35%",
                        bannerImage: nil
                    )
                ]
            case .driveThru:
                return [
                    PromotionalBanner(
                        id: "banner-drivethru-1",
                        backgroundColor: Color(hex: "#C8E6C9"),
                        accentColor: Color(hex: "#2E7D32"),
                        mainTitle: "Drive and bite.",
                        subtitle: "No parking needed.",
                        image: "burger",
                        bannerImage: nil
                    ),
                    PromotionalBanner(
                        id: "banner-drivethru-2",
                        backgroundColor: Color(hex: "#A5D6A7"),
                        accentColor: Color(hex: "#1B5E20"),
                        mainTitle: "Window Service",
                        subtitle: "Fast lane combos",
                        image: "burger",
                        bannerImage: nil
                    ),
                    PromotionalBanner(
                        id: "banner-drivethru-3",
                        backgroundColor: Color(hex: "#E8F5E9"),
                        accentColor: Color(hex: "#33691E"),
                        mainTitle: "Turbo Meals",
                        subtitle: "Ready in 10 mins",
                        image: "burger",
                        restaurantName: "FOODZIPPY DRIVE",
                        discount: "15%",
                        bannerImage: nil
                    )
                ]
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if selectedMode != .dineIn {
                    CategoryListView(items: categoryItems, title: categorySectionTitle)
                        .padding(.top, 8)
                    
                    PromotionalBannerCarouselView(banners: promotionalBanners)
                        .padding(.top, 12)
                        .padding(.bottom, 12)
                    
                    Store99SectionView(
                        selectedMode: selectedMode,
                        products: storeProducts,
                        swiggyCards: swiggyHighlights,
                        onSeeAllTap: {
                            onOpenRestaurantView()
                        },
                        onCardTap: {
                            onOpenFlash()
                        },
                        onAddTap: { product in
                            onShowDishDetail(product)
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
                    
                    DeliciousYardSectionView(
                        selectedMode: selectedMode,
                        products: deliciousYardProducts,
                        swiggyCards: deliciousYardCards,
                        onSeeAllTap: {
                            onOpenRestaurantView()
                        },
                        onCardTap: {
                            onOpenFlash()
                        },
                        onAddTap: { product in
                            onShowDishDetail(product)
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
                }
                
                FilterChipsView(
                    isFilterActive: viewModel.openNow,
                    isSortActive: viewModel.sortBy != .relevance,
                    isStore99Active: viewModel.hasOffers,
                    isOffersActive: viewModel.hasOffers,
                    onFilterTap: {
                        onOpenRestaurantView()
                    },
                    onSortTap: {
                        onOpenRestaurantView()
                    },
                    onStore99Tap: {
                        onOpenRestaurantView()
                    },
                    onOffersTap: {
                        onOpenRestaurantView()
                    }
                )
                .padding(.top, 10)
                
                Text(topRestaurantsTitle)
                    .font(.system(size: 42/2, weight: .bold))
                    .foregroundColor(Color(hex: "#1F1F1F"))
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 14)
                
                if viewModel.isLoading && selectedMode == .food {
                    VStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { _ in
                            ListShimmerRow()
                        }
                    }
                } else {
                    ExploreRestaurantListView(
                        restaurants: restaurants,
                        favoriteIds: favoriteIds,
                        onFavoriteToggle: { id in
                            if favoriteIds.contains(id) {
                                favoriteIds.remove(id)
                            } else {
                                favoriteIds.insert(id)
                            }
                        },
                        onSelect: { _ in
                            onOpenRestaurantView()
                        }
                    )
                }
            }
        }
        
        private var categorySectionTitle: String {
            switch selectedMode {
            case .food: return "What's on your mind?"
            case .takeAway: return "What's ready for pickup?"
            case .dineIn: return "Where do you want to dine?"
            case .driveThru: return "What's hot on the drive lane?"
            }
        }
        
        private var topRestaurantsTitle: String {
            let count = sourceRestaurants.isEmpty ? 1743 : sourceRestaurants.count
            switch selectedMode {
            case .food: return "Top \(count) restaurants to explore"
            case .takeAway: return "Top \(count) pickup points near you"
            case .dineIn: return "Top \(count) dine-in places near you"
            case .driveThru: return "Top \(count) drive-thru spots near you"
            }
        }
    }
    
    private struct Category: Identifiable, Equatable {
        var id: String { name }
        let name: String
        let image: String
        var isSelected: Bool
    }
    
    private struct CategoryListView: View {
        let items: [Category]
        let title: String
        @State private var selectedId: String
        
        init(items: [Category], title: String) {
            self.items = items
            self.title = title
            self._selectedId = State(initialValue: items.first(where: { $0.isSelected })?.id ?? items.first?.id ?? "")
        }
        
        private var normalizedItems: [Category] {
            items.map { item in
                Category(name: item.name, image: item.image, isSelected: item.id == selectedId)
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.system(size: 42/2, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1D26"))
                    .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(normalizedItems) { item in
                            CategoryItemView(item: item) {
                                selectedId = item.id
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 10)
            }
        }
    }
    
    private struct CategoryItemView: View {
        let item: Category
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                VStack(spacing: 10) {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 84, height: 84)
                            
                            Circle()
                                .stroke(item.isSelected ? Color(hex: "#FF5A00") : Color.clear, lineWidth: 4)
                                .frame(width: 84, height: 84)
                            
                            categoryImage
                                .frame(width: 68, height: 68)
                                .clipShape(Circle())
                        }
                        
                        if item.isSelected {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#FF5A00"))
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 6, y: -4)
                        }
                    }
                    
                    Text(item.name)
                        .font(.system(size: 15, weight: item.isSelected ? .semibold : .regular))
                        .foregroundColor(item.isSelected ? Color(hex: "#FF5A00") : Color(hex: "#676D76"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 104)
                }
                .frame(width: 104)
            }
            .buttonStyle(.plain)
        }
        
        @ViewBuilder
        private var categoryImage: some View {
            if let url = URL(string: item.image), item.image.hasPrefix("http") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Image("burger")
                            .resizable()
                            .scaledToFill()
                    }
                }
            } else {
                Image(item.image)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
    
    private struct Product: Identifiable {
        let id = UUID()
        let name: String
        let image: String
        let price: Int
        let oldPrice: Int?
        let rating: Double
        let ratingCount: Int
        let restaurant: String
        let isVeg: Bool
    }
    
    private struct MoreOnSwiggyCard: Identifiable {
        let id = UUID()
        let title: String
        let image: String
    }
    
    private struct Store99SectionView: View {
        let selectedMode: HomeTopMode
        let products: [Product]
        let swiggyCards: [MoreOnSwiggyCard]
        let onSeeAllTap: () -> Void
        let onCardTap: () -> Void
        let onAddTap: (Product) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    StoreHeaderView(selectedMode: selectedMode, onSeeAllTap: onSeeAllTap)
                    ProductListView(products: products, onAddTap: onAddTap)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#E3F2FD"),
                                    Color(hex: "#F8FAFB")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                
                Text(moreTitle)
                    .font(.system(size: 22/1.4, weight: .bold))
                    .foregroundColor(Color(hex: "#363A43"))
                    .padding(.horizontal, 2)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(swiggyCards) { card in
                            Button(action: onCardTap) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.white)
                                        .frame(width: 132, height: 132)
                                        .overlay(
                                            VStack(spacing: 6) {
                                                Text(card.title)
                                                    .font(.system(size: 11, weight: .black))
                                                    .foregroundColor(Color(hex: "#4A4E57"))
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                                
                                                Image(card.image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 72, height: 56)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            }
                                                .padding(.top, 10)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .stroke(Color(hex: "#E1E3E9"), lineWidth: 1.2)
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        
        private var moreTitle: String {
            switch selectedMode {
            case .food: return "More on FoodZippy"
            case .takeAway: return "More pickup features"
            case .dineIn: return "More dine-in experiences"
            case .driveThru: return "More drive-thru options"
            }
        }
    }
    
    private struct StoreHeaderView: View {
        let selectedMode: HomeTopMode
        let onSeeAllTap: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 24, weight: .black))
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .foregroundStyle(
                                Color(hex: "#1F2937"
                                     )
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: onSeeAllTap) {
                        HStack(spacing: 4) {
                            Text("See All")
                                .font(.system(size: 19/1.4, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "#0C8AC5"))
                    }
                    .buttonStyle(.plain)
                }
                
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#276221"))
                            .frame(width: 23, height: 23)
                        Image(systemName: "star")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 19/1.4, weight: .semibold))
                        .foregroundColor(Color(hex: "#1F2937"))
                }
            }
        }
        
        private var title: String {
            switch selectedMode {
            case .food: return "The Pankh Restaurant's and Cafe & Banquet Hall"
            case .takeAway: return "Quick Pickup Kitchens Near You"
            case .dineIn: return "Premium Dine-In Restaurants"
            case .driveThru: return "Fast Lane Drive-Thru Spots"
            }
        }
        
        private var subtitle: String {
            switch selectedMode {
            case .food: return "3.12 mins"
            case .takeAway: return "Ready in 10 mins"
            case .dineIn: return "Table Booking Available"
            case .driveThru: return "Window Service in 6 mins"
            }
        }
    }
    
    private struct ProductListView: View {
        let products: [Product]
        let onAddTap: (Product) -> Void
        @State private var didAnimate = false
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                        ProductCardView(product: product, onAddTap: { onAddTap(product) })
                            .offset(y: didAnimate ? 0 : 10)
                            .opacity(didAnimate ? 1 : 0)
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.86)
                                .delay(Double(index) * 0.05),
                                value: didAnimate
                            )
                    }
                }
            }
            .onAppear { didAnimate = true }
        }
    }
    
    private struct ProductCardView: View {
        let product: Product
        let onAddTap: () -> Void
        @State private var addPressed = false
        @State private var quantity = 0
        
        var body: some View {
            VStack(alignment: .leading, spacing: 7) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let url = URL(string: product.image), product.image.hasPrefix("http") {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                default:
                                    Image("burger")
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                        } else {
                            Image(product.image)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: 128, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    Group {
                        if quantity == 0 {
                            Button(action: {
                                quantity = 1
                                onAddTap()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(Color(hex: "#1FA971"))
                                    .frame(width: 50, height: 44)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(addPressed ? 0.94 : 1)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in addPressed = true }
                                    .onEnded { _ in addPressed = false }
                            )
                        } else {
                            HStack(spacing: 0) {
                                Button(action: {
                                    if quantity > 0 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: quantity == 1 ? "trash" : "minus")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(quantity == 1 ? Color(hex: "#D94B57") : .white)
                                        .frame(width: 22, height: 22)
                                        .background(Color(hex: "#1FA971"))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                
                                Text("\(quantity)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(hex: "#1FA971"))
                                    .frame(maxWidth: .infinity)
                                
                                Button(action: {
                                    quantity += 1
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.white)
                                        .frame(width: 22, height: 22)
                                        .background(Color(hex: "#1FA971"))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                            .frame(height: 44)
                            .padding(.horizontal, 4)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
                        }
                    }
                    .offset(x: 8, y: 9)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(product.isVeg ? Color(hex: "#1FA971") : Color(hex: "#D94B57"), lineWidth: 1.5)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .fill(product.isVeg ? Color(hex: "#1FA971") : Color(hex: "#D94B57"))
                                    .frame(width: 6, height: 6)
                            )
                        
                        Text(product.name)
                            .font(.system(size: 14.5, weight: .semibold))
                            .foregroundColor(Color(hex: "#3A3F46"))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack(alignment: .center, spacing: 6) {
                        if let oldPrice = product.oldPrice {
                            Text("₹\(oldPrice)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "#424B5A"))
                                .strikethrough()
                        }
                        
                        Text("₹\(product.price)")
                            .font(.system(size: 14.5, weight: .black))
                            .foregroundColor(Color(hex: "#1E1E1E"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#FFD400"))
                            .clipShape(PriceTagShape())
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(String(format: "%.1f (%d)", product.rating, product.ratingCount))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "#1AA572"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#D8F3E8"))
                    .clipShape(Capsule())
                    
                    Rectangle()
                        .fill(Color(hex: "#D8DDE5"))
                        .frame(width: 24, height: 1)
                    
                    Text(product.restaurant)
                        .font(.system(size: 12.5, weight: .regular))
                        .foregroundColor(Color(hex: "#9399A3"))
                        .lineLimit(1)
                }
            }
            .frame(width: 128, alignment: .leading)
        }
    }
    
    private struct PriceTagShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let cut: CGFloat = 8
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
    
    private struct FilterChipsView: View {
        let isFilterActive: Bool
        let isSortActive: Bool
        let isStore99Active: Bool
        let isOffersActive: Bool
        let onFilterTap: () -> Void
        let onSortTap: () -> Void
        let onStore99Tap: () -> Void
        let onOffersTap: () -> Void
        
        @State private var showSortMenu = false
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ChipButton(active: isFilterActive, action: onFilterTap) {
                        HStack(spacing: 6) {
                            Text("Filter")
                                .font(.system(size: 16, weight: .medium))
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    
                    ZStack(alignment: .topLeading) {
                        ChipButton(active: isSortActive, action: { showSortMenu.toggle() }) {
                            HStack(spacing: 6) {
                                Text("Sort by")
                                    .font(.system(size: 16, weight: .medium))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 13, weight: .bold))
                                    .rotationEffect(.degrees(showSortMenu ? 180 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: showSortMenu)
                            }
                        }
                        
                        if showSortMenu {
                            VStack(alignment: .leading, spacing: 0) {
                                SortMenuItem(title: "Relevance", action: {
                                    onSortTap()
                                    showSortMenu = false
                                })
                                Divider().padding(.horizontal, 8)
                                SortMenuItem(title: "Rating", action: {
                                    onSortTap()
                                    showSortMenu = false
                                })
                                Divider().padding(.horizontal, 8)
                                SortMenuItem(title: "Time", action: {
                                    onSortTap()
                                    showSortMenu = false
                                })
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                            .padding(.top, 48)
                            .zIndex(100)
                        }
                    }
                    
                    ChipButton(active: isStore99Active, action: onStore99Tap) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "#F9A602"))
                            Text("99 Store")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    
                    ChipButton(active: isOffersActive, action: onOffersTap) {
                        HStack(spacing: 6) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "#F9A602"))
                            Text("Offers")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private struct SortMenuItem: View {
        let title: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#1F1F1F"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct ChipButton<Content: View>: View {
        let active: Bool
        let action: () -> Void
        @ViewBuilder let content: Content
        
        var body: some View {
            Button(action: action) {
                content
                    .foregroundColor(Color(hex: "#262626"))
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(active ? Color(hex: "#F4F4F4") : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct ExploreRestaurantListView: View {
        struct Restaurant: Identifiable {
            let id: String
            let name: String
            let image: String
            let offer: String
            let rating: Double
            let reviews: String
            let deliveryTime: String
            let cuisine: String
            let location: String
            let distance: String
            let isFavorite: Bool
        }
        
        let restaurants: [Restaurant]
        let favoriteIds: Set<String>
        let onFavoriteToggle: (String) -> Void
        let onSelect: (Restaurant) -> Void
        
        var body: some View {
            LazyVStack(spacing: 18) {
                ForEach(restaurants) { restaurant in
                    RestaurantCardView(
                        restaurant: restaurant,
                        isFavorite: favoriteIds.contains(restaurant.id) || restaurant.isFavorite,
                        onFavoriteTap: { onFavoriteToggle(restaurant.id) },
                        onTap: { onSelect(restaurant) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private struct RestaurantCardView: View {
        let restaurant: ExploreRestaurantListView.Restaurant
        let isFavorite: Bool
        let onFavoriteTap: () -> Void
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack(alignment: .topTrailing) {
                        ZStack(alignment: .bottomLeading) {
                            Group {
                                if let url = URL(string: restaurant.image), restaurant.image.hasPrefix("http") {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().scaledToFill()
                                        default:
                                            Image("burger")
                                                .resizable()
                                                .scaledToFill()
                                        }
                                    }
                                } else {
                                    Image("burger")
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                            .frame(width: 124, height: 158)
                            .clipped()
                            
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.72)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(width: 124, height: 158)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("ITEMS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                Text("AT \(restaurant.offer)")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        
                        Button(action: onFavoriteTap) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(isFavorite ? Color(hex: "#E23744") : Color(hex: "#616161"))
                                .frame(width: 32, height: 32)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.16), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 0) {
                            Text(" Food in 10–15 min")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#2B2B2B"))
                                .lineLimit(1)
                            
                            Spacer(minLength: 4)
                            
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#9A9A9A"))
                        }
                        
                        Text(restaurant.name)
                            .font(.system(size: 23/1.7, weight: .bold))
                            .foregroundColor(Color(hex: "#1B1B1B"))
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: "#128B4C"))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.system(size: 17/1.4, weight: .bold))
                                .foregroundColor(Color(hex: "#1D1D1D"))
                            
                            Text("(\(restaurant.reviews))")
                                .font(.system(size: 17/1.4, weight: .semibold))
                                .foregroundColor(Color(hex: "#1D1D1D"))
                            
                            Text("•")
                                .font(.system(size: 17/1.4, weight: .bold))
                                .foregroundColor(Color(hex: "#6F6F6F"))
                            
                            Text(restaurant.deliveryTime)
                                .font(.system(size: 17/1.4, weight: .semibold))
                                .foregroundColor(Color(hex: "#1D1D1D"))
                        }
                        
                        Text(restaurant.cuisine)
                            .font(.system(size: 18/1.35, weight: .regular))
                            .foregroundColor(Color(hex: "#686868"))
                            .lineLimit(1)
                        
                        Text("\(restaurant.location) • \(restaurant.distance)")
                            .font(.system(size: 18/1.35, weight: .regular))
                            .foregroundColor(Color(hex: "#686868"))
                            .lineLimit(1)
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct ListShimmerRow: View {
        @State private var on = false
        var body: some View {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.13))
                    .frame(width: 88, height: 88)
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.13)).frame(height: 13)
                    RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.09)).frame(width: 120, height: 10)
                    RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.09)).frame(width: 80, height: 10)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .opacity(on ? 0.45 : 1)
            .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: on)
            .onAppear { on = true }
        }
    }
    
    private struct DeliciousYardSectionView: View {
        let selectedMode: HomeTopMode
        let products: [Product]
        let swiggyCards: [MoreOnSwiggyCard]
        let onSeeAllTap: () -> Void
        let onCardTap: () -> Void
        let onAddTap: (Product) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    DeliciousYardHeaderView(selectedMode: selectedMode, onSeeAllTap: onSeeAllTap)
                    ProductListView(products: products, onAddTap: onAddTap)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#E3F2FD"),
                                    Color(hex: "#F8FAFB")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
        }
    }
    
    private struct DeliciousYardHeaderView: View {
        let selectedMode: HomeTopMode
        let onSeeAllTap: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(
                                Color(hex: "#1F2937")
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: onSeeAllTap) {
                        HStack(spacing: 4) {
                            Text("See All")
                                .font(.system(size: 19/1.4, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#0C8AC5"),
                                    Color.white
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                HStack(spacing: 8) {
                    
                    Text(subtitle)
                        .font(.system(size: 19/1.4, weight: .semibold))
                        .foregroundColor(Color(hex: "#1F2937"))
                }
            }
        }
        
        private var title: String {
            switch selectedMode {
            case .food: return "delicious yard"
            case .takeAway: return "pickup express"
            case .dineIn: return "signature dining"
            case .driveThru: return "turbo lane"
            }
        }
        
        private var subtitle: String {
            switch selectedMode {
            case .food: return "₹ 2000 for two"
            case .takeAway: return "Quick combos from ₹99"
            case .dineIn: return "Fine meals from ₹499"
            case .driveThru: return "Fast meals from ₹129"
            }
        }
    }
    
    // MARK: - Address helpers
    
    private func addressLine1(_ addr: Address) -> String {
        if let hno = addr.hno, !hno.isEmpty { return hno }
        return addr.type ?? "Home"
    }
    
    // MARK: - Promotional Banner Models & Views
    
    struct PromotionalBanner: Identifiable {
        let id: String
        let backgroundColor: Color
        let accentColor: Color
        let mainTitle: String
        let subtitle: String
        let image: String
        let restaurantName: String?
        let discount: String?
        let bannerImage: String?
        
        init(
            id: String,
            backgroundColor: Color,
            accentColor: Color,
            mainTitle: String,
            subtitle: String,
            image: String,
            restaurantName: String? = nil,
            discount: String? = nil,
            bannerImage: String? = nil
        ) {
            self.id = id
            self.backgroundColor = backgroundColor
            self.accentColor = accentColor
            self.mainTitle = mainTitle
            self.subtitle = subtitle
            self.image = image
            self.restaurantName = restaurantName
            self.discount = discount
            self.bannerImage = bannerImage
        }
    }
    
    private struct PromotionalBannerCarouselView: View {
        let banners: [PromotionalBanner]
        @State private var currentIndex = 0
        @State private var timer: Timer?
        
        var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $currentIndex) {
                    ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                        PromotionalBannerCard(banner: banner)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 160)
                .padding(.horizontal, 12)
                .onAppear {
                    startAutoScroll()
                }
                .onDisappear {
                    stopAutoScroll()
                }
                
                // Page indicators removed per request
            }
        }
        
        private func startAutoScroll() {
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentIndex = (currentIndex + 1) % banners.count
                }
            }
        }
        
        private func stopAutoScroll() {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private struct PromotionalBannerCard: View {
        let banner: PromotionalBanner
        
        var body: some View {
            if banner.restaurantName != nil {
                DesserBannerCard(banner: banner)
            } else {
                StandardBannerCard(banner: banner)
            }
        }
    }
    
    private struct StandardBannerCard: View {
        let banner: PromotionalBanner
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(banner.backgroundColor)
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(banner.mainTitle)
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                        
                        Text(banner.subtitle)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#424242"))
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(banner.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        
                        Spacer()
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
    
    private struct DesserBannerCard: View {
        let banner: PromotionalBanner
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(banner.backgroundColor)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(banner.restaurantName ?? "")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(banner.accentColor)
                            .tracking(1)
                        
                        Text("Best pastries and\ndesserts in town.\nWe are waiting for\nyour whole family!")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(banner.accentColor)
                            .lineLimit(4)
                        
                        Text(banner.mainTitle)
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                        
                        Text(banner.subtitle)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                        
                        if let discount = banner.discount {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                
                                VStack(spacing: 1) {
                                    Text(discount)
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(banner.accentColor)
                                    Text("Discount")
                                        .font(.system(size: 8, weight: .semibold))
                                        .foregroundColor(banner.accentColor)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        Image(banner.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        
                        Image(banner.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        
                        Image(banner.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
        // MARK: - Dine-In Helper Sub-Views

    /// Walk-in restaurant card (horizontal scroll) — matches Android card style exactly
    private struct DineInWalkInCard: View {
        let restaurant: Restaurant?
        let actionLabel: String
        let onTap: () -> Void

        private func resolvedImageURL(_ raw: String?) -> URL? {
            guard let raw = raw, !raw.isEmpty else { return nil }
            if raw.hasPrefix("http") { return URL(string: raw) }
            return URL(string: Constants.baseURL + raw)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    // Restaurant image
                    if let url = resolvedImageURL(restaurant?.restImg) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Color(hex: "#F0F0F0")
                            }
                        }
                        .frame(width: 180, height: 120)
                        .clipped()
                    } else {
                        Color(hex: "#E8E8E8")
                            .frame(width: 180, height: 120)
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "#BDBDBD"))
                            )
                    }

                    // Heart favourite button
                    Image(systemName: "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "#616161"))
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                        .padding(8)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(restaurant?.restTitle ?? "Restaurant")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#E23744"))
                        Text(restaurant?.restRating ?? "4.5")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                        Text("• \(restaurant?.restDistance ?? "1.0 km")")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#757575"))
                    }

                    Text(restaurant?.restSdesc ?? "Multi Cuisine")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .lineLimit(1)

                    Button(action: onTap) {
                        Text(actionLabel)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(Color(hex: "#E23744"))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
            }
            .frame(width: 180)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        }
    }

    private struct DineInBookingCard: View {
        let restaurant: Restaurant?
        let bookingTime: String
        let bookingStatus: String
        let onTap: () -> Void

        private func resolvedImageURL(_ raw: String?) -> URL? {
            guard let raw = raw, !raw.isEmpty else { return nil }
            if raw.hasPrefix("http") { return URL(string: raw) }
            return URL(string: Constants.baseURL + raw)
        }

        var body: some View {
            HStack(spacing: 12) {
                if let url = resolvedImageURL(restaurant?.restImg) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            Color(hex: "#F0F0F0")
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    Color(hex: "#E8E8E8")
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#BDBDBD"))
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant?.restTitle ?? "Restaurant")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(bookingTime)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#757575"))
                    
                    Text(bookingStatus)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#1D8B41"))
                }
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "#BDBDBD"))
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(hex: "#E8E8E8"), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
            .onTapGesture {
                onTap()
            }
        }
    }

    /// Spotlight banner card — full-width-ish red banner card like Android screenshot
    private struct DineInSpotlightBannerCard: View {
        let banner: HomeBannerItem

        private func resolvedImageURL(_ raw: String?) -> URL? {
            guard let raw = raw, !raw.isEmpty else { return nil }
            if raw.hasPrefix("http") { return URL(string: raw) }
            return URL(string: Constants.baseURL + raw)
        }

        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if let url = resolvedImageURL(banner.bannerImg) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color(hex: "#EFEFEF")
                                .overlay(ProgressView().tint(.white))
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .failure:
                            Color(hex: "#C62828")
                        @unknown default:
                            Color(hex: "#C62828")
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 52, height: 130)
                    .clipped()
                } else {
                    // Fallback: red gradient like Android
                    LinearGradient(
                        colors: [Color(hex: "#B71C1C"), Color(hex: "#E53935")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .frame(width: UIScreen.main.bounds.width - 52, height: 130)
                }

                // Overlay text
                if let title = banner.bannerTitle, !title.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        if let restName = banner.restaurantName {
                            Text(restName.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        Text(title)
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 52, height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    /// Events/facilities card for Dine-In.
    private struct DineInFacilityCard: View {
        let facility: Facility

        private func resolvedImageURL(_ raw: String?) -> URL? {
            guard let raw = raw, !raw.isEmpty else { return nil }
            if raw.hasPrefix("http") { return URL(string: raw) }
            return URL(string: Constants.baseURL + raw)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "#ECECEC"))
                        .frame(width: 120, height: 96)

                    if let url = resolvedImageURL(facility.icon) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(hex: "#ECECEC"))
                                    .overlay(ProgressView().tint(.gray))
                            case .success(let img):
                                img.resizable().scaledToFill()
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "#B0B0B0"))
                            @unknown default:
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "#B0B0B0"))
                            }
                        }
                        .frame(width: 120, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                Text(facility.name ?? "Facility Name")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .frame(width: 120, alignment: .center)
            }
        }
    }

    /// Popular brand circle — circular image + restaurant name label
    private struct DineInBrandCircle: View {
        let restaurant: Restaurant?

        private func resolvedImageURL(_ raw: String?) -> URL? {
            guard let raw = raw, !raw.isEmpty else { return nil }
            if raw.hasPrefix("http") { return URL(string: raw) }
            return URL(string: Constants.baseURL + raw)
        }

        var body: some View {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 80, height: 80)

                    if let url = resolvedImageURL(restaurant?.restImg) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Circle()
                                    .fill(Color.white.opacity(0.18))
                                    .overlay(ProgressView().tint(.white))
                            case .success(let img):
                                img.resizable().scaledToFill()
                            case .failure:
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white.opacity(0.5))
                            @unknown default:
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )

                Text(restaurant?.restTitle ?? "Restaurant")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 80)
            }
        }
    }

    /// Restaurants-to-explore card — large image + info row, exactly like Android
    private struct DineInRestaurantExploreCard: View {
        let restaurant: Restaurant

        private func resolvedImageURL(_ raw: String?) -> URL? {
            guard let raw = raw, !raw.isEmpty else { return nil }
            if raw.hasPrefix("http") { return URL(string: raw) }
            return URL(string: Constants.baseURL + raw)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Image with distance badge
                ZStack(alignment: .topTrailing) {
                    if let url = resolvedImageURL(restaurant.restImg) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Color(hex: "#E8E8E8")
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 32))
                                            .foregroundColor(Color(hex: "#BDBDBD"))
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                    } else {
                        Color(hex: "#E8E8E8")
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "#BDBDBD"))
                            )
                    }

                    // Distance badge (top-right)
                    if let dist = restaurant.restDistance {
                        Text("\(dist) km")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .padding(10)
                    }
                }

                // Info row
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(restaurant.restTitle ?? "Restaurant")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        // Veg / Non-veg indicator
                        ZStack {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(restaurant.isVeg ? Color(hex: "#22A45D") : Color(hex: "#E23744"), lineWidth: 1.5)
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(restaurant.isVeg ? Color(hex: "#22A45D") : Color(hex: "#E23744"))
                                .frame(width: 8, height: 8)
                        }
                    }

                    HStack(spacing: 6) {
                        // Rating badge
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            Text(restaurant.restRating ?? "4.0")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#22A45D"))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                        Text("•")
                            .foregroundColor(Color(hex: "#9E9E9E"))
                        Text(restaurant.restDeliverytime ?? "30 mins")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#5E5E5E"))
                        Text("•")
                            .foregroundColor(Color(hex: "#9E9E9E"))
                        Text("₹\(restaurant.restCostfortwo ?? "0") for two")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#5E5E5E"))
                    }

                    Text(restaurant.restLandmark ?? restaurant.restFullAddress ?? "Jaipur")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#757575"))

                    Text(restaurant.isOpen ? "Open" : "Closed")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(restaurant.isOpen ? Color(hex: "#22A45D") : Color(hex: "#E23744"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .background(Color.white)
        }
    }

#if DEBUG

    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
                .environmentObject(CartManager.shared)
        }
    }
#endif
}
