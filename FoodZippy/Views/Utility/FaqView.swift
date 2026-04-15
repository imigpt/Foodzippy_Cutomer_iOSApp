// FaqView.swift
// Matches Android FaqActivity

import SwiftUI

struct FaqView: View {
    @State private var faqs: [FaqItem] = []
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if faqs.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No FAQs available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List {
                    ForEach(faqs, id: \.id) { faq in
                        DisclosureGroup {
                            Text(faq.answer ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.vertical, 4)
                        } label: {
                            Text(faq.question ?? "")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                let response = try await APIService.shared.getFaq()
                faqs = response.faqData ?? []
            } catch {}
            isLoading = false
        }
    }
}
