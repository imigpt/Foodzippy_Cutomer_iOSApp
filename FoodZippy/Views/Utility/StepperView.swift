import SwiftUI

struct StepperView: View {
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 22) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(Color(hex: "#16A34A"))
            }

            Text("\(quantity)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#16A34A"))
                .frame(minWidth: 24)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(Color(hex: "#16A34A"))
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(hex: "#D5D8DE"), lineWidth: 1.2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    StepperView(quantity: 1, onIncrement: {}, onDecrement: {})
        .padding()
}
