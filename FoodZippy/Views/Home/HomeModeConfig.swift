import SwiftUI

enum HomeTopMode: String, CaseIterable {
    case food = "Food"
    case takeAway = "Take Away"
    case dineIn = "Dine In"
    case driveThru = "Drive-Thru"

    var emoji: String {
        switch self {
        case .food: return "🍔"
        case .takeAway: return "🛍️"
        case .dineIn: return "🍽️"
        case .driveThru: return "🚗"
        }
    }

    var theme: HomeTopModeTheme {
        switch self {
        case .food:
            return HomeTopModeTheme(
                headerStart: Color(hex: "#09041A"),
                headerEnd: Color(hex: "#09041A"),
                tabBackground: Color(hex: "#09041A"),
                activeTab: Color(hex: "#3D13A4"),
                connector: Color(hex: "#3D13A4"),
                promoStart: Color(hex: "#3D13A4"),
                promoEnd: Color(hex: "#3D13A4")
            )
        case .takeAway:
            return HomeTopModeTheme(
                headerStart: Color(hex: "#0A1F33"),
                headerEnd: Color(hex: "#0A1F33"),
                tabBackground: Color(hex: "#0A1F33"),
                activeTab: Color(hex: "#0C8AC5"),
                connector: Color(hex: "#0C8AC5"),
                promoStart: Color(hex: "#0C8AC5"),
                promoEnd: Color(hex: "#0C8AC5")
            )
        case .dineIn:
            return HomeTopModeTheme(
                headerStart: Color(hex: "#29140F"),
                headerEnd: Color(hex: "#29140F"),
                tabBackground: Color(hex: "#29140F"),
                activeTab: Color(hex: "#E26D1F"),
                connector: Color(hex: "#E26D1F"),
                promoStart: Color(hex: "#E26D1F"),
                promoEnd: Color(hex: "#E26D1F")
            )
        case .driveThru:
            return HomeTopModeTheme(
                headerStart: Color(hex: "#0B1E17"),
                headerEnd: Color(hex: "#0B1E17"),
                tabBackground: Color(hex: "#0B1E17"),
                activeTab: Color(hex: "#0B8457"),
                connector: Color(hex: "#0B8457"),
                promoStart: Color(hex: "#0B8457"),
                promoEnd: Color(hex: "#0B8457")
            )
        }
    }

    var promo: HomeTopPromoContent {
        switch self {
        case .food:
            return HomeTopPromoContent(
                bannerLead: "CRAVE",
                bannerTrail: "ATHON",
                ctaText: "ORDER NOW",
                offerLineText: "MIN 150 OFF + ₹100 CASHBACK",
                card1Title: "CRAVING\nMEETS OFFERS",
                card1Top: "MIN",
                card1Main: "₹150",
                card1Sub: "OFF\n+ ₹100 CASHBACK",
                card2Title: "EATRIGHT",
                card2Top: "WIN UP TO",
                card2Main: "₹300",
                card2Sub: "FREE CASH",
                card3Title: "LARGE\nORDERS"
            )
        case .takeAway:
            return HomeTopPromoContent(
                bannerLead: "PICKUP",
                bannerTrail: "SMART",
                ctaText: "PICKUP NOW",
                offerLineText: "EXTRA 20% OFF ON PICKUP ORDERS",
                card1Title: "PICKUP\nPOWER DEALS",
                card1Top: "FLAT",
                card1Main: "20%",
                card1Sub: "EXTRA\nON PICKUP",
                card2Title: "GRAB & GO",
                card2Top: "CASHBACK",
                card2Main: "₹120",
                card2Sub: "ON 3 ORDERS",
                card3Title: "PICKUP\nSPECIAL"
            )
        case .dineIn:
            return HomeTopPromoContent(
                bannerLead: "DINE",
                bannerTrail: "& SAVE",
                ctaText: "BOOK TABLE",
                offerLineText: "TABLE BOOKINGS STARTING AT ₹199",
                card1Title: "DINE-IN\nSPECIALS",
                card1Top: "SAVE",
                card1Main: "₹200",
                card1Sub: "OFF\nON BILL",
                card2Title: "TABLE TREATS",
                card2Top: "FREE",
                card2Main: "DESSERT",
                card2Sub: "ON BOOKINGS",
                card3Title: "DINE-IN\nFAMILY"
            )
        case .driveThru:
            return HomeTopPromoContent(
                bannerLead: "DRIVE",
                bannerTrail: "FAST",
                ctaText: "READY IN 10",
                offerLineText: "QUICK LANE DEALS • READY IN 10 MINS",
                card1Title: "QUICK\nWINDOW DEALS",
                card1Top: "FAST",
                card1Main: "10 MIN",
                card1Sub: "OR\nFREE DRINK",
                card2Title: "SPEED BITE",
                card2Top: "COMBO",
                card2Main: "₹99",
                card2Sub: "MEAL DEAL",
                card3Title: "DRIVE-THRU\nCOMBOS"
            )
        }
    }
}

struct HomeTopModeTheme {
    let headerStart: Color
    let headerEnd: Color
    let tabBackground: Color
    let activeTab: Color
    let connector: Color
    let promoStart: Color
    let promoEnd: Color
}

struct HomeTopPromoContent {
    let bannerLead: String
    let bannerTrail: String
    let ctaText: String
    let offerLineText: String
    let card1Title: String
    let card1Top: String
    let card1Main: String
    let card1Sub: String
    let card2Title: String
    let card2Top: String
    let card2Main: String
    let card2Sub: String
    let card3Title: String
}
