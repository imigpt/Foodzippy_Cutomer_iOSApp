// RefundsView.swift
// Matches Android RefundsActivity

import SwiftUI

struct RefundsView: View {
    @State private var refunds: [RefundItem] = []
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if refunds.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "arrow.uturn.left.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No refunds")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Your refund history will appear here")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List(refunds, id: \.id) { refund in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Order #\(refund.orderId ?? "")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(SessionManager.shared.currency)\(refund.amount ?? "0")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.appGreen)
                        }
                        
                        if let message = refund.message, !message.isEmpty {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text(refund.rdate ?? "")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(refund.status ?? "")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(refund.status == "Completed" ? .appGreen : .appAccent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background((refund.status == "Completed" ? Color.appGreen : Color.appAccent).opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Refunds")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let uid = SessionManager.shared.currentUser?.id ?? ""
            do {
                let response = try await APIService.shared.getRefundList(uid: uid)
                refunds = response.refundList ?? []
            } catch {}
            isLoading = false
        }
    }
}
