// IntroView.swift
// Onboarding screens matching Android IntroActivity

import SwiftUI

struct IntroView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    private let pages = [
        IntroPage(
            icon: "fork.knife.circle.fill",
            title: "Explore Restaurants",
            description: "Browse through hundreds of restaurants near you and discover new cuisines.",
            color: .appPrimary
        ),
        IntroPage(
            icon: "cart.fill",
            title: "Easy Ordering",
            description: "Add your favourite items to cart, apply coupons, and checkout seamlessly.",
            color: .appAccent
        ),
        IntroPage(
            icon: "bicycle",
            title: "Fast Delivery",
            description: "Track your order in real-time and get your food delivered to your doorstep.",
            color: .appGreen
        )
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        IntroPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Bottom Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            SessionManager.shared.isIntroShown = true
                            appState.currentScreen = .login
                        }
                    }) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                    }
                    
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            SessionManager.shared.isIntroShown = true
                            appState.currentScreen = .login
                        }
                        .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct IntroPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct IntroPageView: View {
    let page: IntroPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(page.color)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.appBlack)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}
