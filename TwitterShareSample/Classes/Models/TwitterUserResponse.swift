//
//  TwitterUserResponse.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/06.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import Foundation

struct TwitterUserResponse: Codable {
    let users: [TwitterUser]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var users: [TwitterUser] = []
        while !container.isAtEnd {
            let user = try container.decode(TwitterUser.self)
            users.append(user)
        }

        self.users = users
    }
}
