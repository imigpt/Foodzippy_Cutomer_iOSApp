import SwiftUI

struct RestaurantView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var appState: AppState

    @StateObject private var cartViewModel = AddToCartViewModel.shared

    @State private var searchText = ""
    @State private var isUnder199Filter = false
    @State private var isVegFilter = false
    @State private var isNonVegFilter = false
    @State private var isMenuVisible = false
    @State private var isLiked = false

    @State private var selectedDishForDetail: AddToCartDish?
    @State private var selectedDishForCustomization: AddToCartDish?

    private let fastFoodItems: [FastFoodDish] = [
        .init(
            name: "Fries + Sauce",
            imageURL: "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=900&q=80",
            oldPrice: 169,
            offerPrice: 139,
            rating: 4.4,
            ratingCount: 281,
            isVeg: true,
            description: "Golden fries with chef special sauce.",
            isCustomizable: false,
            customisationOptions: []
        ),
        .init(
            name: "Masala Fries",
            imageURL: "https://images.unsplash.com/photo-1619881590738-a111d176d906?auto=format&fit=crop&w=900&q=80",
            oldPrice: 189,
            offerPrice: 149,
            rating: 4.2,
            ratingCount: 202,
            isVeg: true,
            description: "Crispy masala fries with peri peri seasoning.",
            isCustomizable: false,
            customisationOptions: []
        ),
        .init(
            name: "Veg Manchurian",
            imageURL: "https://images.unsplash.com/photo-1604908176997-431221e2d4cf?auto=format&fit=crop&w=900&q=80",
            oldPrice: 229,
            offerPrice: 189,
            rating: 4.5,
            ratingCount: 419,
            isVeg: true,
            description: "Indo-Chinese veggie dumplings in tangy sauce.",
            isCustomizable: true,
            customisationOptions: [
                DishCustomisationOption(id: "half", title: "Half", additionalPrice: 0, isVeg: true),
                DishCustomisationOption(id: "full", title: "Full", additionalPrice: 40, isVeg: true)
            ]
        ),
        .init(
            name: "Paneer Wrap",
            imageURL: "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=900&q=80",
            oldPrice: 249,
            offerPrice: 199,
            rating: 4.3,
            ratingCount: 163,
            isVeg: true,
            description: "Grilled paneer wrap with crunchy veggies.",
            isCustomizable: true,
            customisationOptions: [
                DishCustomisationOption(id: "regular", title: "Regular", additionalPrice: 0, isVeg: true),
                DishCustomisationOption(id: "cheese", title: "Extra Cheese", additionalPrice: 30, isVeg: true)
            ]
        ),
        .init(
            name: "Crispy Burger",
            imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80",
            oldPrice: 259,
            offerPrice: 209,
            rating: 4.6,
            ratingCount: 357,
            isVeg: false,
            description: "Crunchy patty burger with signature sauce.",
            isCustomizable: false,
            customisationOptions: []
        ),
        .init(
            name: "Cheese Pizza Slice",
            imageURL: "https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80",
            oldPrice: 279,
            offerPrice: 219,
            rating: 4.1,
            ratingCount: 138,
            isVeg: true,
            description: "Classic cheese loaded pizza slice.",
            isCustomizable: false,
            customisationOptions: []
        )
    ]

    private let menuItems: [MenuOverlayItem] = [
        .init(title: "Fast Food", count: 6),
        .init(title: "99 Store", count: 11),
        .init(title: "Items starting at 169", count: 104),
        .init(title: "Buy 1 Get 1 Free", count: 3),
        .init(title: "Recommended", count: 20),
        .init(title: "Combos for you", count: 5, badge: "NEW"),
        .init(title: "Fries", count: 3),
        .init(title: "Celebration Combo", count: 8)
    ]

    private var gridColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
        }
        return [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    }

    private var filteredItems: [FastFoodDish] {
        fastFoodItems.filter { dish in
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || dish.name.localizedCaseInsensitiveContains(searchText)
            let matchesPrice = !isUnder199Filter || dish.offerPrice <= 199
            
            let vegFilter = isVegFilter && !isNonVegFilter
            let nonVegFilter = isNonVegFilter && !isVegFilter
            let bothFilters = isVegFilter && isNonVegFilter
            
            let matchesVegFilter: Bool
            if vegFilter {
                matchesVegFilter = dish.isVeg
            } else if nonVegFilter {
                matchesVegFilter = !dish.isVeg
            } else if bothFilters {
                matchesVegFilter = true
            } else {
                matchesVegFilter = true
            }
            
            return matchesSearch && matchesPrice && matchesVegFilter
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                Color(hex: "#F4F4F5").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ZStack(alignment: .top) {
                            Color(hex: "#0F141E")
                                .cornerRadius(34, corners: [.bottomLeft, .bottomRight])

                            VStack(spacing: 14) {
                                customNavigationBar
                                    .padding(.top, geo.safeAreaInsets.top + 6)
                                    .padding(.horizontal, 16)

                                restaurantInfoCard
                                    .padding(.horizontal, 16)
                            }
                        }
                        .frame(height: 312)

                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                        filterChips

                        fastFoodSection
                            .padding(.top, 4)

                        Spacer(minLength: 120)
                    }
                }

                floatingMenuButton
                    .padding(.trailing, 24)
                    .padding(.bottom, 28)
            }
            .overlay {
                if isMenuVisible {
                    Color.black.opacity(0.18)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isMenuVisible = false
                            }
                        }

                    menuOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            appState.hideMainTabBar = true
        }
        .onDisappear {
            appState.hideMainTabBar = false
        }
        .sheet(item: $selectedDishForDetail) { dish in
            DishDetailSheetView(
                dish: dish,
                cartViewModel: cartViewModel,
                onClose: {
                    selectedDishForDetail = nil
                },
                onRequestCustomization: { customDish in
                    selectedDishForDetail = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        selectedDishForCustomization = customDish
                    }
                }
            )
            .presentationDetents([.fraction(0.92), .large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(item: $selectedDishForCustomization) { dish in
            CustomisationSheetView(
                dish: dish,
                cartViewModel: cartViewModel,
                onClose: {
                    selectedDishForCustomization = nil
                }
            )
            .presentationDetents([.fraction(0.62), .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var customNavigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLiked.toggle()
                    }
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(isLiked ? Color(hex: "#FF2D55") : .white)
                        .frame(width: 44, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.45), lineWidth: 1)
                        )
                }

                Button(action: {}) {
                    Image(systemName: "ellipsis.vertical")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var restaurantInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("Pure Veg")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "#1EA86F"))

                    Text("Shri Govindam Pavitra\nBhojnalaya")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#171A29"))
                        .lineSpacing(2)

                    HStack(spacing: 8) {
                        Text("40–45 mins")
                        Text("|")
                            .foregroundColor(Color.gray.opacity(0.5))
                        Text("Jagatpura")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#8A8D94"))
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("3.8")
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "star.fill")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#1EA86F"))
                    .clipShape(Capsule())

                    Text("2.5K+ ratings")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#8A8D94"))
                }
            }

            Divider()
                .background(Color(hex: "#E7E7EA"))

            HStack(alignment: .center) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: "#A11457").opacity(0.1))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "#A11457"))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Flat ₹150 off")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "#171A29"))
                        Text("USE AXISREWARDS | ABOVE ₹500")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8D94"))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("2/5")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#F65A0A"))

                    HStack(spacing: 4) {
                        Circle().fill(Color(hex: "#F65A0A")).frame(width: 6, height: 6)
                        Circle().fill(Color(hex: "#D8D8DC")).frame(width: 5, height: 5)
                        Circle().fill(Color(hex: "#D8D8DC")).frame(width: 5, height: 5)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(hex: "#6E7280"))

            TextField("Search for dishes", text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "#4A4D55"))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

            Divider()
                .frame(height: 22)
                .background(Color(hex: "#D0D2D8"))

            Button(action: {}) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#FC791A"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(hex: "#EAEAF0"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isUnder199Filter.toggle()
                    }
                }) {
                    Text("Under Rs. 199")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isUnder199Filter ? .white : Color(hex: "#4B4E57"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isUnder199Filter ? Color(hex: "#1EA86F") : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isUnder199Filter ? Color.clear : Color(hex: "#E0E0E0"), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isVegFilter.toggle()
                    }
                }) {
                    Text("Veg")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isVegFilter ? .white : Color(hex: "#4B4E57"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isVegFilter ? Color(hex: "#1EA86F") : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isVegFilter ? Color.clear : Color(hex: "#E0E0E0"), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isNonVegFilter.toggle()
                    }
                }) {
                    Text("Non-Veg")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isNonVegFilter ? .white : Color(hex: "#4B4E57"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isNonVegFilter ? Color(hex: "#D54141") : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isNonVegFilter ? Color.clear : Color(hex: "#E0E0E0"), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isUnder199Filter = false
                        isVegFilter = false
                        isNonVegFilter = false
                        searchText = ""
                    }
                }) {
                    Text("Reset")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#4B4E57"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
        }
    }

    private var fastFoodSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .background(Color(hex: "#DCDDDF"))
                .padding(.horizontal, 16)

            Text("Fast Food")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#171A29"))
                .padding(.horizontal, 16)

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(filteredItems) { dish in
                    FastFoodCard(
                        dish: dish,
                        onAdd: { handleAddTap(for: dish) }
                    )
                }
            }
            .padding(.horizontal, 16)

            if filteredItems.isEmpty {
                Text("No items found")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
        }
    }

    private var floatingMenuButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                isMenuVisible.toggle()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                Text("MENU")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 76, height: 76)
            .background(Color(hex: "#010B1A"))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.24), radius: 10, x: 0, y: 5)
        }
    }

    private var menuOverlay: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(menuItems) { item in
                HStack(alignment: .center, spacing: 10) {
                    Text(item.title)
                        .font(.system(size: item.title == "Fast Food" || item.title == "99 Store" ? 18 : 17, weight: item.title == "Fast Food" || item.title == "99 Store" ? .bold : .medium))
                        .foregroundColor(Color.white.opacity(0.97))

                    if let badge = item.badge {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.92))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                    }

                    Spacer()

                    Text("\(item.count)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: 580)
        .background(Color(hex: "#010B1A"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 18)
        .padding(.bottom, 120)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func handleAddTap(for dish: FastFoodDish) {
        let addDish = toAddToCartDish(dish)
        if addDish.isCustomizable {
            selectedDishForCustomization = addDish
        } else {
            selectedDishForDetail = addDish
        }
    }

    private func toAddToCartDish(_ dish: FastFoodDish) -> AddToCartDish {
        AddToCartDish(
            id: dish.id,
            restaurantId: "restaurant-shri-govindam",
            restaurantName: "Shri Govindam",
            title: dish.name,
            imageURL: dish.imageURL,
            description: dish.description,
            basePrice: dish.offerPrice,
            oldPrice: dish.oldPrice,
            rating: dish.rating,
            ratingCount: dish.ratingCount,
            isVeg: dish.isVeg,
            isCustomizable: dish.isCustomizable,	
            customisationOptions: dish.customisationOptions
        )
    }
}

private struct FastFoodDish: Identifiable {
    let id = UUID().uuidString
    let name: String
    let imageURL: String
    let oldPrice: Double
    let offerPrice: Double
    let rating: Double
    let ratingCount: Int
    let isVeg: Bool
    let description: String
    let isCustomizable: Bool
    let customisationOptions: [DishCustomisationOption]

    var ratingText: String { String(format: "%.1f", rating) }

    var oldPriceText: String {
        if oldPrice == floor(oldPrice) {
            return "₹\(Int(oldPrice))"
        }
        return "₹\(String(format: "%.2f", oldPrice))"
    }

    var offerPriceText: String {
        if offerPrice == floor(offerPrice) {
            return "₹\(Int(offerPrice))"
        }
        return "₹\(String(format: "%.2f", offerPrice))"
    }
}

private struct MenuOverlayItem: Identifiable {
    let id = UUID()
    let title: String
    let count: Int
    let badge: String?

    init(title: String, count: Int, badge: String? = nil) {
        self.title = title
        self.count = count
        self.badge = badge
    }
}

private struct FastFoodCard: View {
    let dish: FastFoodDish
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // MARK: - Image
            AsyncImage(url: URL(string: dish.imageURL)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.16))
                        .overlay(ProgressView())

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )

                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 124)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // MARK: - Title
            HStack(spacing: 6) {
                MiniVegIndicator(isVeg: dish.isVeg)

                Text(dish.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#2A2D34"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(height: 20)

            // MARK: - Price
            HStack(spacing: 6) {
                Text(dish.oldPriceText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .strikethrough()
                    .lineLimit(1)

                Text(dish.offerPriceText)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#FFD938"))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(height: 22)

            // MARK: - Bottom Row
            HStack(spacing: 8) {

                // Rating
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .bold))

                    Text("\(dish.ratingText)")
                        .font(.system(size: 11, weight: .bold))
                        .lineLimit(1)
                }
                .foregroundColor(Color(hex: "#0B9F63"))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(hex: "#E9F8F1"))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Spacer(minLength: 0)

                // ADD Button
                Button(action: onAdd) {
                    Text("ADD")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#1EA86F"))
                        .frame(minWidth: 56)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "#D8DBE2"), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: 320, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

private struct MiniVegIndicator: View {
    let isVeg: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(isVeg ? Color(hex: "#129A5E") : Color(hex: "#D54141"), lineWidth: 1.2)
                .frame(width: 12, height: 12)

            Circle()
                .fill(isVeg ? Color(hex: "#129A5E") : Color(hex: "#D54141"))
                .frame(width: 6, height: 6)
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantView()
            .environmentObject(AppState.shared)
    }
}
