import SwiftUI
import MapKit

struct TakeAwaysDetailsView: View {
    let restaurant: Restaurant
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = RestaurantViewModel()
    
    @State private var isPureVeg = false
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 26.9124, longitude: 75.7873),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Grid columns for menu items
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private var menuItemsToDisplay: [MenuItem] {
        viewModel.filteredCategories.flatMap { $0.menuitemData ?? [] }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // 1. Red Header
                    ZStack(alignment: .top) {
                        Color(hex: "#E23744")
                            .frame(height: 150)
                        
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task { await viewModel.toggleFavourite() }
                            }) {
                                Image(systemName: viewModel.isFavourite ? "suit.heart.fill" : "heart")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "#E23744"))
                                    .padding(8)
                                    .background(Circle().fill(Color.white))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 60)
                    }
                    .ignoresSafeArea(edges: .top)
                    
                    // 2. Overlapping Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Best in Pickup")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "#FF9800"))
                        
                        HStack {
                            Text(restaurant.restTitle ?? "Restaurant Name")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text(restaurant.restRating ?? "4.5")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#098430"))
                            .cornerRadius(6)
                        }
                        
                        HStack(spacing: 4) {
                            Text(restaurant.restDeliverytime ?? "25-30 mins")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#666666"))
                            Text("•")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#666666"))
                            Text(restaurant.restSdesc ?? "Restaurant Category")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#666666"))
                            Text("•")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#666666"))
                            Text(restaurant.restDistance ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#666666"))
                        }
                        .padding(.top, 4)
                        
                        Text("Takeaway only")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#666666"))
                            .padding(.top, 2)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .offset(y: -40)
                    .padding(.bottom, -40)
                    
                    // 3. Ready for self-pickup
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ready for self-pickup")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#6B1F1F"))
                        Text("Order will be ready approximately \(restaurant.restDeliverytime ?? "20-25 mins").")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8B5050"))
                        
                        Text("Pickup instructions")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#6B1F1F"))
                            .padding(.top, 8)
                        Text("Please collect the order from the takeaway counter at the entrance.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8B5050"))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#FDF5F5"))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // 4. Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "#999999"))
                        TextField("Search in Menu", text: $searchText)
                            .font(.system(size: 14))
                        Image(systemName: "mic.fill")
                            .foregroundColor(Color(hex: "#E23744"))
                    }
                    .padding(12)
                    .background(Color(hex: "#F5F5F5"))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // 5. Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChipTakeaway(title: "Pure Veg", isSelected: $isPureVeg)
                                .onChange(of: isPureVeg) { newValue in
                                    viewModel.vegOnly = newValue
                                }
                            FilterChipTakeaway(title: "Ratings 4.0", isSelected: .constant(false))
                            FilterChipTakeaway(title: "60% Off", isSelected: .constant(false))
                            FilterChipTakeaway(title: "Best Seller", isSelected: .constant(false))
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 12)
                    
                    // 6. Map
                    Map(coordinateRegion: $region, annotationItems: [restaurant].compactMap { MapMarkerItem(rest: $0) }) { marker in
                        MapMarker(coordinate: marker.coordinate, tint: Color(hex: "#E23744"))
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // 7. Menu Items Grid
                    if viewModel.filteredCategories.isEmpty && viewModel.isLoading {
                        // Still loading - show dummy cards
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(getDummyMenuItems()) { item in
                                TakeawayMenuItemCard(item: item, onAdd: {
                                    addToCart(item: item)
                                })
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                        .opacity(0.6)
                        .overlay(alignment: .top) {
                            ProgressView("Loading menu items...")
                                .padding(.top, 30)
                        }
                    } else if viewModel.filteredCategories.isEmpty {
                        // No data available
                        VStack {
                            Text("No menu items available")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        }
                    } else {
                        // Data loaded successfully
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredCategories.flatMap { $0.menuitemData ?? [] }) { item in
                                TakeawayMenuItemCard(item: item, onAdd: {
                                    addToCart(item: item)
                                })
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color.white)
            
            // 8. Sticky Bottom Cart Bar
            if !cartManager.cartItems.isEmpty {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(cartManager.cartItems.reduce(0) { $0 + $1.quantity }) Item Added")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("₹\(String(format: "%.2f", cartManager.totalAmount))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: CartView().environmentObject(cartManager)) {
                            HStack {
                                Text("View Cart")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(hex: "#E23744"))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(hex: "#E23744"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#E23744"))
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .onAppear {
            appState.hideMainTabBar = true
        }
        .onDisappear {
            appState.hideMainTabBar = false
        }
        .task {
            await viewModel.loadRestaurant(restId: restaurant.restId ?? "")
            if let latStr = restaurant.restLats, let lat = Double(latStr),
               let lngStr = restaurant.restLongs, let lng = Double(lngStr) {
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    private func addToCart(item: MenuItem) {
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
            addonId: "",
            addonTitle: "",
            addonPrice: ""
        )
        cartManager.addItem(cartItem, restaurantName: restaurant.restTitle ?? "")
    }
    
    private func getDummyMenuItems() -> [MenuItem] {
        return [
            MenuItem(
                id: "dummy-1",
                title: "Chicken Biryani",
                itemImg: "burger",
                price: FlexibleNumber(299),
                originalPrice: "399",
                offerPercentage: 25,
                offerPercentageText: "25% OFF",
                discountAmount: "100",
                finalPrice: "299",
                isCustomize: 0,
                requiredStep: 0,
                cdesc: "Fragrant basmati rice with spiced chicken",
                isQuantity: "1",
                isVeg: 0,
                isSubscription: "0",
                addondata: nil
            ),
            MenuItem(
                id: "dummy-2",
                title: "Paneer Tikka",
                itemImg: "burger",
                price: FlexibleNumber(199),
                originalPrice: "279",
                offerPercentage: 28,
                offerPercentageText: "28% OFF",
                discountAmount: "80",
                finalPrice: "199",
                isCustomize: 0,
                requiredStep: 0,
                cdesc: "Grilled cottage cheese with spices",
                isQuantity: "1",
                isVeg: 1,
                isSubscription: "0",
                addondata: nil
            ),
            MenuItem(
                id: "dummy-3",
                title: "Butter Chicken",
                itemImg: "burger",
                price: FlexibleNumber(349),
                originalPrice: "449",
                offerPercentage: 22,
                offerPercentageText: "22% OFF",
                discountAmount: "100",
                finalPrice: "349",
                isCustomize: 0,
                requiredStep: 0,
                cdesc: "Tender chicken in creamy butter sauce",
                isQuantity: "1",
                isVeg: 0,
                isSubscription: "0",
                addondata: nil
            ),
            MenuItem(
                id: "dummy-4",
                title: "Garlic Naan",
                itemImg: "burger",
                price: FlexibleNumber(49),
                originalPrice: "69",
                offerPercentage: 29,
                offerPercentageText: "29% OFF",
                discountAmount: "20",
                finalPrice: "49",
                isCustomize: 0,
                requiredStep: 0,
                cdesc: "Soft naan bread with fresh garlic",
                isQuantity: "1",
                isVeg: 1,
                isSubscription: "0",
                addondata: nil
            )
        ]
    }
}

struct TakeawayMenuItemCard: View {
    let item: MenuItem
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Image or fallback
                Group {
                    if let itemImg = item.itemImg, !itemImg.isEmpty, let url = URL(string: itemImg) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image("burger")
                                .resizable()
                                .scaledToFill()
                        }
                    } else {
                        Image("burger")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(8)
                
                // Veg/Non-veg indicator
                HStack(spacing: 0) {
                    if item.isVeg == 1 {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.green, lineWidth: 2)
                            .frame(width: 12, height: 12)
                    } else {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.red, lineWidth: 2)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(8)
                .background(Circle().fill(Color.white))
                .padding(8)
            }
            
            Text(item.title ?? "Item")
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
                .foregroundColor(.black)
            
            if let desc = item.cdesc, !desc.isEmpty {
                Text(desc)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("₹\(String(format: "%.0f", item.effectivePrice))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: onAdd) {
                    Text("ADD")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#E23744"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#E23744"), lineWidth: 1.5)
                        )
                }
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct FilterChipTakeaway: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "#E23744") : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

struct MapMarkerItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    init?(rest: Restaurant) {
        guard let latStr = rest.restLats, let lat = Double(latStr),
              let lngStr = rest.restLongs, let lng = Double(lngStr) else { return nil }
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
