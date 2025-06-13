//
//  TGBotActor.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import SwiftTelegramSdk

// MARK: - Telegram Bot Actor.
public actor TGBotActor {
    private var _bot: TGBot!

    var bot: TGBot {
        self._bot
    }
    
    func setBot(_ bot: TGBot) {
        self._bot = bot
    }
}
