// SearchView.swift
// Matches Android SearchRestorentActivity + SearchActivity

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search restaurants, dishes...", text: $viewModel.searchQuery)
                        .font(.subheadline)
                        .focused($isSearchFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await viewModel.searchRestaurants() }
                        }
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Button("Cancel") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundColor(.appPrimary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if viewModel.searchQuery.isEmpty {
                // Recent Searches
                recentSearchesView
            } else if viewModel.isLoading {
                // Loading
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    Spacer()
                }
            } else if viewModel.restaurants.isEmpty && viewModel.hasSearched {
                // No results
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No results found")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Try searching with a different keyword")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                // Results
                searchResultsView
            }
        }
        .onAppear {
            isSearchFocused = true
        }
    }
    
    // MARK: - Recent Searches
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !viewModel.recentSearches.isEmpty {
                HStack {
                    Text("Recent Searches")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.appBlack)
                    
                    Spacer()
                    
                    Button("Clear") {
                        viewModel.clearRecentSearches()
                    }
                    .font(.caption)
                    .foregroundColor(.appPrimary)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                ForEach(viewModel.recentSearches, id: \.self) { search in
                    Button {
                        viewModel.searchQuery = search
                        Task { await viewModel.searchRestaurants() }
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(search)
                                .font(.subheadline)
                                .foregroundColor(.appBlack)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.left")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    
                    Divider().padding(.leading, 40)
                }
            }
            
            // Popular suggestions
            VStack(alignment: .leading, spacing: 12) {
                Text("Popular Searches")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.appBlack)
                    .padding(.top, 16)
                
                FlowLayout(spacing: 8) {
                    ForEach(["Pizza", "Burger", "Biryani", "Chinese", "South Indian", "Desserts", "Thali", "Rolls"], id: \.self) { tag in
                        Button {
                            viewModel.searchQuery = tag
                            Task { await viewModel.searchRestaurants() }
                        } label: {
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(.appBlack)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Search Results
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                // Restaurant results
                if !viewModel.restaurants.isEmpty {
                    HStack {
                        Text("Restaurants")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        Text("(\(viewModel.restaurants.count))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    ForEach(viewModel.restaurants, id: \.restId) { restaurant in
                        NavigationLink {
                            Text("Restaurant: \(restaurant.restTitle ?? "")").navigationTitle("Restaurant")
                        } label: {
                            RestaurantRowView(restaurant: restaurant)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Flow Layout (for tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }
    
    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (CGSize(width: width, height: y + rowHeight), frames)
    }
}
