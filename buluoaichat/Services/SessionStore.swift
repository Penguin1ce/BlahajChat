//
//  SessionStore.swift
//  buluaichat
//

import Foundation
import Security

@MainActor
protocol SessionStore: AnyObject {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    func clear()
}

final class KeychainSessionStore: SessionStore {
    private enum Key {
        static let refreshToken = "refresh_token"
    }

    private let service = "com.hinapi.buluaichat.session"
    private let userDefaults = UserDefaults.standard

    var accessToken: String?

    var refreshToken: String? {
        get {
            readKeychainValue(for: Key.refreshToken) ?? userDefaults.string(forKey: Key.refreshToken)
        }
        set {
            if let newValue {
                saveKeychainValue(newValue, for: Key.refreshToken)
                userDefaults.set(newValue, forKey: Key.refreshToken)
            } else {
                deleteKeychainValue(for: Key.refreshToken)
                userDefaults.removeObject(forKey: Key.refreshToken)
            }
        }
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
    }

    private func saveKeychainValue(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        deleteKeychainValue(for: key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func readKeychainValue(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteKeychainValue(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
