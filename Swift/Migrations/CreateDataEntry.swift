//
//  CreateDataEntry.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Fluent

struct CreateDataEntry: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("data_entries")
            .id()
            .field("user_id", .uuid, .required)
            .field("department", .string, .required)
            .field("sub_department", .string, .required)
            .field("date", .string, .required)
            .field("time_of_check", .string, .required)
            .field("quantity", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("data_entries").delete()
    }
} 
