// AddressListView.swift
// Matches Android activity_address_list.xml
// Select/manage delivery addresses

import SwiftUI
import MapKit
import CoreLocation

struct AddressListView: View {
    let selectionMode: Bool
    var onSelect: ((Address) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var addresses: [Address] = []
    @State private var isLoading = true
    @State private var showAddAddress = false
    @State private var showDeleteConfirm = false
    @State private var addressToDelete: Address?

    init(selectionMode: Bool = false, onSelect: ((Address) -> Void)? = nil) {
        self.selectionMode = selectionMode
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F5").ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        // Action Tiles Row — Use Current Location / Add New Address
                        HStack(spacing: 10) {
                            ActionTile(
                                icon: "location.fill",
                                title: "Use Current\nLocation"
                            ) {
                                useCurrentLocation()
                            }

                            ActionTile(
                                icon: "plus.circle.fill",
                                title: "Add New\nAddress"
                            ) {
                                showAddAddress = true
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                        if addresses.isEmpty {
                            VStack(spacing: 16) {
                                Spacer()
                                Image(systemName: "mappin.slash")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.4))
                                Text("No saved addresses")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                                Text("Add an address to get started")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray.opacity(0.7))
                                Spacer()
                            }
                        } else {
                            // Saved addresses section header
                            HStack {
                                Text("Saved Addresses")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "#888888"))
                                    .textCase(.uppercase)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)

                            List {
                                ForEach(addresses, id: \.id) { address in
                                    Button {
                                        if selectionMode {
                                            onSelect?(address)
                                            dismiss()
                                        }
                                    } label: {
                                        AddressItemRow(address: address, selectionMode: selectionMode)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.white)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 14, bottom: 4, trailing: 14))
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            addressToDelete = address
                                            showDeleteConfirm = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .background(Color(hex: "#F5F5F5"))
                        }
                    }
                }
            }
            .navigationTitle(selectionMode ? "Select Location" : "My Addresses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#E23744"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                if !selectionMode {
                    ToolbarItem(placement: .primaryAction) {
                        Button { showAddAddress = true } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddAddress) {
                AddressPickerView { newAddress in
                    addresses.insert(newAddress, at: 0)
                    showAddAddress = false
                    if selectionMode {
                        onSelect?(newAddress)
                        dismiss()
                    }
                }
            }
            .alert("Delete Address", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    if let address = addressToDelete {
                        Task { await deleteAddress(address) }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this address?")
            }
            .task { await loadAddresses() }
        }
    }

    private func useCurrentLocation() {
        let locMgr = LocationManager.shared
        let lat = locMgr.latitude
        let lng = locMgr.longitude
        let address = Address(
            id: "current",
            uid: SessionManager.shared.currentUser?.id,
            hno: nil,
            address: "Current Location",
            latMap: lat,
            longMap: lng,
            landmark: nil,
            type: "current",
            addressImage: nil
        )
        onSelect?(address)
        dismiss()
    }

    private func loadAddresses() async {
        guard let uid = SessionManager.shared.currentUser?.id else {
            isLoading = false
            return
        }
        do {
            let response = try await APIService.shared.getAddressList(uid: uid)
            addresses = response.addressList ?? []
        } catch {}
        isLoading = false
    }

    private func deleteAddress(_ address: Address) async {
        guard let addressId = address.id else { return }
        do {
            let _ = try await APIService.shared.deleteAddress(addressId: addressId)
            addresses.removeAll { $0.id == address.id }
        } catch {}
    }
}

// MARK: - Action Tile (Use Current Location / Add New)
private struct ActionTile: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#E23744"))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

