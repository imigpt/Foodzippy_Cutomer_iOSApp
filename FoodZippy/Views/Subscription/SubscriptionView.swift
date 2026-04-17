import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                        .padding(.top, 12)

                    SubscriptionPlansView()
                }
            }
            .background(Color(hex: "#F7F7F7").ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .onAppear {
            appState.hideMainTabBar = false
        }
    }

    private var header: some View {
        HStack {
            Button {
                if appState.selectedTab == .Subscription {
                    appState.selectedTab = .home
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Subscription")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Color.clear
                .frame(width: 38, height: 38)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AppState.shared)
}
