import Foundation

struct KeyChainManager {

    static let serverUrl: String = RequestManager.serverUrl

    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    static private func getKeyChainItem () -> [String: Any] {
        var keyChainItem: [String: Any] = [:]
        keyChainItem[kSecClass as String] = kSecClassInternetPassword
        keyChainItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        keyChainItem[kSecAttrServer as String] = serverUrl

        return keyChainItem
    }

    static func saveTokenTokeychain(token: Token) throws {
        var keyChainItem: [String: Any] = getKeyChainItem()

        do {
            // try to update token
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = token.access.data(using: .utf8) as AnyObject?
            attributesToUpdate[kSecAttrDescription as String] = token.refresh.data(using: .utf8) as AnyObject?
            // kSecAttrCreationDate
            // kSecAttrModificationDate
            // kSecAttrLabel = expiration
            // kSecAttrCreator = user

            let status: OSStatus = SecItemUpdate(keyChainItem as CFDictionary, attributesToUpdate as CFDictionary)

            guard status == noErr else {
                print("Error OSStatus ", status)
                throw KeychainError.unhandledError(status:status)
            }
        } catch {
            // add new token
            keyChainItem[kSecValueData as String] = token.access.data(using: .utf8)
            keyChainItem[kSecAttrDescription as String] = token.refresh.data(using: .utf8) as AnyObject?

            let status: OSStatus = SecItemAdd(keyChainItem as CFDictionary, nil)

            guard status == noErr else {
                print("Error OSStatus ", status)
                throw KeychainError.unhandledError(status:status)
            }
        }
    }

    static func getTokenFromKeyChain() throws -> (accessToken: String, refreshToken: String) {

        var keyChainItem: [String:Any] = getKeyChainItem()

        keyChainItem[kSecMatchLimit as String] = kSecMatchLimitOne
        keyChainItem[kSecReturnAttributes as String] = kCFBooleanTrue
        keyChainItem[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(keyChainItem as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.

        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let refreshTokenData = existingItem[kSecAttrDescription as String] as? Data,
            let refreshtoken = String(data: refreshTokenData, encoding: String.Encoding.utf8)

            else {
                throw KeychainError.unexpectedPasswordData
        }

        return (password, refreshtoken)
    }

    static func deleteKeyChain() throws {

        // Delete the existing item from the keychain.
        let query = getKeyChainItem()
        let status = SecItemDelete(query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
