// OrderHistoryView.swift
import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.orderHistory.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "bag")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No orders yet")
                            .font(.headline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowInsets(EdgeInsets())
                } else {
                    ForEach(viewModel.orderHistory, id: \.orderId) { order in
                        NavigationLink {
                            OrderDetailView(orderId: order.orderId ?? "")
                        } label: {
                            OrderHistoryRow(order: order)
                        }
                    }
                }
            }
            .navigationTitle("Order History")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadOrderHistory()
            }
        }
    }
}

#Preview {
    OrderHistoryView()
}
