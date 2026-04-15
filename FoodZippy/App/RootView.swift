// RootView.swift
// Root navigation controller for the app

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        Group {
            switch appState.currentScreen {
            case .splash:
                SplashView()
                    .transition(.opacity)
                
            case .intro:
                IntroView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .login:
                NavigationStack {
                    LoginView()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                
            case .guestHome, .home:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
