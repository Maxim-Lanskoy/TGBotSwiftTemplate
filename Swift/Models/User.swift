//
//  User.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Vapor
import Fluent
import Foundation
@preconcurrency import SwiftTelegramSdk

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final public class User: Model, @unchecked Sendable {
    public static let schema = "users"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "telegram_id")
    var telegramId: Int64

    @Field(key: "router_name")
    var routerName: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Field(key: "user_name")
    var userName: String?
    
    @Field(key: "first_name")
    var firstName: String?
    
    @Field(key: "last_name")
    var lastName: String?
    
    @Field(key: "locale")
    var locale: String
        
    var name: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else if let lastName = lastName {
            return lastName
        } else if let userName = userName {
            return userName
        } else {
            return "🧑‍💻 User"
        }
    }

    public init() {}

    init(id: UUID? = nil, telegramId: Int64, locale: String, userName: String? = nil, firstName: String? = nil, lastName: String? = nil) {
        self.id = id
        self.telegramId = telegramId
        self.routerName = "registration"
        self.userName = userName
        self.firstName = firstName
        self.lastName = lastName
        self.locale = locale
        self.createdAt = Date()
    }
    
    static func session(for tgUser: TGUser, locale: String = "en", db: any Database) async throws -> User {
        if let found = try await User.query(on: db).filter(\.$telegramId, .equal, tgUser.id).first() {
            return found
        } else {
            let newUser = User(telegramId: tgUser.id, locale: locale, userName: tgUser.username, firstName: tgUser.firstName, lastName: tgUser.lastName)
            try await newUser.save(on: db)
            return newUser
        }
    }
}
