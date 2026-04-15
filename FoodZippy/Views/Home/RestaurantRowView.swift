// RestaurantRowView.swift
// Restaurant list item matching Android item_restorent.xml
// 130×160dp card image, green rating badge, offer overlay

import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left: Restaurant Image Card (130×160dp)
            ZStack(alignment: .top) {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: restaurant.restImg ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.15)
                    }
                    .frame(width: 130, height: 160)
                    .clipped()

                    // Offer overlay at bottom
                    if let offerTitle = restaurant.couTitle, !offerTitle.isEmpty {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.65)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 70)

                        VStack(alignment: .leading, spacing: 2) {
                            if let sub = restaurant.couSubtitle, !sub.isEmpty {
                                Text(sub.uppercased())
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 1)
                            }
                            Text(offerTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(width: 130, height: 160)

                // Favorite heart icon top-right
                HStack {
                    Spacer()
                    Image(systemName: restaurant.isFav ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(restaurant.isFav ? .appPrimary : .white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                        .padding(8)
                }
            }
            .frame(width: 130, height: 160)
            .cornerRadius(16)
            .clipped()

            // Right: Restaurant Details
            VStack(alignment: .leading, spacing: 4) {
                // Restaurant Name
                Text(restaurant.restTitle ?? "")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.top, 4)

                // Rating Row
                HStack(spacing: 6) {
                    // Green rating badge
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                        Text(restaurant.restRating ?? "0")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#098430"))
                    .cornerRadius(10)

                    Text("(2.7K+)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#666666"))

                    Text("•")
                        .foregroundColor(Color(hex: "#666666"))
                        .font(.system(size: 12))

                    Text(restaurant.restDeliverytime ?? "")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#666666"))
                }

                // Cuisine / Description
                if let desc = restaurant.restSdesc, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#888888"))
                        .lineLimit(1)
                }

                // Location
                if let location = restaurant.restLandmark ?? restaurant.restFullAddress {
                    HStack(spacing: 3) {
                        let distance = restaurant.restDistance ?? ""
                        Text(location + (distance.isEmpty ? "" : " • \(distance)"))
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#888888"))
                            .lineLimit(1)
                    }
                }

                // Closed indicator
                if !restaurant.isOpen {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 6, height: 6)
                        Text(restaurant.canPreorder ? "Pre-order available" : "Currently closed")
                            .font(.system(size: 11))
                            .foregroundColor(.appPrimary)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .opacity(restaurant.isOpen ? 1.0 : 0.65)
    }
}
