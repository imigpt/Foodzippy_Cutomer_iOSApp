import SwiftUI

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
