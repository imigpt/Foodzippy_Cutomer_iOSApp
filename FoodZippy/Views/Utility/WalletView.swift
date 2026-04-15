// WalletView.swift
// Matches Android MywalletActivity

import SwiftUI

struct WalletView: View {
    @State private var balance: Double = 0
    @State private var transactions: [WalletTransaction] = []
    @State private var isLoading = true
    @State private var showAddMoney = false
    @State private var addAmount = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if (SessionManager.shared.currentUser?.isVerify ?? 0) == 0 {
                NavigationLink {
                    // WalletActivationView()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.appPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Activate your wallet")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.appBlack)
                            Text("Complete verification to unlock full wallet features")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }
                .buttonStyle(.plain)
            }

            // Balance card
            VStack(spacing: 8) {
                Text("Zippy Money")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(SessionManager.shared.currency)\(String(format: "%.2f", balance))")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Available Balance")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Button {
                    showAddMoney = true
                } label: {
                    Text("+ Add Money")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.appAccent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.appAccent, Color.appPrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Transactions
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if transactions.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "wallet.pass")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List(transactions, id: \.id) { tx in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(tx.message ?? "")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(tx.tdate ?? "")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(tx.isCredit ? "+" : "-")\(SessionManager.shared.currency)\(tx.amount)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(tx.isCredit ? .appGreen : .appRed)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Zippy Money")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Add Money", isPresented: $showAddMoney) {
            TextField("Amount", text: $addAmount)
                .keyboardType(.numberPad)
            Button("Add") {
                Task { await addMoney() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .task {
            await loadWallet()
        }
    }
    
    private func loadWallet() async {
        let uid = SessionManager.shared.currentUser?.id ?? ""
        do {
            let response = try await APIService.shared.getWalletReport(uid: uid)
            balance = Double(response.wallet ?? "0") ?? 0
            transactions = response.walletItems ?? []
        } catch {}
        isLoading = false
    }
    
    private func addMoney() async {
        guard let amount = Double(addAmount), amount > 0 else { return }
        let uid = SessionManager.shared.currentUser?.id ?? ""
        do {
            let transactionId = UUID().uuidString
            let _ = try await APIService.shared.addMoney(uid: uid, amount: addAmount, transactionId: transactionId)
            await loadWallet()
        } catch {}
        addAmount = ""
    }
}
