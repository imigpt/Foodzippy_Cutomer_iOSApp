// SubscriptionHistoryView.swift
// Shows user's past & active subscriptions

import SwiftUI

struct SubscriptionHistoryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var subscriptions: [ActiveSubscriptionItem] = []
    @State private var isLoading = true
    @State private var itemToCancel: ActiveSubscriptionItem?
    @State private var showCancelPopup = false
    @State private var cancelReason: String = ""

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground) // Light grey background
                .ignoresSafeArea()

            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if subscriptions.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No subscriptions yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Your subscription history will appear here")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(subscriptions, id: \.id) { item in
                            SubscriptionHistoryCard(
                                item: item,
                                onCancelTapped: {
                                    itemToCancel = item
                                    showCancelPopup = true
                                }
                            )
                        }
                    }
                    .padding(16)
                }
            }

            // Cancellation Popup Overlay
            if showCancelPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showCancelPopup = false
                    }

                cancelPopupView
            }
        }
        .navigationTitle("Subscription History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // If using a custom back button, handle dismiss here.
                // NavigationStack automatically provides a standard chevron.
            }
        }
        .task {
            await fetchSubscriptions()
        }
        .onAppear {
            appState.hideMainTabBar = true
        }
        // .onDisappear {
        //     appState.hideMainTabBar = false
        // }
    }

    private func fetchSubscriptions() async {
        let uid = SessionManager.shared.currentUser?.id?.stringValue ?? ""
        do {
            let response = try await APIService.shared.getUserSubscriptions(userId: uid)
            subscriptions = response.activeOrders ?? []
            
            // If no subscriptions from API, use mock data for testing
            if subscriptions.isEmpty {
                subscriptions = [
                    ActiveSubscriptionItem(
                        orderId: "1001",
                        subscriptionId: "sub_001",
                        planTitle: "Plus",
                        planDescription: "Unlimited Benefits and Savings",
                        planDays: "365",
                        amount: "799",
                        status: "active",
                        startDateFormatted: "2025-04-20",
                        endDateFormatted: "2026-04-20",
                        daysRemaining: 365,
                        dailySchedule: []
                    ),
                    ActiveSubscriptionItem(
                        orderId: "1002",
                        subscriptionId: "sub_002",
                        planTitle: "Premium",
                        planDescription: "Premium Plus with Priority Delivery",
                        planDays: "30",
                        amount: "99",
                        status: "cancelled",
                        startDateFormatted: "2025-03-01",
                        endDateFormatted: "2025-03-31",
                        daysRemaining: 0,
                        dailySchedule: []
                    )
                ]
            }
        } catch {
            print("Error fetching subscriptions: \(error)")
            // Use mock data on error for testing
            subscriptions = [
                ActiveSubscriptionItem(
                    orderId: "1001",
                    subscriptionId: "sub_001",
                    planTitle: "Plus",
                    planDescription: "Unlimited Benefits and Savings",
                    planDays: "365",
                    amount: "799",
                    status: "active",
                    startDateFormatted: "2025-04-20",
                    endDateFormatted: "2026-04-20",
                    daysRemaining: 365,
                    dailySchedule: []
                )
            ]
        }
        isLoading = false
    }

    // MARK: - Cancel Popup View
    private var cancelPopupView: some View {
        VStack(spacing: 0) {
            // Header
            VStack {
                Text("Cancel Subscription?")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Text("We're sad to see you go!")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(LinearGradient(colors: [.red, Color(red: 1.0, green: 0.3, blue: 0.3)], startPoint: .top, endPoint: .bottom))

            // Form Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Please tell us why you're cancelling")
                    .font(.subheadline)
                    .bold()
                Text("Your feedback helps us improve")
                    .font(.caption)
                    .foregroundColor(.gray)

                TextField("Write your cancellation reason", text: $cancelReason)
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.top, 8)

                // Warning Banner
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Once cancelled, you'll lose access to all Plus benefits immediately.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(8)
                .padding(.top, 16)
            }
            .padding(20)
            .background(Color.white)

            // Buttons
            HStack(spacing: 16) {
                Button(action: {
                    showCancelPopup = false
                }) {
                    Text("Keep Benefits")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }

                Button(action: {
                    // Handle actual API cancellation here
                    // In a real app, this would call the API to cancel the subscription
                    showCancelPopup = false
                }) {
                    Text("Confirm Cancel")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(Color.white)
        }
        .cornerRadius(20)
        .padding(.horizontal, 24)
        .shadow(radius: 10)
    }
}

// MARK: - Subscription Card View
struct SubscriptionHistoryCard: View {
    let item: ActiveSubscriptionItem
    let onCancelTapped: () -> Void

    var isActive: Bool {
        item.status?.lowercased() == "active"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Gradient Section
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.planTitle ?? "Plus")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    Text(item.planDescription ?? "Unlimited Benefits and Savingss")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                Spacer()

                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: isActive ? "checkmark.square.fill" : "xmark")
                        .font(.caption)
                    Text(isActive ? "Active" : "Cancelled")
                        .font(.caption)
                        .bold()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isActive ? Color.green : Color.red.opacity(0.8))
                .cornerRadius(6)
            }
            .padding(16)
            .background(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))

            // Body
            VStack(spacing: 16) {
                // Info Banner
                if isActive, let days = item.daysRemaining, days > 0 {
                    Text("\(days) days remaining")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }

                // Details Grid
                VStack(spacing: 16) {
                    HStack {
                        DetailColumn(title: "Start Date", value: item.startDateFormatted ?? "-")
                        Spacer()
                        DetailColumn(title: "End Date", value: item.endDateFormatted ?? "-", alignment: .leading)
                            .frame(width: 140, alignment: .leading)
                    }

                    HStack {
                        DetailColumn(title: "Amount Paid", value: "\(SessionManager.shared.currency)\(item.amount ?? "0")", valueColor: .green)
                        Spacer()
                        if isActive {
                            // Only show payment method if active per prompt instructions
                            DetailColumn(title: "Payment Method", value: "1", alignment: .leading)
                                .frame(width: 140, alignment: .leading)
                        } else {
                            Spacer()
                                .frame(width: 140)
                        }
                    }

                    HStack {
                        DetailColumn(title: "Transaction ID", value: "pay_SfdRPUclhDtYoy")
                        Spacer()
                    }

                    HStack {
                        DetailColumn(title: "Purchased On", value: "2026-04-19 22:41:11")
                        Spacer()
                    }
                }
                .padding(.top, 8)

                if isActive {
                    Button(action: onCancelTapped) {
                        Text("Cancel Subscription")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .padding(.top, 8)
                }
            }
            .padding(16)
            .background(Color.white)
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
}

// Helper view for data columns
struct DetailColumn: View {
    let title: String
    let value: String
    var valueColor: Color = .black
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SubscriptionHistoryView()
    }
}
