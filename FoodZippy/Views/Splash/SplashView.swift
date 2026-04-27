// SplashView.swift
// Splash screen matching Android SplashActivity

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var hasScheduledNavigation = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "bolt.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.appPrimary)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Text("FoodZippy")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.appPrimary)
                    .opacity(logoOpacity)
                
                Text("Fast Food Delivery")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
        .task {
            guard !hasScheduledNavigation else { return }
            hasScheduledNavigation = true

            // Use a structured task instead of GCD so cancellation/lifecycle is predictable.
            try? await Task.sleep(nanoseconds: 2_500_000_000)

            await MainActor.run {
                withAnimation {
                    appState.determineInitialScreen()
                }
            }
        }
    }
}
