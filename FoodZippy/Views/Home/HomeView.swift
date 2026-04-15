// HomeView.swift
// Pixel-perfect match of reference screenshot:
// Deep purple gradient header with category tabs, search, CRAVE banner,
// yellow offer cards, filter row, horizontal restaurant cards.

import SwiftUI

// MARK: - Colour tokens (reference image)
private extension Color {
    static let hPurpleDark   = Color(hex: "#3D13A4")
    static let hPurpleMid    = Color(hex: "#7B1FA2")
    static let hPurpleLight  = Color(hex: "#9C27B0")
    static let hYellow       = Color(hex: "#FFC107"	)
    static let hPink         = Color(hex: "#D81B60")
    static let hOrange       = Color(hex: "#FF5722")
    static let hGreen        = Color(hex: "#098430")
    static let hBg           = Color(hex: "#F5F5F5")
}

// MARK: - Root view

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedRestaurant: Restaurant?
    @State private var navigateToRestaurant = false
    @State private var navigateToDineIn = false
    @State private var scrollResetToken = UUID()
    private let topAnchorId = "home_top_anchor"

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
                    offer: "AT ₹\(item.restCostfortwo ?? "99")",
                    rating: Double(item.restRating ?? "4.5") ?? 4.5,
                    deliveryTime: item.restDeliverytime ?? "15-20 mins",
                    category: item.restSdesc ?? "Snacks, Bakery",
                    isFavorite: item.isFav
                )
            }
        }

        return [
            HorizontalRestaurantListView.Restaurant(
                id: "demo-1",
                name: "Falahaar & Kitchen",
                image: "burger",
                offer: "AT ₹29",
                rating: 4.3,
                deliveryTime: "15-20 mins",
                category: "Snacks, Bakery",
                isFavorite: false
            ),
            HorizontalRestaurantListView.Restaurant(
                id: "demo-2",
                name: "Shri Shyam Bakers",
                image: "burger",
                offer: "AT ₹129",
                rating: 4.5,
                deliveryTime: "10-15 mins",
                category: "Bakery, Fast Food",
                isFavorite: false
            ),
            HorizontalRestaurantListView.Restaurant(
                id: "demo-3",
                name: "Burger Farm",
                image: "burger",
                offer: "AT ₹84",
                rating: 4.4,
                deliveryTime: "20-25 mins",
                category: "American, Burgers",
                isFavorite: true
            )
        ]
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
                            onDineInTap: { navigateToDineIn = true },
                            onFoodTap: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo(topAnchorId, anchor: .top)
                                }
                            }
                        )

                        // ── White content area ─────────────────────────────────────
                        VStack(spacing: 0) {

                            // CRAVE banner
                            BannerView()
                                .padding(.horizontal, 12)
                                .padding(.top, 6)
                                .padding(.bottom, 0)

                            // Offer text below banner (inside purple area continues)
                            OfferTextRow()
                                .padding(.horizontal, 12)
                                .padding(.top, 10)

                            // 3 yellow offer cards
                            OfferCardsRow()
                                .padding(.top, 12)
                                .padding(.bottom, 14)
                        }
                        .background(Color.hPurpleDark)

                        // ── White body ─────────────────────────────────────────────
                        VStack(spacing: 0) {

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
                                onSelect: { r in
                                    selectedRestaurant = r
                                    navigateToRestaurant = true
                                }
                            )
                            .padding(.bottom, 24)
                        }
                        .background(Color.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                        .frame(minHeight: geo.size.height, alignment: .top)
                    }
                    .id(scrollResetToken)
                    .background(Color.hBg)
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
        .task { await viewModel.loadHomeData() }
        .refreshable { await viewModel.refresh() }
        .navigationDestination(isPresented: $navigateToRestaurant) {
            if let r = selectedRestaurant {
                RestaurantDetailView(restaurant: r).environmentObject(cartManager)
            }
        }
        .navigationDestination(isPresented: $navigateToDineIn) {
            DineInMainView()
        }
    }
}

