// RestaurantDetailView.swift
// Restaurant detail screen matching Android activity_restaurant_details.xml
// Shows menu categories, items, gallery, reviews, add-to-cart flow

import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @StateObject private var viewModel = RestaurantViewModel()
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: DetailTab = .menu
    @State private var showCart = false
    @State private var selectedMenuItem: MenuItem?
    @State private var showAddonSheet = false
    @State private var searchText = ""
    @State private var scrolledPastHeader = false

    enum DetailTab: String, CaseIterable {
        case menu = "Menu"
        case gallery = "Gallery"
        case reviews = "Reviews"
    }

    var displayedCategories: [ProductCategory] {
        if searchText.isEmpty {
            return viewModel.filteredCategories
        }
        return viewModel.filteredCategories.compactMap { category in
            let filtered = category.menuitemData?.filter {
                ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.cdesc ?? "").localizedCaseInsensitiveContains(searchText)
            } ?? []
            if filtered.isEmpty { return nil }
            return ProductCategory(catId: category.catId, title: category.title, menuitemData: filtered)
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: - Hero Header
                        RestaurantHeroHeader(
                            restaurant: viewModel.restaurant ?? restaurant,
                            safeAreaTop: geo.safeAreaInsets.top,
                            isFavourite: viewModel.isFavourite,
                            onBack: { dismiss() },
                            onFavourite: {
                                Task { await viewModel.toggleFavourite() }
                            }
                        )

                        // MARK: - Info Row
                        RestaurantInfoRow(restaurant: viewModel.restaurant ?? restaurant)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        Divider()

                        // MARK: - Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "#999999"))
                            TextField("Search in menu", text: $searchText)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#F5F5F5"))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        // MARK: - Tab Selector
                        HStack(spacing: 0) {
                            ForEach(DetailTab.allCases, id: \.self) { tab in
                                let isSelected = selectedTab == tab
                                Button {
                                    selectedTab = tab
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(tab.rawValue)
                                            .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                            .foregroundColor(isSelected ? Color(hex: "#E23744") : Color(hex: "#666666"))
                                            .padding(.vertical, 10)

                                        Rectangle()
                                            .fill(isSelected ? Color(hex: "#E23744") : Color.clear)
                                            .frame(height: 2)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .background(Color.white)
                        .overlay(
                            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2)),
                            alignment: .bottom
                        )

                        // MARK: - Content
                        switch selectedTab {
                        case .menu:
                            MenuTabContent(
                                categories: displayedCategories,
                                isLoading: viewModel.isLoading,
                                vegOnly: $viewModel.vegOnly,
                                cartManager: cartManager,
                                onAddItem: { item in
                                    if item.hasCustomization {
                                        selectedMenuItem = item
                                        showAddonSheet = true
                                    } else {
                                        addToCart(item: item, addonId: "", addonTitle: "", addonPrice: "")
                                    }
                                }
                            )

                        case .gallery:
                            GalleryTabContent(images: viewModel.gallery)
                                .padding(.top, 8)

                        case .reviews:
                            ReviewsTabContent(reviews: viewModel.reviews)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, cartManager.cartItems.isEmpty ? 0 : 80)
                }
                .ignoresSafeArea(edges: .top)

                // MARK: - Floating View Cart
                if !cartManager.cartItems.isEmpty {
                    FloatingCartBar(cartManager: cartManager) {
                        showCart = true
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .task {
            await viewModel.loadRestaurant(restId: restaurant.restId ?? "")
        }
        .sheet(isPresented: $showAddonSheet) {
            if let item = selectedMenuItem {
                AddonSelectionSheet(
                    menuItem: item,
                    restaurant: viewModel.restaurant ?? restaurant,
                    cartManager: cartManager
                )
                .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $showCart) {
            CartView().environmentObject(cartManager)
        }
    }

    private func addToCart(item: MenuItem, addonId: String, addonTitle: String, addonPrice: String) {
        let cartItem = CartItem(
            restaurantId: restaurant.restId ?? "",
            productId: item.id ?? "",
            title: item.title ?? "",
            itemImg: item.itemImg ?? "",
            cdesc: item.cdesc ?? "",
            price: item.effectivePrice,
            quantity: 1,
            isCustomize: item.isCustomize ?? 0,
            isQuantity: Int(item.isQuantity ?? "0") ?? 0,
            isVeg: item.isVeg ?? 0,
            addonId: addonId,
            addonTitle: addonTitle,
            addonPrice: addonPrice
        )
        cartManager.addItem(cartItem, restaurantName: restaurant.restTitle ?? "")
    }
}

// MARK: - Hero Header
private struct RestaurantHeroHeader: View {
    let restaurant: Restaurant
    let safeAreaTop: CGFloat
    let isFavourite: Bool
    let onBack: () -> Void
    let onFavourite: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: restaurant.restImg ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color(hex: "#E23744").opacity(0.3)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200 + safeAreaTop)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 200 + safeAreaTop)

            // Custom Navigation Bar Overlay
            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(restaurant.restTitle ?? "")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .opacity(0) // Hide for now, can show when scrolled

                    Spacer()

                    Button(action: onFavourite) {
                        Image(systemName: isFavourite ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, safeAreaTop + 8)

                Spacer()
            }

            HStack {
                // Restaurant logo
                if let logo = restaurant.restLogo, !logo.isEmpty {
                    AsyncImage(url: URL(string: logo)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.white.opacity(0.3)
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.leading, 16)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.restTitle ?? "")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    if let addr = restaurant.restLandmark ?? restaurant.restFullAddress {
                        Text(addr)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                    }
                }
                .padding(.leading, 8)
                .padding(.bottom, 12)

                Spacer()
            }
        }
        .frame(height: 200 + safeAreaTop)
    }
}