// MARK: - Address Row
private struct AddressItemRow: View {
    let address: Address
    let selectionMode: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: address.typeIcon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#E23744"))
                .frame(width: 40, height: 40)
                .background(Color(hex: "#E23744").opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text((address.type ?? "Other").capitalized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Text(address.fullAddress)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            if selectionMode {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Address Picker (Map + Form)
struct AddressPickerView: View {
    let onSave: (Address) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 23.0225, longitude: 72.5714),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var detectedAddress = ""
    @State private var houseNo = ""
    @State private var landmark = ""
    @State private var addressType = "Home"
    @State private var isSaving = false
    @State private var isGeocodingInProgress = false

    private let addressTypes = ["Home", "Work", "Other"]
    private let locManager = LocationManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Map
                    ZStack {
                        Map(coordinateRegion: $region, showsUserLocation: true)
                            .frame(height: 260)
                            .cornerRadius(0)

                        // Center pin
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "#E23744"))
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                            .allowsHitTesting(false)

                        // Current location button
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button {
                                    centerOnUserLocation()
                                } label: {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "#E23744"))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white)
                                        .cornerRadius(22)
                                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                                }
                                .padding(.trailing, 14)
                                .padding(.bottom, 14)
                            }
                        }
                    }
                    .frame(height: 260)

                    // Form
                    VStack(spacing: 16) {
                        // Detected address
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#E23744"))
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Selected Location")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                if isGeocodingInProgress {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                } else {
                                    Text(detectedAddress.isEmpty ? "Move the map to pick a location" : detectedAddress)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)
                                }
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(12)

                        // House/Flat No
                        VStack(alignment: .leading, spacing: 6) {
                            Text("House / Flat No.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField("E.g., B-42, 3rd Floor", text: $houseNo)
                                .font(.system(size: 14))
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        // Landmark
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Landmark (optional)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            TextField("E.g., Near bus stop", text: $landmark)
                                .font(.system(size: 14))
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        // Address type chips
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Save as")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            HStack(spacing: 10) {
                                ForEach(addressTypes, id: \.self) { atype in
                                    Button { addressType = atype } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: atype == "Home" ? "house" : atype == "Work" ? "briefcase" : "mappin")
                                                .font(.system(size: 12))
                                            Text(atype)
                                                .font(.system(size: 13, weight: .medium))
                                        }
                                        .foregroundColor(addressType == atype ? .white : Color(hex: "#333333"))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(addressType == atype ? Color(hex: "#E23744") : Color.white)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(addressType == atype ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }

                        // Save button
                        Button(action: saveAddress) {
                            Group {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Save Address")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(detectedAddress.isEmpty ? Color.gray : Color(hex: "#E23744"))
                            .cornerRadius(12)
                        }
                        .disabled(detectedAddress.isEmpty || isSaving)
                    }
                    .padding(14)
                }
            }
            .navigationTitle("Add Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { centerOnUserLocation() }
        }
    }

    private func centerOnUserLocation() {
        let lat = Double(locManager.latitude) ?? 23.0225
        let lng = Double(locManager.longitude) ?? 72.5714
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        reverseGeocode(lat: lat, lng: lng)
    }

    private func reverseGeocode(lat: Double, lng: Double) {
        isGeocodingInProgress = true
        let location = CLLocation(latitude: lat, longitude: lng)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            DispatchQueue.main.async {
                isGeocodingInProgress = false
                if let pm = placemarks?.first {
                    let parts = [pm.name, pm.subLocality, pm.locality,
                                 pm.administrativeArea, pm.postalCode].compactMap { $0 }
                    detectedAddress = parts.joined(separator: ", ")
                }
            }
        }
    }

    private func saveAddress() {
        isSaving = true
        guard let uid = SessionManager.shared.currentUser?.id else {
            isSaving = false
            return
        }

        let lat = String(region.center.latitude)
        let lng = String(region.center.longitude)

        Task {
            do {
                let _ = try await APIService.shared.addAddress(
                    uid: uid,
                    hno: houseNo,
                    address: detectedAddress,
                    lat: lat,
                    lng: lng,
                    landmark: landmark,
                    type: addressType.lowercased()
                )
                let newAddress = Address(
                    id: UUID().uuidString,
                    uid: uid,
                    hno: houseNo.isEmpty ? nil : houseNo,
                    address: detectedAddress,
                    latMap: lat,
                    longMap: lng,
                    landmark: landmark.isEmpty ? nil : landmark,
                    type: addressType.lowercased(),
                    addressImage: nil
                )
                await MainActor.run {
                    isSaving = false
                    onSave(newAddress)
                    dismiss()
                }
            } catch {
                await MainActor.run { isSaving = false }
            }
        }
    }
}

#Preview {
    AddressListView()
}
