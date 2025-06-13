//
//  configure.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import FluentSQLiteDriver
import Vapor
import SwiftDotenv
@preconcurrency import SwiftTelegramSdk

let store = RouterStore()

let owner: Int64          = 123456789 // 123456789
let helper: Int64         = 987654321 // 987654321
let allowedUsers: [Int64] = [owner, helper]

let allSupportedLocales   = ["en", "ru-UA"]

// MARK: - Setting up Vapor Application.
public func configure(_ app: Application) async throws {

    let projectPath: String = "/Users/{username}/TGBotSwiftTemplate"
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
    
    let botActor: TGBotActor = .init()
    let tgApi: String = try Env.get("TELEGRAM_BOT_TOKEN")

    // Setting the level of debug
    app.logger.logLevel = .info
    let bot: TGBot = try await .init(connectionType: .longpolling(limit: nil, timeout: nil, allowedUpdates: nil),
                                     dispatcher: nil, tgClient: VaporTGClient(client: app.client),
                                     tgURI: TGBot.standardTGURL, botId: tgApi, log: app.logger)
    await botActor.setBot(bot)
    
    await EverywhereController.addHandlers(bot: botActor.bot, app: app)
    
    await botActor.bot.dispatcher.add(TGBaseHandler({ update in
        let unsafeMessage = update.editedMessage?.from ?? update.message?.from
        guard let entity = unsafeMessage ?? update.callbackQuery?.from else { return }
        let session = try await User.session(for: entity, db: app.db)
        if !allowedUsers.contains(entity.id) {
            print("[TGBotSwiftTemplate] Unauthorized user tried to access: \(entity.id), @\(entity.username ?? "\"No Username\"")")
            let lingo = try? app.lingoVapor.lingo()
            let string = "Sorry, you are not allowed. Your user ID: \(entity.id). Please ask @TGUserName for an invite."
            let text = lingo?.localize("not.allowed.ask.invite", locale: session.locale, interpolations: ["user-id": String(entity.id)]) ?? string
            let chatId = TGChatId.chat(entity.id)
            let params = TGSendMessageParams(chatId: chatId, text: text, parseMode: .html)
            _ = try? await botActor.bot.sendMessage(params: params)
            return
        }
        let props: [String: User] = ["session": session]
        let lingo = try app.lingoVapor.lingo()
        let key = session.routerName
        let db = app.db
        _ = try await store.process(key: key, update: update, properties: props, db: db, lingo: lingo)
    }))
    
    let lingo = try app.lingoVapor.lingo()
    await Controllers.attachAllHandlers(for: bot, lingo: lingo)
    
    try await botActor.bot.start()

    // MARK: - Finish configuration
    
    try routes(app)
    
    // MARK: - Notify admins about starting bot
    for user in allowedUsers {
        let chatId = TGChatId.chat(user)
        let text = "📟 Bot started."
        let message = TGSendMessageParams(chatId: chatId, text: text, disableNotification: true)
        _ = try? await botActor.bot.sendMessage(params: message)
    }
}
