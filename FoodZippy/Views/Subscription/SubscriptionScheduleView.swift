import SwiftUI

// MARK: - Subscription Schedule View (Moved here to fix scope issues)

// MARK: - Models
struct ScheduleMeal: Identifiable, Equatable, Hashable {
    let id = UUID()
    let type: String // "Breakfast", "Lunch", "Dinner"
    let title: String
    let time: String
    let status: String
    let statusColor: Color
    let image: String
    let price: String
    let icon: String
}

struct ScheduleDate: Identifiable, Hashable {
    let id = UUID()
    let fullDateStr: String // e.g. "2025-12-29"
    let dayName: String // e.g. "Mon"
    let dayNum: String // e.g. "29"
    let monthName: String // e.g. "Dec"
    let status: String // e.g. "Scheduled", "Delivered", "Holiday"
    let isToday: Bool
    let meals: [ScheduleMeal]
}

struct SubscriptionScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    // UI State
    @State private var selectedDate: ScheduleDate?
    @State private var scrollOffset: CGFloat = 0
    
    // Mock Data
    private let restaurantName = "Restaurant Name"
    private let planTitle = "Premium Meal Plan"
    private let planDays = "30 Days Plan"
    private let orderId = "#4"
    private let daysRemaining = "15"
    private let completedDeliveries = "12"
    private let upcomingDeliveries = "18"
    private let holidays = "0"
    private let startDate = "Dec 20, 2025"
    private let endDate = "Jan 20, 2026"
    
    @State private var dates: [ScheduleDate] = []
    
    // Theme Colors
    private let bgColor = Color(hex: "#F5F5F5")
    private let primaryGreen = Color(hex: "#0C831F")
    private let darkGreen = Color(hex: "#1D8B41")
    private let orangeColor = Color(hex: "#FF9800")
    
    init() {
        // Prepare mock dates
        var mockDates: [ScheduleDate] = []
        let today = Date()
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: today)!
            let isToday = i == 0
            
            let meals = [
                ScheduleMeal(type: "Breakfast", title: "Idli Sambar", time: "08:00 AM", status: "Scheduled", statusColor: Color(hex: "#1D8B41"), image: "burger", price: "₹150", icon: "☕️"),
                ScheduleMeal(type: "Lunch", title: "North Indian Thali", time: "01:00 PM", status: "Scheduled", statusColor: Color(hex: "#1D8B41"), image: "burger", price: "₹250", icon: "🍽️"),
                ScheduleMeal(type: "Dinner", title: "Chapati & Paneer", time: "08:00 PM", status: "Scheduled", statusColor: Color(hex: "#1D8B41"), image: "burger", price: "₹200", icon: "🌙")
            ]
            
            let fDayName = DateFormatter()
            fDayName.dateFormat = "EEE"
            let dayName = fDayName.string(from: date)
            
            let fDayNum = DateFormatter()
            fDayNum.dateFormat = "dd"
            let dayNum = fDayNum.string(from: date)
            
            let fMonth = DateFormatter()
            fMonth.dateFormat = "MMM"
            let monthName = fMonth.string(from: date)
            
            let sd = ScheduleDate(
                fullDateStr: formatter.string(from: date),
                dayName: dayName,
                dayNum: dayNum,
                monthName: monthName,
                status: "Scheduled",
                isToday: isToday,
                meals: meals
            )
            mockDates.append(sd)
        }
        
        _dates = State(initialValue: mockDates)
        _selectedDate = State(initialValue: mockDates.first)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                // Tracking scroll offset
                GeometryReader { geo in
                    Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // Banner Carousel
                    BannerSliderView()
                        .padding(.top, 90) // Space for header
                        .padding(.vertical, 16)
                    
                    // Today's Meal Card
                    if let today = dates.first(where: { $0.isToday }) {
                        todayMealsCard(for: today)
                            .padding(.bottom, 16)
                    }
                    
                    // Tomorrow's Meal Card
                    if dates.count > 1 {
                        tomorrowMealsCard(for: dates[1])
                            .padding(.bottom, 16)
                    }
                    
                    // Daily Schedule Section
                    dailyScheduleSection
                }
                .padding(.bottom, 40)
            }
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffset = value
            }
            
            // Floating Header
            floatingHeader
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            appState.hideMainTabBar = true
        }
    }
    
    // MARK: - Components
    
    private var floatingHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(Color(hex: "#1F1F1F"))
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4)
            }
            
            Spacer()
            
            // Title visible only when scrolled
            if scrollOffset < -100 {
                Text("Monthly Plan")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#1F1F1F"))
                    .transition(.opacity)
            }
            
            Spacer()
            
            Text(orderId)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#666666"))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, safeAreaTop + 8)
        .animation(.easeInOut, value: scrollOffset)
    }
    
    private var safeAreaTop: CGFloat {
        let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return window?.windows.first?.safeAreaInsets.top ?? 44
    }
    
    
    private func todayMealsCard(for date: ScheduleDate) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("🍽️ Today's Meals")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                Spacer()
                Text("Scheduled")
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#22A45D"))
                    .clipShape(Capsule())
            }
            
            ForEach(date.meals) { meal in
                mealRow(meal: meal, showAddOn: true)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
    }
    
    private func tomorrowMealsCard(for date: ScheduleDate) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("🌅 Tomorrow's Meals")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                Spacer()
                Text("Tomorrow")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#888888"))
            }
            
            ForEach(date.meals) { meal in
                mealRow(meal: meal, showAddOn: true)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
    }
    
    private func mealRow(meal: ScheduleMeal, showAddOn: Bool) -> some View {
        HStack(spacing: 12) {
            Text(meal.icon)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(meal.type) • \(meal.time)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                Text(meal.title)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#666666"))
                Text(meal.status)
                    .font(.system(size: 11))
                    .foregroundColor(meal.statusColor)
            }
            Spacer()
            
            if showAddOn {
                Text("Add On")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#E53935"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: "#E53935"), lineWidth: 1)
                    )
            }
        }
        .padding(12)
        .background(Color(hex: "#F8F8F8"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var dailyScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📅 Daily Schedule")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "#333333"))
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(dates) { date in
                        let isSelected = selectedDate?.id == date.id
                        VStack(spacing: 2) {
                            Text(date.dayName)
                                .font(.system(size: 11))
                                .foregroundColor(isSelected && !date.isToday ? .white : (date.isToday && isSelected ? .white : Color(hex: "#666666")))
                            Text(date.dayNum)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isSelected && !date.isToday ? .white : (date.isToday && isSelected ? .white : Color(hex: "#333333")))
                            Text(date.monthName)
                                .font(.system(size: 10))
                                .foregroundColor(isSelected && !date.isToday ? .white : (date.isToday && isSelected ? .white : Color(hex: "#888888")))
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? (date.isToday ? primaryGreen : Color(hex: "#1F1F1F")) : (date.isToday ? primaryGreen : Color(hex: "#EEEEEE")))
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 16)
            
            if let date = selectedDate {
                VStack(spacing: 12) {
                    HStack {
                        Text(date.isToday ? "Today, \(date.monthName) \(date.dayNum)" : "\(date.dayName), \(date.monthName) \(date.dayNum)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "#333333"))
                        
                        Text(date.status)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color(hex: "#22A45D"))
                            .clipShape(Capsule())
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    ForEach(date.meals) { meal in
                        scheduleMealRow(meal: meal)
                    }
                }
            }
        }
    }
    
    private func scheduleMealRow(meal: ScheduleMeal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(meal.icon) \(meal.type) • \(meal.time)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(hex: "#333333"))
                .padding(.horizontal, 16)
            
            HStack(spacing: 12) {
                Image(meal.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#333333"))
                    
                    Text(meal.price)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#888888"))
                    
                    Text(meal.status)
                        .font(.system(size: 12))
                        .foregroundColor(meal.statusColor)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 12)
    }
}

// Helper for scroll tracking
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

// MARK: - Banner Carousel

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

struct SubscriptionScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionScheduleView()
    }
}