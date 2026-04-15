// CartView.swift
// Cart screen matching Android activity_cart.xml

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @StateObject private var viewModel = CartViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var couponCode = ""
    @State private var showCouponField = false
    @State private var navigateToOrderSuccess = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(hex: "#F5F5F5").ignoresSafeArea()

                if cartManager.cartItems.isEmpty {
                    CartEmptyView(dismiss: dismiss)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            CartRestaurantCard()
                                .padding(.horizontal, 8)
                                .padding(.top, 8)

                            CartItemsSection(cartManager: cartManager, viewModel: viewModel)
                                .padding(.horizontal, 8)

                            CartCouponSection(
                                viewModel: viewModel,
                                couponCode: $couponCode,
                                showCouponField: $showCouponField
                            )
                            .padding(.horizontal, 8)

                            if !viewModel.tipItems.isEmpty {
                                CartTipSection(viewModel: viewModel)
                                    .padding(.horizontal, 8)
                            }

                            CartBillSection(viewModel: viewModel)
                                .padding(.horizontal, 8)

                            CartAddressSection(viewModel: viewModel)
                                .padding(.horizontal, 8)
                                .padding(.bottom, 90)
                        }
                    }

                    CartPlaceOrderBar(viewModel: viewModel) {
                        Task {
                            await viewModel.placeOrder()
                            if viewModel.orderPlaced {
                                navigateToOrderSuccess = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#E23744"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
            .task {
                viewModel.loadCart()
                await viewModel.loadCartData()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Replace Cart?", isPresented: $cartManager.showReplaceCartAlert) {
                Button("Replace", role: .destructive) {
                    cartManager.replaceCartWithPendingItem()
                    viewModel.loadCart()
                }
                Button("Cancel", role: .cancel) {
                    cartManager.pendingItem = nil
                    cartManager.showReplaceCartAlert = false
                }
            } message: {
                Text("Your cart has items from another restaurant. Replace?")
            }
            .navigationDestination(isPresented: $navigateToOrderSuccess) {
                CartOrderSuccessView(orderId: viewModel.placedOrderId, dismiss: dismiss)
            }
        }
    }
}