// MARK: - Header section (purple gradient + location + category tabs)

private struct HeaderView: View {
    @ObservedObject var viewModel: HomeViewModel
    let topSafeInset: CGFloat
    let onDineInTap: () -> Void
    let onFoodTap: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Background color (matches category tabs)
            Color(red: 0.13, green: 0.02, blue: 0.24)
                .ignoresSafeArea(.container, edges: .top)

            VStack(spacing: 0) {
                Color.clear
                    .frame(height: topSafeInset)

                // ── Location row ──────────────────────────────────────────────
                HStack(alignment: .center, spacing: 0) {
                    // Location
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
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // BUY one badge
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
                    .padding(.trailing, 12)

                    // Profile circle
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E9E9EE"))
                            .frame(width: 38, height: 38)
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#505056"))
                    }
                }
                .padding(.horizontal, 16)

                SearchBarView(viewModel: viewModel)
                    .padding(.horizontal, 12)
                    .padding(.top, 14)
                    .padding(.bottom, 12)

                // ── Category tabs ──────────────────────────────────────────────
                CategoryTabView(viewModel: viewModel, onDineInTap: onDineInTap, onFoodTap: onFoodTap)
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
    @ObservedObject var viewModel: HomeViewModel
    let onDineInTap: () -> Void
    let onFoodTap: () -> Void

    @State private var selectedTab = "Food"
    @Namespace private var animation

    // Exact colours sampled from reference image
    private let bgColor    = Color(hex: "#09041A")   // very dark background
    private let activeColor = Color(hex: "#3D13A4")  // bright violet (selected card)
    private let inactiveColor = Color.white.opacity(0.04)

    private let categories: [(name: String, emoji: String)] = [
        ("Food",          "🍔"),
        ("Take Away",     "🛍️"),
        ("Subscription",  "📦"),
        ("Drive-Thru",    "🚗")
    ]

    var body: some View {
        VStack(spacing: 0) {

            // ── Tab row ────────────────────────────────────────────────────
            HStack(alignment: .bottom, spacing: -28) {
                ForEach(Array(categories.enumerated()), id: \.element.name) { index, category in
                    TabCell(
                        category: category,
                        isSelected: selectedTab == category.name,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        animation: animation
                    )
                    // The left-most tab has the highest natural zIndex, except for the selected tab which is forcefully pushed to the very front
                    .zIndex(selectedTab == category.name ? 100 : Double(categories.count - index))
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = category.name
                        }
                        if category.name == "Food" { onFoodTap() }
                        if category.name == "Drive-Thru" { onDineInTap() }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 0)
            .background(bgColor)

            // ── Bottom connector strip ─────────
            Rectangle()
                .fill(Color(hex: "#3D13A4")) // Matches the active card colored line at the bottom
                .frame(height: 6)
        }
        .background(bgColor)
    }
}

// ── Single tab cell ──────────────────────────────────────────────────────────

private struct TabCell: View {
    let category: (name: String, emoji: String)
    let isSelected: Bool
    let activeColor: Color
    let inactiveColor: Color
    var animation: Namespace.ID

    // Dimensions exactly matching the provided image
    private var cardHeight: CGFloat { 80 }
    private var emojiSize:  CGFloat { isSelected ? 36 : 30  }