// MARK: - Info Row
private struct RestaurantInfoRow: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 20) {
            // Rating
            VStack(spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    Text(restaurant.restRating ?? "0")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: "#098430"))
                .cornerRadius(8)
                Text("Rating")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Divider().frame(height: 36)

            // Delivery time
            VStack(spacing: 2) {
                Text(restaurant.restDeliverytime ?? "")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                Text("Delivery")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Divider().frame(height: 36)

            // Cost for two
            if let cost = restaurant.restCostfortwo, !cost.isEmpty {
                VStack(spacing: 2) {
                    Text("₹\(cost)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    Text("For two")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Open/Closed badge
            Text(restaurant.isOpen ? "OPEN" : "CLOSED")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(restaurant.isOpen ? Color(hex: "#098430") : Color(hex: "#E23744"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(restaurant.isOpen ? Color(hex: "#098430").opacity(0.1) : Color(hex: "#E23744").opacity(0.1))
                .cornerRadius(12)
        }
    }
}

// MARK: - Menu Tab Content
private struct MenuTabContent: View {
    let categories: [ProductCategory]
    let isLoading: Bool
    @Binding var vegOnly: Bool
    let cartManager: CartManager
    let onAddItem: (MenuItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Veg toggle row
            HStack {
                Text("Veg Only")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Toggle("", isOn: $vegOnly)
                    .labelsHidden()
                    .tint(Color(hex: "#098430"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(hex: "#F5F5F5"))

            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Color(hex: "#E23744"))
                    Text("Loading menu...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    ForEach(categories) { category in
                        Section {
                            // Grid layout: 2 columns matching item_menu_item.xml
                            let items = category.menuitemData ?? []
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8)
                            ], spacing: 12) {
                                ForEach(items) { item in
                                    MenuItemCard(
                                        item: item,
                                        cartManager: cartManager,
                                        onAdd: { onAddItem(item) }
                                    )
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                        } header: {
                            Text(category.title ?? "")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                        }

                        Divider()
                    }
                }
            }
        }
    }
}

// MARK: - Menu Item Card
private struct MenuItemCard: View {
    let item: MenuItem
    let cartManager: CartManager
    let onAdd: () -> Void

    var quantityInCart: Int {
        cartManager.cartItems
            .filter { $0.productId == (item.id ?? "") }
            .reduce(0) { $0 + $1.quantity }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image (140dp height matching item_menu_item.xml)
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: item.itemImg ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.12)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipped()

                // Veg/Non-veg indicator
                Image(systemName: item.isVegetarian ? "leaf.circle.fill" : "circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(item.isVegetarian ? Color(hex: "#098430") : Color.red)
                    .padding(8)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
                    .padding(8)
            }

