import SwiftUI

struct DineInRestaurantDetailView: View {
    let restaurant: Restaurant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                AsyncImageView(url: restaurant.restImg, placeholder: "fork.knife", height: 220)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(14)

                Text(restaurant.restTitle ?? "Restaurant")
                    .font(.title3.bold())

                HStack(spacing: 10) {
                    Label(restaurant.restRating ?? "0", systemImage: "star.fill")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.appGreen.opacity(0.15))
                        .cornerRadius(18)

                    if let time = restaurant.restDeliverytime, !time.isEmpty {
                        Label(time, systemImage: "clock")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(18)
                    }
                }

                if let address = restaurant.restFullAddress ?? restaurant.restLandmark, !address.isEmpty {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let desc = restaurant.restSdesc, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                NavigationLink {
                    DineInBookingView(restaurant: restaurant)
                } label: {
                    Text("Book a Table")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                }
            }
            .padding(12)
        }
        .background(Color.appGrayBg.ignoresSafeArea())
        .navigationTitle("Dine-In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DineInBookingView: View {
    let restaurant: Restaurant

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

    private var maxGuests: Int {
        settings?.bookingSettings?.maxGuestsPerBooking ?? 10
    }

    private var advanceDays: Int {
        settings?.bookingSettings?.advanceBookingDays ?? 7
    }

    private var slotWindow: DineSlotWindow? {
        if mealType == "Lunch" {
            return settings?.timeSlots?.lunch ?? settings?.lunchSettings
        }
        return settings?.timeSlots?.dinner ?? settings?.dinnerSettings
    }

    private var generatedSlots: [String] {
        guard let start = slotWindow?.startTime,
              let end = slotWindow?.endTime else { return [] }

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
            guard let next = Calendar.current.date(byAdding: .minute, value: 30, to: current) else { break }
            current = next
        }
        return slots
    }

    private var perGuestAmount: Double {
        slotWindow?.perGuestAmount ?? 0
    }

    private var totalAmount: Double {
        perGuestAmount * Double(guests)
    }

    var body: some View {
        Form {
            if isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Loading table settings...")
                        Spacer()
                    }
                }
            } else {
                Section("Booking") {
                    Stepper("Guests: \(guests)", value: $guests, in: 1...maxGuests)

                    DatePicker(
                        "Visiting Date",
                        selection: $selectedDate,
                        in: Date()...Calendar.current.date(byAdding: .day, value: max(1, advanceDays), to: Date())!,
                        displayedComponents: .date
                    )

                    Picker("Meal", selection: $mealType) {
                        Text("Lunch").tag("Lunch")
                        Text("Dinner").tag("Dinner")
                    }
                    .pickerStyle(.segmented)

                    Picker("Time Slot", selection: $selectedTime) {
                        Text("Select time").tag("")
                        ForEach(generatedSlots, id: \.self) { slot in
                            Text(slot).tag(slot)
                        }
                    }

                    if perGuestAmount > 0 {
                        Text("Per guest: \(perGuestAmount.currencyStringNoDecimal)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Total: \(totalAmount.currencyStringNoDecimal)")
                            .font(.subheadline.bold())
                    }
                }

                Section("Contact") {
                    TextField("Name", text: $customerName)
                    TextField("Phone", text: $customerPhone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $customerEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    TextField("Special Request", text: $specialRequest, axis: .vertical)
                }

                Section {
                    Button {
                        Task { await submitBooking() }
                    } label: {
                        if submitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Confirm & Pay")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(submitting || selectedTime.isEmpty || customerName.isEmpty || customerPhone.isEmpty)
                }
            }
        }
        .navigationTitle("Book Table")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadSettings() }
        .alert("Dine-In", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertText)
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