    var body: some View {
        VStack(spacing: 0) {

            // ── Emoji + optional badge ────────────────────────────────────
            ZStack(alignment: .bottom) {
                Text(category.emoji)
                    .font(.system(size: emojiSize))
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSelected)

                if category.name == "Instamart" {
                    Text("8 mins")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: "#2B52F6")) // Swiggy instamart blue
                        )
                        .offset(y: 16)
                }
            }
            .frame(height: 40)                    // fixed zone so label stays aligned

            // ── Label ─────────────────────────────────────────────────────
            Text(category.name)
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
                        .fill(activeColor)
                    
                    // Top glowing effect
                    PlateauTabShape()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.35), Color.clear]),
                                center: UnitPoint(x: 0.5, y: 0.0),
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                }
                .overlay(
                    PlateauTabShape(isOpen: true)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                )
                .matchedGeometryEffect(id: "activeTab", in: animation)
            } else {
                PlateauTabShape()
                    .fill(inactiveColor)
                    .overlay(
                        PlateauTabShape(isOpen: true)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
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

        let topInset = w * 0.18
        let topCornerRadius: CGFloat = 16

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
    @State private var searchText = ""
    @State private var vegOnly   = false

    var body: some View {
        HStack(spacing: 10) {
            // Search field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#999999"))

                TextField("Search for 'Sweets'", text: $searchText)
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
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.white)
            .cornerRadius(12)

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
            .cornerRadius(12)
        }
    }
}

// MARK: - Promo banner

private struct BannerView: View {
    var body: some View {
        HStack(spacing: 0) {
            // Left: CRAVE text
            Text("CRAVE")
                .font(.system(size: 42, weight: .heavy))
                .italic()
                .foregroundColor(Color.hYellow)
                .padding(.leading, 4)

            Spacer()

            // Centre: food bowl image (SF symbol fallback)
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 88, height: 88)
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .font(.system(size: 46))
                    .foregroundColor(.white)
            }

            Spacer()

            // Right: ORDER NOW >> button
            VStack(alignment: .trailing) {
                HStack(spacing: 3) {
                    Text("ORDER NOW")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.hYellow)
                    Text("»")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(Color.hYellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.hYellow, lineWidth: 1.5)
                )
            }
            .padding(.trailing, 4)
        }
        .frame(height: 90)
    }
}

// MARK: - Offer text row  ("--- MIN 150 OFF + ₹100 CASHBACK ---")

private struct OfferTextRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(height: 1)
            Text("MIN 150 OFF + ₹100 CASHBACK")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(height: 1)
        }
    }
}

// MARK: - 3 Offer cards row (yellow, full width inside purple area)

private struct OfferCardsRow: View {
    var body: some View {
        HStack(spacing: 8) {
            // Card 1 – ₹150 OFF
            OfferCardView(
                title: "CRAVING\nMEETS OFFERS",
                badgeTopText: "MIN",
                badgeMainText: "₹150",
                badgeSubText: "OFF\n+ ₹100 CASHBACK"
            )

            // Card 2 – ₹300 FREE CASH
            OfferCardView(
                title: "EATRIGHT",
                badgeTopText: "WIN UP TO",
                badgeMainText: "₹300",
                badgeSubText: "FREE CASH"
            )

            // Card 3 – LARGE ORDERS (image card)
            LargeOrderCard()
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
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(Color(hex: "#5B3300"))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 8)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Pink starburst badge
                ZStack {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 68))
                        .foregroundColor(Color.hPink.opacity(0.92))

