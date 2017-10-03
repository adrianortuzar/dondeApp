//
//  RequestManager.swift
//  clientApp
//
//  Created by Adrian on 2/23/17.
//  Copyright © 2017 AdrianOrtuzar. All rights reserved.
//

import Foundation

struct ApiSession {
    let username: String
    let password: String
}

struct RequestManager {
    enum ResponseError: Error {
        case dataEmpty
        case incorrectResponse
        case domain
        case keychain
        case parsingData
        case response(code:Int?, response:URLResponse?, data:Data?)
    }

    static let serverUrl: String = "http://localhost:1337"

    static let urlsession = URLSession.shared

    static private func request(path: String, body: [String:Any]) -> URLRequest {
        var request = URLRequest(url: URL(string:serverUrl + path)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // pass dictionary to nsdata object and set it as request body
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options:.prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        return request
    }

    static private func serverResponse(error: Error?, response: URLResponse?, data: Data?) throws {

        guard error == nil else {
            print(error!)
            throw ResponseError.domain
        }
        guard let data = data else {
            print("Data is empty")
            throw ResponseError.dataEmpty
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("Server status \(httpResponse.statusCode)")

            if  httpResponse.statusCode > 400 {
                throw ResponseError.response(code: httpResponse.statusCode, response: response, data: data)
            }
        } else {
            throw ResponseError.incorrectResponse
        }
    }

    static func logout() {
        do {
            try KeyChainManager.deleteKeyChain()
        } catch {
            print("Error deleting keychain")
        }

    }

    static private func parseLoginResponse (data: Data) throws -> (user: [String:Any], token: [String:Any]) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                throw ResponseError.parsingData
            }

            guard let user: [String:Any] = json["user"] as? [String:Any] else {
                throw ResponseError.parsingData
            }

            guard let usertoken = user["token"] as? [Any] else {
                throw ResponseError.parsingData
            }

            guard let token: [String:Any] = usertoken[0] as? [String:Any]  else {
                throw ResponseError.parsingData
            }

            return (user:user, token:token)
        } catch {
            throw ResponseError.parsingData
        }
    }

    static func login(apiSession: ApiSession,
                      success: @escaping () -> Void,
                      errorCallback: @escaping (_ error: Error) -> Void) {

        let request = self.request(path: "/auth", body: ["email": apiSession.username, "password": apiSession.password])
        let task = urlsession.dataTask(with: request) { data, response, error in

            do {
                try self.serverResponse(error: error, response: response, data: data)

                do {
                    let parseUserToken = try parseLoginResponse(data: data!)

                    do {
                        let tokenModel: Token = try Token(tokenDic: parseUserToken.token)

                        do {
                            try KeyChainManager.saveTokenTokeychain(token: tokenModel)

                            DispatchQueue.main.async { success() }
                        } catch {
                            print("Error saving data in keychain")
                            DispatchQueue.main.async { errorCallback(ResponseError.keychain) }
                        }
                    } catch {
                        print("Error parse token data")
                        DispatchQueue.main.async { errorCallback(ResponseError.parsingData) }
                    }
                } catch {
                    print("Error parse data")
                    DispatchQueue.main.async { errorCallback(ResponseError.parsingData) }
                }
            } catch let error {
                DispatchQueue.main.async { errorCallback(error) }
            }
        }

        task.resume()
    }

    static func createUser(apiSession: ApiSession,
                           success: @escaping () -> Void,
                           errorCallback: @escaping (_ error: Error) -> Void) {

        let request = self.request(path: "/user",
                                   body: ["emailaddress": apiSession.username,
                                          "password": apiSession.password]
        )

        let task = urlsession.dataTask(with: request) { _, _, _ in

            //            let serverResponse = self.serverResponse(error: error, response: response, data: data)
            //
            //            DispatchQueue.main.async(){
            //                if (serverResponse.error != nil) {
            //                    let json = try! JSONSerialization.jsonObject(with: data!, options: [])
            //                    print(json)
            //                    success()
            //                }else{
            //                    errorCallback(serverResponse.error!)
            //                }
            //            }
        }

        task.resume()
    }
}
