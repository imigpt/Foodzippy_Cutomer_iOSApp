// SubscriptionViews.swift
// Matches Android SubscriptionPlansActivity + SubscriptionHistoryActivity

import SwiftUI

// MARK: - Subscription Plans View

struct SubscriptionPlansView: View {
    @State private var plans: [SubscriptionPlan] = []
    @State private var isLoading = true
    @State private var selectedPlan: SubscriptionPlan?
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if plans.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "crown")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No subscription plans available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Hero
                        VStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.purple)
                            
                            Text("FoodZippy Plus")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Subscribe to get exclusive benefits")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Plans
                        ForEach(plans, id: \.id) { plan in
                            SubscriptionPlanCard(plan: plan) {
                                selectedPlan = plan
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Subscription Plans")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                let response = try await APIService.shared.getSubscriptionPlans(restId: "")
                plans = response.plans ?? []
            } catch {}
            isLoading = false
        }
        .sheet(item: $selectedPlan) { plan in
            NavigationStack {
                PurchaseSubscriptionView(plan: plan)
            }
        }
    }
}

struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let onSubscribe: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.planName ?? "")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if let desc = plan.planDescription, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(SessionManager.shared.currency)\(plan.planPrice ?? "0")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.appPrimary)
                    
                    Text(plan.planDuration ?? "")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            // Meals
            if let meals = plan.planMeals, !meals.isEmpty {
                Divider()
                Text("Includes:")
                    .font(.caption)
                    .fontWeight(.bold)
                
                ForEach(meals, id: \.id) { meal in
                    HStack {
                        Text(meal.mealName ?? "")
                            .font(.caption)
                        Spacer()
                        Text("x1")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Subscribe button
            Button {
                onSubscribe()
            } label: {
                Text("Subscribe Now")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.purple, .appPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Subscription History View

struct SubscriptionHistoryView: View {
    @State private var subscriptions: [ActiveSubscriptionItem] = []
    @State private var isLoading = true
    
    var body: some View {
        Group {
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
                    Text("No subscription history")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    NavigationLink {
                        SubscriptionPlansView()
                    } label: {
                        Text("Browse Plans")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
            } else {
                    List(subscriptions, id: \.id) { sub in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                                Text(sub.planTitle ?? "")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("Active")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.appGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.appGreen.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        HStack {
                            Text("\(SessionManager.shared.currency)\(sub.amount ?? "0")")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Text("•")
                                .foregroundColor(.gray)
                            
                            Text("\(sub.daysRemaining ?? 0) days left")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        if let start = sub.startDateFormatted, let end = sub.endDateFormatted {
                            Text("\(start) → \(end)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        NavigationLink {
                            SubscriptionScheduleView(subscription: sub)
                        } label: {
                            Text("Manage Schedule")
                                .font(.caption.bold())
                                .foregroundColor(.appPrimary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Subscription History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                let uid = SessionManager.shared.currentUser?.id ?? ""
                if !uid.isEmpty {
                    let response = try await APIService.shared.getUserSubscriptions(userId: uid)
                    subscriptions = response.activeOrders ?? []
                } else {
                    subscriptions = []
                }
            } catch {}
            isLoading = false
        }
    }
}

// MARK: - Purchase Subscription

private struct PurchaseSubscriptionView: View {
    let plan: SubscriptionPlan
    @Environment(\.dismiss) private var dismiss

    @State private var startDate = Date()
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var message = ""

    var body: some View {
        Form {
            Section("Plan") {
                Text(plan.planName ?? "Plan")
                    .font(.headline)
                Text("\(SessionManager.shared.currency)\(plan.planPrice ?? "0")")
                    .font(.subheadline)
            }

            Section("Start Date") {
                DatePicker("Subscription starts", selection: $startDate, in: Date()..., displayedComponents: .date)
            }

            Section {
                Button {
                    Task { await placeOrder() }
                } label: {
                    if isSubmitting {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Confirm Subscription")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isSubmitting)
            }
        }
        .navigationTitle("Subscribe")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Subscription", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if message.lowercased().contains("success") {
                    dismiss()
                }
            }
        } message: {
            Text(message)
        }
    }

    private func placeOrder() async {
        guard let userId = SessionManager.shared.currentUser?.id, !userId.isEmpty else {
            message = "Please login first"
            showAlert = true
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateText = dateFormatter.string(from: startDate)

        let restId = SessionManager.shared.restaurantId.isEmpty ? "0" : SessionManager.shared.restaurantId
        let planId = plan.planId ?? "0"

        do {
            let response = try await APIService.shared.createSubscriptionOrder(
                userId: userId,
                planId: planId,
                restId: restId,
                startDate: startDateText,
                transactionId: "IOS_SUB_\(Int(Date().timeIntervalSince1970))"
            )
            message = response.responseMsg ?? (response.isSuccess ? "Subscription purchased successfully" : "Failed to purchase subscription")
        } catch {
            message = error.localizedDescription
        }

        showAlert = true
    }
}

// MARK: - Subscription Schedule

private struct SubscriptionScheduleView: View {
    let subscription: ActiveSubscriptionItem

    @State private var reason = ""
    @State private var selectedMeal: SubscriptionDailyMeal?
    @State private var selectedAction: ActionType?
    @State private var showReasonSheet = false
    @State private var message = ""
    @State private var showAlert = false

    private enum ActionType {
        case skip
        case holiday
    }

    var body: some View {
        List {
            if let meals = subscription.dailySchedule, !meals.isEmpty {
                ForEach(meals) { meal in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text((meal.mealType ?? "Meal").capitalized)
                                .font(.subheadline.bold())
                            Spacer()
                            Text(meal.status ?? "scheduled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text(meal.itemTitle ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(meal.dayName ?? "") \(meal.dateFormatted ?? meal.deliveryDate ?? "")")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            Button("Skip Meal") {
                                selectedMeal = meal
                                selectedAction = .skip
                                reason = "Skipping for today"
                                showReasonSheet = true
                            }
                            .buttonStyle(.bordered)

                            Button("Request Holiday") {
                                selectedMeal = meal
                                selectedAction = .holiday
                                reason = "Not available"
                                showReasonSheet = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No schedule available")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Subscription Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReasonSheet) {
            NavigationStack {
                Form {
                    Section("Reason") {
                        TextField("Enter reason", text: $reason, axis: .vertical)
                    }

                    Section {
                        Button("Submit") {
                            Task { await performAction() }
                        }
                        .disabled(reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .navigationTitle("Add Reason")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert("Subscription", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message)
        }
    }

    private func performAction() async {
        guard let action = selectedAction,
              let meal = selectedMeal,
              let uid = SessionManager.shared.currentUser?.id,
              let orderId = subscription.orderId else {
            return
        }

        do {
            let response: GenericResponse
            switch action {
            case .skip:
                response = try await APIService.shared.skipMeal(
                    userId: uid,
                    orderId: orderId,
                    mealId: meal.mealId ?? meal.id,
                    mealType: meal.mealType ?? ""
                )
            case .holiday:
                response = try await APIService.shared.requestHoliday(
                    userId: uid,
                    orderId: orderId,
                    requestedDate: meal.deliveryDate ?? "",
                    reason: reason
                )
            }

            message = response.responseMsg ?? (response.isSuccess ? "Request submitted" : "Request failed")
        } catch {
            message = error.localizedDescription
        }

        showReasonSheet = false
        showAlert = true
    }
}
