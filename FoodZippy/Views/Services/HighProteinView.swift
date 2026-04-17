import SwiftUI

// MARK: - Main View
struct HighProteinView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let restaurants: [HighProteinRestaurant] = [
        HighProteinRestaurant(
            name: "The Pankh Restaur...",
            rating: "3",
            eta: "12 mins",
            categories: "Fast Food, Snacks, Beverages",
            location: "Pratap Nagar • 0.1 km",
            imageURL: URL(string: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80"),
            strikeText: "Items at ₹450",
            offerText: "AT ₹59",
            restaurant: Restaurant(
                restId: "high-protein-pankh",
                restTitle: "The Pankh Restaur...",
                restImg: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1200&q=80",
                restImg1: nil,
                restImg2: nil,
                restImg3: nil,
                restLogo: nil,
                restRating: "3",
                restDeliverytime: "12 mins",
                restCostfortwo: nil,
                restIsVeg: 0,
                restFullAddress: "Pratap Nagar • 0.1 km",
                restLandmark: nil,
                restMobile: nil,
                restLats: nil,
                restLongs: nil,
                restCharge: nil,
                restLicence: nil,
                restDcharge: nil,
                restMorder: nil,
                restIsOpen: 1,
                restIsDeliver: 1,
                restSdesc: "Fast Food, Snacks, Beverages",
                restDistance: "0.1 km",
                isFavourite: 0,
                couTitle: nil,
                couSubtitle: nil,
                isPreorder: 0,
                openTime: nil,
                closeTime: nil,
                deliveryTypes: nil,
                deliveryTypesLabels: nil
            )
        ),
        HighProteinRestaurant(
            name: "Protein Factory",
            rating: "4.2",
            eta: "16 mins",
            categories: "Healthy Food, Salads, Bowls",
            location: "Malviya Nagar • 1.3 km",
            imageURL: URL(string: "https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=900&q=80"),
            strikeText: "Items at ₹320",
            offerText: "AT ₹99",
            restaurant: Restaurant(
                restId: "high-protein-factory",
                restTitle: "Protein Factory",
                restImg: "https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=1200&q=80",
                restImg1: nil,
                restImg2: nil,
                restImg3: nil,
                restLogo: nil,
                restRating: "4.2",
                restDeliverytime: "16 mins",
                restCostfortwo: nil,
                restIsVeg: 1,
                restFullAddress: "Malviya Nagar • 1.3 km",
                restLandmark: nil,
                restMobile: nil,
                restLats: nil,
                restLongs: nil,
                restCharge: nil,
                restLicence: nil,
                restDcharge: nil,
                restMorder: nil,
                restIsOpen: 1,
                restIsDeliver: 1,
                restSdesc: "Healthy Food, Salads, Bowls",
                restDistance: "1.3 km",
                isFavourite: 0,
                couTitle: nil,
                couSubtitle: nil,
                isPreorder: 0,
                openTime: nil,
                closeTime: nil,
                deliveryTypes: nil,
                deliveryTypesLabels: nil
            )
        )
    ]

    var body: some View {
        // Removed GeometryReader wrapping the whole view to prevent layout collapsing issues
        // Safe area is handled automatically by the NavigationStack/ScrollView.
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    BannerView()
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                    Text("High Protein Restaurants")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(Color(hex: "#2E2E2E"))
                        .padding(.horizontal, 16)
                        .padding(.top, 24)

                    CustomTabBar(tabs: ["Restaurants"], selectedTab: .constant("Restaurants"))
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    VStack(spacing: 16) {
                        ForEach(restaurants) { restaurant in
                            RestaurantCard(restaurant: restaurant)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(hex: "#F7F7F7"))
        }
        .background(Color(hex: "#F7F7F7").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack {
            Button {
                if appState.selectedTab == .highProtein {
                    appState.selectedTab = .home
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#222222"))
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(hex: "#F7F7F7"))
    }
}

// MARK: - Responsive Banner
struct BannerView: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: "#F5F2E9"))
                
                // Decorative Shapes (Using relative positioning instead of fixed offsets)
                Circle()
                    .fill(Color(hex: "#BBD7A0").opacity(0.75))
                    .frame(width: width * 0.5)
                    .position(x: 0, y: 0) // Top Left
                
                Ellipse()
                    .fill(Color(hex: "#A8C98D").opacity(0.8))
                    .frame(width: width * 0.6, height: 160)
                    .position(x: width, y: 244) // Bottom Right
                
                // Content
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HIGH PROTEIN")
                            .font(.system(size: width > 350 ? 27 : 22, weight: .black))
                            .foregroundColor(Color(hex: "#1F5630"))
                            .kerning(0.3)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text("No Fluff\nJust Stuff")
                            .font(.system(size: width > 350 ? 21 : 18, weight: .medium))
                            .foregroundColor(Color(hex: "#6FA15D"))
                            .lineSpacing(4)
                    }
                    .padding(.leading, 20)

                    Spacer(minLength: 10)

                    // Responsive Image
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: width * 0.4, height: width * 0.4)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: width * 0.4, height: width * 0.4)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "fork.knife.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(hex: "#6CA86B"))
                                .padding(20)
                                .background(Color.white.opacity(0.6))
                                .clipShape(Circle())
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.24))
                            .frame(width: (width * 0.4) + 10, height: (width * 0.4) + 10)
                    )
                    .shadow(color: .black.opacity(0.16), radius: 10, y: 6)
                    .padding(.trailing, 16)
                }
            }
            // CRITICAL: Clip the decorations so they don't leak outside the banner
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)) 
        }
        .frame(height: 220) // Give GeometryReader a fixed height to work with
    }
}

