//
//  entrypoint.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Vapor
import Logging
import NIOCore
import NIOPosix

// MARK: - Setting up Vapor Application.
@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = try await Application.make(env)

        do {
            try await configure(app)
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}