// MARK: - Empty Cart
private struct CartEmptyView: View {
    let dismiss: DismissAction
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "cart.badge.minus")
                .font(.system(size: 72))
                .foregroundColor(Color.gray.opacity(0.4))
            Text("Your cart is empty")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            Text("Add items from a restaurant to get started")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
            Button { dismiss() } label: {
                Text("Browse Restaurants")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#E23744"))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Restaurant Info Card (65×65dp, cornerRadius 10)
private struct CartRestaurantCard: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#E23744").opacity(0.12))
                .frame(width: 65, height: 65)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "#E23744"))
                )
            VStack(alignment: .leading, spacing: 4) {
                let restName = SessionManager.shared.restaurantName
                Text(restName.isEmpty ? "Restaurant" : restName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                let restAddr = SessionManager.shared.currentAddress?.fullAddress ?? ""
                if !restAddr.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Text(restAddr)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Cart Items Section
private struct CartItemsSection: View {
    @ObservedObject var cartManager: CartManager
    @ObservedObject var viewModel: CartViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Your Order")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Button {
                    cartManager.clearCart()
                    viewModel.loadCart()
                } label: {
                    Text("Clear All")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#E23744"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 14)

            ForEach(cartManager.cartItems) { item in
                CartItemRow(item: item, cartManager: cartManager, viewModel: viewModel)
                if item.id != cartManager.cartItems.last?.id {
                    Divider().padding(.horizontal, 14)
                }
            }
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

private struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var cartManager: CartManager
    @ObservedObject var viewModel: CartViewModel

    var body: some View {
        HStack(spacing: 10) {
            // Veg/non-veg dot indicator
            Image(systemName: item.isVegetarian ? "circle.fill" : "square.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(item.isVegetarian ? Color(hex: "#098430") : .red)
                .padding(3)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(item.isVegetarian ? Color(hex: "#098430") : .red, lineWidth: 1.2)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                if !item.addonTitle.isEmpty {
                    Text(item.addonTitle)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Text("₹\(String(format: "%.0f", item.price))")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#E23744"))
            }

            Spacer()

            // Quantity stepper
            HStack(spacing: 0) {
                Button {
                    if item.quantity <= 1 {
                        cartManager.removeItem(item.id)
                    } else {
                        cartManager.decrementQuantity(for: item.id)
                    }
                    viewModel.loadCart()
                } label: {
                    Image(systemName: item.quantity <= 1 ? "trash" : "minus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#E23744"))
                        .frame(width: 28, height: 28)
                }
                Text("\(item.quantity)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#E23744"))
                    .frame(width: 24)
                Button {
                    cartManager.incrementQuantity(for: item.id)
                    viewModel.loadCart()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#E23744"))
                        .frame(width: 28, height: 28)
                }
            }
            .background(Color(hex: "#E23744").opacity(0.1))
            .cornerRadius(8)

            Text("₹\(String(format: "%.0f", item.totalPrice))")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Coupon Section
private struct CartCouponSection: View {
    @ObservedObject var viewModel: CartViewModel
    @Binding var couponCode: String
    @Binding var showCouponField: Bool

    var body: some View {
        VStack(spacing: 0) {
            Button { showCouponField.toggle() } label: {
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(Color(hex: "#E23744"))
                    Text(viewModel.couponDiscount > 0 ? "Coupon Applied ✓" : "Apply Coupon")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(viewModel.couponDiscount > 0 ? Color(hex: "#098430") : .black)
                    Spacer()
                    Image(systemName: showCouponField ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if showCouponField {
                Divider()
                if viewModel.couponDiscount > 0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#098430"))
                        Text("Saving ₹\(String(format: "%.0f", viewModel.couponDiscount)) with coupon!")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#098430"))
                        Spacer()
                        Button {
                            viewModel.removeCoupon()
                            couponCode = ""
                        } label: {
                            Text("Remove")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#E23744"))
                        }
                    }
                    .padding(14)
                } else {
                    HStack(spacing: 8) {
                        TextField("Enter coupon code", text: $couponCode)
                            .font(.system(size: 14))
                            .textInputAutocapitalization(.characters)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#F5F5F5"))
                            .cornerRadius(8)
                        Button {
                            Task { await viewModel.applyCouponCode(couponCode) }
                        } label: {
                            Text("Apply")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(couponCode.isEmpty ? Color.gray : Color(hex: "#E23744"))
                                .cornerRadius(8)
                        }
                        .disabled(couponCode.isEmpty)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Tip Section
private struct CartTipSection: View {
    @ObservedObject var viewModel: CartViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tip your delivery partner ❤️")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                Text("Your generosity means the world to them!")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.tipItems) { tip in
                        Button {
                            if tip.isSelected { viewModel.clearTip() }
                            else { viewModel.selectTip(tip.amount) }
                        } label: {
                            Text("₹\(String(format: "%.0f", tip.amount))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(tip.isSelected ? .white : Color(hex: "#E23744"))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .background(tip.isSelected ? Color(hex: "#E23744") : Color.clear)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: "#E23744"), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 14)
            }
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Bill Details
private struct CartBillSection: View {
    @ObservedObject var viewModel: CartViewModel
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Bill Details")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 14)

            VStack(spacing: 12) {
                BillDetailRow(label: "Items Total",
                              value: "₹\(String(format: "%.0f", viewModel.itemTotal))")
                if viewModel.deliveryCharge > 0 {
                    BillDetailRow(label: "Delivery Fee",
                                  value: "₹\(String(format: "%.0f", viewModel.deliveryCharge))")
                } else {
                    BillDetailRow(label: "Delivery Fee",
                                  value: "FREE",
                                  valueColor: Color(hex: "#098430"))
                }
                if viewModel.storeCharge > 0 {
                    BillDetailRow(label: "Platform Fee",
                                  value: "₹\(String(format: "%.0f", viewModel.storeCharge))")
                }
                if viewModel.taxAmount > 0 {
                    BillDetailRow(label: "Taxes & Charges",
                                  value: "₹\(String(format: "%.0f", viewModel.taxAmount))")
                }
                if viewModel.tipAmount > 0 {
                    BillDetailRow(label: "Delivery Tip",
                                  value: "₹\(String(format: "%.0f", viewModel.tipAmount))",
                                  valueColor: Color(hex: "#098430"))
                }
                if viewModel.couponDiscount > 0 {
                    BillDetailRow(label: "Coupon Discount",
                                  value: "-₹\(String(format: "%.0f", viewModel.couponDiscount))",
                                  valueColor: Color(hex: "#098430"))
                }
                if viewModel.walletAmount > 0 {
                    BillDetailRow(label: "Wallet Used",
                                  value: "-₹\(String(format: "%.0f", viewModel.walletAmount))",
                                  valueColor: Color(hex: "#098430"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider().padding(.horizontal, 14)

            HStack {
                Text("To Pay")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text("₹\(String(format: "%.0f", viewModel.grandTotal))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#E23744"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if viewModel.couponDiscount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#098430"))
                    Text("You saved ₹\(String(format: "%.0f", viewModel.couponDiscount)) on this order!")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#098430"))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: "#D0F4E8"))
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

private struct BillDetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = Color(hex: "#333333")
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#555555"))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Delivery Address Section
private struct CartAddressSection: View {
    @ObservedObject var viewModel: CartViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Deliver to")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 14)

            if let address = viewModel.selectedAddress {
                HStack(spacing: 12) {
                    Image(systemName: address.typeIcon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#E23744"))
                        .frame(width: 38, height: 38)
                        .background(Color(hex: "#E23744").opacity(0.1))
                        .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 3) {
                        Text((address.type ?? "Home").capitalized)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black)
                        Text(address.fullAddress)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button { viewModel.showAddressSheet = true } label: {
                        Text("Change")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#E23744"))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            } else {
                Button { viewModel.showAddressSheet = true } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "#E23744"))
                        Text("Add Delivery Address")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#E23744"))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .sheet(isPresented: $viewModel.showAddressSheet) {
            AddressListView(selectionMode: true) { address in
                viewModel.selectedAddress = address
                viewModel.showAddressSheet = false
                viewModel.calculateBill()
            }
        }
    }
}

// MARK: - Place Order Bottom Bar
private struct CartPlaceOrderBar: View {
    @ObservedObject var viewModel: CartViewModel
    let onPlaceOrder: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("₹\(String(format: "%.0f", viewModel.grandTotal))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Text("Grand Total")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 16)

                Spacer()

                Button(action: onPlaceOrder) {
                    ZStack {
                        if viewModel.isPlacingOrder {
                            ProgressView().tint(.white)
                        } else {
                            Text("Place Order")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 150, height: 46)
                    .background(
                        viewModel.isPlacingOrder
                            ? Color(hex: "#E23744").opacity(0.7)
                            : Color(hex: "#E23744")
                    )
                    .cornerRadius(10)
                }
                .disabled(viewModel.isPlacingOrder)
                .padding(.trailing, 16)
            }
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
    }
}

// MARK: - Order Success Screen
struct CartOrderSuccessView: View {
    let orderId: String
    let dismiss: DismissAction
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(hex: "#D0F4E8"))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(hex: "#098430"))
            }
            Text("Order Placed! 🎉")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            if !orderId.isEmpty {
                Text("Order #\(orderId)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            Text("Your order has been placed successfully.\nGet ready to enjoy your meal!")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button { dismiss() } label: {
                Text("Continue Shopping")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#E23744"))
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager.shared)
}
