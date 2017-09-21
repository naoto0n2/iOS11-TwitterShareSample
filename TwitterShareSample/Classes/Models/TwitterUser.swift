//
//  TwitterUser.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/06.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import Foundation
import Himotoki

struct TwitterUser {
    let id: String
    let name: String
    let screenName: String
    let profileImageURLString: String

    var profileImageURL: URL? {
        return URL(string: self.biggerProfileImageURLString)
    }

    private var biggerProfileImageURLString: String {
        return self.profileImageURLString.replacingOccurrences(of: "_normal.", with: "_bigger.", options: [.backwards])
    }
}

extension TwitterUser {
    init(_ user: EntityTwitterUser) {
        self.id = user.id
        self.name = user.name
        self.screenName = user.screenName
        self.profileImageURLString = user.imageURL
    }
}

extension TwitterUser: Himotoki.Decodable {
    static func decode(_ e: Extractor) throws -> TwitterUser {
        return try TwitterUser(
            id: e <| "id_str",
            name: e <| "name",
            screenName: e <| "screen_name",
            profileImageURLString: e <| "profile_image_url_https")
    }
}