            // Name and price row
            HStack(alignment: .bottom, spacing: 4) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title ?? "")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(2)

                    if let desc = item.cdesc, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#888888"))
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("₹\(String(format: "%.0f", item.effectivePrice))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#E23744"))

                    // Discount badge
                    if item.hasDiscount, let pct = item.offerPercentage {
                        Text("\(pct)% OFF")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "#00875A"))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(hex: "#D0F4E8"))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(10)

            // Add / Stepper button
            if quantityInCart > 0 {
                HStack(spacing: 0) {
                    Button {
                        let items = cartManager.cartItems.filter { $0.productId == (item.id ?? "") }
                        if let first = items.first {
                            if first.quantity <= 1 {
                                cartManager.removeItem(first.id)
                            } else {
                                cartManager.decrementQuantity(for: first.id)
                            }
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#E23744"))
                            .frame(width: 28, height: 28)
                    }

                    Text("\(quantityInCart)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#E23744"))
                        .frame(minWidth: 24)

                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#E23744"))
                            .frame(width: 28, height: 28)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(Color(hex: "#E23744").opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(hex: "#E23744").opacity(0.3), lineWidth: 1)
                )
            } else {
                Button(action: onAdd) {
                    Text("ADD")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#E23744"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .overlay(
                            Rectangle()
                                .stroke(Color(hex: "#E23744").opacity(0.4), lineWidth: 1)
                        )
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Gallery Tab
private struct GalleryTabContent: View {
    let images: [GalleryImage]

    let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]

    var body: some View {
        if images.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 44))
                    .foregroundColor(.gray.opacity(0.4))
                Text("No photos yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(images) { image in
                    AsyncImage(url: URL(string: image.img ?? "")) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.15)
                    }
                    .frame(height: 120)
                    .clipped()
                }
            }
        }
    }
}

// MARK: - Reviews Tab
private struct ReviewsTabContent: View {
    let reviews: [Review]

    var body: some View {
        if reviews.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "star.bubble")
                    .font(.system(size: 44))
                    .foregroundColor(.gray.opacity(0.4))
                Text("No reviews yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else {
            LazyVStack(spacing: 0) {
                ForEach(reviews) { review in
                    ReviewRowView(review: review)
                    Divider().padding(.leading, 60)
                }
            }
        }
    }
}

