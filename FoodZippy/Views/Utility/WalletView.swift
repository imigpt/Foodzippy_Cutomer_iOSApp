import SwiftUI

struct WalletView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var balance: Double = 0
    @State private var transactions: [WalletTransaction] = []
    @State private var isLoading = true
    
    // Full Screen Cover State
    @State private var showAddMoneySheet = false
    @State private var addAmount = ""
    
    // Custom colors matching the UI
    private let bgColor = Color(red: 0.96, green: 0.96, blue: 0.97)
    private let cardGradientStart = Color(red: 0.35, green: 0.74, blue: 0.45)
    private let cardGradientEnd = Color(red: 0.17, green: 0.54, blue: 0.44)
    private let buttonGreen = Color(red: 0.14, green: 0.64, blue: 0.43)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. HEADER (Foodzippy Money)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Text("Foodzippy Money")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    // Powered by Razorpay
                    HStack(spacing: 4) {
                        Text("powered by")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Text("Razorpay")
                            .font(.system(size: 12, weight: .black, design: .default))
                            .italic()
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // 2. MAIN BALANCE CARD
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Available Balance")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text("₹\(String(format: "%.0f", balance))")
                                        .font(.system(size: 42, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "banknote.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white.opacity(0.8))
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                            }
                            .padding(.bottom, 24)
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                                .padding(.bottom, 16)
                            
                            Text("Foodzippy money can be used for all your orders across categories (Food, Instamart, Dineout & more)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [cardGradientStart, cardGradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .padding(.horizontal, 16)
                        
                        // 3. TRANSACTIONS LIST
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Transactions")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                            
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 20)
                            } else if transactions.isEmpty {
                                Text("No recent transactions")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 20)
                            } else {
                                ForEach(transactions, id: \.id) { tx in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(tx.message ?? "Transaction")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                            Text(tx.tdate ?? "")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(tx.isCredit ? "+" : "-")₹\(tx.amount)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(tx.isCredit ? buttonGreen : .red)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // Bottom spacing so scroll doesn't hide behind sticky footer
                        Color.clear.frame(height: 100)
                    }
                }
            }
            
            // 4. STICKY BOTTOM FOOTER
            VStack(spacing: 16) {
                Button {
                    addAmount = "" // Reset amount when opening
                    showAddMoneySheet = true
                } label: {
                    Text("Add Balance")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(buttonGreen)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 20)
            .background(
                Color.white
                    .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: -5)
            )
        }
        .navigationBarHidden(true) // Hides default iOS nav bar
        // 🔥 FULL SCREEN COVER FOR ADD MONEY 🔥
        .fullScreenCover(isPresented: $showAddMoneySheet) {
            AddMoneySheet(
                balance: balance,
                amount: $addAmount,
                onAdd: {
                    Task { await addMoney() }
                }
            )
        }
        .task {
            await loadWallet()
        }
    }
    
    // MARK: - API Logic
    private func loadWallet() async {
        let uid = SessionManager.shared.currentUser?.id?.stringValue ?? ""
        do {
            let response = try await APIService.shared.getWalletReport(uid: uid)
            balance = Double(response.wallet ?? "0") ?? 0
            transactions = response.walletItems ?? []
        } catch {}
        isLoading = false
    }
    
    private func addMoney() async {
        guard let amount = Double(addAmount), amount > 0 else { return }
        let uid = SessionManager.shared.currentUser?.id?.stringValue ?? ""
        do {
            let transactionId = UUID().uuidString
            let _ = try await APIService.shared.addMoney(uid: uid, amount: addAmount, transactionId: transactionId)
            await loadWallet()
        } catch {}
        addAmount = ""
        showAddMoneySheet = false // Close the full screen when done
    }
}

// MARK: - ADD MONEY FULL SCREEN VIEW
struct AddMoneySheet: View {
    @Environment(\.dismiss) private var dismiss // Used to close the full screen
    
    let balance: Double
    @Binding var amount: String
    var onAdd: () -> Void
    
    let quickAmounts = ["100", "500", "1000", "2000"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // 1. TOP NAV BAR WITH BACK BUTTON
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(8)
                }
                Spacer()
            }
            .padding(.top, 8)
            
            // 2. Title & Balance
            VStack(alignment: .leading, spacing: 4) {
                Text("Add money to Foodzippy Money")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Balance: ₹\(String(format: "%.0f", balance))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // 3. Amount Input Field
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("₹")
                        .font(.title2)
                        .foregroundColor(.black)
                        .fontWeight(.medium)
                    
                    TextField("0", text: $amount)
                        .keyboardType(.numberPad)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Divider()
                    .frame(height: 2)
                    .background(Color(red: 0.14, green: 0.64, blue: 0.43)) // Green line
            }
            
            // 4. Quick Amount Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickAmounts, id: \.self) { val in
                        Button(action: {
                            amount = val
                        }) {
                            Text("+ ₹\(val)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.black.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            Spacer()
            
            // 5. Proceed Button
            Button(action: {
                onAdd()
            }) {
                Text("PROCEED TO ADD MONEY")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.45, blue: 0.15), Color(red: 0.90, green: 0.25, blue: 0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
            }
            .disabled(amount.isEmpty || (Double(amount) ?? 0) <= 0)
            .opacity(amount.isEmpty || (Double(amount) ?? 0) <= 0 ? 0.6 : 1.0)
            .padding(.bottom, 16)
            
        }
        .padding(.horizontal, 20)
        .background(Color.white.ignoresSafeArea())
    }
}