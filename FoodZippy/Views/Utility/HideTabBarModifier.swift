import SwiftUI

// 1. Create the Modifier
struct HideTabBarModifier: ViewModifier {
    @EnvironmentObject var appState: AppState
    
    func body(content: Content) -> some View {
        content
            // Hides the native SwiftUI Tab Bar (iOS 16+)
            .toolbar(.hidden, for: .tabBar)
            // Hides your custom Tab Bar state
            .onAppear {
                appState.hideMainTabBar = true
            }
            .onDisappear {
                appState.hideMainTabBar = false
            }
    }
}

// 2. Create an easy-to-use extension
extension View {
    /// Use this on any child screen to hide both native and custom tab bars
    func hidesTabBarOnNavigation() -> some View {
        self.modifier(HideTabBarModifier())
    }
}