                    VStack(spacing: 1) {
                        Text(badgeTopText)
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.white)
                        Text(badgeMainText)
                            .font(.system(size: 20, weight: .heavy))
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
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.hYellow)

            VStack(spacing: 6) {
                Text("LARGE\nORDERS")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(Color(hex: "#5B3300"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

                Spacer()

                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color(hex: "#5B3300").opacity(0.75))
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
                                        .frame(width: 58, height: 58)

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
    let onSelect: (Restaurant) -> Void

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

        return [
            Category(name: "Rasgulla", image: "burger", isSelected: true),
            Category(name: "Gulab Jamun", image: "burger", isSelected: false),
            Category(name: "Rasmalai", image: "burger", isSelected: false),
            Category(name: "Jalebi", image: "burger", isSelected: false),
            Category(name: "North Indian", image: "burger", isSelected: false)
        ]
    }

    private var restaurants: [ExploreRestaurantListView.Restaurant] {
        if !sourceRestaurants.isEmpty {
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

        return [
            ExploreRestaurantListView.Restaurant(id: "demo-1", name: "Burger Farm", image: "burger", offer: "₹84", rating: 4.5, reviews: "8.1K+", deliveryTime: "20–25 mins", cuisine: "American, Italian", location: "Jagatpura", distance: "0.9 km", isFavorite: false),
            ExploreRestaurantListView.Restaurant(id: "demo-2", name: "Theobroma", image: "burger", offer: "₹48", rating: 4.6, reviews: "168", deliveryTime: "10–15 mins", cuisine: "Bakery, Desserts", location: "Sector-23", distance: "0.1 km", isFavorite: false),
            ExploreRestaurantListView.Restaurant(id: "demo-3", name: "NBC - Nothing Before Coffee", image: "burger", offer: "₹69", rating: 4.4, reviews: "474", deliveryTime: "15–20 mins", cuisine: "Coffee, Fast Food, Cafe", location: "Jagatpura", distance: "0.1 km", isFavorite: true)
        ]
    }

    private var storeProducts: [Product] {
        [
            Product(name: "Paneer Onion Pizza", image: "burger", price: 79, oldPrice: 160, rating: 4.1, ratingCount: 136, restaurant: "Crazy Pizza Hot", isVeg: true),
            Product(name: "Egg Curry", image: "burger", price: 69, oldPrice: 190, rating: 3.7, ratingCount: 158, restaurant: "The Royal Mult...", isVeg: false),
            Product(name: "Pyaz Kachori", image: "burger", price: 59, oldPrice: 60, rating: 4.2, ratingCount: 634, restaurant: "Rawat Mishth...", isVeg: true)
        ]
    }

    private var swiggyHighlights: [MoreOnSwiggyCard] {
        [
            MoreOnSwiggyCard(title: "FLASH", image: "burger"),
            MoreOnSwiggyCard(title: "HIGH", image: "burger"),
            MoreOnSwiggyCard(title: "REORDER", image: "burger"),
        ]
    }

    private var deliciousYardProducts: [Product] {
        [
            Product(name: "Grilled Chicken Skewers", image: "burger", price: 149, oldPrice: 299, rating: 4.3, ratingCount: 245, restaurant: "Yard Kitchen", isVeg: false),
            Product(name: "Garden Fresh Salad", image: "burger", price: 89, oldPrice: 180, rating: 4.4, ratingCount: 187, restaurant: "Green Yard Cafe", isVeg: true),
            Product(name: "Herb Butter Naan", image: "burger", price: 79, oldPrice: 120, rating: 4.2, ratingCount: 412, restaurant: "Yard Bakers", isVeg: true)
        ]
    }

    private var deliciousYardCards: [MoreOnSwiggyCard] {
        [
            MoreOnSwiggyCard(title: "DELICIOUS\nYARD SPECIALS", image: "burger"),
            MoreOnSwiggyCard(title: "FRESH\nVEGETABLES", image: "burger"),
            MoreOnSwiggyCard(title: "GRILLED\nDELICACIES", image: "burger"),
            MoreOnSwiggyCard(title: "SEASONAL\nFAVORITES", image: "burger")
        ]
    }

    private var promotionalBanners: [PromotionalBanner] {
        [
            PromotionalBanner(
                id: "banner-1",
                backgroundColor: Color(hex: "#FFC107"),
                accentColor: Color(hex: "#FF9800"),
                mainTitle: "Fresh year.",
                subtitle: "Fresh cravings.",
                image: "burger",
                bannerImage: nil
            ),
            PromotionalBanner(
                id: "banner-2",
                backgroundColor: Color(hex: "#FF9800"),
                accentColor: Color(hex: "#FF7043"),
                mainTitle: "Special Noodle",
                subtitle: "Best Noodle Ever",
                image: "burger",
                bannerImage: nil
            ),
            PromotionalBanner(
                id: "banner-3",
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
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CategoryListView(items: categoryItems)
                .padding(.top, 8)

            PromotionalBannerCarouselView(banners: promotionalBanners)
                .padding(.top, 12)
                .padding(.bottom, 12)

            Store99SectionView(
                products: storeProducts,
                swiggyCards: swiggyHighlights,
                onSeeAllTap: {
                    viewModel.hasOffers = true
                    viewModel.applyFilters()
                },
                onAddTap: { _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            )
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 8)

            DeliciousYardSectionView(
                products: deliciousYardProducts,
                swiggyCards: deliciousYardCards,
                onSeeAllTap: {
                    viewModel.hasOffers = true
                    viewModel.applyFilters()
                },
                onAddTap: { _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            )
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 8)

            FilterChipsView(
                isFilterActive: viewModel.openNow,
                isSortActive: viewModel.sortBy != .relevance,
                isStore99Active: viewModel.hasOffers,
                isOffersActive: viewModel.hasOffers,
                onFilterTap: {
                    viewModel.openNow.toggle()
                    viewModel.applyFilters()
                },
                onSortTap: {
                    viewModel.sortBy = viewModel.sortBy == .rating ? .relevance : .rating
                    viewModel.applyFilters()
                },
                onStore99Tap: {
                    viewModel.hasOffers.toggle()
                    viewModel.applyFilters()
                },
                onOffersTap: {
                    viewModel.hasOffers.toggle()
                    viewModel.applyFilters()
                }
            )
            .padding(.top, 10)

            Text("Top \(sourceRestaurants.isEmpty ? 1743 : sourceRestaurants.count) restaurants to explore")
                .font(.system(size: 42/2, weight: .bold))
                .foregroundColor(Color(hex: "#1F1F1F"))
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 14)

            if viewModel.isLoading {
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
                    onSelect: { item in
                        if let selected = sourceRestaurants.first(where: { ($0.restId ?? "") == item.id }) {
                            onSelect(selected)
                        }
                    }
                )
            }
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
    @State private var selectedId: String

    init(items: [Category]) {
        self.items = items
        self._selectedId = State(initialValue: items.first(where: { $0.isSelected })?.id ?? items.first?.id ?? "")
    }

    private var normalizedItems: [Category] {
        items.map { item in
            Category(name: item.name, image: item.image, isSelected: item.id == selectedId)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What's on your mind?")
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
    let products: [Product]
    let swiggyCards: [MoreOnSwiggyCard]
    let onSeeAllTap: () -> Void
    let onAddTap: (Product) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 14) {
                StoreHeaderView(onSeeAllTap: onSeeAllTap)
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

            Text("More on Swiggy")
                .font(.system(size: 22/1.4, weight: .bold))
                .foregroundColor(Color(hex: "#363A43"))
                .padding(.horizontal, 2)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(swiggyCards) { card in
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
                }
            }
        }
    }
}

private struct StoreHeaderView: View {
    let onSeeAllTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                HStack(spacing: 6) {
                    Text("The Pankh Restaurant's and Cafe & Banquet Hall")
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

                Text("3.12 mins")
                    .font(.system(size: 19/1.4, weight: .semibold))
                    .foregroundColor(Color(hex: "#1F2937"))
            }
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
                                Image(systemName: "minus")
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundColor(.white)
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
    let products: [Product]
    let swiggyCards: [MoreOnSwiggyCard]
    let onSeeAllTap: () -> Void
    let onAddTap: (Product) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 14) {
                DeliciousYardHeaderView(onSeeAllTap: onSeeAllTap)
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
    let onSeeAllTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                HStack(spacing: 6) {
                    Text("delicious yard")
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

                Text("₹ 2000 for two")
                    .font(.system(size: 19/1.4, weight: .semibold))
                    .foregroundColor(Color(hex: "#1F2937"))
            }
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

#Preview {
    HomeView()
        .environmentObject(CartManager.shared)
}
