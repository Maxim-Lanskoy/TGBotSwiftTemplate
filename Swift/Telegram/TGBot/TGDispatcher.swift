//
//  TGDispatcher.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Foundation
import Logging
import Fluent
@preconcurrency import SwiftTelegramSdk

actor TGDispatcher: @preconcurrency TGDispatcherPrtcl {
    
    private let db: any Database
    private var log: Logger
    private var handlersId: Int = 0
    private var nextHandlerId: Int {
        handlersId += 1
        return handlersId
    }
    private var index: Int = 0

    public var handlersGroup: [[any TGHandlerPrtcl]] = []
    private var routerHandlers: [String: [any TGHandlerPrtcl]] = [:]
    private var handlersIndex: [Level: [IndexId: Position]] = .init()

    private typealias Level = Int
    private typealias IndexId = Int
    private typealias Position = Int

    public init(log: Logger, db: any Database) async throws {
        self.log = log
        self.db = db
        try await handle()
    }
    
    public func handle() async throws {}

    public func add(_ handler: any TGHandlerPrtcl) async {
        await add(handler, priority: 0)
    }
    
    public func add(_ handler: any TGHandlerPrtcl, priority: Int) async {
        var handler: any TGHandlerPrtcl = handler
        handler.id = nextHandlerId
        var handlerPosition: Int = 0
        let correctLevel: Int = priority >= 0 ? priority : 0
        if handlersGroup.count > correctLevel {
            self.handlersGroup[correctLevel].append(handler)
            handlerPosition = handlersGroup[correctLevel].count - 1
        } else {
            handlersGroup.append([handler])
            handlerPosition = handlersGroup[handlersGroup.count - 1].count - 1
        }
        if handlersIndex[priority] == nil { handlersIndex[priority] = .init() }
        handlersIndex[priority]?[handler.id] = handlerPosition
    }

    public func remove(_ handler: any TGHandlerPrtcl, from priority: Int?) async {
        let priority: Level = priority ?? 0
        let indexId: IndexId = handler.id
        guard
            let index: [IndexId: Position] = handlersIndex[priority],
            let position: Position = index[indexId]
        else {
            return
        }
        let positionIndex = position - 1
        let group = handlersGroup[priority]
        if group.count > positionIndex, group[positionIndex].id == handler.id {
            handlersGroup[priority].remove(at: positionIndex)
            handlersIndex[priority]?.removeValue(forKey: indexId)
        }
    }
    
    public func add(_ handler: any TGHandlerPrtcl, routerName: String) {
        var handler = handler
        handler.id = nextHandlerId
        if routerHandlers[routerName] == nil {
            routerHandlers[routerName] = []
        }
        routerHandlers[routerName]?.append(handler)
    }

    public func remove(_ handler: any TGHandlerPrtcl, from routerName: String) {
        guard var handlers = routerHandlers[routerName] else { return }
        if let idx = handlers.firstIndex(where: { $0.id == handler.id }) {
            handlers.remove(at: idx)
            routerHandlers[routerName] = handlers
        }
    }

    public func process(_ updates: [TGUpdate]) {
        for update in updates {
            Task.detached(priority: .high) { [log] in
                do {
                    try await self.processByHandler(update, db: self.db)
                } catch {
                    log.error("\(BotError(String(describing: error)))")
                }
            }
        }
    }
    
    private func processByHandler(_ update: TGUpdate, db: any Database) async throws {
        log.trace("\(dump(update))")
        // Process priority-based handlers as before
        if handlersGroup.isEmpty { return }
        for i in 1...handlersGroup.count {
            for handler in handlersGroup[handlersGroup.count - i] {
                if handler.check(update: update) {
                    try await handler.handle(update: update)
                }
            }
        }
        // Process routerName handlers
        let message = update.message?.from ?? update.editedMessage?.from
        if let from = message ?? update.callbackQuery?.from {
            let session = try await User.session(for: from, db: db)
            if let handlers = routerHandlers[session.routerName] {
                for handler in handlers {
                    if handler.check(update: update) {
                        try await handler.handle(update: update)
                    }
                }
            }
        }
    }
}
