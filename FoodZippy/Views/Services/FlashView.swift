import SwiftUI

// MARK: - Flash / 99 Store View Model
@MainActor
final class FlashStoreViewModel: ObservableObject {
    @Published var categories: [FlashStoreCategory] = []
    @Published var trendingItems: [FlashStoreItem] = []
    @Published var allItems: [FlashStoreItem] = []
    @Published var isLoading = false

    private var loaded = false

    let totalItemCount = 734

    func loadIfNeeded() async {
        guard !loaded else { return }
        await refresh()
        loaded = true
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 250_000_000)
        seedContent()
    }

    func filteredItems(category: String, priceFilter: FlashPriceFilter, dietFilter: FlashDietFilter) -> [FlashStoreItem] {
        allItems.filter { item in
            let matchesCategory = category == "All" || item.category == category
            let matchesPrice = item.finalPrice <= priceFilter.upperBound
            let matchesDiet: Bool = {
                switch dietFilter {
                case .all: return true
                case .veg: return item.isVeg
                case .nonVeg: return !item.isVeg
                }
            }()
            return matchesCategory && matchesPrice && matchesDiet
        }
    }

    func trendingItems(category: String, priceFilter: FlashPriceFilter, dietFilter: FlashDietFilter) -> [FlashStoreItem] {
        Array(filteredItems(category: category, priceFilter: priceFilter, dietFilter: dietFilter).prefix(6))
    }

    private func seedContent() {
        categories = [
            FlashStoreCategory(title: "All", imageURL: "https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=300&q=80"),
            FlashStoreCategory(title: "Pizzas", imageURL: "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=300&q=80"),
            FlashStoreCategory(title: "Burgers", imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=300&q=80"),
            FlashStoreCategory(title: "Biryani", imageURL: "https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?auto=format&fit=crop&w=300&q=80"),
            FlashStoreCategory(title: "Rolls", imageURL: "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=300&q=80")
        ]

        allItems = [
            FlashStoreItem(id: "sev-tamater", title: "Sev Tamater", restaurantName: "Shri Govindam", imageURL: "https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=600&q=80", category: "All", rating: 4.0, ratingCount: 340, oldPrice: 80, finalPrice: 69, isVeg: true, badgeText: "₹99 DEAL"),
            FlashStoreItem(id: "classic-egg-roll", title: "Classic Egg Roll", restaurantName: "Roll Express", imageURL: "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=600&q=80", category: "Rolls", rating: 4.4, ratingCount: 227, oldPrice: 118, finalPrice: 59, isVeg: false, badgeText: "HOT"),
            FlashStoreItem(id: "spicy-chicken-kuboos", title: "Spicy Chicken Kuboos", restaurantName: "Shawarmajaan", imageURL: "https://images.unsplash.com/photo-1603360946369-dc9bb6258143?auto=format&fit=crop&w=600&q=80", category: "Rolls", rating: 4.1, ratingCount: 18, oldPrice: 159, finalPrice: 99, isVeg: false, badgeText: "BEST SELLER"),
            FlashStoreItem(id: "paneer-biryani-bowl", title: "Paneer Biryani Bowl", restaurantName: "Biryani House", imageURL: "https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?auto=format&fit=crop&w=600&q=80", category: "Biryani", rating: 4.5, ratingCount: 412, oldPrice: 149, finalPrice: 99, isVeg: true, badgeText: "TRENDING"),
            FlashStoreItem(id: "peri-peri-burger", title: "Peri Peri Burger", restaurantName: "Burger Barn", imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80", category: "Burgers", rating: 4.2, ratingCount: 289, oldPrice: 129, finalPrice: 89, isVeg: false, badgeText: "NEW"),
            FlashStoreItem(id: "margherita-slice", title: "Classic Margherita", restaurantName: "Pizza Point", imageURL: "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80", category: "Pizzas", rating: 4.3, ratingCount: 560, oldPrice: 139, finalPrice: 99, isVeg: true, badgeText: "TOP PICK"),
            FlashStoreItem(id: "veg-roll", title: "Veg Mayo Roll", restaurantName: "Roll Express", imageURL: "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=600&q=80", category: "Rolls", rating: 4.2, ratingCount: 127, oldPrice: 109, finalPrice: 79, isVeg: true, badgeText: "CHEF SPECIAL"),
            FlashStoreItem(id: "chicken-burger", title: "Chicken Crunch Burger", restaurantName: "Burger Barn", imageURL: "https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=600&q=80", category: "Burgers", rating: 4.6, ratingCount: 181, oldPrice: 149, finalPrice: 99, isVeg: false, badgeText: "LIMITED"),
            FlashStoreItem(id: "veg-biryani", title: "Veg Dum Biryani", restaurantName: "Biryani House", imageURL: "https://images.unsplash.com/photo-1613514785940-daed07799d9b?auto=format&fit=crop&w=600&q=80", category: "Biryani", rating: 4.1, ratingCount: 301, oldPrice: 119, finalPrice: 89, isVeg: true, badgeText: "HOT"),
            FlashStoreItem(id: "mushroom-pizza", title: "Mushroom Cheese Pizza", restaurantName: "Pizza Point", imageURL: "https://images.unsplash.com/photo-1548365328-9f547fb095b5?auto=format&fit=crop&w=600&q=80", category: "Pizzas", rating: 4.5, ratingCount: 245, oldPrice: 179, finalPrice: 149, isVeg: true, badgeText: "NEW"),
            FlashStoreItem(id: "paneer-roll", title: "Paneer Tikka Roll", restaurantName: "Shawarmajaan", imageURL: "https://images.unsplash.com/photo-1633933358116-a27b902fad35?auto=format&fit=crop&w=600&q=80", category: "Rolls", rating: 4.0, ratingCount: 98, oldPrice: 99, finalPrice: 69, isVeg: true, badgeText: "₹99 DEAL"),
            FlashStoreItem(id: "fry-burger", title: "Cheese Fries Burger", restaurantName: "Burger Barn", imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80", category: "Burgers", rating: 4.2, ratingCount: 210, oldPrice: 159, finalPrice: 99, isVeg: true, badgeText: "SAVE MORE")
        ]

        trendingItems = Array(allItems.prefix(6))
    }
}

enum FlashPriceFilter: String, CaseIterable, Identifiable {
    case under99 = "₹99 & under"
    case under149 = "₹100 – ₹149"

    var id: String { rawValue }

    var upperBound: Double {
        switch self {
        case .under99: return 99
        case .under149: return 149
        }
    }
}

enum FlashDietFilter: String, CaseIterable, Identifiable {
    case all = "Veg/Non-Veg"
    case veg = "Veg"
    case nonVeg = "Non-Veg"

    var id: String { rawValue }
}

struct FlashStoreCategory: Identifiable {
    let id = UUID()
    let title: String
    let imageURL: String
}

struct FlashStoreItem: Identifiable {
    let id: String
    let title: String
    let restaurantName: String
    let imageURL: String
    let category: String
    let rating: Double
    let ratingCount: Int
    let oldPrice: Double
    let finalPrice: Double
    let isVeg: Bool
    let badgeText: String

    var ratingText: String { String(format: "%.1f", rating) }
    var oldPriceText: String {
        if oldPrice == floor(oldPrice) {
            return "₹\(Int(oldPrice))"
        }
        return "₹\(String(format: "%.2f", oldPrice))"
    }
    var finalPriceText: String {
        if finalPrice == floor(finalPrice) {
            return "₹\(Int(finalPrice))"
        }
        return "₹\(String(format: "%.2f", finalPrice))"
    }
}

struct FlashRestaurantSection: Identifiable {
    let id: String
    let restaurantName: String
    let rating: Double
    let reviewCount: Int
    let deliveryTime: String
    let offerText: String
    let dishes: [FlashDish]

    var ratingText: String { String(format: "%.1f", rating) }
}

struct FlashDish: Identifiable {
    let id: String
    let title: String
    let imageURL: String
    let price: Double
    let oldPrice: Double
    let isVeg: Bool
    let rating: Double
    let ratingCount: Int
    let description: String
    let isCustomizable: Bool
    let customisationOptions: [DishCustomisationOption]

    var priceText: String {
        if price == floor(price) {
            return "₹\(Int(price))"
        }
        return "₹\(String(format: "%.2f", price))"
    }
}

// MARK: - Flash Store View
struct FlashView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var cartManager: CartManager
    @StateObject private var viewModel = FlashStoreViewModel()
    @StateObject private var cartViewModel = AddToCartViewModel.shared
    @State private var selectedCategory = "All"
    @State private var selectedPriceFilter: FlashPriceFilter = .under99
    @State private var selectedDietFilter: FlashDietFilter = .all
    @State private var selectedDishForDetail: AddToCartDish?
    @State private var selectedDishForCustomization: AddToCartDish?
    @State private var queuedCustomizationDish: AddToCartDish?

    private var heroHeight: CGFloat {
        horizontalSizeClass == .regular ? 280 : 248
    }

    private var gridColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
        }
        return [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    }

    private var heroTitleFontSize: CGFloat {
        horizontalSizeClass == .regular ? 56 : 48
    }

    private var heroSubtitleFontSize: CGFloat {
        horizontalSizeClass == .regular ? 20 : 18
    }

    private var sectionTitleFontSize: CGFloat {
        horizontalSizeClass == .regular ? 32 : 28
    }

    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .regular ? 24 : 16
    }

    private let brandImages = [
        "https://images.unsplash.com/photo-1585238341710-4dd0bd180d8d?auto=format&fit=crop&w=200&q=80",
        "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=200&q=80",
        "https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=200&q=80",
        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80",
        "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=200&q=80",
        "https://images.unsplash.com/photo-1559827260-dc66d52bef19?auto=format&fit=crop&w=200&q=80"
    ]

    private var filteredItems: [FlashStoreItem] {
        viewModel.filteredItems(
            category: selectedCategory,
            priceFilter: selectedPriceFilter,
            dietFilter: selectedDietFilter
        )
    }

    private var filteredTrendingItems: [FlashStoreItem] {
        viewModel.trendingItems(
            category: selectedCategory,
            priceFilter: selectedPriceFilter,
            dietFilter: selectedDietFilter
        )
    }

    private var flashRestaurantSections: [FlashRestaurantSection] {
        [
            FlashRestaurantSection(
                id: "burger-farm-1",
                restaurantName: "Burger Farm",
                rating: 4.6,
                reviewCount: 14,
                deliveryTime: "10–15 min",
                offerText: "40% off upto ₹80",
                dishes: [
                    FlashDish(id: "farm-aloo-1", title: "Farm Aloo Tikki", imageURL: "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=500&q=80", price: 71, oldPrice: 99, isVeg: true, rating: 4.6, ratingCount: 14, description: "Crisp aloo tikki burger with fresh veggies and house sauce.", isCustomizable: false, customisationOptions: []),
                    FlashDish(id: "farm-aloo-2", title: "Farm Aloo Tikki", imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=80", price: 71, oldPrice: 99, isVeg: true, rating: 4.5, ratingCount: 21, description: "Loaded aloo tikki burger in soft bun with signature spices.", isCustomizable: true, customisationOptions: [DishCustomisationOption(id: "half", title: "Half", additionalPrice: 0, isVeg: true), DishCustomisationOption(id: "full", title: "Full", additionalPrice: 40, isVeg: true)]),
                    FlashDish(id: "farm-aloo-3", title: "Farm Aloo Tikki", imageURL: "https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=500&q=80", price: 71, oldPrice: 99, isVeg: true, rating: 4.4, ratingCount: 31, description: "Crunchy and juicy burger with tomato chutney flavour.", isCustomizable: false, customisationOptions: [])
                ]
            ),
            FlashRestaurantSection(
                id: "burger-farm-2",
                restaurantName: "Burger Farm",
                rating: 4.6,
                reviewCount: 14,
                deliveryTime: "10–15 min",
                offerText: "40% off upto ₹80",
                dishes: [
                    FlashDish(id: "farm-aloo-4", title: "Farm Aloo Tikki", imageURL: "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=500&q=80", price: 71, oldPrice: 99, isVeg: true, rating: 4.6, ratingCount: 14, description: "Classic aloo tikki burger combo style taste.", isCustomizable: false, customisationOptions: []),
                    FlashDish(id: "farm-aloo-5", title: "Farm Aloo Tikki", imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=80", price: 71, oldPrice: 99, isVeg: true, rating: 4.4, ratingCount: 18, description: "Farm style burger with crispy patty and tangy spread.", isCustomizable: true, customisationOptions: [DishCustomisationOption(id: "half", title: "Half", additionalPrice: 0, isVeg: true), DishCustomisationOption(id: "full", title: "Full", additionalPrice: 40, isVeg: true)]),
                    FlashDish(id: "farm-aloo-6", title: "Farm Aloo Tikki", imageURL: "https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=500&q=80", price: 71, oldPrice: 99, isVeg: true, rating: 4.3, ratingCount: 11, description: "Popular spicy tikki burger with soft bun and sauces.", isCustomizable: false, customisationOptions: [])
                ]
            )
        ]
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#FAFAFA").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    heroBanner
                    brandsSection
                    categoriesSection
                    bannersSection
                    flashRestaurantsSection
                }
                .padding(.bottom, 24)
            }
            .refreshable { await viewModel.refresh() }

            if let dish = selectedDishForDetail {
                SpringBottomSheetOverlay(onDismissed: {
                    selectedDishForDetail = nil
                    if let queuedDish = queuedCustomizationDish {
                        queuedCustomizationDish = nil
                        if selectedDishForCustomization == nil {
                            selectedDishForCustomization = queuedDish
                        }
                    }
                }) { dismiss in
                    DishDetailSheetView(
                        dish: dish,
                        cartViewModel: cartViewModel,
                        onClose: dismiss,
                        onRequestCustomization: { customDish in
                            queuedCustomizationDish = customDish
                            dismiss()
                        }
                    )
                }
                .zIndex(10)
            }

            if selectedDishForDetail == nil, let dish = selectedDishForCustomization {
                SpringBottomSheetOverlay(onDismissed: {
                    selectedDishForCustomization = nil
                }) { dismiss in
                    CustomisationSheetView(
                        dish: dish,
                        cartViewModel: cartViewModel,
                        onClose: dismiss
                    )
                }
                .zIndex(11)
            }
        }
        .task { await viewModel.loadIfNeeded() }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var heroBanner: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#F72437"), Color(hex: "#D41F31")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.white.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 24,
                endRadius: 420
            )

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.18))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.18))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                Spacer(minLength: 0)

                HStack(alignment: .bottom, spacing: 8) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("99 store")
                            .font(.system(size: heroTitleFontSize, weight: .black, design: .rounded))
                            .foregroundColor(Color.white)
                            .shadow(color: .black.opacity(0.25), radius: 0, x: 2, y: 2)

                        Text("Meals at ₹99 + Free Delivery")
                            .font(.system(size: heroSubtitleFontSize, weight: .semibold))
                            .foregroundColor(Color(hex: "#F72437"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 26)

                    Spacer(minLength: 0)

                    heroFoodStack
                        .frame(width: horizontalSizeClass == .regular ? 220 : 190, height: horizontalSizeClass == .regular ? 185 : 162)
                        .padding(.trailing, horizontalSizeClass == .regular ? 20 : 10)
                        .padding(.bottom, horizontalSizeClass == .regular ? 20 : 12)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
        .clipped()
    }

    private var heroFoodStack: some View {
        ZStack(alignment: .trailing) {
            heroImage(
                url: "https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=700&q=80",
                size: CGSize(width: 102, height: 102),
                offset: CGSize(width: -112, height: 34)
            )

            heroImage(
                url: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=700&q=80",
                size: CGSize(width: 126, height: 126),
                offset: CGSize(width: -14, height: 54)
            )

            heroImage(
                url: "https://images.unsplash.com/photo-1513610364583-349559d0edab?auto=format&fit=crop&w=700&q=80",
                size: CGSize(width: 104, height: 104),
                offset: CGSize(width: -34, height: -8)
            )
        }
    }

    private func heroImage(url: String, size: CGSize, offset: CGSize) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: size.width / 2, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .overlay(ProgressView().tint(.white))
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                RoundedRectangle(cornerRadius: size.width / 2, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white.opacity(0.85))
                    )
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 3))
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
        .offset(offset)
    }

    private var brandsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Popular Brands")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#171A29"))
                .padding(.horizontal, horizontalPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: horizontalSizeClass == .regular ? 28 : 22) {
                    ForEach(0..<6, id: \.self) { index in
                        BrandItemView(
                            imageURL: brandImages[index % brandImages.count],
                            sizeClass: horizontalSizeClass
                        )
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What's on your mind?")
                 .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#171A29"))
                .padding(.horizontal, horizontalPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: horizontalSizeClass == .regular ? 28 : 22) {
                    ForEach(viewModel.categories) { item in
                        CategoryItemView(
                            item: item,
                            isSelected: selectedCategory == item.title,
                            sizeClass: horizontalSizeClass
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                selectedCategory = item.title
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }

    private var bannersSection: some View {
        VStack(spacing: 0) {
            TabView {
                ForEach(promotionalBanners) { banner in
                    PromotionalBannerCard(banner: banner)
                        .padding(.horizontal, 12)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 160)
        }
    }

    private var promotionalBanners: [FlashPromotionalBanner] {
        [
            FlashPromotionalBanner(
                id: "flash-banner-1",
                backgroundColor: Color(hex: "#FFC107"),
                accentColor: Color(hex: "#FF9800"),
                mainTitle: "Fresh Flash",
                subtitle: "Mega Deals Daily",
                image: "burger",
                bannerImage: nil
            ),
            FlashPromotionalBanner(
                id: "flash-banner-2",
                backgroundColor: Color(hex: "#FF9800"),
                accentColor: Color(hex: "#FF7043"),
                mainTitle: "Quick Eats",
                subtitle: "99 Store Specials",
                image: "burger",
                bannerImage: nil
            )
        ]
    }

    private var flashRestaurantsSection: some View {
        LazyVStack(spacing: 14) {
            ForEach(flashRestaurantSections) { section in
                RestaurantFlashCardView(
                    section: section,
                    onViewItems: {
                        selectedCategory = "All"
                    },
                    onDishTap: { dish in
                        presentDishDetail(for: dish, restaurant: section)
                    }
                )
            }
        }
        .padding(.horizontal, 12)
    }

    private func toAddToCartDish(_ dish: FlashDish, restaurant: FlashRestaurantSection) -> AddToCartDish {
        AddToCartDish(
            id: dish.id,
            restaurantId: restaurant.id,
            restaurantName: restaurant.restaurantName,
            title: dish.title,
            imageURL: dish.imageURL,
            description: dish.description,
            basePrice: dish.price,
            oldPrice: dish.oldPrice,
            rating: dish.rating,
            ratingCount: dish.ratingCount,
            isVeg: dish.isVeg,
            isCustomizable: dish.isCustomizable,
            customisationOptions: dish.customisationOptions
        )
    }

    private func presentDishDetail(for dish: FlashDish, restaurant: FlashRestaurantSection) {
        guard selectedDishForDetail == nil else { return }

        if selectedDishForCustomization != nil {
            selectedDishForCustomization = nil
        }
        queuedCustomizationDish = nil
        selectedDishForDetail = toAddToCartDish(dish, restaurant: restaurant)
    }

    private func addToCart(_ item: FlashStoreItem) {
        let cartItem = CartItem(
            restaurantId: item.restaurantName,
            productId: item.id,
            title: item.title,
            itemImg: item.imageURL,
            cdesc: item.badgeText,
            price: item.finalPrice,
            quantity: 1,
            isCustomize: 0,
            isQuantity: 1,
            isVeg: item.isVeg ? 1 : 0
        )
        cartManager.addItem(cartItem, restaurantName: item.restaurantName)
    }
}

private struct BrandItemView: View {
    let imageURL: String
    let sizeClass: UserInterfaceSizeClass?

    private var brandSize: CGFloat {
        sizeClass == .regular ? 92 : 78
    }

    private var brandWidth: CGFloat {
        sizeClass == .regular ? 108 : 92
    }

    var body: some View {
        NavigationLink {
            RestaurantView()
        } label: {
            VStack(spacing: 0) {
                ZStack {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color.white)
                                .overlay(ProgressView().tint(.orange))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Circle()
                                .fill(Color.white)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.orange)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: brandSize, height: brandSize)
                    .clipShape(Circle())
                }
            }
            .frame(width: brandWidth)
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryItemView: View {
    let item: FlashStoreCategory
    let isSelected: Bool
    let sizeClass: UserInterfaceSizeClass?
    let action: () -> Void

    private var categorySize: CGFloat {
        sizeClass == .regular ? 92 : 78
    }

    private var categoryWidth: CGFloat {
        sizeClass == .regular ? 108 : 92
    }

    private var titleFontSize: CGFloat {
        sizeClass == .regular ? 18 : 16
    }

    private var iconSize: CGFloat {
        sizeClass == .regular ? 28 : 24
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: item.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color.white)
                                .overlay(ProgressView().tint(Color(hex: "#F72437")))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Circle()
                                .fill(Color.white)
                                .overlay(
                                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                                        .font(.system(size: iconSize, weight: .semibold))
                                        .foregroundColor(Color(hex: "#F72437"))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: categorySize, height: categorySize)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color(hex: "#F72437") : Color.clear, lineWidth: 4)
                    )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: sizeClass == .regular ? 13 : 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color(hex: "#F72437")))
                            .offset(x: 8, y: -4)
                    }
                }

                Text(item.title)
                    .font(.system(size: titleFontSize, weight: .bold))
                    .foregroundColor(isSelected ? Color(hex: "#F72437") : .secondary)
            }
            .frame(width: categoryWidth)
        }
        .buttonStyle(.plain)
    }
}

