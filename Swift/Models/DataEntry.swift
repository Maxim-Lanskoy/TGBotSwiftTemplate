//
//  DataEntry.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Vapor
import Fluent
import Foundation

/// Model to store data entries from users
final public class DataEntry: Model, @unchecked Sendable {
    public static let schema = "data_entries"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "user_id")
    var userId: UUID

    @OptionalField(key: "department")
    var department: String?

    @OptionalField(key: "sub_department")
    var subDepartment: String?

    @OptionalField(key: "date")
    var date: String?

    @OptionalField(key: "time_of_check")
    var timeOfCheck: String?

    @OptionalField(key: "quantity")
    var quantity: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    public init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        department: String?,
        subDepartment: String?,
        date: String?,
        timeOfCheck: String?,
        quantity: String?
    ) {
        self.id = id
        self.userId = userId
        self.department = department
        self.subDepartment = subDepartment
        self.date = date
        self.timeOfCheck = timeOfCheck
        self.quantity = quantity
    }

    /// Get all entries for a user on a specific date
    static func getEntries(for userId: UUID, date: String, db: any Database) async throws -> [DataEntry] {
        return try await DataEntry.query(on: db)
            .filter(\.$userId, .equal, userId)
            .filter(\.$date, .equal, date)
            .all()
    }

    /// Get all entries for a user by fromId (Int64) on a specific date
    static func getEntries(for fromId: Int64, date: String, db: any Database) async throws -> [DataEntry] {
        // First find the user session by fromId
        let user = try await User.query(on: db)
            .filter(\.$telegramId, .equal, fromId)
            .first()
        
        guard let userId = user?.id else {
            return []
        }
        
        return try await DataEntry.query(on: db)
            .filter(\.$userId, .equal, userId)
            .filter(\.$date, .equal, date)
            .all()
    }
} 
