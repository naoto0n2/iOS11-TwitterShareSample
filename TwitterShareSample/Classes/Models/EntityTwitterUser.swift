//
//  EntityTwitterUser.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/06.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import Foundation
import RealmSwift

final class EntityTwitterUser: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var screenName = ""
    @objc dynamic var imageURL = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension EntityTwitterUser {
    convenience init(_ user: TwitterUser) {
        self.init()
        self.id = user.id
        self.name = user.name
        self.screenName = user.screenName
        self.imageURL = user.profileImageURLString
    }

    static func findAll() -> Results<EntityTwitterUser> {
        return Realms.realm.objects(EntityTwitterUser.self).sorted(byKeyPath: "createdAt")
    }

    static func find(byId userId: String) -> EntityTwitterUser? {
        return Realms.realm.object(ofType: EntityTwitterUser.self, forPrimaryKey: userId)
    }

    static func find(byIds userIds: [String]) -> Results<EntityTwitterUser> {
        return Realms.realm.objects(EntityTwitterUser.self).filter("id IN %@", userIds)
    }

    static func delete(userId: String) {
        Realms.commit { (realm) in
            guard let user = realm.object(ofType: EntityTwitterUser.self, forPrimaryKey: userId) else {
                return
            }
            realm.delete(user)
        }
    }

    static func deleteAll() {
        Realms.commit { (realm) in
            realm.delete(realm.objects(EntityTwitterUser.self))
        }
    }
}