private struct ReviewRowView: View {
    let review: Review

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            AsyncImage(url: URL(string: review.userImg ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(Color(hex: "#E23744").opacity(0.2))
                    .overlay(
                        Text(String(review.userName?.prefix(1) ?? "U"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#E23744"))
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(review.userName ?? "User")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    if let rating = review.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                            Text(rating)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#098430"))
                        .cornerRadius(8)
                    }
                }

                if let reviewText = review.review, !reviewText.isEmpty {
                    Text(reviewText)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#555555"))
                        .lineLimit(3)
                }

                if let date = review.rdate, !date.isEmpty {
                    Text(date)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Addon Selection Sheet
struct AddonSelectionSheet: View {
    let menuItem: MenuItem
    let restaurant: Restaurant
    let cartManager: CartManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAddons: [String: Set<String>] = [:]
    @State private var quantity = 1

    var totalAddonPrice: Double {
        menuItem.addondata?.reduce(0) { catTotal, category in
            let selected = selectedAddons[category.addonId ?? ""] ?? []
            let categoryPrice = category.addonItemData?.filter { selected.contains($0.subId ?? "") }
                .reduce(0) { $0 + $1.priceDouble } ?? 0
            return catTotal + categoryPrice
        } ?? 0
    }

    var totalPrice: Double {
        (menuItem.effectivePrice + totalAddonPrice) * Double(quantity)
    }

    var addonIdString: String {
        selectedAddons.values.flatMap { $0 }.joined(separator: ",")
    }

    var addonTitleString: String {
        menuItem.addondata?.flatMap { category in
            let selected = selectedAddons[category.addonId ?? ""] ?? []
            return category.addonItemData?.filter { selected.contains($0.subId ?? "") }.map { $0.title ?? "" } ?? []
        }.joined(separator: ",") ?? ""
    }

    var addonPriceString: String {
        menuItem.addondata?.flatMap { category in
            let selected = selectedAddons[category.addonId ?? ""] ?? []
            return category.addonItemData?.filter { selected.contains($0.subId ?? "") }.map { $0.price ?? "0" } ?? []
        }.joined(separator: ",") ?? ""
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(menuItem.title ?? "")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text("₹\(String(format: "%.0f", menuItem.effectivePrice))")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#E23744"))
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Divider()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(menuItem.addondata ?? []) { addonCategory in
                        AddonCategorySection(
                            category: addonCategory,
                            selectedItems: Binding(
                                get: { selectedAddons[addonCategory.addonId ?? ""] ?? [] },
                                set: { selectedAddons[addonCategory.addonId ?? ""] = $0 }
                            )
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            // Bottom: Quantity + Add to Cart
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 16) {
                    // Quantity stepper
                    HStack(spacing: 0) {
                        Button {
                            if quantity > 1 { quantity -= 1 }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#E23744"))
                                .frame(width: 36, height: 36)
                        }

                        Text("\(quantity)")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 28)

                        Button {
                            quantity += 1
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#E23744"))
                                .frame(width: 36, height: 36)
                        }
                    }
                    .background(Color(hex: "#F5F5F5"))
                    .cornerRadius(8)

                    Button {
                        let item = CartItem(
                            restaurantId: restaurant.restId ?? "",
                            productId: menuItem.id ?? "",
                            title: menuItem.title ?? "",
                            itemImg: menuItem.itemImg ?? "",
                            cdesc: menuItem.cdesc ?? "",
                            price: menuItem.effectivePrice,
                            quantity: quantity,
                            isCustomize: menuItem.isCustomize ?? 0,
                            isQuantity: Int(menuItem.isQuantity ?? "0") ?? 0,
                            isVeg: menuItem.isVeg ?? 0,
                            addonId: addonIdString,
                            addonTitle: addonTitleString,
                            addonPrice: addonPriceString
                        )
                        cartManager.addItem(item, restaurantName: restaurant.restTitle ?? "")
                        dismiss()
                    } label: {
                        Text("Add  ₹\(String(format: "%.0f", totalPrice))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(hex: "#E23744"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color.white)
    }
}

private struct AddonCategorySection: View {
    let category: AddonCategory
    @Binding var selectedItems: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.addonTitle ?? "")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                if category.isRequired {
                    Text("Required")
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#E23744"))
                        .cornerRadius(4)
                }
            }

            ForEach(category.addonItemData ?? []) { addonItem in
                let isSelected = selectedItems.contains(addonItem.subId ?? "")
                Button {
                    let key = addonItem.subId ?? ""
                    if category.isRadioSelection {
                        selectedItems = isSelected ? [] : [key]
                    } else {
                        if isSelected { selectedItems.remove(key) }
                        else { selectedItems.insert(key) }
                    }
                } label: {
                    HStack {
                        Image(systemName: category.isRadioSelection
                              ? (isSelected ? "circle.inset.filled" : "circle")
                              : (isSelected ? "checkmark.square.fill" : "square"))
                            .font(.system(size: 18))
                            .foregroundColor(isSelected ? Color(hex: "#E23744") : .gray)

                        Text(addonItem.title ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(.black)

                        Spacer()

                        if let price = addonItem.price, price != "0", !price.isEmpty {
                            Text("+₹\(price)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#E23744"))
                        }
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                Divider()
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Floating Cart Bar (reusable)
struct FloatingCartBar: View {
    @ObservedObject var cartManager: CartManager
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(cartManager.itemCount) item\(cartManager.itemCount == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 12)

                Text("|")
                    .foregroundColor(.white.opacity(0.6))

                Text("₹\(String(format: "%.0f", cartManager.totalAmount))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 6) {
                    Text("View Cart")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "cart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(hex: "#E23744"))
            .cornerRadius(12)
            .shadow(color: Color(hex: "#E23744").opacity(0.4), radius: 8, y: 4)
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: Restaurant(
            restId: "1",
            restTitle: "Burger Garage",
            restImg: nil,
            restRating: "4.5",
            restDeliverytime: "25 mins",
            restCostfortwo: "400",
            restIsVeg: 0,
            restDistance: "0.5 km",
            restIsOpen: 1
        ))
        .environmentObject(CartManager.shared)
    }
}

