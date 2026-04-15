// Address.swift
// Address model matching Android Address.java, MyAddress.java

import Foundation

struct Address: Codable, Identifiable {
    let id: String?
    let uid: String?
    let hno: String?
    let address: String?
    let latMap: String?
    let longMap: String?
    let landmark: String?
    let type: String?
    let addressImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id, uid, hno, address, landmark, type
        case latMap = "lat_map"
        case longMap = "long_map"
        case addressImage = "address_image"
    }
    
    var latitude: Double { Double(latMap ?? "0") ?? 0 }
    var longitude: Double { Double(longMap ?? "0") ?? 0 }
    
    var fullAddress: String {
        var parts: [String] = []
        if let h = hno, !h.isEmpty { parts.append(h) }
        if let a = address, !a.isEmpty { parts.append(a) }
        if let l = landmark, !l.isEmpty { parts.append(l) }
        return parts.joined(separator: ", ")
    }
    
    var typeIcon: String {
        switch type?.lowercased() {
        case "home": return "house.fill"
        case "work", "office": return "briefcase.fill"
        default: return "mappin.circle.fill"
        }
    }
}

struct AddressListResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    let addressList: [Address]?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
        case addressList = "AddressList"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}

struct AddressAddResponse: Codable {
    let responseCode: String?
    let responseMsg: String?
    let result: String?
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "ResponseCode"
        case responseMsg = "ResponseMsg"
        case result = "Result"
    }
    
    var isSuccess: Bool { responseCode == "200" && result == "true" }
}
