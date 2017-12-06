//
//  TwitterUser.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/06.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import Foundation

struct TwitterUser: Codable {
    let id: String
    let name: String
    let screenName: String
    let profileImageURLString: String

    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case name
        case screenName = "screen_name"
        case profileImageURLString = "profile_image_url_https"
    }
}

extension TwitterUser {
    var profileImageURL: URL? {
        return URL(string: self.biggerProfileImageURLString)
    }

    private var biggerProfileImageURLString: String {
        return self.profileImageURLString.replacingOccurrences(of: "_normal.", with: "_bigger.", options: [.backwards])
    }

    init(_ user: EntityTwitterUser) {
        self.id = user.id
        self.name = user.name
        self.screenName = user.screenName
        self.profileImageURLString = user.imageURL
    }
}