struct RestaurantFlashCardView: View {
    let section: FlashRestaurantSection
    let onViewItems: () -> Void
    let onDishTap: (FlashDish) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.restaurantName)
                        .font(.system(size: 31, weight: .bold))
                        .foregroundColor(.primary)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#F72437"))

                Text("\(section.ratingText) (\(section.reviewCount)) \(section.deliveryTime)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#2A2A2A"))
            }
                }

                Spacer()

                Button(action: onViewItems) {
                    HStack(spacing: 4) {
                        Text("View items")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "#F72437"))
                }
                .buttonStyle(.plain)
            }

            Text(section.offerText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(section.dishes) { dish in
                        DishItemView(dish: dish) {
                            onDishTap(dish)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct DishItemView: View {
    let dish: FlashDish
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: dish.imageURL)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.gray.opacity(0.12))
                        .overlay(ProgressView().tint(.orange))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.gray.opacity(0.12))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 94, height: 94)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            MiniVegIndicator(isVeg: dish.isVeg)

            Text(dish.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)

            HStack(alignment: .center, spacing: 8) {
                Text(dish.priceText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#1E1E1E"))

                Spacer()

                Button(action: onTap) {
                    Text("ADD")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#098430"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "#098430"), lineWidth: 1)
                        )
                }
                .fixedSize()
                .buttonStyle(.plain)
            }
        }
        .frame(width: 130, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

private struct MiniVegIndicator: View {
    let isVeg: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(isVeg ? Color(hex: "#129A5E") : Color(hex: "#D54141"), lineWidth: 1.2)
                .frame(width: 13, height: 13)

            Circle()
                .fill(isVeg ? Color(hex: "#129A5E") : Color(hex: "#D54141"))
                .frame(width: 6, height: 6)
        }
    }
}

