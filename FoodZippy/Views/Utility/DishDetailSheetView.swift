import SwiftUI

struct DishDetailSheetView: View {
    let dish: AddToCartDish
    @ObservedObject var cartViewModel: AddToCartViewModel
    let onClose: () -> Void
    let onRequestCustomization: (AddToCartDish) -> Void
    
    @State private var nonCustomQuantity = 1
    @State private var isAdded = false
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - Image Section
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
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.white)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: height * 0.38) // 🔥 Responsive height
                        .frame(maxWidth: .infinity)
                        .clipped()
                        
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: width * 0.045, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: width * 0.12, height: width * 0.12)
                                .background(Circle().fill(Color.white.opacity(0.92)))
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                    }
                    
                    // MARK: - Content
                    VStack(alignment: .leading, spacing: height * 0.015) {
                        
                        HStack(alignment: .top, spacing: 14) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                SheetVegIndicatorView(isVeg: dish.isVeg)
                                
                                // Title
                                Text(dish.title)
                                    .font(.system(size: width * 0.075, weight: .bold)) // 🔥 Responsive
                                    .foregroundColor(Color(hex: "#3B3F46"))
                                    .lineLimit(2)
                                
                                // Price
                                HStack(spacing: 6) {
                                    Text(dish.oldPriceText)
                                        .font(.system(size: width * 0.045, weight: .semibold))
                                        .foregroundColor(.gray)
                                        .strikethrough()
                                    
                                    Text(dish.finalPriceText(for: nil))
                                        .font(.system(size: width * 0.065, weight: .black))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color(hex: "#FFD938"))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                
                                // Rating
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: width * 0.025, weight: .bold))
                                    
                                    Text("\(dish.ratingText) (\(dish.ratingCount))")
                                        .font(.system(size: width * 0.03, weight: .bold))
                                }
                                .foregroundColor(Color(hex: "#0B9F63"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#E9F8F1"))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Spacer()
                            
                            // Add / Stepper
                            if dish.isCustomizable {
                                AddButtonView(subtitle: "Customisable") {
                                    onRequestCustomization(dish)
                                }
                            } else if !isAdded {
                                AddButtonView(subtitle: "") {
                                    isAdded = true
                                    nonCustomQuantity = 1
                                    cartViewModel.setQuantity(for: dish, quantity: nonCustomQuantity)
                                }
                            } else {
                                StepperView(
                                    quantity: nonCustomQuantity,
                                    onIncrement: {
                                        nonCustomQuantity += 1
                                        cartViewModel.setQuantity(for: dish, quantity: nonCustomQuantity)
                                    },
                                    onDecrement: {
                                        if nonCustomQuantity > 0 {
                                            nonCustomQuantity -= 1
                                            cartViewModel.setQuantity(for: dish, quantity: nonCustomQuantity)
                                            if nonCustomQuantity == 0 {
                                                isAdded = false
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        
                        // Description
                        Text(dish.description)
                            .font(.system(size: width * 0.038, weight: .medium))
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
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .modifier(PresentationStyling())
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
    
    private struct PresentationStyling: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 16.4, *) {
                content
                    .presentationBackground(.clear)
                    .presentationCornerRadius(24)
            } else {
                content
            }
        }
    }
    
    #if DEBUG
    struct DishDetailSheetView_Previews: PreviewProvider {
        static var previews: some View {
            DishDetailSheetView(
                dish: AddToCartDish(
                    id: "demo",
                    restaurantId: "rest",
                    restaurantName: "Demo",
                    title: "2 Pcs Sattu Paratha With Tamatar Chutney",
                    imageURL: "https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=1200&q=80",
                    description: "Traditional dish with roasted tomatoes and rich taste.",
                    basePrice: 129.0,
                    oldPrice: 279.0,
                    rating: 4.4,
                    ratingCount: 31,
                    isVeg: true,
                    isCustomizable: true,
                    customisationOptions: [
                        DishCustomisationOption(id: "half", title: "Half", additionalPrice: 0.0, isVeg: true),
                        DishCustomisationOption(id: "full", title: "Full", additionalPrice: 40.0, isVeg: true)
                    ]
                ),
                cartViewModel: .shared,
                onClose: {},
                onRequestCustomization: { _ in }
            )
        }
    }
    #endif
}
