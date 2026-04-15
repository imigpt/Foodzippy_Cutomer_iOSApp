// Extensions.swift
// SwiftUI and Foundation extensions for the app

import SwiftUI

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // App Colors
    static let appPrimary = Color(hex: Constants.Colors.primary)
    static let appAccent = Color(hex: Constants.Colors.accent)
    static let appGreen = Color(hex: Constants.Colors.green)
    static let appRed = Color(hex: Constants.Colors.red)
    static let appBlack = Color(hex: Constants.Colors.black)
    static let appGray = Color(hex: Constants.Colors.gray)
    static let appGrayBg = Color(hex: Constants.Colors.grayBg)
    static let appYellow = Color(hex: Constants.Colors.yellow)
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - String Extensions
extension String {
    var isValidPhone: Bool {
        let phoneRegex = "^[0-9]{10}$"
        return self.range(of: phoneRegex, options: .regularExpression) != nil
    }
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return self.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    var doubleValue: Double {
        Double(self) ?? 0
    }
    
    var intValue: Int {
        Int(self) ?? 0
    }
}

// MARK: - Double Extensions
extension Double {
    @MainActor
    var currencyString: String {
        let currency = SessionManager.shared.currency
        return "\(currency)\(String(format: "%.2f", self))"
    }
    
    @MainActor
    var currencyStringNoDecimal: String {
        let currency = SessionManager.shared.currency
        if self == floor(self) {
            return "\(currency)\(Int(self))"
        }
        return "\(currency)\(String(format: "%.2f", self))"
    }
}

// MARK: - Image Loading
struct AsyncImageView: View {
    let url: String?
    var placeholder: String = "photo"
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    
    var body: some View {
        if let urlString = url, let imageUrl = URL(string: urlString) {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: width, height: height)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .if(width != nil) { view in
                            view.frame(width: width)
                        }
                        .if(height != nil) { view in
                            view.frame(height: height)
                        }
                        .clipped()
                case .failure:
                    Image(systemName: placeholder)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.appGray)
                        .frame(width: width, height: height)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: placeholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.appGray)
                .frame(width: width, height: height)
        }
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.4), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 300
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let count: Int
    
    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.appPrimary)
                .clipShape(Circle())
                .frame(minWidth: 18)
        }
    }
}
