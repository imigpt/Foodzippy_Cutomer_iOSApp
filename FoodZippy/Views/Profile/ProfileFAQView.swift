import SwiftUI

struct ProfileFAQView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var expandedId: UUID?
    @State private var searchText = ""

    private let faqs: [FAQItem] = [
        FAQItem(question: "How do I track my order?", answer: "Go to Orders from your profile and tap any active order to see live tracking details."),
        FAQItem(question: "How can I cancel an order?", answer: "Open your order details and use Cancel Order if cancellation is available for that order status."),
        FAQItem(question: "How do I add or update my saved address?", answer: "In Profile, tap Saved Address and add a new address or edit your existing address."),
        FAQItem(question: "How do I use vouchers or promo codes?", answer: "Apply your voucher/promo code on the checkout screen before placing the order."),
        FAQItem(question: "When will I get my refund?", answer: "Refund timelines depend on payment mode. Most refunds are processed within 3-7 business days."),
        FAQItem(question: "How can I contact support?", answer: "Use the Help/Support option from the app menu and share your issue with order details."),
        FAQItem(question: "How do I register as a restaurant partner?", answer: "From Profile, tap Registered as Restaurant. You will be redirected to the registration page in browser.")
    ]

    private var filteredFaqs: [FAQItem] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return faqs
        }
        return faqs.filter {
            $0.question.localizedCaseInsensitiveContains(searchText) ||
            $0.answer.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.appGrayBg
                    .ignoresSafeArea()
    
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Color.clear
                            .frame(height: 42 + geo.safeAreaInsets.top)
    
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How can we help you?")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
    
                            Text("Find quick answers for common questions")
                                .font(.subheadline)
                                .foregroundColor(.gray)
    
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
    
                                TextField("Search FAQs", text: $searchText)
                                    .font(.subheadline)
                                    .textInputAutocapitalization(.never)
                            }
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
    
                        VStack(spacing: 10) {
                            ForEach(filteredFaqs) { item in
                                FAQAccordionRow(
                                    item: item,
                                    isExpanded: expandedId == item.id,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            expandedId = (expandedId == item.id) ? nil : item.id
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
    
                        if filteredFaqs.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "questionmark.circle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                                Text("No FAQ found")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 24)
                        }
    
                        Spacer(minLength: 30)
                    }
                    .padding(.bottom, 24)
                }
                .ignoresSafeArea(edges: .top)
    
                VStack {
                    HStack(spacing: 12) {
                        Button {
                            appState.hideMainTabBar = false
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 2)
                        }
    
                        Text("FAQ")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
    
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, geo.safeAreaInsets.top + 8)
    
                    Spacer()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            appState.hideMainTabBar = true
        }
    }
}

private struct FAQAccordionRow: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Text(item.question)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }

                if isExpanded {
                    Text(item.answer)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}
