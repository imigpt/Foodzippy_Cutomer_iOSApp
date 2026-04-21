// AddressListView.swift
// Matches Android activity_address_list.xml
// Select/manage delivery addresses

import SwiftUI
import MapKit
import CoreLocation

struct AddressListView: View {
    let selectionMode: Bool
    var onSelect: ((Address) -> Void)?

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var addresses: [Address] = []
    @State private var isLoading = true
    @State private var showAddAddress = false
    @State private var showDeleteConfirm = false
    @State private var addressToDelete: Address?
    @State private var searchText = ""
    @State private var selectedAddressId: String? = nil
    @State private var showEditSheet = false
    @State private var addressToEdit: Address? = nil

    init(selectionMode: Bool = false, onSelect: ((Address) -> Void)? = nil) {
        self.selectionMode = selectionMode
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack(spacing: 16) {
                Button(action: {
                    appState.hideMainTabBar = false
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "#333333"))
                }
                Text("Select your location")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Search Bar
                    HStack {
                        TextField("Search an area or address", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Action Tiles
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ActionTileView(
                                icon: "location.viewfinder",
                                iconColor: Color(hex: "#E65100"), // Orange
                                title: "Use Current\nLocation"
                            ) {
                                showAddAddress = true
                            }
                            
                            ActionTileView(
                                icon: "plus.square",
                                iconColor: Color(hex: "#E65100"), // Orange
                                title: "Add New\nAddress"
                            ) {
                                showAddAddress = true
                            }
                            
                            ActionTileView(
                                icon: "phone.circle.fill", // WhatsApp fallback
                                iconColor: Color(hex: "#25D366"), // WhatsApp Green
                                title: "Request\nAddress",
                                isWhatsApp: true
                            ) {
                                // Request Address Action
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Content Area (List or Empty State)
                    if isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if addresses.isEmpty {
                        // Empty State Illustration
                        VStack(spacing: 24) {
                            ZStack {
                                Image(systemName: "map.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 140)
                                    .foregroundColor(Color(hex: "#E8EAF6"))
                                
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color(hex: "#A8B0C4"))
                                    .offset(x: 10, y: 10)
                                
                                Text("?")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(hex: "#7A8299"))
                                    .offset(x: -2, y: -2)
                                
                                Image(systemName: "arrow.uturn.up")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(Color(hex: "#A8B0C4"))
                                    .offset(x: 60, y: -40)
                                    .rotationEffect(.degrees(20))
                            }
                            .padding(.bottom, 10)
                            .padding(.top, 40)
                            
                            VStack(spacing: 6) {
                                Text("You don't have any saved addresses")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(Color(hex: "#828282"))
                                
                                Text("Add a new address and\ncontinue ordering")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color(hex: "#5C5C64"))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                        }
                        .padding(.bottom, 60)
                    } else {
                        // Saved Addresses List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SAVED ADDRESSES")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "#8E939C"))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(addresses) { address in
                                    AddressCardView(
                                        address: address,
                                        isSelected: selectedAddressId == address.id,
                                        onSelect: {
                                            selectedAddressId = address.id
                                            if selectionMode {
                                                onSelect?(address)
                                                dismiss()
                                            }
                                        },
                                        onEdit: {
                                            addressToEdit = address
                                            showEditSheet = true
                                        },
                                        onShare: {
                                            let text = "\(address.type?.capitalized ?? "Address"): \(address.fullAddress)"
                                            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                               let window = scene.windows.first,
                                               let rootVC = window.rootViewController {
                                                rootVC.present(activityVC, animated: true)
                                            }
                                        },
                                        onDelete: {
                                            addressToDelete = address
                                            showDeleteConfirm = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: "#F9F9FB").ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showAddAddress) {
            DeliveryLocationView { newAddress in
                upsertAddress(newAddress)
                selectedAddressId = newAddress.id
                isLoading = false
                showAddAddress = false
                if selectionMode {
                    onSelect?(newAddress)
                    dismiss()
                }
            }
            .environmentObject(appState)
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
        .onAppear {
            appState.hideMainTabBar = true
        }
        .onDisappear {
            if !showAddAddress {
                appState.hideMainTabBar = false
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let address = addressToEdit {
                EditAddressSheet(address: address, isPresented: $showEditSheet) { updatedAddress in
                    if let index = addresses.firstIndex(where: { $0.id == updatedAddress.id }) {
                        addresses[index] = updatedAddress
                    }
                }
            }
        }
    }

    private func loadAddresses() async {
        guard let uid = SessionManager.shared.currentUser?.id else {
            isLoading = false
            return
        }
        do {
            let response = try await APIService.shared.getAddressList(uid: uid)
            addresses = mergeLocalAddresses(remote: response.addressList ?? [])
            // Auto-select the first one if applicable
            if let first = addresses.first {
                selectedAddressId = first.id
            }
        } catch {}
        isLoading = false
    }

    private func upsertAddress(_ newAddress: Address) {
        if let id = newAddress.id,
           let index = addresses.firstIndex(where: { $0.id == id }) {
            addresses[index] = newAddress
            return
        }

        if let index = addresses.firstIndex(where: {
            ($0.fullAddress == newAddress.fullAddress) && ($0.latitude == newAddress.latitude) && ($0.longitude == newAddress.longitude)
        }) {
            addresses[index] = newAddress
            return
        }

        addresses.insert(newAddress, at: 0)
    }

    private func mergeLocalAddresses(remote: [Address]) -> [Address] {
        var merged = remote
        for local in addresses {
            let existsById = local.id != nil && merged.contains(where: { $0.id == local.id })
            let existsByLocation = merged.contains(where: {
                ($0.fullAddress == local.fullAddress) && ($0.latitude == local.latitude) && ($0.longitude == local.longitude)
            })

            if !existsById && !existsByLocation {
                merged.insert(local, at: 0)
            }
        }
        return merged
    }

    private func deleteAddress(_ address: Address) async {
        guard let addressId = address.id else { return }
        do {
            let _ = try await APIService.shared.deleteAddress(addressId: addressId)
            addresses.removeAll { $0.id == address.id }
        } catch {}
    }
}

// MARK: - Address Card View
private struct AddressCardView: View {
    let address: Address
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#F4F5F7"))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "location") // Outline arrow
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#333333"))
            }

            // Text Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text((address.type ?? "Other").capitalized)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    
                    if isSelected {
                        Text("SELECTED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#00B47A")) // Dark Green
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#E5F7ED")) // Light Green
                            .cornerRadius(4)
                    }
                }

                Text(address.fullAddress)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#6B7280"))
                    .lineLimit(2)
                    .lineSpacing(2)
            }
            .padding(.top, 2)

            Spacer()

            // Context Menu (Vertical Ellipsis)
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                Button(action: onShare) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90)) // Makes it vertical
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#8E939C"))
                    .frame(width: 30, height: 40, alignment: .topTrailing)
                    .contentShape(Rectangle())
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Action Tile View
private struct ActionTileView: View {
    let icon: String
    let iconColor: Color
    let title: String
    var isWhatsApp: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#5E626B"))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
            }
            .padding(14)
            .frame(width: 110, height: 100, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

// MARK: - Address Picker (Map + Form) remains unchanged
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

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "#E23744"))
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                            .allowsHitTesting(false)

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

