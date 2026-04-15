// RestaurantListView.swift
// Generic restaurant list (used for filtered/category results)

import SwiftUI

struct RestaurantListView: View {
    let restaurants: [Restaurant]
    let title: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var vegOnly = false
    @State private var sortOption: SortOption = .relevance
    @State private var showSortSheet = false
    
    enum SortOption: String, CaseIterable {
        case relevance = "Relevance"
        case ratingHighToLow = "Rating: High to Low"
        case deliveryTime = "Delivery Time"
        case costLowToHigh = "Cost: Low to High"
        case costHighToLow = "Cost: High to Low"
    }
    
    var filteredRestaurants: [Restaurant] {
        var list: [Restaurant] = []
        if vegOnly {
            for restaurant in restaurants {
                if restaurant.restIsVeg == 1 {
                    list.append(restaurant)
                }
            }
        } else {
            list = restaurants
        }
        switch sortOption {
        case .ratingHighToLow:
            list.sort { (Double($0.restRating ?? "0") ?? 0) > (Double($1.restRating ?? "0") ?? 0) }
        case .deliveryTime:
            list.sort {
                let t1 = Int($0.restDeliverytime?.replacingOccurrences(of: " min", with: "") ?? "999") ?? 999
                let t2 = Int($1.restDeliverytime?.replacingOccurrences(of: " min", with: "") ?? "999") ?? 999
                return t1 < t2
            }
        case .costLowToHigh:
            list.sort { (Double($0.restCostfortwo ?? "0") ?? 0) < (Double($1.restCostfortwo ?? "0") ?? 0) }
        case .costHighToLow:
            list.sort { (Double($0.restCostfortwo ?? "0") ?? 0) > (Double($1.restCostfortwo ?? "0") ?? 0) }
        default: break
        }
        return list
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter bar
            HStack(spacing: 12) {
                // Veg filter
                Button {
                    vegOnly.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: vegOnly ? "checkmark.circle.fill" : "circle")
                            .font(.caption)
                        Text("Veg Only")
                            .font(.caption)
                    }
                    .foregroundColor(vegOnly ? .appGreen : .gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(vegOnly ? Color.appGreen.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
                
                // Sort
                Button {
                    showSortSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                        Text("Sort")
                            .font(.caption)
                    }
                    .foregroundColor(.appBlack)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
                
                Spacer()
                
                Text("\(filteredRestaurants.count) restaurants")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Restaurant list
            if filteredRestaurants.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "storefront")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No restaurants found")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredRestaurants, id: \.restId) { restaurant in
                            NavigationLink {
                                RestaurantDetailView(restaurant: restaurant)
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Sort By", isPresented: $showSortSheet, titleVisibility: .visible) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(option.rawValue) {
                    sortOption = option
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
