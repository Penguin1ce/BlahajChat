//
//  APIError.swift
//  buluaichat
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case missingToken
    case unauthorized(String)
    case server(code: Int, message: String)
    case transport(String)
    case emptyData
    case decoding(String)

    var errorDescription: String? {
        userFacingMessage
    }

    var userFacingMessage: String {
        switch self {
        case .invalidURL:
            return "接口地址无效"
        case .missingToken:
            return "登录状态已失效"
        case .unauthorized(let message):
            return message.isEmpty ? "登录已过期，请重新登录" : message
        case .server(_, let message):
            return message
        case .transport(let message):
            return message
        case .emptyData:
            return "服务器没有返回数据"
        case .decoding:
            return "服务器数据格式暂时无法识别"
        }
    }
}

extension Error {
    var userFacingMessage: String {
        if let apiError = self as? APIError {
            return apiError.userFacingMessage
        }
        return localizedDescription
    }
}