// MARK: - Edit Address Sheet
struct EditAddressSheet: View {
    let address: Address
    @Binding var isPresented: Bool
    let onSave: (Address) -> Void
    
    @State private var houseNo = ""
    @State private var landmark = ""
    @State private var addressType = "Home"
    @State private var isSaving = false
    
    let addressTypes = ["Home", "Work", "Other"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("House / Flat No.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("E.g., B-42, 3rd Floor", text: $houseNo)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Landmark (optional)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("E.g., Near bus stop", text: $landmark)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Save as")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    HStack(spacing: 12) {
                        ForEach(addressTypes, id: \.self) { atype in
                            Button { addressType = atype } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: atype == "Home" ? "house" : atype == "Work" ? "briefcase" : "mappin")
                                        .font(.system(size: 12))
                                    Text(atype)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(addressType == atype ? .white : Color(hex: "#333333"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(addressType == atype ? Color(hex: "#FF5200") : Color(hex: "#F4F5F7"))
                                .cornerRadius(20)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: saveAddress) {
                    Group {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Update Address")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#FF5200"))
                    .cornerRadius(12)
                }
                .disabled(isSaving)
            }
            .padding(24)
            .navigationTitle("Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
            .onAppear {
                houseNo = address.hno ?? ""
                landmark = address.landmark ?? ""
                addressType = (address.type ?? "Home").capitalized
            }
        }
    }
    
    private func saveAddress() {
        isSaving = true
        
        // Create an updated address with new values
        let updatedAddress = Address(
            id: address.id,
            uid: address.uid,
            hno: houseNo.isEmpty ? nil : houseNo,
            address: address.address,
            latMap: address.latMap,
            longMap: address.longMap,
            landmark: landmark.isEmpty ? nil : landmark,
            type: addressType.lowercased(),
            addressImage: address.addressImage
        )
        
        DispatchQueue.main.async {
            isSaving = false
            onSave(updatedAddress)
            isPresented = false
        }
    }
}