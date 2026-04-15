import SwiftUI

struct DishDetailSheetView: View {
    let dish: AddToCartDish
    @ObservedObject var cartViewModel: AddToCartViewModel
    let onClose: () -> Void
    let onRequestCustomization: (AddToCartDish) -> Void

    @State private var nonCustomQuantity = 1

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: dish.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.14))
                                .overlay(ProgressView().tint(.white))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.18))
                                .overlay(Image(systemName: "photo").foregroundColor(.white))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 350)
                    .frame(maxWidth: .infinity)
                    .clipped()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(Color.white.opacity(0.92)))
                    }
                    .padding(.top, 14)
                    .padding(.trailing, 14)
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            SheetVegIndicatorView(isVeg: dish.isVeg)

                            Text(dish.title)
                                .font(.system(size: 47, weight: .bold))
                                .foregroundColor(Color(hex: "#3B3F46"))
                                .lineLimit(2)

                            HStack(spacing: 6) {
                                Text(dish.oldPriceText)
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .strikethrough()

                                Text(dish.finalPriceText(for: nil))
                                    .font(.system(size: 40, weight: .black))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: "#FFD938"))
                                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11, weight: .bold))
                                Text("\(dish.ratingText) (\(dish.ratingCount))")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(Color(hex: "#0B9F63"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#E9F8F1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }

                        Spacer(minLength: 12)

                        if dish.isCustomizable {
                            AddButtonView(subtitle: "Customisable") {
                                onRequestCustomization(dish)
                            }
                        } else {
                            StepperView(
                                quantity: nonCustomQuantity,
                                onIncrement: {
                                    nonCustomQuantity += 1
                                    cartViewModel.setQuantity(for: dish, quantity: nonCustomQuantity)
                                },
                                onDecrement: {
                                    if nonCustomQuantity > 1 {
                                        nonCustomQuantity -= 1
                                        cartViewModel.setQuantity(for: dish, quantity: nonCustomQuantity)
                                    }
                                }
                            )
                        }
                    }

                    Text(dish.description)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#63666C"))
                        .lineSpacing(3)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 20)
                .background(Color.white)
            }
        }
        .background(Color(hex: "#EFEFF4"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onAppear {
            let current = cartViewModel.quantity(for: dish.id)
            nonCustomQuantity = max(1, current)
        }
    }
}

private struct SheetVegIndicatorView: View {
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
    DishDetailSheetView(
        dish: AddToCartDish(
            id: "demo",
            restaurantId: "rest",
            restaurantName: "Demo",
            title: "2 Pcs Sattu Paratha With Tamatar Chutney",
            imageURL: "https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=1200&q=80",
            description: "Traditional dish with roasted tomatoes and rich taste.",
            basePrice: 129,
            oldPrice: 279,
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
        onClose: {},
        onRequestCustomization: { _ in }
    )
}
