import SwiftUI

struct OffersView: View {
    @State private var offers: [OfferDetail] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading offers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if offers.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tag")
                        .font(.system(size: 38))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No offers available")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(offers) { offer in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(offer.title ?? "Offer")
                            .font(.headline)
                        if let text = offer.offerText, !text.isEmpty {
                            Text(text)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Offers")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                let response = try await APIService.shared.getOfferList()
                offers = response.offerData ?? []
            } catch {
                offers = []
            }
            isLoading = false
        }
    }
}

struct WalletActivationView: View {
    @State private var govId = ""
    @State private var govType = "PAN"
    @State private var isLoading = false
    @State private var message = ""
    @State private var showMessage = false

    private let types = ["PAN", "Passport", "Aadhaar", "Driving Licence"]

    var body: some View {
        Form {
            Section("Verification") {
                Picker("Government ID Type", selection: $govType) {
                    ForEach(types, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }

                TextField("Government ID Number", text: $govId)
                    .textInputAutocapitalization(.characters)
            }

            Section {
                Button {
                    Task { await activateWallet() }
                } label: {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Activate Wallet")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isLoading || govId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Activate Wallet")
        .alert("Wallet", isPresented: $showMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message)
        }
    }

    private func activateWallet() async {
        guard let uid = SessionManager.shared.currentUser?.id, !uid.isEmpty else {
            message = "Please login first"
            showMessage = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await APIService.shared.activateWallet(uid: uid, govId: govId, govType: govType)
            message = response.responseMsg ?? "Wallet request submitted"
        } catch {
            message = error.localizedDescription
        }
        showMessage = true
    }
}

struct RewardsOtpView: View {
    enum RewardsType: String, CaseIterable {
        case student = "Student Rewards"
        case corporate = "Corporate Rewards"
    }

    @State private var rewardsType: RewardsType
    @State private var email = ""
    @State private var otp = ""
    @State private var otpSent = false
    @State private var isLoading = false
    @State private var message = ""
    @State private var showMessage = false

    init(defaultType: RewardsType = .student) {
        _rewardsType = State(initialValue: defaultType)
    }

    var body: some View {
        Form {
            Section("Program") {
                Picker("Rewards Program", selection: $rewardsType) {
                    ForEach(RewardsType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Email") {
                TextField("Work/Student Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                Button("Send OTP") {
                    Task { await sendOtp() }
                }
                .disabled(isLoading || !email.isValidEmail)
            }

            if otpSent {
                Section("Verify OTP") {
                    TextField("Enter OTP", text: $otp)
                        .keyboardType(.numberPad)

                    Button("Verify OTP") {
                        Task { await verifyOtp() }
                    }
                    .disabled(isLoading || otp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .navigationTitle(rewardsType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Rewards", isPresented: $showMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message)
        }
    }

    private func sendOtp() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response: GenericResponse
            switch rewardsType {
            case .student:
                response = try await APIService.shared.sendStudentOtp(email: email)
            case .corporate:
                response = try await APIService.shared.sendCorporateOtp(email: email)
            }
            otpSent = response.isSuccess
            message = response.responseMsg ?? (response.isSuccess ? "OTP sent" : "Failed to send OTP")
        } catch {
            message = error.localizedDescription
        }
        showMessage = true
    }

    private func verifyOtp() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response: GenericResponse
            switch rewardsType {
            case .student:
                response = try await APIService.shared.verifyStudentOtp(email: email, otp: otp)
            case .corporate:
                response = try await APIService.shared.verifyCorporateOtp(email: email, otp: otp)
            }
            message = response.responseMsg ?? (response.isSuccess ? "Verification successful" : "Verification failed")
        } catch {
            message = error.localizedDescription
        }
        showMessage = true
    }
}

struct LanguageSettingsView: View {
    @State private var selectedLanguage = SessionManager.shared.language

    private let options: [(String, String)] = [
        ("en", "English"),
        ("hi", "Hindi"),
        ("gu", "Gujarati"),
        ("ar", "Arabic")
    ]

    var body: some View {
        List {
            ForEach(options, id: \.0) { code, label in
                Button {
                    selectedLanguage = code
                    SessionManager.shared.language = code
                } label: {
                    HStack {
                        Text(label)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedLanguage == code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}
