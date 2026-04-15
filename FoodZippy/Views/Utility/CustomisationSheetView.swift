import SwiftUI

struct CustomisationSheetView: View {
    let dish: AddToCartDish
    @ObservedObject var cartViewModel: AddToCartViewModel
    let onClose: () -> Void

    @State private var quantity = 1
    @State private var selectedOption: DishCustomisationOption?

    private var finalPriceText: String {
        dish.finalPriceText(for: selectedOption)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: dish.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.gray.opacity(0.14))
                            .overlay(ProgressView().tint(.orange))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.gray.opacity(0.14))
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(dish.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#44474D"))
                    .lineLimit(1)

                Spacer(minLength: 8)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#8C8F94"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)

            Divider()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quantity")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color(hex: "#3B3F46"))

                        Text("Select any 1")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#6A6E75"))
                    }
                    .padding(.top, 6)

                    VStack(spacing: 0) {
                        ForEach(dish.customisationOptions) { option in
                            Button(action: {
                                selectedOption = option
                                cartViewModel.setSelectedCustomization(option, for: dish.id)
                            }) {
                                HStack(spacing: 12) {
                                    CustomSheetVegIndicatorView(isVeg: option.isVeg)

                                    Text(option.title)
                                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "#171A29"))

                                    if option.additionalPrice > 0 {
                                        Text(option.additionalPriceText)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color(hex: "#73777F"))
                                    }

                                    Image(systemName: selectedOption?.id == option.id ? "circle.inset.filled" : "circle")
                                        .font(.system(size: 19, weight: .semibold))
                                        .foregroundColor(selectedOption?.id == option.id ? Color(hex: "#FF6B00") : Color(hex: "#8B8F96"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                            }
                            .buttonStyle(.plain)

                            if option.id != dish.customisationOptions.last?.id {
                                Divider()
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(16)
                .padding(.bottom, 6)
            }
            .background(Color(hex: "#ECECF1"))

            HStack(spacing: 12) {
                StepperView(
                    quantity: quantity,
                    onIncrement: { quantity += 1 },
                    onDecrement: {
                        if quantity > 1 { quantity -= 1 }
                    }
                )
                .frame(maxWidth: 148)

                Button(action: {
                    guard let selectedOption else { return }
                    cartViewModel.addDish(dish, customization: selectedOption, quantity: quantity)
                    onClose()
                }) {
                    HStack(spacing: 6) {
                        Text("Add Item | \(finalPriceText)")
                            .font(.system(size: 18, weight: .bold))

                        Text(dish.oldPriceText)
                            .font(.system(size: 16, weight: .semibold))
                            .strikethrough()
                            .opacity(0.82)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#098430"))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(selectedOption == nil)
                .opacity(selectedOption == nil ? 0.65 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onAppear {
            selectedOption = cartViewModel.selectedCustomization(for: dish.id) ?? dish.customisationOptions.first
        }
    }
}

private struct CustomSheetVegIndicatorView: View {
    let isVeg: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(isVeg ? Color(hex: "#129A5E") : Color(hex: "#D54141"), lineWidth: 1.6)
                .frame(width: 14, height: 14)

            Circle()
                .fill(isVeg ? Color(hex: "#129A5E") : Color(hex: "#D54141"))
                .frame(width: 7, height: 7)
        }
    }
}

#Preview {
    CustomisationSheetView(
        dish: AddToCartDish(
            id: "sev-tamater",
            restaurantId: "rest-1",
            restaurantName: "Shri Govindam",
            title: "Sev Tamater",
            imageURL: "https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=800&q=80",
            description: "Roasted tomato based traditional curry.",
            basePrice: 69,
            oldPrice: 80,
            rating: 4.4,
            ratingCount: 31,
            isVeg: true,
            isCustomizable: true,
            customisationOptions: [
                DishCustomisationOption(id: "half", title: "Half", additionalPrice: 0, isVeg: true),
                DishCustomisationOption(id: "full", title: "Full", additionalPrice: 40, isVeg: true)
            ]
        ),
        cartViewModel: .shared,
        onClose: {}
    )
}