private enum DishCardStyle {
    case trending
    case grid
}

private struct DishCardView: View {
    let item: FlashStoreItem
    let style: DishCardStyle
    let onAdd: () -> Void

    private var cardWidth: CGFloat {
        style == .trending ? 188 : .infinity
    }

    private var imageHeight: CGFloat {
        style == .trending ? 126 : 132
    }

    private var titleFont: Font {
        .system(size: 16, weight: .semibold)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: item.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.gray.opacity(0.12))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.gray.opacity(0.12))
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: imageHeight)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#098430"))
                        .frame(width: 48, height: 48)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                }
                .padding(8)
            }

            HStack(spacing: 6) {
                VegIndicatorView(isVeg: item.isVeg)
                Text(item.title)
                    .font(titleFont)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }

            HStack(spacing: 8) {
                Text(item.oldPriceText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .strikethrough()

                Text(item.finalPriceText)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: "#FFD938"))
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            }

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11, weight: .bold))
                Text("\(item.ratingText)(\(item.ratingCount))")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(Color(hex: "#0B9F63"))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: "#E9F8F1"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(item.restaurantName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding(10)
        .frame(width: cardWidth, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

private struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let showChevron: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                if showChevron {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .foregroundColor(isSelected ? Color(hex: "#FF6B00") : Color(hex: "#4B4B4B"))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color(hex: "#FFF1E8") : Color.white)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color(hex: "#FF6B00") : Color.gray.opacity(0.22), lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct VegIndicatorView: View {
    let isVeg: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(isVeg ? Color(hex: "#129A5E") : Color(hex: "#D54141"), lineWidth: 1.6)
                .frame(width: 14, height: 14)

            Circle()
                .fill(isVeg ? Color(hex: "#129A5E") : Color(hex: "#D54141"))
                .frame(width: 7, height: 7)
        }
    }
}

