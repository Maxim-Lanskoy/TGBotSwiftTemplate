//
//  BotService.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Vapor
import SwiftTelegramBot

extension Vapor.Application {
    private struct TGServiceServiceKey: StorageKey {
        typealias Value = TGBot
    }

    public var bot: TGBot {
        get {
            guard let service = storage[TGServiceServiceKey.self] else {
                fatalError("TGBot not configured. Use app.bot = ...")
            }
            return service
        }
        set {
            storage[TGServiceServiceKey.self] = newValue
        }
    }
}
