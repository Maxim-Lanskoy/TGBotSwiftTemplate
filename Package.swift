//  swift-tools-version: 6.1
//
//  Package.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import PackageDescription

let package = Package(
    name: "TGBotSwiftTemplate",
    platforms: [
       .macOS(.v14)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.12.0"),
        // 🪶 Fluent driver for SQLite.
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.8.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.83.0"),
        // ✈ A Swift wrapper for the Telegram API.
        .package(url: "https://github.com/nerzh/swift-telegram-sdk", from: "3.9.4"),
        // 🔑 A dotenv library for Swift.
        .package(url: "https://github.com/thebarndog/swift-dotenv.git", from: "2.1.0"),
        // 🗺️ Lingo-Vapor: A Swift package for language processing.
        .package(url: "https://github.com/vapor-community/Lingo-Vapor.git", from: "4.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "TGBotSwiftTemplate",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "SwiftTelegramSdk", package: "swift-telegram-sdk"),
                .product(name: "SwiftDotenv", package: "swift-dotenv"),
                .product(name: "LingoVapor", package: "Lingo-Vapor")
            ],
            path: "Swift", swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
