import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    @State private var navigateToSchedule = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    // Header + Search Bar overlapping
                    ZStack(alignment: .bottom) {
                        headerBackground(safeAreaTop: geo.safeAreaInsets.top)
                        headerContent(safeAreaTop: geo.safeAreaInsets.top)
                    }
                    .zIndex(1) // Ensures search bar shadow overlaps the scrollview
                    
                    // Main Scrollable Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            BannerSliderView()
                                .padding(.horizontal, 16)
                                .padding(.top, 40) // Space for floating search bar
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("My Subscriptions")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                
                                SubscriptionCard(navigateToSchedule: $navigateToSchedule)
                                    .padding(.horizontal, 16)
                                
                                Text("Subscription Restaurants")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                
                                // 1st Restaurant Card (from video)
                                SubscriptionRestaurantCard(
                                    imageName: "restaurant_interior_mock", // Replace with your asset
                                    distance: "12.12 Kms",
                                    name: "delicious yard",
                                    isVeg: false,
                                    rating: "4",
                                    reviews: "10",
                                    priceInfo: "₹2000 for two",
                                    location: "jaipur, rajasthan"
                                )
                                .padding(.horizontal, 16)
                                
                                // 2nd Restaurant Card (from video)
                                SubscriptionRestaurantCard(
                                    imageName: "wtp_exterior_mock", // Replace with your asset
                                    distance: "5.75 Kms",
                                    name: "World Trade Park",
                                    isVeg: true,
                                    rating: "4",
                                    reviews: "10",
                                    priceInfo: "₹2000 for two",
                                    location: "jaipur, rajasthan"
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 80)
                    }
                    .background(Color(hex: "#F7F7F7"))
                }
                .navigationDestination(isPresented: $navigateToSchedule) {
                    SubscriptionScheduleView()
                }
                .navigationBarHidden(true)
                .ignoresSafeArea(edges: .top)
            }
        }
        .onAppear {
            appState.hideMainTabBar = false
        }
    }
    
    // MARK: - Header Components
    private func headerBackground(safeAreaTop: CGFloat) -> some View {
        LinearGradient(
            colors: [Color(hex: "#8E8CE6"), Color(hex: "#B0AFFF")],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 96 + safeAreaTop)
    }
    
    private func headerContent(safeAreaTop: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Top Nav Elements
            HStack(spacing: 16) {
                Button {
                    if appState.selectedTab == .Subscription {
                        appState.selectedTab = .home
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }
                .buttonStyle(BouncyButtonStyle())

                // Matched to target UI (Black text)
                Text("Subscription")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)

                Spacer()

            }
            .padding(.horizontal, 16)
            .padding(.top, safeAreaTop + 8)
            .padding(.bottom, 36) // Space above the search bar
        }
        .frame(height: 96 + safeAreaTop)
        .overlay(alignment: .bottom) {
            SearchBarView()
                .padding(.horizontal, 16)
                .offset(y: 24) // Floats exactly halfway out of the header
        }
    }
}

// MARK: - Floating Search Bar
struct SearchBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 18, weight: .medium))
            
            TextField("Search subscription restaurants", text: .constant(""))
                .font(.system(size: 16))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

// MARK: - Auto-Scrolling Banner Carousel (Original UI Restored

import SwiftUI

import SwiftUI

struct BannerSliderView: View {
    @State private var currentIndex = 76 
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private let actualBannersCount = 3
    private let fakeBannersCount = 150 
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let cardWidth = width * 0.78
            let cardSpacing: CGFloat = 14
            let step = cardWidth + cardSpacing
            let baseOffset = (width - cardWidth) / 2

            ZStack {
                Color.black.opacity(0.001) 
                    .ignoresSafeArea()
                
                HStack(spacing: cardSpacing) {
                    ForEach(0..<fakeBannersCount, id: \.self) { index in
                        let relative = abs((CGFloat(index) - CGFloat(currentIndex)) + (dragOffset / step))
                        let scale = max(0.92, 1 - (relative * 0.08))

                        let realIndex = index % actualBannersCount

                        BannerItemView() 
                            .frame(width: cardWidth)
                            .scaleEffect(scale)
                            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                    }
                }
                .offset(x: baseOffset - (CGFloat(currentIndex) * step) + dragOffset)
            }
            .contentShape(Rectangle()) 
            
            // 🛑 CRITICAL FIX: Changed from .gesture to .highPriorityGesture 🛑
            // This stops the middle banner from swallowing your swipe!
            .highPriorityGesture(
                DragGesture(minimumDistance: 15) 
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = step * 0.20
                        let predicted = value.predictedEndTranslation.width
                        var nextIndex: Int = currentIndex

                        if value.translation.width < -threshold || predicted < -threshold {
                            nextIndex = currentIndex + 1
                        } else if value.translation.width > threshold || predicted > threshold {
                            nextIndex = currentIndex - 1
                        }

                        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                            currentIndex = nextIndex
                            dragOffset = 0
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            isDragging = false
                        }
                    }
            )
        }
        .frame(height: 380) 
        .onReceive(timer) { _ in
            guard !isDragging else { return } 
            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                currentIndex += 1 
            }
        }
    }
}

