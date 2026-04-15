// OrderViewModel.swift
// Handles order detail, tracking, and rating

import Foundation
import Combine

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orderDetail: OrderDetail?
    @Published var mapInfo: OrderMapInfo?
    @Published var ratingData: RatingData?
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // Rating
    @Published var restaurantRating: Int = 0
    @Published var riderRating: Int = 0
    @Published var restaurantReview = ""
    @Published var riderReview = ""
    @Published var showRatingScreen = false
    @Published var ratingSubmitted = false
    
    // Tracking
    @Published var isTracking = false
    private var trackingTimer: AnyCancellable?
    
    let ratingLabels = ["VERY BAD", "BAD", "AVERAGE", "GOOD", "LOVED IT"]
    let ratingEmojis = ["😡", "😞", "😐", "😊", "😍"]
    
    // MARK: - Load Order Detail
    
    func loadOrderDetail(orderId: String) async {
        isLoading = true
        
        do {
            let response = try await APIService.shared.getOrderDetail(orderId: orderId)
            if response.isSuccess {
                orderDetail = response.orderData
            } else {
                showErrorMessage(response.responseMsg ?? "Failed to load order")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Order Tracking
    
    func startTracking(orderId: String) {
        isTracking = true
        
        // Poll every 10 seconds
        trackingTimer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.fetchMapInfo(orderId: orderId)
                }
            }
        
        // Initial fetch
        Task {
            await fetchMapInfo(orderId: orderId)
        }
    }
    
    func stopTracking() {
        isTracking = false
        trackingTimer?.cancel()
        trackingTimer = nil
    }
    
    private func fetchMapInfo(orderId: String) async {
        do {
            let response = try await APIService.shared.getMapInfo(orderId: orderId)
            mapInfo = response.mapData
        } catch {
            print("Map info error: \(error)")
        }
    }
    
    // MARK: - Rating
    
    func loadRatingData(orderId: String) async {
        do {
            let response = try await APIService.shared.getRatingData(orderId: orderId)
            ratingData = response.rateData
        } catch {
            print("Rating data error: \(error)")
        }
    }
    
    func submitRating(orderId: String) async {
        guard restaurantRating > 0 else {
            showErrorMessage("Please rate the restaurant")
            return
        }
        
        do {
            let response = try await APIService.shared.submitRating(
                orderId: orderId,
                restRate: String(restaurantRating),
                restText: restaurantReview,
                riderRate: String(riderRating),
                riderText: riderReview
            )
            
            if response.isSuccess {
                ratingSubmitted = true
            } else {
                showErrorMessage(response.responseMsg ?? "Failed to submit rating")
            }
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    deinit {
        trackingTimer?.cancel()
    }
}
