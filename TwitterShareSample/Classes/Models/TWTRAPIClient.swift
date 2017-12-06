//
//  TWTRAPIClient.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/06.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import Foundation
import TwitterKit

extension TWTRAPIClient {

    typealias RequestUserCompletion = (_ result: RequestUserResult) -> Void

    enum RequestUserResult {
        case success([TwitterUser])
        case failure(Error)
    }

    private struct Endpoint {
        static let usersLookup = "https://api.twitter.com/1.1/users/lookup.json"
    }

    func fetchUsers(withUserIDs userIDs: [String], completion: @escaping RequestUserCompletion) {
        let client = TWTRAPIClient()
        let userIDsString = userIDs.joined(separator: ",")
        let params = ["user_id": userIDsString]
        var clientError: NSError?

        let request = client.urlRequest(withMethod: "GET", url: Endpoint.usersLookup, parameters: params, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, connectionError) in
            if let error = connectionError {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.success([]))
                return
            }

            do {
                let response = try JSONDecoder().decode(TwitterUserResponse.self, from: data)
                completion(.success(response.users))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
