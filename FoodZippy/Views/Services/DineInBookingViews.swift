import SwiftUI
import MapKit

// MARK: - Dine In Restaurant Details View
struct DineInRestaurentDetailsView: View {
    let restaurant: Restaurant

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = RestaurantViewModel()

    @State private var isFavourite = false
    @State private var showPayBillAlert = false
    @State private var showQrAlert = false
    
    // UI State for Offers
    @State private var selectedOfferType = "Pre-booking offers"

    private var effectiveRestaurant: Restaurant { viewModel.restaurant ?? restaurant }
    
    private var menuItems: [MenuItem] {
        viewModel.productCategories
            .flatMap { $0.menuitemData ?? [] }
    }
    
    private var restaurantCoordinate: CLLocationCoordinate2D {
        let lat = Double(effectiveRestaurant.restLats ?? "") ?? 26.9124
        let lng = Double(effectiveRestaurant.restLongs ?? "") ?? 75.7873
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: restaurantCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    private func resolvedURL(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        if raw.hasPrefix("http") { return URL(string: raw) }
        return URL(string: Constants.baseURL + raw)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Hero Image Header
                    heroHeader
                    
                    // 2. Overlapping Info Card
                    infoCard
                        .padding(.horizontal, 16)
                        .padding(.top, -45) // Structurally accurate overlap
                        .zIndex(1) // Ensures it renders above the image and its shadow drops correctly
                    
                    // 3. Main Content
                    bodyContent
                }
                .padding(.bottom, 140) // Space for bottom fixed bar
            }
            .ignoresSafeArea(edges: .top)
            .background(Color(hex: "#F8F8FA").ignoresSafeArea()) // Light background
            
            // Fixed Bottom Bar
            bottomFixedBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            isFavourite = effectiveRestaurant.isFav
            if let restId = restaurant.restId, !restId.isEmpty {
                await viewModel.loadRestaurant(restId: restId)
                isFavourite = effectiveRestaurant.isFav
            }
        }
        .alert("Scan QR on your table", isPresented: $showQrAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert("Pay bill now", isPresented: $showPayBillAlert) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            appState.hideMainTabBar = true
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        ZStack(alignment: .top) {
            if let url = resolvedURL(effectiveRestaurant.restImg) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: Color.black.opacity(0.1)
                    }
                }
                .frame(height: 320)
                .clipped()
            } else {
                LinearGradient(colors: [Color(hex: "#484848"), Color(hex: "#7A7A7A")], startPoint: .top, endPoint: .bottom)
                    .frame(height: 320)
            }
            
            // Top Nav & Badges overlaid on image
            VStack {
                topBar.padding(.top, 55)
                Spacer()
                HStack {
                    Spacer()
                    // Image Counter Badge
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                        Text("3/9")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.trailing, 16)
                    .padding(.bottom, 60) // Visible above the -45 overlap
                }
            }
        }
        .frame(height: 320)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            circularButton(icon: "arrow.left", tint: .black, background: .white) { dismiss() }
            Spacer()
            circularButton(icon: isFavourite ? "heart.fill" : "heart", tint: .black, background: .white) { isFavourite.toggle() }
            ShareLink(item: URL(string: "https://foodzippy.com")!) {
                circleIcon(icon: "square.and.arrow.up", tint: .black, background: .white)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(effectiveRestaurant.restTitle ?? "Arogo")
                    .font(.system(size: 28, weight: .bold)) 
                    .foregroundColor(.black)
                
                Spacer()
                
                // Rating Badge
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(effectiveRestaurant.restRating ?? "4.0")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#1D8B41")) // Dark Green
                    .cornerRadius(6)
                    
                    HStack(spacing: 2) {
                        Text("G").font(.system(size: 10, weight: .black)).foregroundColor(.gray)
                        Text("Google")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    
                    Text("19 ratings")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                        .overlay( 
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 14),
                            alignment: .bottom
                        )
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(effectiveRestaurant.restDistance ?? "11.1 km") • \(effectiveRestaurant.restFullAddress ?? effectiveRestaurant.restLandmark ?? "Grand Uniara Hotel, Lal Kothi, Jaipur")")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#4A4A4A"))
                        .lineLimit(2)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color(hex: "#FF6300"))
                }
                
                Text("North Indian, South Indian | ₹\(effectiveRestaurant.restCostfortwo ?? "1800") for two")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            HStack {
                HStack(spacing: 4) {
                    Text("Open")
                        .foregroundColor(Color(hex: "#1D8B41"))
                        .font(.system(size: 12, weight: .bold))
                    Text("till 10:30PM")
                        .foregroundColor(.gray)
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(hex: "#EAF5EE")) // Light green bg
                .cornerRadius(8)

                Spacer()
                
                HStack(spacing: 12) {
                    roundedActionBtn(icon: "arrow.turn.up.right") {
                        // Action for directions
                    }
                    roundedActionBtn(icon: "phone.fill") {
                        // Action for calling
                        guard let phone = effectiveRestaurant.restMobile?.filter(\.isNumber),
                              let url = URL(string: "tel://\(phone)") else { return }
                        openURL(url)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
    }

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            offersSection
            qrCodeCard
            mapSection
            itemsSection
        }
        .padding(.top, 16) 
    }
    
    private var offersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Offers for you")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
            
            HStack(spacing: 20) {
                offerTab(title: "Pre-booking offers")
                offerTab(title: "Bill payment offers")
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<2) { _ in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FLAT 20% OFF")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "#E23744"))
                            Text("on total bill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(16)
                        .frame(width: 200)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E8E8E8"), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private func offerTab(title: String) -> some View {
        Button(action: { selectedOfferType = title }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: selectedOfferType == title ? .bold : .medium))
                    .foregroundColor(selectedOfferType == title ? .black : .gray)
                
                if selectedOfferType == title {
                    Color(hex: "#E23744").frame(height: 2).cornerRadius(1)
                } else {
                    Color.clear.frame(height: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var qrCodeCard: some View {
        Button(action: { showQrAlert = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FF6300").opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#FF6300"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scan QR on table")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text("Order food directly from your table")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
            
            ZStack(alignment: .bottomTrailing) {
                Map(coordinateRegion: .constant(mapRegion), annotationItems: [DineInMapMarker(coordinate: restaurantCoordinate)]) { marker in
                    MapMarker(coordinate: marker.coordinate, tint: .red)
                }
                .frame(height: 190)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                Button("Directions") {
                    openMapDirections()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.75))
                .clipShape(Capsule())
                .padding(10)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
            
            if menuItems.isEmpty {
                Text("No items available right now.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(menuItems.prefix(10).enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 12) {
                            if let url = resolvedURL(item.itemImg) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        Color.gray.opacity(0.16)
                                    }
                                }
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            } else {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.gray.opacity(0.16))
                                    .frame(width: 56, height: 56)
                                    .overlay(Image(systemName: "fork.knife").foregroundColor(.gray))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title ?? "Item")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                Text(item.cdesc ?? "Freshly prepared")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Text("₹\(Int(item.effectivePrice))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        
                        Divider().padding(.leading, 84).padding(.trailing, 16)
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Fixed Bottom Bar
    private var bottomFixedBar: some View {
        VStack(spacing: 0) {
            // DineCash Banner
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#1D8B41"))
                Text("Pay via Zippy Money to get extra 5% cashback")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#1D8B41"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "#1D8B41"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "#D6F3E6")) // Light green banner bg
            .clipShape(CustomTopRoundedCorner(radius: 16))

            // Action Buttons
            HStack(spacing: 12) {
                NavigationLink(destination: BookTableView(restaurant: effectiveRestaurant).environmentObject(appState)) {
                    Text("Book a table")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#FF6300"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#FFF0E6")) // Light Orange
                        .cornerRadius(12)
                }

                Button(action: { showPayBillAlert = true }) {
                    Text("Pay bill now")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#FF6300")) // Solid Orange
                        .cornerRadius(12)
                }
            }
            .padding(16)
            .background(Color.white)
        }
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -5)
    }

    // Helpers
    private func circularButton(icon: String, tint: Color, background: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) { circleIcon(icon: icon, tint: tint, background: background) }
    }
    private func circleIcon(icon: String, tint: Color, background: Color) -> some View {
        Image(systemName: icon).font(.system(size: 18, weight: .semibold)).foregroundColor(tint)
            .frame(width: 40, height: 40).background(background).clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 4)
    }
    private func roundedActionBtn(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(Color(hex: "#4A4A4A"))
                .frame(width: 38, height: 38).background(Color(hex: "#F5F5F5")).cornerRadius(10)
        }
    }
    
    private func openMapDirections() {
        let c = restaurantCoordinate
        guard let url = URL(string: "http://maps.apple.com/?daddr=\(c.latitude),\(c.longitude)") else { return }
        openURL(url)
    }
}

