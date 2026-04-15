import SwiftUI

struct RestaurantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private let chips = ["Pure Veg", "EatRight", "Ratings 4.0+", "Bestseller", "Fast Delivery"]
    private let topPicks: [TopPickDish] = [
        .init(
            name: "Shahi Paneer",
            imageURL: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=1200&q=80",
            oldPrice: "₹120",
            offerPrice: "₹99",
            isVeg: true,
            badge: nil
        ),
        .init(
            name: "Kadai Paneer",
            imageURL: "https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=1200&q=80",
            oldPrice: "₹140",
            offerPrice: "₹99",
            isVeg: true,
            badge: "Bestseller"
        )
    ]

    var body: some View {
        GeometryReader { geo in
            let headerHeight = geo.size.height * 0.25

            ZStack(alignment: .bottom) {
                Color(hex: "#F4F4F5").ignoresSafeArea()

                VStack(spacing: 0) {
                    Color(hex: "#020817")
                        .frame(height: headerHeight)
                    Spacer(minLength: 0)
                }
                .ignoresSafeArea(edges: .top)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        customNavigationBar
                            .padding(.top, geo.safeAreaInsets.top + 8)
                            .padding(.horizontal, 18)

                        restaurantInfoCard
                            .padding(.top, 10)
                            .padding(.horizontal, 14)

                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                        filterChips

                        topPicksSection

                        Spacer(minLength: 140)
                    }
                }
                .padding(.top, 0)

                floatingMenuButton
                    .padding(.trailing, 18)
                    .padding(.bottom, 110)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                bottomCartBanner
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var customNavigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 15, weight: .semibold))
                        Text("GROUP ORDER")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white.opacity(0.92))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.55), lineWidth: 1.5)
                    )
                }

                Button(action: {}) {
                    Image(systemName: "ellipsis.vertical")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
    }

    private var restaurantInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#159A6E"))
                        Text("Pure Veg")
                            .font(.system(size: 41/2, weight: .bold))
                            .foregroundColor(Color(hex: "#159A6E"))
                    }

                    Text("Shri Govindam Pavitra\nBhojnalaya")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(Color(hex: "#171A29"))
                        .lineSpacing(2)

                    HStack(spacing: 10) {
                        Text("40–45 mins")
                        Text("|")
                        Text("Jagatpura")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#8A8D94"))
                }

                Spacer(minLength: 10)

                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("3.8")
                        Image(systemName: "star.fill")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .font(.system(size: 35/2, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#1EA86F"))
                    .clipShape(Capsule())

                    Text("2.5K+ ratings")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#8A8D94"))
                }
            }

            Divider()
                .overlay(Color(hex: "#E7E7EA"))

            HStack(alignment: .center) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: "#F6F0F5"))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "#A11457"))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Flat ₹150 off")
                            .font(.system(size: 41/2, weight: .heavy))
                            .foregroundColor(Color(hex: "#171A29"))
                        Text("USE AXISREWARDS | ABOVE ₹500")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#8A8D94"))
                    }
                }

                Spacer(minLength: 10)

                VStack(alignment: .trailing, spacing: 8) {
                    Text("2/5")
                        .font(.system(size: 37/2, weight: .black))
                        .foregroundColor(Color(hex: "#F65A0A"))

                    HStack(spacing: 6) {
                        Circle().fill(Color(hex: "#D8D8DC")).frame(width: 8, height: 8)
                        Circle().fill(Color(hex: "#F65A0A")).frame(width: 10, height: 10)
                        Circle().fill(Color(hex: "#D8D8DC")).frame(width: 8, height: 8)
                    }
                }
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 20, x: 0, y: 10)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "#6E7280"))

            TextField("Search for dishes", text: $searchText)
                .font(.system(size: 20/2, weight: .medium))
                .foregroundColor(Color(hex: "#4A4D55"))

            Divider()
                .frame(height: 30)
                .overlay(Color(hex: "#D0D2D8"))

            Button(action: {}) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#FC791A"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(hex: "#EAEAF0"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(chips, id: \.self) { chip in
                    HStack(spacing: 8) {
                        if chip == "Pure Veg" {
                            Image(systemName: "leaf")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#159A6E"))
                        } else if chip == "EatRight" {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#4B4E57"))
                        }

                        Text(chip)
                            .font(.system(size: 18/2*2, weight: .semibold))
                            .foregroundColor(chip == "Pure Veg" ? Color(hex: "#159A6E") : Color(hex: "#4B4E57"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(hex: "#D6D7DC"), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var topPicksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .overlay(Color(hex: "#DCDDDF"))
                .padding(.horizontal, 16)

            Text("Top Picks")
                .font(.system(size: 40/2, weight: .black))
                .foregroundColor(Color(hex: "#171A29"))
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(topPicks) { dish in
                        TopPickCard(dish: dish)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var floatingMenuButton: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle.portrait")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
                Text("MENU")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 108, height: 108)
            .background(Color(hex: "#020817"))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 8)
        }
    }

    private var bottomCartBanner: some View {
        VStack(spacing: 0) {
            Color.white
                .frame(height: 10)

            HStack {
                Text("1 Item added")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 8) {
                    Text("View Cart")
                        .font(.system(size: 19, weight: .bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color(hex: "#22A36D"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
            .background(Color.white)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct TopPickDish: Identifiable {
    let id = UUID()
    let name: String
    let imageURL: String
    let oldPrice: String
    let offerPrice: String
    let isVeg: Bool
    let badge: String?
}

private struct TopPickCard: View {
    let dish: TopPickDish

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: dish.imageURL)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.gray.opacity(0.16))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.gray.opacity(0.18))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 330, height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            LinearGradient(
                colors: [.black.opacity(0.72), .black.opacity(0.12), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(width: 330, height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            if let badge = dish.badge {
                Text(badge)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(Color(hex: "#F65A0A"))
                    .shadow(color: .white.opacity(0.95), radius: 1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)
                    .padding(.bottom, 128)
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color(hex: "#129A5E"), lineWidth: 1.6)
                            .frame(width: 16, height: 16)
                        Circle()
                            .fill(Color(hex: "#129A5E"))
                            .frame(width: 8, height: 8)
                    }

                    Text(dish.name)
                        .font(.system(size: 41/2, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(dish.oldPrice)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white.opacity(0.82))
                        .strikethrough()

                    Text(dish.offerPrice)
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Color(hex: "#1D1D20"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#FFD938"))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }

                Spacer()

                Button(action: {}) {
                    Text("ADD")
                        .font(.system(size: 20/2*2, weight: .heavy))
                        .foregroundColor(Color(hex: "#1EA86F"))
                        .frame(width: 148, height: 54)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            .frame(width: 330)
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantView()
    }
}
