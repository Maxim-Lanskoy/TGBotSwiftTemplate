//
//  routes.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Fluent
import Vapor
@preconcurrency import Lingo
@preconcurrency import SwiftTelegramSdk

// MARK: - Setting up Telegram Routes.
actor RouterStore {
    private var backStore: [String: Router] = [:]
    
    func set(_ router: Router, forKey key: String) {
        backStore[key] = router
    }
    
    func get(_ key: String) -> Router? {
        backStore[key]
    }
    
    func process(key: String, update: TGUpdate, properties: [String: User], db: any Database, lingo: Lingo) async throws {
        guard let router = backStore[key] else { return }
        try await router.process(update: update, properties: properties, db: db, lingo: lingo)
    }
}

// MARK: - Concurrency Safety Fixes.
// Allow passing Router instances across actors safely
extension Router: @unchecked Sendable {}

// MARK: - Setting up Vapor Routes (not needed now).
func routes(_ app: Application) throws {
    // app.get { req async in
    //     "It works!"
    // }
    // app.get("hello") { req async -> String in
    //     "Hello, world!"
    // }
    // try app.register(collection: TodoController())
}
