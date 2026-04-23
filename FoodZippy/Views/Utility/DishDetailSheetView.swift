import SwiftUI

struct DishDetailSheetView: View {
    let dish: AddToCartDish
    @ObservedObject var cartViewModel: AddToCartViewModel
    let onClose: () -> Void
    let onRequestCustomization: (AddToCartDish) -> Void
    
    @State private var nonCustomQuantity = 1
    @State private var isAdded = false
    
    var body: some View {
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
                                    .font(.system(size: 44))
                                    .foregroundColor(.gray.opacity(0.3))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 320)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.9)))
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
                
                // MARK: - Content
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            SheetVegIndicatorView(isVeg: dish.isVeg)
                            
                            // Title
                            Text(dish.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#3B3F46"))
                                .lineLimit(3)
                            
                            // Price
                            HStack(spacing: 8) {
                                if dish.oldPrice > 0 {
                                    Text(dish.oldPriceText)
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .strikethrough()
                                }
                                
                                Text(dish.finalPriceText(for: nil))
                                    .font(.title2)
                                    .fontWeight(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "#FFD938"))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption.weight(.bold))
                                
                                Text("\(dish.ratingText) (\(dish.ratingCount))")
                                    .font(.caption.weight(.bold))
                            }
                            .foregroundColor(Color(hex: "#0B9F63"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: "#E9F8F1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Spacer()
                        
                        // Add / Stepper
                        VStack {
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
                        .padding(.top, 4)
                    }
                    
                    // Description
                    Text(dish.description)
                        .font(.body)
                        .foregroundColor(Color(hex: "#63666C"))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(28, corners: [.topLeft, .topRight])
            }
        }
        .background(Color.white)
        .ignoresSafeArea()
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
                    .presentationBackground(Color.white)
                    .presentationCornerRadius(32)
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
