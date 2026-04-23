import SwiftUI

// MARK: - Meal Model
private struct MealData: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
}

private struct DayMeals: Identifiable {
    let id: Int
    let day: Int
    let breakfast: [MealData]
    let lunch: [MealData]
    let dinner: [MealData]
}

struct SubscriptionPlanDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    // Theme Colors
    let bgColor = Color(hex: "#FFF8E7")
    let badgeGreen = Color(hex: "#158C31")
    let textGreen = Color(hex: "#1E8E2D")
    let redAccent = Color(hex: "#D03546")
    
    @State private var selectedDay: Int = 1
    @State private var selectedMeals: [Int: [String]] = [:] // day -> ["breakfast", "lunch", "dinner"]
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    // Sample meal data for each day
    private let dayMealsData = [
        DayMeals(id: 1, day: 1, 
                 breakfast: [MealData(name: "Hotel", price: 300)],
                 lunch: [MealData(name: "Hotel", price: 300)],
                 dinner: [MealData(name: "Hotel", price: 300)]),
        DayMeals(id: 2, day: 2,
                 breakfast: [MealData(name: "Hotel", price: 320)],
                 lunch: [MealData(name: "Hotel", price: 320)],
                 dinner: [MealData(name: "Hotel", price: 320)]),
        DayMeals(id: 3, day: 3,
                 breakfast: [MealData(name: "Hotel", price: 310)],
                 lunch: [MealData(name: "Hotel", price: 310)],
                 dinner: [MealData(name: "Hotel", price: 310)]),
        DayMeals(id: 4, day: 4,
                 breakfast: [MealData(name: "Hotel", price: 300)],
                 lunch: [MealData(name: "Hotel", price: 300)],
                 dinner: [MealData(name: "Hotel", price: 300)]),
        DayMeals(id: 5, day: 5,
                 breakfast: [MealData(name: "Hotel", price: 330)],
                 lunch: [MealData(name: "Hotel", price: 330)],
                 dinner: [MealData(name: "Hotel", price: 330)]),
        DayMeals(id: 6, day: 6,
                 breakfast: [MealData(name: "Hotel", price: 340)],
                 lunch: [MealData(name: "Hotel", price: 340)],
                 dinner: [MealData(name: "Hotel", price: 340)]),
        DayMeals(id: 7, day: 7,
                 breakfast: [MealData(name: "Hotel", price: 300)],
                 lunch: [MealData(name: "Hotel", price: 300)],
                 dinner: [MealData(name: "Hotel", price: 300)])
    ]
    
    private var currentDayMeals: DayMeals? {
        dayMealsData.first { $0.day == selectedDay }
    }
    
    private var totalAmount: Double {
        guard let currentDay = currentDayMeals else { return 0 }
        var total: Double = 0
        
        if selectedMeals[selectedDay]?.contains("breakfast") ?? false {
            total += currentDay.breakfast.first?.price ?? 0
        }
        if selectedMeals[selectedDay]?.contains("lunch") ?? false {
            total += currentDay.lunch.first?.price ?? 0
        }
        if selectedMeals[selectedDay]?.contains("dinner") ?? false {
            total += currentDay.dinner.first?.price ?? 0
        }
        
        return total
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            bgColor.ignoresSafeArea()
            
            // Main Content
            ScrollView {
                VStack(spacing: 0) {
                    // 1. Header Image & Navigation
                    ZStack(alignment: .top) {
                        Image("burger") // Placeholder image, replace with actual asset
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.3)
                            .clipped()
                        
                        // Navigation overlay
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Circle()
                                    .fill(Color.black.opacity(0.4))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "arrow.left")
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            Spacer()
                            
                            // Top-Right Badge
                            Text("7 Days Plan")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(badgeGreen))
                        }
                        .padding(.horizontal, 16)
                        // Adjusting for safe area manually since image ignores it
                        .padding(.top, 44)
                    }
                    
                    // 2. Floating Info Card
                    FloatingInfoCard(textGreen: textGreen)
                        .offset(y: -40)
                        .padding(.horizontal, 16)
                        .zIndex(1) // Ensure it overlaps image
                        
                    
                    // Content below floating card (Negative spacing compensates for the offset)
                    VStack(alignment: .leading, spacing: 24) {
                        // 3. Day Selection (Horizontal Scroll)
                        DaySelector(selectedDay: $selectedDay, redAccent: redAccent)
                        
                        // 4. Meal List Sections
                        VStack(spacing: 24) {
                            if let currentDay = currentDayMeals {
                                MealSectionView(
                                    title: "🌅 Breakfast",
                                    mealLabel: "breakfast",
                                    mealName: currentDay.breakfast.first?.name ?? "Hotel",
                                    price: String(format: "₹%.2f", currentDay.breakfast.first?.price ?? 0),
                                    redAccent: redAccent,
                                    isSelected: selectedMeals[selectedDay]?.contains("breakfast") ?? false,
                                    onToggle: { toggleMeal("breakfast") }
                                )
                                MealSectionView(
                                    title: "☀️ Lunch",
                                    mealLabel: "lunch",
                                    mealName: currentDay.lunch.first?.name ?? "Hotel",
                                    price: String(format: "₹%.2f", currentDay.lunch.first?.price ?? 0),
                                    redAccent: redAccent,
                                    isSelected: selectedMeals[selectedDay]?.contains("lunch") ?? false,
                                    onToggle: { toggleMeal("lunch") }
                                )
                                MealSectionView(
                                    title: "🌙 Dinner",
                                    mealLabel: "dinner",
                                    mealName: currentDay.dinner.first?.name ?? "Hotel",
                                    price: String(format: "₹%.2f", currentDay.dinner.first?.price ?? 0),
                                    redAccent: redAccent,
                                    isSelected: selectedMeals[selectedDay]?.contains("dinner") ?? false,
                                    onToggle: { toggleMeal("dinner") }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Extra bottom padding for the sticky bar
                        Spacer().frame(height: 100)
                    }
                    .offset(y: -20) // Snug up the content
                }
            }
            .ignoresSafeArea(.all, edges: .top)
            
            // 5. Sticky Bottom Bar
            BottomActionBar(badgeGreen: badgeGreen, totalAmount: totalAmount, onBuyTapped: { showDatePicker = true })
            
            // Calendar Dialog Box - Overlaid on entire view
            if showDatePicker {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showDatePicker = false
                        }
                    
                    // Dialog popup
                    VStack(spacing: 16) {
                        Text("Select Start Date")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 16)
                        
                        DatePicker(
                            "Start Date",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        
                        HStack(spacing: 12) {
                            Button {
                                showDatePicker = false
                            } label: {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Button {
                                // Handle purchase with selected date
                                showDatePicker = false
                            } label: {
                                Text("Confirm")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#158C31"))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(16)
                    .frame(maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            appState.hideMainTabBar = true
            // Initialize meals for first day
            if selectedMeals[selectedDay] == nil {
                selectedMeals[selectedDay] = ["breakfast", "lunch", "dinner"]
            }
        }
        .onDisappear { appState.hideMainTabBar = false }
        .onChange(of: selectedDay) { newDay in
            // Initialize meals for newly selected day if not already done
            if selectedMeals[newDay] == nil {
                selectedMeals[newDay] = ["breakfast", "lunch", "dinner"]
            }
        }
    }
    
    private func toggleMeal(_ mealType: String) {
        if selectedMeals[selectedDay] == nil {
            selectedMeals[selectedDay] = []
        }
        
        if selectedMeals[selectedDay]?.contains(mealType) ?? false {
            selectedMeals[selectedDay]?.removeAll { $0 == mealType }
        } else {
            selectedMeals[selectedDay]?.append(mealType)
        }
    }
}

// MARK: - Subviews

private struct FloatingInfoCard: View {
    let textGreen: Color
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Fast Food")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black)
                    Spacer()
                }
                Text("This Plan is for Fast Food")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Price Row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Price")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    Text("₹2700.00")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(textGreen)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Per Day")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    Text("₹386/day")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            
            // Stats Row
            HStack(spacing: 12) {
                StatBox(value: "9", label: "Total Meals", color: textGreen)
                StatBox(value: "7", label: "Days", color: textGreen)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

private struct StatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct DaySelector: View {
    @Binding var selectedDay: Int
    let redAccent: Color
    let days = 1...7
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Day")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(days, id: \.self) { day in
                        Button(action: {
                            selectedDay = day
                        }) {
                            Text("Day \(day)")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .foregroundColor(selectedDay == day ? .white : .gray)
                                .background(selectedDay == day ? redAccent : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selectedDay == day ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct MealSectionView: View {
    let title: String
    let mealLabel: String
    let mealName: String
    let price: String
    let redAccent: Color
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
            
            // Meal Card
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // Left Image
                    Image("burger") // Placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(12)
                    
                    // Right Content
                    VStack(alignment: .leading, spacing: 6) {
                        // Tiny Badge
                        Text(mealLabel)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.orange.opacity(0.8)))
                        
                        // Radio + Title
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.5), lineWidth: 1.5)
                                    .frame(width: 14, height: 14)
                                if isSelected {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            Text(mealName)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.black)
                        }
                        
                        // Price
                        Text(price)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(redAccent)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            }
        }
    }
}

private struct BottomActionBar: View {
    let badgeGreen: Color
    let totalAmount: Double
    let onBuyTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.2))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Amount")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    Text(String(format: "₹%.2f", totalAmount))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: onBuyTapped) {
                    Text("Buy Subscription ->")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .padding(.horizontal, 24)
                        .background(Capsule().fill(badgeGreen))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 8)
            .background(Color.white)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
    }
}

// MARK: - Preview
private struct SubscriptionPlanDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionPlanDetailsView()
    }
}
