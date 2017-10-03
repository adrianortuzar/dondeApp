//
//  Token.swift
//  clientApp
//
//  Created by Adrian on 2/9/17.
//  Copyright © 2017 AdrianOrtuzar. All rights reserved.
//

import Foundation

struct Token {

    let access: String
    let refresh: String
    let userId: Int
    let createdAt: Date
    let updatedAt: Date
    let expiration: Int

    enum ParseError: Error {
        case wrongKey
    }

    init(tokenDic: [String: Any]) throws {

        guard let accessTokenn = tokenDic["access_token"] as? String else {
            throw ParseError.wrongKey
        }
        self.access = accessTokenn

        guard let refreshToken = tokenDic["refresh_token"] as? String else {
            throw ParseError.wrongKey
        }
        self.refresh =  refreshToken

        guard let userId = tokenDic["user"] as? Int else {
            throw ParseError.wrongKey
        }
        self.userId = userId

        guard let createdAt = tokenDic["createdAt"] as? String else {
            throw ParseError.wrongKey
        }
        self.createdAt = DataManager.shared.stringToDate(createdAt)

        guard let updatedAt = tokenDic["updatedAt"] as? String else {
            throw ParseError.wrongKey
        }
        self.updatedAt = DataManager.shared.stringToDate(updatedAt)

        guard let expiration = tokenDic["expiration"] as? Int else {
            throw ParseError.wrongKey
        }
        self.expiration = expiration
    }
}
