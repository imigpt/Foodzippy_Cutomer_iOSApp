// SearchViewModel.swift
// Handles restaurant and product search

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var hasSearched = false
    @Published var recentSearches: [String] = []
    
    private let recentSearchesKey = "recent_searches"
    private var searchTask: Task<Void, Never>?
    
    init() {
        loadRecentSearches()
    }
    
    // MARK: - Search Restaurants
    
    func searchRestaurants() async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isLoading = true
        hasSearched = true
        
        saveToRecentSearches(searchQuery)
        
        let lat = SessionManager.shared.currentAddress?.latMap ?? LocationManager.shared.latitude
        let lng = SessionManager.shared.currentAddress?.longMap ?? LocationManager.shared.longitude
        
        do {
            let response = try await APIService.shared.searchRestaurants(
                query: searchQuery, lat: lat, lng: lng
            )
            restaurants = response.restuarantData ?? []
        } catch {
            print("Search error: \(error)")
            restaurants = []
        }
        
        isLoading = false
    }
    
    // MARK: - Debounced Search
    
    func onSearchQueryChanged() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            if !Task.isCancelled {
                await searchRestaurants()
            }
        }
    }
    
    // MARK: - Recent Searches
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }
    
    private func saveToRecentSearches(_ query: String) {
        recentSearches.removeAll { $0 == query }
        recentSearches.insert(query, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
    
    func selectRecentSearch(_ query: String) {
        searchQuery = query
        Task {
            await searchRestaurants()
        }
    }
}
