// User.swift
// User model matching Android User.java / UserDetails.java

import Foundation

struct User: Codable, Identifiable {
    let id: AnyCodableValue?
    let name: String?
    let mobile: String?
    let email: String?
    let ccode: AnyCodableValue?
    let password: String?
    let code: AnyCodableValue?
    let wallet: AnyCodableValue?
    let rdate: String?
    let refercode: AnyCodableValue?
    let status: AnyCodableValue?
    let isVerify: AnyCodableValue?
    
    enum CodingKeys: String, CodingKey {
        case id, name, mobile, email, ccode, password, code, wallet, rdate, refercode, status
        case isVerify = "is_verify"
    }
}

struct LoginResponse: Codable {
    let responseCode: AnyCodableValue?
    let responseMsg: String?
    let result: AnyCodableValue?
    let userLogin: User?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case userLogin = "UserLogin"
    }
    
    var isSuccess: Bool {
        let code = responseCode?.stringValue ?? ""
        let res = result?.stringValue ?? ""
        return (code == "200" || code == "1") && (res == "true" || res == "1" || res == "Success")
    }
}

struct CountryCodeItem: Codable, Identifiable {
    let id: String?
    let ccode: String?
    let status: String?
}

struct CountryCodeResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let countryCode: [CountryCodeItem]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case countryCode = "CountryCode"
    }
}

struct MobileCheckResponse: Codable {
    let responseCode: AnyCodableValue?
    let responseMsg: String?
    let result: AnyCodableValue?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
    }
    
    var isSuccess: Bool {
        let code = responseCode?.stringValue ?? ""
        let res = result?.stringValue ?? ""
        return (code == "200" || code == "1") && (res == "true" || res == "1" || res == "Success")
    }
}

struct ProfileResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let userData: User?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case userData = "UserData"
    }
}

// MARK: - AnyCodableValue for flexible JSON types
enum AnyCodableValue: Codable, Equatable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let val = try? container.decode(String.self) {
            self = .string(val)
        } else if let val = try? container.decode(Int.self) {
            self = .int(val)
        } else if let val = try? container.decode(Double.self) {
            self = .double(val)
        } else if let val = try? container.decode(Bool.self) {
            self = .bool(val)
        } else {
            self = .null
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let val): try container.encode(val)
        case .int(let val): try container.encode(val)
        case .double(let val): try container.encode(val)
        case .bool(let val): try container.encode(val)
        case .null: try container.encodeNil()
        }
    }
    
    var stringValue: String? {
        switch self {
        case .string(let val): return val
        case .int(let val): return String(val)
        case .double(let val): return String(val)
        default: return nil
        }
    }
}
