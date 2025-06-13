//
//  Helpers.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Vapor
import SwiftDotenv

// MARK: - Universal Environment Variable Helper.
public final class Env {
    public static func get(_ key: String) throws -> String {
        if let value = Environment.get(key) ?? Dotenv[key]?.stringValue {
            return value
        } else {
            throw Abort(.internalServerError, reason: "Environment variable \(key) not set.")
        }
    }
}