// MARK: - Helper Structs & Shapes (MUST BE OUTSIDE THE VIEW)

// Map the old simplified view directly to this new one to prevent code breaks
typealias DineInRestaurantDetailView = DineInRestaurentDetailsView

struct DineInMapMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct CustomTopRoundedCorner: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

// MARK: - Past Dine In Bookings View
struct PastDineInBookingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Using mock data for now
    private var pastBookings: [PastBookingItem] = [
        PastBookingItem(id: "1", restaurantName: "Royal Table", image: "burger", date: "15 Apr 2026, 8:00 PM", guests: 2, status: "Completed"),
        PastBookingItem(id: "2", restaurantName: "Family Feast Hub", image: "burger", date: "10 Apr 2026, 1:00 PM", guests: 4, status: "Completed"),
        PastBookingItem(id: "3", restaurantName: "Fine Dine Grill", image: "burger", date: "05 Apr 2026, 7:30 PM", guests: 2, status: "Cancelled")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Past Bookings")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                // Placeholder to balance the back button
                Image(systemName: "arrow.left")
                    .foregroundColor(.clear)
            }
            .padding()
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 5)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(pastBookings) { booking in
                        PastBookingCard(booking: booking)
                    }
                }
                .padding()
            }
            .background(Color(hex: "#F8F8FA"))
        }
        .navigationBarHidden(true)
    }
}

struct PastBookingItem: Identifiable {
    let id: String
    let restaurantName: String
    let image: String
    let date: String
    let guests: Int
    let status: String
}

struct PastBookingCard: View {
    let booking: PastBookingItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(booking.image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.restaurantName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text("\(booking.date) | \(booking.guests) Guests")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray)
                
                Text(booking.status)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(booking.status == "Completed" ? Color(hex: "#1D8B41") : Color.red)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

extension Formatter {
    static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()
    static let shortWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
}
