import SwiftUI

struct RefundsView: View {
    @State private var refunds: [RefundItem] = []
    @State private var isLoading = true
    
    // Modern iOS light gray background for the list
    private let bgColor = Color(red: 0.96, green: 0.96, blue: 0.97)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading refunds...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else if refunds.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(refunds, id: \.id) { refund in
                                RefundCardView(refund: refund)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationTitle("Order Refunds")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadRefunds()
        }
    }
    
    // MARK: - Modern Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.bottom, 8)
            
            Text("No Refunds Yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Your refund history for orders will securely appear here.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - API Call
    private func loadRefunds() async {
        let uid = SessionManager.shared.currentUser?.id?.stringValue ?? ""
        do {
            let response = try await APIService.shared.getRefundList(uid: uid)
            refunds = response.refundList ?? []
        } catch {}
        isLoading = false
    }
}

// MARK: - iOS Style Refund Card
struct RefundCardView: View {
    let refund: RefundItem
    
    // Determine if the status is successfully completed
    var isCompleted: Bool {
        (refund.status ?? "").lowercased() == "completed"
    }
    
    // Green for completed, Orange for pending/processing
    var statusColor: Color {
        isCompleted ? Color(red: 0.14, green: 0.64, blue: 0.43) : Color.orange
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // TOP SECTION: Order ID & Amount
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Order #\(refund.orderId ?? "")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    if let msg = refund.message, !msg.isEmpty {
                        Text(msg)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Amount
                Text("\(SessionManager.shared.currency ?? "₹")\(refund.amount ?? "0")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
            }
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // BOTTOM SECTION: Date & Status Badge
            HStack {
                // Date with Icon
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(refund.rdate ?? "")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Native iOS Pill-shaped Status Badge
                Text(refund.status ?? "Pending")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        // Soft iOS style shadow
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}