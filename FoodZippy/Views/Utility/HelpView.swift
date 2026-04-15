// HelpView.swift
// Matches Android HelpActivity with contact options + FAQ pages

import SwiftUI

struct HelpView: View {
    @State private var helpPages: [HelpPage] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        // Contact Card
                        VStack(spacing: 14) {
                            Image(systemName: "headphones.circle.fill")
                                .font(.system(size: 52))
                                .foregroundColor(Color(hex: "#E23744"))

                            VStack(spacing: 4) {
                                Text("Need Help?")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                Text("We're here to help you with any issues")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }

                            // Contact action buttons
                            HStack(spacing: 14) {
                                ContactButton(
                                    icon: "phone.fill",
                                    label: "Call Us",
                                    color: Color(hex: "#098430")
                                ) {
                                    if let url = URL(string: "tel://18001234567") {
                                        UIApplication.shared.open(url)
                                    }
                                }

                                ContactButton(
                                    icon: "envelope.fill",
                                    label: "Email",
                                    color: Color(hex: "#1976D2")
                                ) {
                                    if let url = URL(string: "mailto:support@foodzippy.com") {
                                        UIApplication.shared.open(url)
                                    }
                                }

                                ContactButton(
                                    icon: "message.fill",
                                    label: "WhatsApp",
                                    color: Color(hex: "#25D366")
                                ) {
                                    if let url = URL(string: "https://wa.me/911800123456") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)

                        // FAQ Pages
                        if !helpPages.isEmpty {
                            HStack {
                                Text("Frequently Asked Questions")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "#888888"))
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            .padding(.top, 4)

                            ForEach(helpPages) { page in
                                HelpPageCard(page: page)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(hex: "#F5F5F5").ignoresSafeArea())
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(hex: "#E23744"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            do {
                let response = try await APIService.shared.getHelpPages()
                helpPages = response.pageList ?? []
            } catch {}
            isLoading = false
        }
    }
}

// MARK: - Contact Button
private struct ContactButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(color)
            .cornerRadius(12)
        }
    }
}

// MARK: - Help Page Card (accordion)
private struct HelpPageCard: View {
    let page: HelpPage
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(page.title ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().padding(.horizontal, 14)
                Text(page.description ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
