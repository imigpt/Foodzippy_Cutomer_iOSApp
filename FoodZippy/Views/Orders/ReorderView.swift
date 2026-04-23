import SwiftUI

struct ReorderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    navBar(safeAreaTop: geo.safeAreaInsets.top)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            searchBar
                                .padding(.horizontal, 16)
                                .padding(.top, 8)

                            filterChips
                                .padding(.top, 4)

                            Spacer()
                                .frame(height: 8)

                            cardsList
                                .padding(.horizontal, 16)
                                .padding(.bottom, 100)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func navBar(safeAreaTop: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    if appState.selectedTab == .reorder {
                        appState.selectedTab = .home
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("REORDER")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .tracking(0.5)
                
                Spacer()
                
                // Mirroring back button for perfect centering, but keeping it empty or a placeholder if needed
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .opacity(0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.top, safeAreaTop)
            
            Divider()
                .padding(.horizontal, 0)
                .background(Color(hex: "#E8E8E8"))
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search by restaurant or dish", text: .constant(""))
                .font(.system(size: 14))
                .foregroundColor(.black)
                .disabled(true) // Just for layout match as per image
            
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#999999"))
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
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
        VStack(spacing: 14) {
            // Sample Reorder Cards
            ReorderCardView(
                restaurantName: "World Trade Park",
                location: "Jaipur",
                total: "₹1220",
                itemName: "WTP Special x 8",
                itemPrice: "₹1220",
                isVeg: true,
                status: "Completed"
            )
            
            ReorderCardView(
                restaurantName: "World Trade Park",
                location: "Jaipur",
                total: "₹320",
                itemName: "chocolate Shake x 4",
                itemPrice: "₹320",
                isVeg: true,
                status: "Completed"
            )
            
            ReorderCardView(
                restaurantName: "World Trade Park",
                location: "Jaipur",
                total: "₹470",
                itemName: "WTP Special x 3",
                itemPrice: "₹470",
                isVeg: true,
                status: "Completed"
            )
        }
    }
}

// MARK: - Filter Chip View
struct ChipView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.black.opacity(0.8))
            .padding(.horizontal, 14)
            .frame(height: 32)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
            )
    }
}

// MARK: - Reorder Card View
struct ReorderCardView: View {
    let restaurantName: String
    let location: String
    let total: String
    let itemName: String
    let itemPrice: String
    let isVeg: Bool
    let status: String
    
    @State private var showConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section: Restaurant Info + Image
            HStack(spacing: 12) {
                // Circular Restaurant Image
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    // Restaurant Name
                    Text(restaurantName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    // Location
                    HStack(spacing: 4) {
                        Text("•")
                        Text(location)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#A0A0A0"))
                    }
                    
                    // Total Amount
                    Text("Total: \(total)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#A0A0A0"))
                }
                
                Spacer()
            }
            .padding(14)
            
            Divider()
                .padding(.horizontal, 14)
            
            // Middle Section: Item Details
            HStack(spacing: 10) {
                // Veg Indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .stroke(Color(hex: "#0B9F63"), lineWidth: 1.2)
                        .frame(width: 14, height: 14)
                    Circle()
                        .fill(Color(hex: "#0B9F63"))
                        .frame(width: 6, height: 6)
                }
                .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(itemName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(itemPrice)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.horizontal, 14)
            
            // Bottom Section: Status + REORDER Button
            HStack(spacing: 12) {
                Text(status)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#0B9F63"))
                
                Spacer()
                
                Button(action: { showConfirmation = true }) {
                    Text("REORDER")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 90)
                        .frame(height: 38)
                        .background(Color(hex: "#EE3333"))
                        .cornerRadius(20)
                }
            }
            .padding(14)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        .alert("Reorder Confirmation", isPresented: $showConfirmation) {
            Button("CANCEL", role: .cancel) {
                showConfirmation = false
            }
            .foregroundColor(Color(hex: "#FF9500"))
            
            Button("YES, REORDER") {
                // Handle reorder action here
                showConfirmation = false
            }
            .foregroundColor(Color(hex: "#FF9500"))
        } message: {
            Text("Do you want to reorder from \(restaurantName)?")
        }
    }
}

#Preview {
    ReorderView()
        .environmentObject(AppState.shared)
}
