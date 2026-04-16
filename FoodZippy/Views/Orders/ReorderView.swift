import SwiftUI

struct ReorderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F2F2F7").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    navBar
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            searchBar
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            
                            filterChips
                                .padding(.top, 4)
                            
                            cardsList
                                .padding(.horizontal, 16)
                                .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("REORDER")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            // To balance the back button layout precisely (though opacity 0)
            Image(systemName: "arrow.left")
                .font(.system(size: 20))
                .opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private var searchBar: some View {
        HStack {
            Text("Search by restaurant or dish")
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#8E8E93"))
            
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "#8E8E93"))
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        // Matching Swiggy's subtle search bar look
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ChipView(title: "Favourites")
                ChipView(title: "Price 149 - 300")
                ChipView(title: "Price > 300")
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var cardsList: some View {
        VStack(spacing: 16) {
            // First Card
            ReorderCardView(
                isAvailable: true,
                hasAd: false,
                restaurantName: "Chinese Wok",
                deliveryTime: "30–35 mins",
                offerText: "50% off",
                imageName: "noodles", 
                dishName: "Veg Schezwan Noodles - Half (500 ml)",
                price: "₹199",
                oldPrice: "₹279",
                isVeg: true
            )
            
            // Second Card (Unavailable)
            ReorderCardView(
                isAvailable: false,
                hasAd: false,
                restaurantName: "Pari Cafe",
                deliveryTime: "45–50 mins",
                offerText: "₹50 off above ₹399",
                imageName: "thali",
                dishName: "8Poori With Aloo Sabji",
                price: "₹120",
                oldPrice: nil,
                isVeg: true,
                extraDishName: "Adrak tea",
                extraDishPrice: "₹40",
                extraDishIsVeg: true
            )
            
            // Third Card (Ad)
            ReorderCardView(
                isAvailable: true,
                hasAd: true,
                restaurantName: "Pizza Hut",
                deliveryTime: "35–40 mins",
                offerText: "₹80 off above ₹249",
                imageName: "pizza",
                dishName: "Create Your Flavour Fun Combo - Box Of 2 - Veg Pizza",
                price: "₹218",
                oldPrice: nil,
                isVeg: true
            )
        }
    }
}

// MARK: - Filter Chip View
struct ChipView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Color(hex: "#3C3C43"))
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Reorder Card View
struct ReorderCardView: View {
    let isAvailable: Bool
    let hasAd: Bool
    let restaurantName: String
    let deliveryTime: String
    let offerText: String
    let imageName: String
    let dishName: String
    let price: String
    let oldPrice: String?
    let isVeg: Bool
    
    // For the second layout which has multiple dishes
    var extraDishName: String? = nil
    var extraDishPrice: String? = nil
    var extraDishIsVeg: Bool? = nil
    
    @State private var isLoved = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Row
            HStack(alignment: .top, spacing: 12) {
                // Restaurant Image
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: "https://via.placeholder.com/100")) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ProgressView().scaleEffect(0.5))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(Image(systemName: "photo").foregroundColor(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    if hasAd {
                        Text("Ad")
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white)
                            .cornerRadius(4)
                            .padding(.top, -6)
                            .padding(.leading, -4)
                            .shadow(color: .black.opacity(0.2), radius: 2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Restaurant Name & Time
                    HStack(spacing: 4) {
                        Text(restaurantName)
                            .font(.system(size: 15, weight: .bold))
                        Text("•")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Text(deliveryTime)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    
                    // Offer Tag
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#FF5722"))
                        
                        Text(offerText)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#5C5C60"))
                    }
                }
                
                Spacer()
                
                // Favorite Button
                Button(action: { isLoved.toggle() }) {
                    Image(systemName: isLoved ? "heart.fill" : "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isLoved ? Color.red : Color(hex: "#D1D1D6"))
                }
                .padding(.top, 4)
            }
            .padding(14)
            
            Divider()
                .padding(.horizontal, 14)
                .opacity(0.6)
            
            // Availability Message
            if !isAvailable {
                Text("Not available at the moment")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#D97706")) // Orange-ish
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .padding(.bottom, -2) // Reduce bottom padding before the dish items
            }
            
            // Dish Row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 14) {
                    dishItemView(
                        name: dishName,
                        price: price,
                        oldPrice: oldPrice,
                        isVeg: isVeg,
                        isAvailable: isAvailable
                    )
                    
                    if let extName = extraDishName, let extPrice = extraDishPrice, let extVeg = extraDishIsVeg {
                        dishItemView(
                            name: extName,
                            price: extPrice,
                            oldPrice: nil,
                            isVeg: extVeg,
                            isAvailable: isAvailable
                        )
                    }
                }
                
                Spacer()
                
                // Add Button
                if isAvailable {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#1EA86F")) // Green
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.top, 4)
                }
            }
            .padding(14)
            .padding(.top, isAvailable ? 0 : 2)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func dishItemView(name: String, price: String, oldPrice: String?, isVeg: Bool, isAvailable: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Veg Indicator
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(isVeg ? Color(hex: "#1EA86F") : Color.red, lineWidth: 1.5)
                    .frame(width: 14, height: 14)
                Circle()
                    .fill(isVeg ? Color(hex: "#1EA86F") : Color.red)
                    .frame(width: 6, height: 6)
            }
            .padding(.top, 3)
            .opacity(isAvailable ? 1.0 : 0.4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isAvailable ? Color.black : Color(hex: "#8E8E93"))
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(price)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isAvailable ? Color(hex: "#3C3C43") : Color(hex: "#8E8E93"))
                    
                    if let old = oldPrice {
                        Text(old)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#8E8E93"))
                            .strikethrough()
                    }
                }
            }
        }
    }
}

#Preview {
    ReorderView()
}
