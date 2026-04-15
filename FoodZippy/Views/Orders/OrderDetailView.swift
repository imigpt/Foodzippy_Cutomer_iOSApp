// OrderDetailView.swift
import SwiftUI
import MapKit

struct OrderDetailView: View {
    let orderId: String

    @StateObject private var viewModel = OrderViewModel()
    @State private var showRatingSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                statusCard

                if let detail = viewModel.orderDetail {
                    restaurantCard(detail)
                    itemsCard(detail)
                    billCard(detail)
                }

                trackingCard

                actionButtons
            }
            .padding(12)
        }
        .background(Color.appGrayBg.ignoresSafeArea())
        .navigationTitle("Order #\(orderId)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadOrderDetail(orderId: orderId)
            await viewModel.loadRatingData(orderId: orderId)
            viewModel.startTracking(orderId: orderId)
        }
        .onDisappear {
            viewModel.stopTracking()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showRatingSheet) {
            NavigationStack {
                ratingSheet
            }
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order Status")
                    .font(.headline)
                Spacer()
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            let status = viewModel.orderDetail?.oStatus ?? "Pending"
            Text(status)
                .font(.subheadline.bold())
                .foregroundColor(status.lowercased().contains("cancel") ? .appRed : .appGreen)

            if let date = viewModel.orderDetail?.orderCompleteDate, !date.isEmpty {
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func restaurantCard(_ detail: OrderDetail) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(detail.restName ?? "Restaurant")
                .font(.headline)
            Text(detail.restAddress ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
            if let p = detail.pMethodName, !p.isEmpty {
                Text("Payment: \(p)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if let type = detail.orderType, !type.isEmpty {
                Text("Type: \(type.capitalized)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func itemsCard(_ detail: OrderDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Items")
                .font(.headline)

            ForEach(detail.orderItemsList ?? []) { item in
                HStack {
                    Text(item.itemName ?? "Item")
                        .font(.subheadline)
                    Spacer()
                    Text(item.totalAmount.currencyStringNoDecimal)
                        .font(.subheadline.bold())
                }
                if let addon = item.itemAddon, !addon.isEmpty {
                    Text(addon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func billCard(_ detail: OrderDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bill Summary")
                .font(.headline)

            billRow("Subtotal", detail.subtotal)
            billRow("Delivery", detail.deliveryCharge)
            billRow("Tax", detail.tax)

            if let cou = detail.couAmt, (Double(cou) ?? 0) > 0 {
                billRow("Coupon", "-\(cou)")
            }
            if let wallet = detail.wallAmt, (Double(wallet) ?? 0) > 0 {
                billRow("Wallet", "-\(wallet)")
            }

            Divider()
            billRow("Total", detail.orderTotal, bold: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
    }

    private var trackingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Live Tracking")
                .font(.headline)

            if let map = viewModel.mapInfo,
               let riderLat = Double(map.riderLat ?? ""),
               let riderLng = Double(map.riderLng ?? "") {
                let region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: riderLat, longitude: riderLng),
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
                Map(coordinateRegion: .constant(region), annotationItems: [MapPinItem(lat: riderLat, lng: riderLng)]) { pin in
                    MapMarker(coordinate: pin.coordinate, tint: .appPrimary)
                }
                .frame(height: 180)
                .cornerRadius(10)

                Text("Rider: \(map.riderName ?? "Not assigned")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Tracking will appear once rider is assigned.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                showRatingSheet = true
            } label: {
                Text("Rate this order")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(Color.appPrimary)
                    .cornerRadius(10)
            }
        }
    }

    private func billRow(_ title: String, _ value: String?, bold: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(bold ? .subheadline.bold() : .subheadline)
            Spacer()
            Text("\(SessionManager.shared.currency)\(value ?? "0")")
                .font(bold ? .subheadline.bold() : .subheadline)
        }
    }

    private var ratingSheet: some View {
        Form {
            Section("Restaurant") {
                ratingSelector(current: $viewModel.restaurantRating)
                TextField("Share your feedback", text: $viewModel.restaurantReview, axis: .vertical)
            }

            Section("Delivery Partner") {
                ratingSelector(current: $viewModel.riderRating)
                TextField("Share your feedback", text: $viewModel.riderReview, axis: .vertical)
            }

            Section {
                Button("Submit") {
                    Task {
                        await viewModel.submitRating(orderId: orderId)
                        if viewModel.ratingSubmitted {
                            showRatingSheet = false
                        }
                    }
                }
            }
        }
        .navigationTitle("Rate Order")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func ratingSelector(current: Binding<Int>) -> some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    current.wrappedValue = star
                } label: {
                    Image(systemName: star <= current.wrappedValue ? "star.fill" : "star")
                        .foregroundColor(.appYellow)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct MapPinItem: Identifiable {
    let id = UUID()
    let lat: Double
    let lng: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(orderId: "123")
    }
}
