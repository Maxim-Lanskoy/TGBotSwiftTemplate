//
//  EverywhereController.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Vapor
@preconcurrency import SwiftTelegramSdk

final class EverywhereController {

    static func addHandlers(bot: TGBot, app: Application) async {
        await showSettingsHandler(bot: bot, app: app)
        await showButtonsHandler(bot: bot, app: app)
        await showHelpHandler(bot: bot, app: app)
        // await defaultBaseHandler(bot: bot)
        // await commandPingHandler(bot: bot)
        // await commandShowButtonsHandler(bot: bot)
        // await buttonsActionHandler(bot: bot)
    }
    
    private static func showSettingsHandler(bot: TGBot, app: Application) async {
        await bot.dispatcher.add(TGCommandHandler(commands: ["/settings"]) { update in
            let unsafeMessage = update.message?.from ?? update.editedMessage?.from
            guard let fromId = unsafeMessage else {return }
            let lingo = try app.lingoVapor.lingo()
            let session = try await User.session(for: fromId, db: app.db)
            let settingsController = Controllers.settingsController
            try await settingsController.showSettingsMenuLogic(bot: bot, session: session, lingo: lingo)
            session.routerName = settingsController.routerName
            try await session.save(on: app.db)
        })
    }
    
    private static func showButtonsHandler(bot: TGBot, app: Application) async {
        await bot.dispatcher.add(TGCommandHandler(commands: ["/buttons"]) { update in
            let unsafeMessage = update.message?.from ?? update.editedMessage?.from
            guard let fromId = unsafeMessage else {return }
            let session = try await User.session(for: fromId, db: app.db)
            let lingo = try app.lingoVapor.lingo()
            if let controller = Controllers.all.first(where: { controller in
                return controller.routerName == session.routerName
            }), let markup = controller.generateControllerKB(session: session, lingo: lingo) {
                let lingo = try app.lingoVapor.lingo()
                let keyboardRestored = lingo.localize("keyboard.restored", locale: session.locale)
                try await bot.sendMessage(session: session, text: "⌨️ \(keyboardRestored).", replyMarkup: markup)
            }
        })
    }
    
    private static func showHelpHandler(bot: TGBot, app: Application) async {
        await bot.dispatcher.add(TGCommandHandler(commands: ["/help"]) { update in
            let unsafeMessage = update.message?.from ?? update.editedMessage?.from
            guard let fromId = unsafeMessage else {return }
            let lingo = try app.lingoVapor.lingo()
            let session = try await User.session(for: fromId, db: app.db)
            
            let welcome = lingo.localize("welcome", locale: session.locale)
            let hereAreTheCommands = lingo.localize("here.are.commands", locale: session.locale)
            let helpMainMenu = lingo.localize("help.main.menu", locale: session.locale)
            let helpShowButtons = lingo.localize("help.show.buttons", locale: session.locale)
            let settingsButtons = lingo.localize("settings.title", locale: session.locale)
            
            let howToUse = lingo.localize("how.to.use", locale: session.locale)
            let howToShowButtons = lingo.localize("how.to.show.buttons", locale: session.locale)
            let howToSettings = lingo.localize("how.to.settings", locale: session.locale)
                        
            let enjoyChatting = lingo.localize("enjoy.chatting", locale: session.locale)
            
            let helpText = """
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
            try await bot.sendMessage(session: session, text: helpText, parseMode: .html)
        })
    }

    private static func defaultBaseHandler(bot: TGBot) async {
        await bot.dispatcher.add(TGBaseHandler({ update in
            guard let message = update.message else { return }
            let params: TGSendMessageParams = .init(chatId: .chat(message.chat.id), text: "TGBaseHandler")
            try await bot.sendMessage(params: params)
        }))
    }

    private static func commandPingHandler(bot: TGBot) async {
        await bot.dispatcher.add(TGCommandHandler(commands: ["/ping"]) { update in
            try await update.message?.reply(text: "pong", bot: bot)
        })
    }

    private static func commandShowButtonsHandler(bot: TGBot) async {
        await bot.dispatcher.add(TGCommandHandler(commands: ["/show_buttons"]) { update in
            guard let userId = update.message?.from?.id else { fatalError("user id not found") }
            let buttons: [[TGInlineKeyboardButton]] = [
                [.init(text: "Button 1", callbackData: "press 1"), .init(text: "Button 2", callbackData: "press 2")]
            ]
            let keyboard: TGInlineKeyboardMarkup = .init(inlineKeyboard: buttons)
            let params: TGSendMessageParams = .init(chatId: .chat(userId),
                                                    text: "Keyboard active",
                                                    replyMarkup: .inlineKeyboardMarkup(keyboard))
            try await bot.sendMessage(params: params)
        })
    }

    private static func buttonsActionHandler(bot: TGBot) async {
        await bot.dispatcher.add(TGCallbackQueryHandler(pattern: "press 1") { update in
            bot.log.info("press 1")
            guard let userId = update.callbackQuery?.from.id else { fatalError("user id not found") }
            let params: TGAnswerCallbackQueryParams = .init(callbackQueryId: update.callbackQuery?.id ?? "0",
                                                            text: update.callbackQuery?.data  ?? "data not exist",
                                                            showAlert: nil,
                                                            url: nil,
                                                            cacheTime: nil)
            try await bot.answerCallbackQuery(params: params)
            try await bot.sendMessage(params: .init(chatId: .chat(userId), text: "press 1"))
        })
        
        await bot.dispatcher.add(TGCallbackQueryHandler(pattern: "press 2") { update in
            bot.log.info("press 2")
            guard let userId = update.callbackQuery?.from.id else { fatalError("user id not found") }
            let params: TGAnswerCallbackQueryParams = .init(callbackQueryId: update.callbackQuery?.id ?? "0",
                                                            text: update.callbackQuery?.data  ?? "data not exist",
                                                            showAlert: nil,
                                                            url: nil,
                                                            cacheTime: nil)
            try await bot.answerCallbackQuery(params: params)
            try await bot.sendMessage(params: .init(chatId: .chat(userId), text: "press 2"))
        })
    }
}
