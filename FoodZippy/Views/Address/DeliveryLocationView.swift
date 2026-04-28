//
//  DeliveryLocationView.swift
//  FoodZippy
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct DeliveryLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    var onSave: ((Address) -> Void)?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 26.8398, longitude: 75.8203),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    @State private var detectedTitle = "Loading..."
    @State private var detectedSubtitle = "Fetching details..."
    @State private var isGeocodingInProgress = false
    @State private var geocodeTask: Task<Void, Never>?
    
    // Search States
    @StateObject private var searchService = LocationSearchService()
    @State private var isSearching = false
    
    @State private var isSaving = false
    
    private let locManager = LocationManager.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background to create the dark purple status bar
            Color(hex: "#26103D")
                .ignoresSafeArea(.all, edges: .top)
            
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    // 1. Map Base
                    Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                        .ignoresSafeArea(.all, edges: .bottom)
                        .onChange(of: region.center.latitude) { _ in
                            performReverseGeocode()
                        }
                        .onChange(of: region.center.longitude) { _ in
                            performReverseGeocode()
                        }
                    
                    // 2. Stationary Center Pin
                    VStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#FF5200"))
                                .frame(width: 48, height: 48)
                                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                            
                            Image(systemName: "mappin")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 48) // Offset to anchor exactly at center
                        Spacer()
                    }
                    .allowsHitTesting(false)
                    
                    // 3. UI Overlays
                    VStack(spacing: 0) {
                        // Top Search Bar Area
                        HStack(spacing: 12) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            }
                            
                            // Tappable Search Bar
                            Button(action: {
                                withAnimation { isSearching = true }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Search an area or address")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.gray.opacity(0.8))
                                    Spacer()
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 48)
                                .background(Color.white)
                                .cornerRadius(24)
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        Spacer()
                        
                        // Floating Current Location Button
                        Button(action: { centerOnUserLocation() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#FF5200"))
                                Text("Current Location")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(hex: "#333333"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                        }
                        .padding(.bottom, 20)
                        
                        // Bottom Card
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Order will be delivered here")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(hex: "#8E939C"))
                                Text("Place the pin at exact delivery location")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#B0B5C1"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                            
                            Divider().background(Color(hex: "#F4F5F7"))
                            
                            HStack(alignment: .center, spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#FF5200"))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "mappin")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(detectedTitle)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(Color(hex: "#1A1A1A"))
                                        
                                        if isGeocodingInProgress {
                                            ProgressView().scaleEffect(0.7)
                                                .padding(.leading, 4)
                                        }
                                    }
                                    Text(detectedSubtitle)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "#6B7280"))
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            
                            Button(action: {
                                saveAddressDirectly()
                            }) {
                                Group {
                                    if isSaving {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Confirm & proceed")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color(hex: "#FF5200"))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 20) // Safely handle bottom spacing
                        }
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.06), radius: 10, y: -4)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            
            // 4. Search Overlay View
            if isSearching {
                ZStack(alignment: .top) {
                    Color.white.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Top Search Bar Area (Active State)
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    isSearching = false
                                    searchService.searchQuery = ""
                                }
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            }
                            
                            HStack(spacing: 8) {
                                TextField("Search an area or address", text: $searchService.searchQuery)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "#1A1A1A"))
                                    .autocapitalization(.none)
                                
                                if !searchService.searchQuery.isEmpty {
                                    Button(action: { searchService.searchQuery = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                        .background(Color(hex: "#26103D").ignoresSafeArea(.all, edges: .top))
                        
                        // Search Results List
                        List(searchService.completions, id: \.self) { completion in
                            Button(action: {
                                searchService.search(for: completion) { coordinate in
                                    if let coordinate = coordinate {
                                        self.region.center = coordinate
                                        withAnimation {
                                            self.isSearching = false
                                            self.searchService.searchQuery = ""
                                        }
                                    }
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(completion.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "#1A1A1A"))
                                    if !completion.subtitle.isEmpty {
                                        Text(completion.subtitle)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "#6B7280"))
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            centerOnUserLocation()
            appState.hideMainTabBar = true
        }
    }
    
    private func centerOnUserLocation() {
        let lat = Double(locManager.latitude) ?? 26.8398
        let lng = Double(locManager.longitude) ?? 75.8203
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        Task { await reverseGeocode(lat: lat, lng: lng) }
    }
    
    private func performReverseGeocode() {
        geocodeTask?.cancel()
        geocodeTask = Task {
            do {
                try await Task.sleep(nanoseconds: 600_000_000)
                guard !Task.isCancelled else { return }
                await reverseGeocode(lat: region.center.latitude, lng: region.center.longitude)
            } catch { }
        }
    }

    private func reverseGeocode(lat: Double, lng: Double) async {
        await MainActor.run { isGeocodingInProgress = true }
        let location = CLLocation(latitude: lat, longitude: lng)
        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            if let pm = placemarks.first {
                let title = pm.subLocality ?? pm.locality ?? pm.name ?? "Unknown Area"
                let parts = [pm.name, pm.subLocality, pm.locality, pm.administrativeArea, pm.postalCode, pm.country].compactMap { $0 }.filter { $0 != title }
                let subtitle = Array(NSOrderedSet(array: parts)).compactMap({$0 as? String}).joined(separator: ", ")
                
                await MainActor.run {
                    self.detectedTitle = title
                    self.detectedSubtitle = subtitle.isEmpty ? title : subtitle
                    self.isGeocodingInProgress = false
                }
            }
        } catch {
            await MainActor.run {
                self.titleFallback()
                self.isGeocodingInProgress = false
            }
        }
    }
    
    private func titleFallback() {
        self.detectedTitle = "Unknown Location"
        self.detectedSubtitle = "Drag map to find exact location"
    }

    private func saveAddressDirectly() {
        isSaving = true
        guard let uid = SessionManager.shared.currentUser?.id?.stringValue else {
            isSaving = false
            return
        }

        let lat = String(region.center.latitude)
        let lng = String(region.center.longitude)

        Task {
            do {
                let _ = try await APIService.shared.addAddress(
                    uid: uid,
                    hno: "",
                    address: detectedSubtitle.isEmpty ? detectedTitle : detectedSubtitle,
                    lat: lat,
                    lng: lng,
                    landmark: "",
                    type: "other"
                )
                let newAddress = Address(
                    id: UUID().uuidString,
                    uid: uid,
                    hno: nil,
                    address: detectedSubtitle.isEmpty ? detectedTitle : detectedSubtitle,
                    latMap: lat,
                    longMap: lng,
                    landmark: nil,
                    type: "other",
                    addressImage: nil
                )
                await MainActor.run {
                    isSaving = false
                    onSave?(newAddress)
                    dismiss()
                }
            } catch {
                await MainActor.run { isSaving = false }
            }
        }
    }
}

// MARK: - Search Service

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = "" {
        didSet {
            if searchQuery.isEmpty {
                completions = []
            } else {
                completer.queryFragment = searchQuery
            }
        }
    }
    @Published var completions: [MKLocalSearchCompletion] = []
    private var completer: MKLocalSearchCompleter
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
    
    func search(for completion: MKLocalSearchCompletion, result: @escaping (CLLocationCoordinate2D?) -> Void) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                result(nil)
                return
            }
            result(coordinate)
        }
    }
}

// MARK: - Subviews & Shapes

