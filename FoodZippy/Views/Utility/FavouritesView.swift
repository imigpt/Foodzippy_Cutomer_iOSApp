// FavouritesView.swift
// Matches Android FavritsActivity

import SwiftUI

struct FavouritesView: View {
    @State private var favourites: [Restaurant] = []
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if favourites.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "heart.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No favourites yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Tap the heart icon on restaurants to save them here")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(favourites, id: \.restId) { restaurant in
                            NavigationLink {
                                Text("Restaurant: \(restaurant.restTitle ?? "")")
                                    .navigationTitle("Restaurant")
                            } label: {
                                RestaurantRowView(restaurant: restaurant)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Favourites")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadFavourites()
        }
    }
    
    private func loadFavourites() async {
        let uid = SessionManager.shared.currentUser?.id?.stringValue ?? ""
        let lat = SessionManager.shared.currentAddress?.latMap ?? LocationManager.shared.latitude
        let lng = SessionManager.shared.currentAddress?.longMap ?? LocationManager.shared.longitude
        do {
            let response = try await APIService.shared.getFavourites(uid: uid, lat: lat, lng: lng)
            favourites = response.favList ?? []
        } catch {}
        isLoading = false
    }
}
