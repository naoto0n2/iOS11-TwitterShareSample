//
//  TwitterUserResponse.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/06.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import Foundation
import Himotoki

struct TwitterUserResponse {
    let users: [TwitterUser]
}

extension TwitterUserResponse: Himotoki.Decodable {
    static func decode(_ e: Extractor) throws -> TwitterUserResponse {
        let users: [TwitterUser] = try decodeArray(e.rawValue)
        return TwitterUserResponse(users: users)
    }
}