// MARK: - Restaurant Card
struct RestaurantCard: View {
    let restaurant: HighProteinRestaurant
    @State private var isFavourite = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink {
                RestaurantView(restaurant: restaurant.restaurant)
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: restaurant.imageURL) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.2).overlay { ProgressView() }
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Color.gray.opacity(0.15)
                                    .overlay { Image(systemName: "photo").foregroundColor(.gray.opacity(0.8)) }
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 110, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.16), .black.opacity(0.60)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(restaurant.strikeText)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.95))
                                .strikethrough()

                            Text(restaurant.offerText)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding([.leading, .bottom], 10)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(restaurant.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#222222"))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 6) {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 9, weight: .bold))
                                Text(restaurant.rating)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#17994A"))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                            Text("• \(restaurant.eta)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#505050"))
                        }

                        Text(restaurant.categories)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(hex: "#7A7A7A"))
                            .lineLimit(1)

                        Text(restaurant.location)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(hex: "#A2A2A2"))
                            .lineLimit(1)
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 0)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            }
            .buttonStyle(.plain)

            Button {
                isFavourite.toggle()
            } label: {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isFavourite ? Color(hex: "#FF4B55") : Color(hex: "#2D2D2D"))
                    .frame(width: 28, height: 28)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.14), radius: 5, y: 2)
            }
            .padding(.top, 18)
            .padding(.trailing, 18)
        }
    }
}

// MARK: - Supporting Views & Models
struct CustomTabBar: View {
    let tabs: [String]
    @Binding var selectedTab: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs, id: \.self) { tab in
                Text(tab)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(selectedTab == tab ? Color(hex: "#1F5630") : Color(hex: "#7C7C7C"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedTab == tab ? Color(hex: "#E8F2DF") : Color.white)
                    .clipShape(Capsule())
            }
            Spacer(minLength: 0)
        }
    }
}

struct HighProteinRestaurant: Identifiable {
    let id = UUID()
    let name: String
    let rating: String
    let eta: String
    let categories: String
    let location: String
    let imageURL: URL?
    let strikeText: String
    let offerText: String
    let restaurant: Restaurant
}

#Preview {
    NavigationStack {
        HighProteinView()
            .environmentObject(AppState.shared)
    }
}