struct BannerItemView: View {
    var body: some View {
        NavigationLink(destination: RestaurantView()) {
            ZStack(alignment: .bottomLeading) {
                // Background & Illustration (Replace with actual asset image from design)
                Color(hex: "#162820") // Dark green background
                    .overlay(
                        // Placeholder for the complex illustration
                        VStack {
                            Spacer()
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.2))
                            Spacer()
                        }
                    )
                
                // Overlaid Text exactly as seen in target UI
                VStack(alignment: .leading, spacing: 2) {
                    Text("Page 2 Banner")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    
                    Text("100% Satisfaction")
                        .font(.system(size: 20, weight: .semibold, design: .serif)) // Script mimic
                        .foregroundColor(.gray)
                    
                    Text("Page 2 Banner")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - My Subscriptions Card
struct SubscriptionCard: View {
    @Binding var navigateToSchedule: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header Row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fast Food")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#D03546")) // Specific red
                    Text("delicious yard")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Active")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#22A45D")) // Success Green
                    .clipShape(Capsule())
            }
            
            // Meals List
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Meals")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                VStack(spacing: 12) {
                    MealItemView(icon: "cup.and.saucer.fill", title: "Breakfast", subtitle: "Hotel", status: "Scheduled")
                    MealItemView(icon: "takeoutbag.and.cup.and.straw.fill", title: "Lunch", subtitle: "Hotel", status: "Scheduled", isCompleted: true) // Grayed out circle in target UI
                    MealItemView(icon: "moon.stars.fill", title: "Dinner", subtitle: "Hotel", status: "Scheduled") // Added Dinner from video
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            SubscriptionDetailsRow()
            
            // CTA Button
            Button {
                navigateToSchedule = true
            } label: {
                HStack {
                    Text("View Schedule & Details")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(Color(hex: "#D03546"))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white.opacity(0.5)) // Slight white fill from video
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#D03546"), lineWidth: 1.5)
                )
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .padding(16)
        .background(Color(hex: "#FCEEEF")) // Lighter pink matching the target
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
}

// MARK: - Meal Item Row
struct MealItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    let status: String
    var isCompleted: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#C4A485"))
                .frame(width: 48, height: 48)
                .background(Color.gray.opacity(0.08))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isCompleted {
                // Gray circle indicator seen in target UI
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
            } else {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(status)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#22A45D"))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#EAEAEA"), lineWidth: 1)
        )
    }
}

// MARK: - Subscription Details Grid
struct SubscriptionDetailsRow: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("From")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Text("17 Apr 2026")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Days Remaining")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Text("5 days")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#D03546"))
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("To")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Text("23 Apr 2026")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Completed")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Text("0 deliveries")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#D03546"))
                }
            }
            .frame(width: 120, alignment: .leading) // Aligning with the video's spacing
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Restaurant Card List Item
struct SubscriptionRestaurantCard: View {
    let imageName: String
    let distance: String
    let name: String
    let isVeg: Bool
    let rating: String
    let reviews: String
    let priceInfo: String
    let location: String
    
    var body: some View {
        NavigationLink(destination: SubscriptionPlansView()) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    // Image Background
                    Image("burger")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                    
                    // Distance Badge
                    Text(distance)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                        .cornerRadius(6)
                        .padding(12)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Veg / Non-Veg Standard Indicator
                        FoodTypeIcon(isVeg: isVeg)
                    }
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                            Text(rating)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#22A45D"))
                        .cornerRadius(6)
                        
                        Text("•").foregroundColor(.gray)
                        Text(reviews).font(.system(size: 13, weight: .medium)).foregroundColor(.gray)
                        Text("•").foregroundColor(.gray)
                        Text(priceInfo).font(.system(size: 13, weight: .medium)).foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text(location)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("Open")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#22A45D"))
                    }
                }
                .padding(16)
                .background(Color.white)
            }
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        }
    }
}

// MARK: - Veg / Non-Veg Indicator View
struct FoodTypeIcon: View {
    let isVeg: Bool
    
    var body: some View {
        let color = isVeg ? Color(hex: "#22A45D") : Color(hex: "#D03546")
        
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(color, lineWidth: 1)
                .frame(width: 16, height: 16)
            
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
    }
}

// MARK: - Helpers & Modifiers
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Note: Color.init(hex:) extension is defined in Utils/Extensions.swift
// AppState is defined in App/AppState.swift

// MARK: - Preview
#Preview {
    SubscriptionView()
        .environmentObject(AppState.shared)
}

