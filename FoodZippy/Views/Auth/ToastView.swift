import SwiftUI

struct ToastView: View {
    let message: String
    var isError: Bool = false
    var onDismiss: (() -> Void)?

    @State private var isVisible: Bool = true

    var body: some View {
        if isVisible {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(isError ? Color.red : Color.green)
                Text(message)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white.opacity(0.9))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isError ? Color.red.opacity(0.9) : Color.black.opacity(0.85))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .center)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                // Auto dismiss after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    dismiss()
                }
            }
        }
    }

    private func dismiss() {
        withAnimation {
            isVisible = false
        }
        onDismiss?()
    }
}

#Preview {
    VStack {
        Spacer()
        ToastView(message: "Sample success message", isError: false, onDismiss: {})
        ToastView(message: "Something went wrong", isError: true, onDismiss: {})
    }
}
