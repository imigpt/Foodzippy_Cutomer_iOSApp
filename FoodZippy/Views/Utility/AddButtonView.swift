import SwiftUI

struct AddButtonView: View {
    let title: String
    let subtitle: String?
    let action: () -> Void

    init(
        title: String = "ADD",
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 6) {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#16A34A"))
                    .frame(minWidth: 118)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(hex: "#16A34A").opacity(0.32), lineWidth: 1.2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    AddButtonView(subtitle: "Customisable") {}
        .padding()
}
