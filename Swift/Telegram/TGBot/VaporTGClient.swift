//
//  VaporTGClient.swift
//  TGBotSwiftTemplate
//
//  Created by Maxim Lanskoy on 13.06.2025.
//

import Foundation
import Vapor
import SwiftTelegramBot

private struct TGEmptyParams: Encodable {}

/// Vapor-based TGClient that uses Vapor's HTTP client instead of URLSession.
/// Integrates better with Vapor's event loop system.
public final class VaporTGClient: TGClientPrtcl, Sendable {

    public typealias HTTPMediaType = SwiftTelegramBot.HTTPMediaType

    private let client: any Vapor.Client
    private let logger: Logger

    public init(client: any Vapor.Client, logger: Logger = .init(label: "VaporTGClient")) {
        self.client = client
        self.logger = logger
    }

    @discardableResult
    public func post<Params: Encodable, Response: Decodable>(
        _ url: URL,
        params: Params? = nil,
        as mediaType: HTTPMediaType? = nil
    ) async throws -> Response {
        var clientRequest = ClientRequest(method: .POST, url: URI(string: url.absoluteString), headers: HTTPHeaders())
        if mediaType == .formData || mediaType == nil {
            let rawMultipart: (body: NSMutableData, boundary: String)
            if let currentParams: Params = params {
                rawMultipart = try currentParams.toMultiPartFormData(log: logger)
            } else {
                rawMultipart = try TGEmptyParams().toMultiPartFormData(log: logger)
            }
            clientRequest.headers.add(name: "Content-Type", value: "multipart/form-data; boundary=\(rawMultipart.boundary)")
            let buffer = ByteBuffer.init(data: rawMultipart.body as Data)
            clientRequest.body = buffer
        } else {
            let vaporMediaType: Vapor.HTTPMediaType = if let mediaType {
                .init(type: mediaType.type, subType: mediaType.subType, parameters: mediaType.parameters)
            } else {
                .json
            }
            try clientRequest.content.encode(params ?? (TGEmptyParams() as! Params), as: vaporMediaType)
        }
        let clientResponse: ClientResponse = try await client.send(clientRequest)
        let telegramContainer = try clientResponse.content.decode(TGTelegramContainer<Response>.self)
        return try processContainer(telegramContainer)
    }

    @discardableResult
    public func post<Response: Decodable>(_ url: URL) async throws -> Response {
        try await post(url, params: TGEmptyParams(), as: nil)
    }

    private func processContainer<T: Decodable>(_ container: TGTelegramContainer<T>) throws -> T {
        guard container.ok else {
            let desc = """
            Response marked as `not Ok`, it seems something wrong with request
            Code: \(container.errorCode ?? -1)
            \(container.description ?? "Empty")
            """
            let error = BotError(type: .server, description: desc)
            logger.error("\(error)")
            throw error
        }

        guard let result = container.result else {
            let error = BotError(
                type: .server,
                reason: "Response marked as `Ok`, but doesn't contain `result` field."
            )
            logger.error("\(error)")
            throw error
        }

        logger.trace("""
        Response:
        Code: \(container.errorCode ?? 0)
        Status OK: \(container.ok)
        Description: \(container.description ?? "Empty")
        """)

        return result
    }
}
