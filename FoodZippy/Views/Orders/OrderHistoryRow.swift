// OrderHistoryRow.swift
import SwiftUI

struct OrderHistoryRow: View {
    let order: OrderHistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.orderId ?? "")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    if let date = order.orderCompleteDate {
                        Text(date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let amount = order.orderTotal {
                        Text("₹\(amount)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    
                    if let status = order.oStatus {
                        Text(status)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    OrderHistoryRow(order: OrderHistoryItem(orderId: "123", oStatus: "Completed", orderCompleteDate: "Jan 15, 2024", orderTotal: "450", restName: "Test", restLandmark: nil, restImage: nil, orderItems: nil, orderThumbnail: nil, restRate: nil, riderRate: nil, restText: nil, riderText: nil))
}
