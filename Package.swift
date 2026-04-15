// swift-tools-version: 5.9
// Package.swift - FoodZippy iOS Dependencies
// Note: This file documents the SPM dependencies to add in Xcode.
// When creating the Xcode project, add these packages via:
// File > Add Package Dependencies...

import PackageDescription

let package = Package(
    name: "FoodZippy",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FoodZippy",
            targets: ["FoodZippy"]),
    ],
    dependencies: [
        // Firebase SDK
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        
        // Kingfisher for async image loading (optional, app uses native AsyncImage)
        // .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        
        // Lottie for animations (optional)
        // .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "FoodZippy",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDynamicLinks", package: "firebase-ios-sdk"),
            ],
            path: "FoodZippy"),
    ]
)
