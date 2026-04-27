import SwiftUI

struct BookTableView: View {
    let restaurant: Restaurant

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    @State private var settings: DineSettingsData?
    @State private var isLoading = true

    @State private var guests = 2
    @State private var selectedDate = Date()
    @State private var mealType = "Lunch"
    @State private var selectedTime = ""

    @State private var customerName = SessionManager.shared.currentUser?.name ?? ""
    @State private var customerPhone = SessionManager.shared.currentUser?.mobile ?? ""
    @State private var customerEmail = ""
    @State private var specialRequest = ""

    @State private var submitting = false
    @State private var alertText = ""
    @State private var showAlert = false
    @State private var navigateToBillDetails = false

    private var maxGuests: Int { settings?.bookingSettings?.maxGuestsPerBooking ?? 30 }
    private var advanceDays: Int { settings?.bookingSettings?.advanceBookingDays ?? 30 }

    private var slotWindow: DineSlotWindow? {
        if mealType == "Lunch" {
            return settings?.timeSlots?.lunch ?? settings?.lunchSettings
        }
        return settings?.timeSlots?.dinner ?? settings?.dinnerSettings
    }

    private var generatedSlots: [String] {
        guard let start = slotWindow?.startTime, let end = slotWindow?.endTime else {
            return ["12:30 PM", "12:45 PM", "01:00 PM", "01:15 PM", "01:30 PM", "01:45 PM", "02:00 PM", "02:15 PM", "02:30 PM", "02:45 PM", "03:00 PM", "03:15 PM"]
        }

        let formatter24 = DateFormatter()
        formatter24.locale = .init(identifier: "en_US_POSIX")
        formatter24.dateFormat = "HH:mm:ss"

        let formatter12 = DateFormatter()
        formatter12.locale = .init(identifier: "en_US_POSIX")
        formatter12.dateFormat = "hh:mm a"

        guard let startDate = formatter24.date(from: start),
              let endDate = formatter24.date(from: end) else { return [] }

        var slots: [String] = []
        var current = startDate
        while current <= endDate {
            slots.append(formatter12.string(from: current))
            guard let next = Calendar.current.date(byAdding: .minute, value: 15, to: current) else { break }
            current = next
        }
        return slots
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. Header Area
            HStack(spacing: 16) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#3E3E3E"))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Book table")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color(hex: "#282C3F"))
                    Text(restaurant.restTitle ?? "Arogo")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#7E808C"))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 50) // Accounts for the notch area
            .padding(.bottom, 14)
            .background(Color.white)
            .ignoresSafeArea(edges: .top)

            // 2. Dashed Divider & Dinecash Banner
           
            // 3. Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) { 
                    
                    // Guests Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Number of guest(s)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#282C3F"))
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(1...max(8, maxGuests), id: \.self) { num in
                                    Button(action: { guests = num }) {
                                        Text("\(num)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(guests == num ? Color(hex: "#FF5200") : Color(hex: "#3E3E3E"))
                                            .frame(width: 54, height: 54) 
                                            .background(guests == num ? Color(hex: "#FFF0E6") : Color.white)
                                            .cornerRadius(16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(guests == num ? Color(hex: "#FF5200") : Color(hex: "#E8E8E8"), lineWidth: 1.5)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // Date Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("When are you visiting?")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#282C3F"))
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(0...max(4, advanceDays), id: \.self) { offset in
                                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                    let dayNum = Formatter.day.string(from: date)
                                    let dayStr = offset == 0 ? "Today" : Formatter.shortWeekday.string(from: date)

                                    Button(action: { selectedDate = date }) {
                                        ZStack(alignment: .bottom) {
                                            VStack(spacing: 4) {
                                                Text(dayNum)
                                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                                    .foregroundColor(isSelected ? Color(hex: "#FF5200") : Color(hex: "#282C3F"))
                                                Text(dayStr.uppercased())
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(isSelected ? Color(hex: "#FF5200") : Color(hex: "#7E808C"))
                                            }
                                            .frame(width: 76, height: 76)
                                            .background(isSelected ? Color(hex: "#FFF0E6") : Color.white)
                                            .cornerRadius(18)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .stroke(isSelected ? Color(hex: "#FF5200") : Color(hex: "#E8E8E8"), lineWidth: 1.5)
                                            )
                                            
                                            // Badge perfectly overlapping
//                                            Text("35% off")
//                                                .font(.system(size: 10, weight: .heavy))
//                                                .foregroundColor(.white)
//                                                .padding(.horizontal, 8)
//                                                .padding(.vertical, 5)
//                                                .background(Color(hex: "#1D8B41"))
//                                                .clipShape(Capsule())
//                                                .overlay(Capsule().stroke(Color.white, lineWidth: 2)) 
//                                                .offset(y: 12) 
                                        }
                                        .padding(.bottom, 12) 
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // 💥 UPDATED: Swiggy Style Lunch / Dinner Pill Toggle Section
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // Interactive Lunch/Dinner Selector
                        HStack(spacing: 12) {
                            // Lunch Button
                            Button(action: { 
                                mealType = "Lunch"
                                selectedTime = "" // Reset time selection when switching tabs
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sun.max.fill")
                                        .font(.system(size: 14))
                                    Text("Lunch")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(mealType == "Lunch" ? .white : Color(hex: "#7E808C"))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(mealType == "Lunch" ? Color(hex: "#282C3F") : Color.white) // Dark gray when selected
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(mealType == "Lunch" ? Color.clear : Color(hex: "#D4D5D9"), lineWidth: 1.5)
                                )
                            }

                            // Dinner Button
                            Button(action: { 
                                mealType = "Dinner"
                                selectedTime = "" // Reset time selection when switching tabs
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "moon.stars.fill")
                                        .font(.system(size: 14))
                                    Text("Dinner")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(mealType == "Dinner" ? .white : Color(hex: "#7E808C"))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(mealType == "Dinner" ? Color(hex: "#282C3F") : Color.white) // Dark gray when selected
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(mealType == "Dinner" ? Color.clear : Color(hex: "#D4D5D9"), lineWidth: 1.5)
                                )
                            }
                        }
                        .padding(.horizontal, 4)

                        // Time Slots Grid
                        if generatedSlots.isEmpty {
                            Text("No slots available").font(.caption).foregroundColor(.gray)
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 14) {
                                ForEach(generatedSlots, id: \.self) { slot in
                                    let isSelected = (selectedTime == slot)
                                    Button(action: { selectedTime = slot }) {
                                        VStack(spacing: 4) {
                                            Text(slot)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(isSelected ? Color(hex: "#FF5200") : Color(hex: "#3E3E3E"))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 58)
                                        .background(isSelected ? Color(hex: "#FFF0E6") : Color.white)
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(isSelected ? Color(hex: "#FF5200") : Color(hex: "#E8E8E8"), lineWidth: 1.5)
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "#F4F5F7")) // Swiggy subtle gray box
                    .cornerRadius(24)
                    .padding(.horizontal, 16)

                    // Selected Slot Info Preview)
                }
                .padding(.top, 24)
                .padding(.bottom, 130)
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .overlay(
            // Bottom Sticky Proceed Button
            VStack {
                Spacer()
                VStack {
                    Button(action: { navigateToBillDetails = true }) {
                        Text("Proceed")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#1D8B41"))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 34) 
                .background(
                    Color.white
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: -5)
                )
            }
            .ignoresSafeArea(.all, edges: .bottom)
        )
        .task { await loadSettings() }
        .alert("Dine-In", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertText)
        }
        .background(
            NavigationLink(
                destination: BookTableBillDetailsView(
                    restaurant: restaurant,
                    guests: guests,
                    date: selectedDate,
                    time: selectedTime,
                    mealType: mealType
                ).environmentObject(appState),
                isActive: $navigateToBillDetails
            ) {
                EmptyView()
            }
        )
        // .hidesTabBarOnNavigation()
        .onAppear {
            appState.hideMainTabBar = true
        }
        
    }

    private func loadSettings() async {
        let restId = restaurant.restId ?? SessionManager.shared.restaurantId
        guard !restId.isEmpty else {
            isLoading = false
            return
        }

        do {
            let response = try await APIService.shared.getDineSettings(restId: restId)
            settings = response.settingsData
        } catch {
            settings = nil
        }

        if selectedTime.isEmpty {
            selectedTime = generatedSlots.first ?? ""
        }
        isLoading = false
    }

    private func submitBooking() async {
        submitting = true
        defer { submitting = false }

        let restId = restaurant.restId ?? SessionManager.shared.restaurantId
        let uid = SessionManager.shared.currentUser?.id ?? "0"

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        do {
            let transactionId = "IOS_DINE_\(Int(Date().timeIntervalSince1970))"
            let response = try await APIService.shared.bookDineTable(
                uid: uid,
                restId: restId,
                numberOfGuests: guests,
                visitingDate: df.string(from: selectedDate),
                mealType: mealType,
                bookingTime: selectedTime,
                customerName: customerName,
                customerPhone: customerPhone,
                customerEmail: customerEmail,
                specialRequest: specialRequest,
                transactionId: transactionId
            )
            alertText = response.responseMsg ?? (response.isSuccess ? "Table booked successfully" : "Unable to book table")
        } catch {
            alertText = error.localizedDescription
        }
        showAlert = true
    }
}

// MARK: - Required Shape Helper

struct BookTableBillDetailsView: View {
    let restaurant: Restaurant
    let guests: Int
    let date: Date
    let time: String
    let mealType: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var submitting = false
    @State private var showAlert = false
    @State private var alertText = ""

    var body: some View {
        VStack(spacing: 0) {
            // 1. Header Area
            header
            
            // 2. Content Area
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Restaurant Info Card
                    restaurantCard
                    
                    // Booking Details Card
                    bookingDetailsCard
                    
                    // Bill Summary Card
                    billSummaryCard
                    
                    // Important Info
                    cancellationPolicyCard
                }
                .padding(16)
            }
            .background(Color(hex: "#F4F5F7"))
            
            // 3. Bottom Sticky Bar
            bottomBar
        }
        .navigationBarHidden(true)
        .alert("Booking Status", isPresented: $showAlert) {
            Button("OK") {
                if alertText.contains("successfully") {
                    // Navigate back to home or root
                    appState.hideMainTabBar = false
                    // Ideally dismiss multiple levels or use appState to reset
                }
            }
        } message: {
            Text(alertText)
        }
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#3E3E3E"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Bill Details")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(Color(hex: "#282C3F"))
                Text("Review your booking")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 50)
        .padding(.bottom, 14)
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
    }
    
    private var restaurantCard: some View {
        HStack(spacing: 12) {
            // Restaurant Logo / Image
            if let img = restaurant.restImg, let url = URL(string: Constants.baseURL + img) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: Color.gray.opacity(0.1)
                    }
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: "fork.knife").foregroundColor(.gray))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.restTitle ?? "Restaurant")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#282C3F"))
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text(restaurant.restFullAddress ?? "Location")
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var bookingDetailsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("BOOKING SUMMARY")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            HStack(spacing: 0) {
                summaryItem(icon: "person.2.fill", value: "\(guests)", label: "Guests")
                Divider().frame(height: 34).padding(.horizontal, 20)
                summaryItem(icon: "calendar", value: formatDate(date), label: "Date")
                Divider().frame(height: 34).padding(.horizontal, 20)
                summaryItem(icon: "clock.fill", value: time, label: mealType)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var billSummaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("BILL DETAILS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            VStack(spacing: 14) {
                billRow(title: "Base Booking Fee", amount: "₹99")
                billRow(title: "Discount", amount: "- ₹99", color: Color(hex: "#1D8B41"))
                billRow(title: "Taxes & Charges", amount: "₹0")
                
                Divider()
                
                HStack {
                    Text("Amount to Pay")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#282C3F"))
                    Spacer()
                    Text("₹0")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color(hex: "#282C3F"))
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var cancellationPolicyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "#FF5200"))
                Text("Cancellation Policy")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#282C3F"))
            }
            
            Text("• Free cancellation until 2 hours before booking time.\n• No-shows may result in a penalty for future bookings.\n• Please arrive 10 minutes prior to your slot.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#FFF0E6").opacity(0.5))
        .cornerRadius(12)
    }
    
    private var bottomBar: some View {
        VStack(spacing: 12) {
            Button(action: { Task { await confirmBooking() } }) {
                if submitting {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#1D8B41"))
                        .cornerRadius(14)
                } else {
                    Text("Confirm & Pay")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#1D8B41"))
                        .cornerRadius(14)
                }
            }
            .disabled(submitting)
            
            Text("By clicking, you agree to our Terms and Conditions")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.white.shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: -5))
    }
    
    // MARK: - Helpers
    
    private func summaryItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#FF5200"))
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "#282C3F"))
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func billRow(title: String, amount: String, color: Color = .gray) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(amount)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color == .gray ? Color(hex: "#282C3F") : color)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM"
        return df.string(from: date)
    }
    
    private func confirmBooking() async {
        submitting = true
        defer { submitting = false }
        
        let restId = restaurant.restId ?? SessionManager.shared.restaurantId
        let uid = SessionManager.shared.currentUser?.id ?? "0"
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let transactionId = "IOS_DINE_\(Int(Date().timeIntervalSince1970))"
        
        do {
            let response = try await APIService.shared.bookDineTable(
                uid: uid,
                restId: restId,
                numberOfGuests: guests,
                visitingDate: df.string(from: date),
                mealType: mealType,
                bookingTime: time,
                customerName: SessionManager.shared.currentUser?.name ?? "Customer",
                customerPhone: SessionManager.shared.currentUser?.mobile ?? "",
                customerEmail: "",
                specialRequest: "",
                transactionId: transactionId
            )
            alertText = response.responseMsg ?? (response.isSuccess ? "Table booked successfully!" : "Unable to book table")
        } catch {
            alertText = error.localizedDescription
        }
        showAlert = true
    }
}
