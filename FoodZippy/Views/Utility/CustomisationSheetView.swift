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
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            VStack(spacing: 0) {
                
                // MARK: - Header
                HStack(spacing: width * 0.03) {
                    AsyncImage(url: URL(string: dish.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.14))
                                .overlay(ProgressView().tint(.orange))
                            
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                            
                        case .failure:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.14))
                                .overlay(Image(systemName: "photo").foregroundColor(.gray))
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: width * 0.12, height: width * 0.12)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text(dish.title)
                        .font(.system(size: width * 0.042, weight: .semibold))
                        .foregroundColor(Color(hex: "#44474D"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: width * 0.045, weight: .semibold))
                            .foregroundColor(Color(hex: "#8C8F94"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, height * 0.015)
                .background(Color.white)
                
                Divider()
                
                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: height * 0.02) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quantity")
                                .font(.system(size: width * 0.07, weight: .bold))
                                .foregroundColor(Color(hex: "#3B3F46"))
                            
                            Text("Select any 1")
                                .font(.system(size: width * 0.038, weight: .medium))
                                .foregroundColor(Color(hex: "#6A6E75"))
                        }
                        .padding(.top, 6)
                        
                        // MARK: - Options List
                        VStack(spacing: 0) {
                            ForEach(dish.customisationOptions) { option in
                                Button {
                                    selectedOption = option
                                    cartViewModel.setSelectedCustomization(option, for: dish.id)
                                } label: {
                                    HStack(spacing: width * 0.03) {
                                        
                                        CustomSheetVegIndicatorView(isVeg: option.isVeg)
                                        
                                        Text(option.title)
                                            .font(.system(size: width * 0.042, weight: .semibold))
                                            .foregroundColor(Color(hex: "#171A29"))
                                        
                                        Spacer()
                                        
                                        if option.additionalPrice > 0 {
                                            Text(option.additionalPriceText)
                                                .font(.system(size: width * 0.038, weight: .semibold))
                                                .foregroundColor(Color(hex: "#73777F"))
                                        }
                                        
                                        Image(systemName: selectedOption?.id == option.id ? "circle.inset.filled" : "circle")
                                            .font(.system(size: width * 0.05, weight: .semibold))
                                            .foregroundColor(
                                                selectedOption?.id == option.id
                                                ? Color(hex: "#FF6B00")
                                                : Color(hex: "#8B8F96")
                                            )
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, height * 0.02)
                                }
                                .buttonStyle(.plain)
                                
                                if option.id != dish.customisationOptions.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(16)
                    .padding(.bottom, height * 0.02)
                }
                .background(Color(hex: "#ECECF1"))
                
                // MARK: - Bottom CTA
                VStack {
                    HStack(spacing: width * 0.03) {
                        
                        StepperView(
                            quantity: quantity,
                            onIncrement: { quantity += 1 },
                            onDecrement: {
                                if quantity > 1 { quantity -= 1 }
                            }
                        )
                        .frame(maxWidth: width * 0.32)
                        
                        Button {
                            guard let selectedOption else { return }
                            cartViewModel.addDish(dish, customization: selectedOption, quantity: quantity)
                            onClose()
                        } label: {
                            HStack(spacing: 6) {
                                Text("Add Item | \(finalPriceText)")
                                    .font(.system(size: width * 0.045, weight: .bold))
                                
                                Text(dish.oldPriceText)
                                    .font(.system(size: width * 0.04, weight: .semibold))
                                    .strikethrough()
                                    .opacity(0.8)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, height * 0.02)
                            .background(Color(hex: "#098430"))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .disabled(selectedOption == nil)
                        .opacity(selectedOption == nil ? 0.6 : 1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 10)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -2)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
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
    
    #if DEBUG
    struct CustomisationSheetView_Previews: PreviewProvider {
        static var previews: some View {
            CustomisationSheetView(
                dish: AddToCartDish(
                    id: "sev-tamater",
                    restaurantId: "rest-1",
                    restaurantName: "Shri Govindam",
                    title: "Sev Tamater",
                    imageURL: "https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=800&q=80",
                    description: "Roasted tomato based traditional curry.",
                    basePrice: 69.0,
                    oldPrice: 80.0,
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
                onClose: {}
            )
        }
    }
    #endif
}
