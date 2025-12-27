//
//  configure.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import FluentSQLiteDriver
import Vapor
import SwiftDotenv
import SwiftTelegramBot

let store = RouterStore()

let owner: Int64          = 123456789 // 123456789
let helper: Int64         = 987654321 // 987654321
let allowedUsers: [Int64] = [owner, helper]

// MARK: - Localization
public enum SupportedLocale: String, CaseIterable, Codable, Sendable {
    case en = "en"
    case ua = "uk"

    func flag() -> String {
        switch self {
        case .en: return "🇬🇧"
        case .ua: return "🇺🇦"
        }
    }
}

// MARK: - Setting up Vapor Application.
public func configure(_ app: Application) async throws {

    let projectPath: String = "/Users/maximlanskoy/TGBotSwiftTemplate"
    app.directory = DirectoryConfiguration(workingDirectory: projectPath)
    try Dotenv.configure(atPath: "\(projectPath)/.env", overwrite: false)
    app.lingoVapor.configuration = .init(defaultLocale: "en")
    
    // MARK: - Vapor.
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("\(projectPath)/SQLite/TGBotSwiftTemplateDB.sqlite")), as: .sqlite)
    // app.databases.use(.sqlite(.memory), as: .sqlite)

    app.migrations.add(CreateUser())
    
    try await app.autoMigrate()
    
    // MARK: - Telegram.
    
    // MARK: - Telegram Bot Setup
    let tgApi: String = try Env.get("TELEGRAM_BOT_TOKEN")

    // Create bot with Vapor's HTTP client
    app.bot = try await .init(
        connectionType: .longpolling(),
        tgClient: VaporTGClient(client: app.client, logger: app.logger),
        tgURI: TGBot.standardTGURL,
        botId: tgApi,
        log: app.logger
    )

    // Create and add unified dispatcher (auth + global commands + routing)
    let dispatcher = TGDispatcher(bot: app.bot, app: app)
    try await app.bot.add(dispatcher: dispatcher)

    // Attach controller-specific handlers
    let lingo = try app.lingoVapor.lingo()
    await Controllers.attachAllHandlers(for: app.bot, lingo: lingo)

    // Start the bot
    try await app.bot.start()

    // MARK: - Finish configuration
    
    try routes(app)
    
    // MARK: - Notify admins about starting bot
    for user in allowedUsers {
        let chatId = TGChatId.chat(user)
        let text = "📟 Bot started."
        let params = TGSendMessageParams(chatId: chatId, text: text, disableNotification: true)
        _ = try? await app.bot.sendMessage(params: params)
    }
}