private struct SpringBottomSheetOverlay<Content: View>: View {
    let heightRatio: CGFloat
    let onDismissed: () -> Void
    @ViewBuilder let content: (_ dismiss: @escaping () -> Void) -> Content

    @State private var isVisible = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDismissing = false

    private let dismissDuration: TimeInterval = 0.24

    init(
        heightRatio: CGFloat = 0.7,
        onDismissed: @escaping () -> Void,
        @ViewBuilder content: @escaping (_ dismiss: @escaping () -> Void) -> Content
    ) {
        self.heightRatio = heightRatio
        self.onDismissed = onDismissed
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let clampedRatio = min(max(heightRatio, 0.4), 0.95)
            let sheetHeight = max(320, geometry.size.height * clampedRatio)
            let hiddenOffset = sheetHeight + geometry.safeAreaInsets.bottom + 44
            let presentationOffset = isVisible ? max(0, dragOffset) : hiddenOffset
            let progress = max(0, min(1, 1 - (presentationOffset / hiddenOffset)))

            ZStack(alignment: .bottom) {
                Color.black
                    .opacity(0.5 * progress)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissSheet()
                    }

                content {
                    dismissSheet()
                }
                .frame(maxWidth: .infinity)
                .frame(height: sheetHeight, alignment: .top)
                .offset(y: presentationOffset)
                .simultaneousGesture(dragGesture)
            }
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 260, damping: 23)) {
                    isVisible = true
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                guard !isDismissing else { return }
                dragOffset = max(0, value.translation.height)
            }
            .onEnded { value in
                guard !isDismissing else { return }
                let shouldDismiss = value.translation.height > 120 || value.predictedEndTranslation.height > 220

                if shouldDismiss {
                    dismissSheet()
                } else {
                    withAnimation(.interpolatingSpring(stiffness: 320, damping: 28)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func dismissSheet() {
        guard !isDismissing else { return }
        isDismissing = true

        withAnimation(.easeOut(duration: dismissDuration)) {
            isVisible = false
            dragOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + dismissDuration) {
            onDismissed()
            isDismissing = false
        }
    }
}

// MARK: - Promotional Banner Models & Views

struct FlashPromotionalBanner: Identifiable {
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

private struct PromotionalBannerCard: View {
    let banner: FlashPromotionalBanner

    var body: some View {
        StandardBannerCard(banner: banner)
    }
}

private struct StandardBannerCard: View {
    let banner: FlashPromotionalBanner

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

#Preview {
    NavigationStack {
        FlashView()
            .environmentObject(CartManager.shared)
    }
}
