//
//  GlobalCommandsController.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Vapor
import FluentSQLiteDriver
import Lingo
import LingoVapor
import SwiftTelegramBot

/// Controller for global commands (/help, /settings, /buttons)
final class GlobalCommandsController: @unchecked Sendable {

    let bot: TGBot
    let db: any Database
    let lingoVapor: LingoProvider

    init(bot: TGBot, db: any Database, lingoVapor: LingoProvider) {
        self.bot = bot
        self.db = db
        self.lingoVapor = lingoVapor
    }

    // MARK: - Registration

    /// Register all global command handlers with the dispatcher
    func registerHandlers(dispatcher: TGDefaultDispatcher) async {
        await dispatcher.add(TGCommandHandler(commands: ["/help"]) { update in
            try await self.handleHelp(update: update)
        })

        await dispatcher.add(TGCommandHandler(commands: ["/settings"]) { [weak self] update in
            try await self?.handleSettings(update: update)
        })

        await dispatcher.add(TGCommandHandler(commands: ["/buttons"]) { [weak self] update in
            try await self?.handleButtons(update: update)
        })
    }

    // MARK: - Command Handlers

    private func handleHelp(update: TGUpdate) async throws {
        guard let fromId = update.message?.from ?? update.editedMessage?.from else { return }

        // AUTH: Comment out this block to disable authorization
        guard allowedUsers.contains(fromId.id) else { return }

        let lingo = try lingoVapor.lingo()
        let session = try await User.cachedSession(for: fromId, db: db)

        let helpText = generateHelpText(lingo: lingo, session: session)
        try await bot.sendMessage(session: session, text: helpText, parseMode: .html)
    }

    private func handleSettings(update: TGUpdate) async throws {
        guard let fromId = update.message?.from ?? update.editedMessage?.from else { return }

        // AUTH: Comment out this block to disable authorization
        guard allowedUsers.contains(fromId.id) else { return }

        let lingo = try lingoVapor.lingo()
        let session = try await User.cachedSession(for: fromId, db: db)

        let settingsController = Controllers.settingsController
        try await settingsController.showSettingsMenuLogic(bot: bot, session: session, lingo: lingo)

        // Use partial update for better performance
        try await session.saveAndCache(in: db)
    }

    private func handleButtons(update: TGUpdate) async throws {
        guard let fromId = update.message?.from ?? update.editedMessage?.from else { return }

        // AUTH: Comment out this block to disable authorization
        guard allowedUsers.contains(fromId.id) else { return }

        let session = try await User.cachedSession(for: fromId, db: db)
        let lingo = try lingoVapor.lingo()

        if let controller = Controllers.all.first(where: { $0.routerName == session.routerName }),
           let markup = controller.generateControllerKB(session: session, lingo: lingo) {
            let keyboardRestored = lingo.localize("keyboard.restored", locale: session.locale)
            try await bot.sendMessage(session: session, text: "⌨️ \(keyboardRestored).", replyMarkup: markup)
        }
    }

    // MARK: - Helper Methods

    private func generateHelpText(lingo: Lingo, session: User) -> String {
        
        let welcome = lingo.localize("welcome", locale: session.locale)
        let hereAreTheCommands = lingo.localize("here.are.commands", locale: session.locale)
        let helpMainMenu = lingo.localize("help.main.menu", locale: session.locale)
        let helpShowButtons = lingo.localize("help.show.buttons", locale: session.locale)
        let settingsButtons = lingo.localize("settings.title", locale: session.locale)
        
        let howToUse = lingo.localize("how.to.use", locale: session.locale)
        let howToShowButtons = lingo.localize("how.to.show.buttons", locale: session.locale)
        let howToSettings = lingo.localize("how.to.settings", locale: session.locale)
                    
        let enjoyChatting = lingo.localize("enjoy.chatting", locale: session.locale)
        
        return """
        <b>TGBotSwiftTemplate Help</b>

        \(welcome)!

        \(hereAreTheCommands):

        <b>/start</b> – 📟 \(helpMainMenu)
        <b>/buttons</b> – ⌨️ \(settingsButtons)
        <b>/settings</b> – ⚙️ \(helpShowButtons)

        <b>\(howToUse):</b>
        • \(howToShowButtons).
        • \(howToSettings).

        \(enjoyChatting).
        """
    }
}
