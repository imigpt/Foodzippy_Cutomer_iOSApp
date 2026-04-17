import SwiftUI
import Combine

class SubscriptionViewModel: ObservableObject {
    @Published var currentBannerIndex = 0
    @Published var bannerDragOffset: CGFloat = 0
    @Published var isBannerDragging = false
    
    let totalBanners = 3
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Banner Management
    func updateBannerIndex(to index: Int) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            currentBannerIndex = max(0, min(index, totalBanners - 1))
        }
    }
    
    func resetBannerDragOffset() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            bannerDragOffset = 0
        }
    }
    
    func calculateNextBannerIndex(with dragValue: CGFloat, step: CGFloat) -> Int {
        let threshold = step * 0.20
        
        if dragValue < -threshold {
            return min(currentBannerIndex + 1, totalBanners - 1)
        } else if dragValue > threshold {
            return max(currentBannerIndex - 1, 0)
        }
        
        return currentBannerIndex
    }
    
    // MARK: - Auto-scroll
    func autoScrollBanner() {
        guard !isBannerDragging else { return }
        
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            currentBannerIndex = (currentBannerIndex + 1) % totalBanners
        }
    }
}
