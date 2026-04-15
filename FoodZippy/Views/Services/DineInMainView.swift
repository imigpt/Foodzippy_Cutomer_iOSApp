import SwiftUI
import MapKit

// MARK: - Dine In Main View Model
@MainActor
final class DineInMainViewModel: ObservableObject {
    @Published var featuredRestaurants: [Restaurant] = []
    @Published var allRestaurants: [Restaurant] = []
    @Published var facilities: [Facility] = []
    @Published var isLoading = false
    @Published var searchText = ""

    private var loaded = false

    func loadIfNeeded() async {
        guard !loaded else { return }
        await refresh()
        loaded = true
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        let uid = SessionManager.shared.currentUser?.id ?? "0"
        let lat = SessionManager.shared.currentAddress?.latMap ?? LocationManager.shared.latitude
        let lng = SessionManager.shared.currentAddress?.longMap ?? LocationManager.shared.longitude

        do {
            let homeResponse = try await APIService.shared.getHomeData(uid: uid, lat: lat, lng: lng)
            allRestaurants = homeResponse.homeData?.restuarantData ?? []
            featuredRestaurants = allRestaurants.prefix(6).map { $0 }
        } catch {
            allRestaurants = []
            featuredRestaurants = []
        }

        do {
            let response = try await APIService.shared.getFacilities()
            facilities = response.facilities ?? []
        } catch {
            facilities = []
        }
    }

    func filteredRestaurants() -> [Restaurant] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return allRestaurants
        }
        let q = searchText.lowercased()
        return allRestaurants.filter {
            ($0.restTitle ?? "").lowercased().contains(q) ||
            ($0.restSdesc ?? "").lowercased().contains(q) ||
            ($0.restLandmark ?? "").lowercased().contains(q)
        }
    }
}

// MARK: - Main Dine In View
struct DineInMainView: View {
    @StateObject private var viewModel = DineInMainViewModel()
    @State private var showAllRestaurants = false
    @State private var showQuickBook = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dine-In Dining")
                                .font(.title2.bold())
                            Text("Book a table at your favorite restaurants")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)

                        // Search Bar
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search restaurants", text: $viewModel.searchText)
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 14)

                        // Facilities Section (If available and not searching)
                        if viewModel.searchText.isEmpty && !viewModel.facilities.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Facilities & Ambiance")
                                    .font(.headline)
                                    .padding(.horizontal, 14)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(viewModel.facilities) { facility in
                                            VStack(spacing: 8) {
                                                Image(systemName: "building.2.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.red)

                                                Text(facility.name ?? "Facility")
                                                    .font(.caption2)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(width: 80)
                                            .padding(.vertical, 10)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                }
                            }
                        }

                        // Featured Section (If not searching)
                        if viewModel.searchText.isEmpty && !viewModel.featuredRestaurants.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Featured for You")
                                        .font(.headline)
                                    Spacer()
                                    NavigationLink("View All") {
                                        DineInBrowseView(viewModel: viewModel)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                                .padding(.horizontal, 14)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.featuredRestaurants) { restaurant in
                                            NavigationLink {
                                                DineInRestaurantDetailView(restaurant: restaurant)
                                            } label: {
                                                DineInRestaurantCardView(restaurant: restaurant)
                                                    .frame(width: 160)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                }
                            }
                        }

                        // Quick Actions
                        VStack(spacing: 10) {
                            Text("Quick Actions")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 14)

                            HStack(spacing: 12) {
                                QuickActionButton(
                                    icon: "calendar",
                                    title: "Quick Book",
                                    color: .red,
                                    action: { showQuickBook = true }
                                )

                                QuickActionButton(
                                    icon: "list.bullet",
                                    title: "Browse All",
                                    color: .green,
                                    action: { showAllRestaurants = true }
                                )

                                QuickActionButton(
                                    icon: "bell.badge",
                                    title: "Offers",
                                    color: .orange,
                                    action: {}
                                )
                            }
                            .padding(.horizontal, 14)
                        }

                        // Search Results
                        if !viewModel.searchText.isEmpty {
                            let results = viewModel.filteredRestaurants()
                            if results.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("No restaurants found")
                                        .font(.headline)
                                    Text("Try searching with different keywords")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Search Results (\(results.count))")
                                        .font(.headline)
                                        .padding(.horizontal, 14)

                                    VStack(spacing: 8) {
                                        ForEach(results) { restaurant in
                                            NavigationLink {
                                                DineInRestaurantDetailView(restaurant: restaurant)
                                            } label: {
                                                RestaurantRowView(restaurant: restaurant)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                }
                            }
                        }

                        // All Restaurants (If not searching and not showing featured)
                        if viewModel.searchText.isEmpty && !viewModel.allRestaurants.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("All Dine-In Restaurants")
                                    .font(.headline)
                                    .padding(.horizontal, 14)

                                VStack(spacing: 8) {
                                    ForEach(viewModel.allRestaurants) { restaurant in
                                        NavigationLink {
                                            DineInRestaurantDetailView(restaurant: restaurant)
                                        } label: {
                                            RestaurantRowView(restaurant: restaurant)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 14)
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.vertical, 12)
                }

                if viewModel.isLoading {
                    VStack {
                        ProgressView("Loading Dine-In options...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                }
            }
            .navigationTitle("Dine-In Dining")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadIfNeeded() }
            .refreshable { await viewModel.refresh() }
            .navigationDestination(isPresented: $showAllRestaurants) {
                DineInBrowseView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showQuickBook) {
                VStack {
                    Text("Quick booking coming soon!")
                        .font(.headline)
                        .padding()
                }
            }
        }
    }
}

// MARK: - Dine In Restaurant Card View
struct DineInRestaurantCardView: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImageView(url: restaurant.restImg, placeholder: "fork.knife", height: 100)
                .frame(height: 100)
                .clipped()
                .cornerRadius(8)

            Text(restaurant.restTitle ?? "Restaurant")
                .font(.subheadline.bold())
                .lineLimit(1)

            HStack(spacing: 4) {
                Label(restaurant.restRating ?? "0", systemImage: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.green)

                Spacer()

                if let time = restaurant.restDeliverytime, !time.isEmpty {
                    Text(time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Text(restaurant.restSdesc ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)

                Text(title)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}

// MARK: - Dine In Browse View
struct DineInBrowseView: View {
    @ObservedObject var viewModel: DineInMainViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search restaurants", text: $searchText)
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 12)

                        let filteredList = searchText.isEmpty
                            ? viewModel.allRestaurants
                            : {
                                let q = searchText.lowercased()
                                return viewModel.allRestaurants.filter {
                                    ($0.restTitle ?? "").lowercased().contains(q) ||
                                    ($0.restSdesc ?? "").lowercased().contains(q)
                                }
                            }()

                        if filteredList.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No restaurants found")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(filteredList) { restaurant in
                                    NavigationLink {
                                        DineInRestaurantDetailView(restaurant: restaurant)
                                    } label: {
                                        RestaurantRowView(restaurant: restaurant)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                        }

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Browse Restaurants")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        DineInMainView()
    }
}
