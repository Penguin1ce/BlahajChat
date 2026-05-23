//
//  ChatWebSocketClient.swift
//  buluaichat
//

import Combine
import Foundation

enum ChatSocketEvent {
    case connected
    case disconnected(String?)
    case ack(WSAckOKData)
    case message(WSMessageData)
    case error(WSErrorData)
    case pong
}

struct WSFrame<Data: Codable>: Codable {
    let op: String
    let seq: UInt64?
    let data: Data?
}

struct RawWSFrame: Decodable {
    let op: String
    let seq: UInt64?
    let data: JSONValue?
}

struct WSSendData: Codable {
    let clientMsgId: String
    let convId: String
    let type: String
    let content: JSONValue
    let replyTo: String?
    let mentions: [UInt64]?
}

struct WSReadData: Codable {
    let convId: String
    let msgId: String
}

struct WSAckOKData: Decodable {
    let msgId: String
    let clientMsgId: String
    let convId: String
    let ts: Int64
}

struct WSMessageData: Decodable {
    let msgId: String
    let convId: String
    let fromUid: UInt64
    let type: String
    let content: JSONValue
    let mentions: [UInt64]?
    let createdAt: Int64

    var displayText: String {
        switch type {
        case "text":
            return content["text"]?.stringValue ?? ""
        case "image":
            return "[图片]"
        case "file":
            return content["name"]?.stringValue.map { "[文件] \($0)" } ?? "[文件]"
        case "audio":
            return "[语音]"
        default:
            return "[消息]"
        }
    }
}

struct WSErrorData: Decodable {
    let code: String
    let message: String
}

final class ChatWebSocketClient {
    let events = PassthroughSubject<ChatSocketEvent, Never>()

    private let environment: APIEnvironment
    private let urlSession: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var task: URLSessionWebSocketTask?
    private var seq: UInt64 = 0

    init(environment: APIEnvironment = .current, urlSession: URLSession = .shared) {
        self.environment = environment
        self.urlSession = urlSession
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func connect(accessToken: String) {
        disconnect()
        guard let url = environment.webSocketLoginURL(accessToken: accessToken) else {
            events.send(.disconnected("实时连接地址无效"))
            return
        }
        let task = urlSession.webSocketTask(with: url)
        self.task = task
        task.resume()
        events.send(.connected)
        receive()
    }

    func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
    }

    func sendText(_ text: String, conversationID: String, clientMessageID: String) {
        let payload = WSSendData(
            clientMsgId: clientMessageID,
            convId: conversationID,
            type: "text",
            content: .object(["text": .string(text)]),
            replyTo: nil,
            mentions: nil
        )
        send(op: "send", data: payload)
    }

    func markRead(conversationID: String, msgID: String) {
        send(op: "read", data: WSReadData(convId: conversationID, msgId: msgID))
    }

    func ping() {
        send(op: "ping", data: APIEmptySocketData())
    }

    private func receive() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                self.handle(message)
                self.receive()
            case .failure(let error):
                self.events.send(.disconnected(error.localizedDescription))
            }
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        let data: Data?
        switch message {
        case .string(let text):
            data = text.data(using: .utf8)
        case .data(let rawData):
            data = rawData
        @unknown default:
            data = nil
        }

        guard let data, let frame = try? decoder.decode(RawWSFrame.self, from: data) else { return }

        switch frame.op {
        case "ackok":
            decodePayload(frame, as: WSAckOKData.self).map { events.send(.ack($0)) }
        case "msg":
            decodePayload(frame, as: WSMessageData.self).map { events.send(.message($0)) }
        case "error":
            decodePayload(frame, as: WSErrorData.self).map { events.send(.error($0)) }
        case "pong":
            events.send(.pong)
        default:
            break
        }
    }

    private func decodePayload<T: Decodable>(_ frame: RawWSFrame, as type: T.Type) -> T? {
        guard let payload = frame.data,
              let data = try? encoder.encode(payload) else {
            return nil
        }
        return try? decoder.decode(type, from: data)
    }

    private func send<T: Codable>(op: String, data: T?) {
        guard let task else {
            events.send(.disconnected("实时连接尚未建立"))
            return
        }
        seq += 1
        let frame = WSFrame(op: op, seq: seq, data: data)
        guard let payload = try? encoder.encode(frame),
              let text = String(data: payload, encoding: .utf8) else {
            return
        }
        task.send(.string(text)) { [weak self] error in
            if let error {
                self?.events.send(.error(WSErrorData(code: "send_failed", message: error.localizedDescription)))
            }
        }
    }
}

private struct APIEmptySocketData: Codable {}
