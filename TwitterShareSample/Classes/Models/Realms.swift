//
//  Realms.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/06.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import Foundation
import RealmSwift

struct Realms {
    static var realm: Realm {
        return try! Realm()
    }

    static func commit(_ block: (_ realm: Realm) -> Void) {
        let realm = Realms.realm
        if realm.isInWriteTransaction {
            block(realm)
        } else {
            realm.beginWrite()
            block(realm)
            do {
                try realm.commitWrite()
            } catch let error {
                print(error)
            }
        }
    }
}
