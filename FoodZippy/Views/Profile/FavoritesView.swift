import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var showMenu = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    FavoritesHeaderView()
                    
                    // Filter & Sort Bar
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Text("Filter")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Text("Sort By")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    
                    // List of Restaurants
                    VStack(spacing: 16) {
                        FavoriteRestaurantRow()
                        // Duplicate for demo
                        FavoriteRestaurantRow()
                    }
                    .padding()
                }
            }
            
            // Back Button Overlay
            VStack {
                HStack {
                    Button(action: {
                        appState.hideMainTabBar = false
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
                .padding(.top, 50)
                Spacer()
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            appState.hideMainTabBar = true
        }
    }
}

struct FavoritesHeaderView: View {
    var body: some View {
        ZStack {
            // Orange Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "FFAE34"), Color(hex: "FF9500")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative Food Images (positioned absolutely)
            VStack {
                HStack {
                    Spacer()
                    Image("favourites")
                        .resizable()
                        .frame(width: 200, height: 280)
                        //.opacity(0.7)
                }
                Spacer()
            }
           // .ignoresSafeArea()
            
            // Text Content
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text("We know\nyou love it!")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.white)
                    .lineSpacing(0)
                
                Text("Browse your favourite restaurants\n& feast like never before.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .padding(.bottom, 24)
        }
        .frame(height: 280)
    }
}

struct FavoriteRestaurantRow: View {
    @State private var isFavorited = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left Image Section
            ZStack(alignment: .bottomLeading) {
                // Burger Image
                Image("burger")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Favorite Heart Badge (top right) - Clickable
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isFavorited.toggle()
                        }) {
                            Image(systemName: isFavorited ? "heart.fill" : "heart")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 3)
                        }
                    }
                    Spacer()
                }
                .padding(8)
                
                // Bottom Text Banner
                VStack(spacing: 0) {
                    Text("ITEMS")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                    Text("AT ₹84")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 140, height: 160)
            
            // Right Text Section
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Burger Farm")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Menu {
                        Button(role: .destructive) {
                            isFavorited = false
                        } label: {
                            Label("Unfavourite", systemImage: "heart.slash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 8, weight: .bold))
                        .padding(4)
                        .background(Color.green)
                        .clipShape(Circle())
                    
                    Text("4.5 (8.1K+) • 35-40 mins")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black.opacity(0.8))
                }
                
                Text("American, Italian, Italian-...")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Text("Jagatpura • 0.9 km")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.top, 8)
            .padding(.trailing, 8)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
