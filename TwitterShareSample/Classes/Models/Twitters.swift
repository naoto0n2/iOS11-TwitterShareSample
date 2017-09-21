//
//  Twitter.swift
//  Twitter
//
//  Created by Naoto Onagi on 2017/08/31.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

struct Twitters {
    static let shared = Twitters()
    private let twitter: Twitter

    init(twitter: Twitter = .sharedInstance()) {
        self.twitter = twitter
    }
}

extension Twitters {

    enum ShareResult {
        case cancelled
        case done
        case failure(Error)
    }

    enum LoginResult {
        case cancelled
        case success(userID: String)
        case failure(Error)
    }

    enum FetchUsersResult {
        case success
        case failure(Error)
    }

    typealias ShareCompletion = (_ result: ShareResult) -> Void
    typealias LoginCompletion = (_ result: LoginResult) -> Void
    typealias FetchUsersCompletion = (_ result: FetchUsersResult) -> Void

    // MARK: - Internal method

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return self.twitter.application(app, open: url, options: options)
    }

    func start(consumerKey: String, consumerSecret: String) {
        self.twitter.start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
    }

    func login(on viewController: UIViewController, completion: @escaping LoginCompletion) {
        self.twitter.logIn(with: viewController) { (session, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let session = session {
                completion(.success(userID: session.userID))
                return
            }
            completion(.cancelled)
        }
    }

    func logout() {
        guard let session = self.sessionStore.session() else {
            return
        }
        self.sessionStore.logOutUserID(session.userID)
    }

    func logoutAllUsers() {
        self.existingUserSessions
            .map { $0.userID }
            .forEach { self.logout(userID: $0) }
    }

    func logout(userID: String) {
        self.sessionStore.logOutUserID(userID)
    }

    func share(text: String? = nil, image: UIImage? = nil, url: URL? = nil, on viewController: UIViewController, completion: @escaping ShareCompletion) {
        if self.hasLoggedInUsers {
            self.showShareDialog(text: text, image: image, url: url, on: viewController, completion: completion)
        } else {
            self.login(on: viewController) { result in
                switch result {
                case .cancelled:
                    completion(.cancelled)
                case .success(let userID):
                    self.fetchUser(byID: userID)
                    self.showComposer(text: text, image: image, url: url, on: viewController) { result in
                        switch result {
                        case .cancelled: completion(.cancelled)
                        case .done: completion(.done)
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchUser(byID userID: String, completion: FetchUsersCompletion? = nil) {
        self.fetchUsers(byIDs: [userID], completion: completion)
    }

    func fetchUsers(byIDs userIDs: [String], completion: FetchUsersCompletion? = nil) {
        let client = TWTRAPIClient()
        client.fetchUsers(withUserIDs: userIDs) { result in
            switch result {
            case .failure(let error):
                completion?(.failure(error))
            case .success(let users):
                self.save(users)
                completion?(.success)
            }
        }
    }

    func loadUsers() -> [TwitterUser] {
        let userIDs = self.existingUserSessions.map { $0.userID }
        let entityUsers = EntityTwitterUser.find(byIds: userIDs)
        return Array(entityUsers).map(TwitterUser.init)
    }

    func loadUser(id: String) -> TwitterUser? {
        if let entityUser = EntityTwitterUser.find(byId: id) {
            return TwitterUser(entityUser)
        }
        return nil
    }

    // MARK: - Private method

    private var sessionStore: TWTRSessionStore {
        return self.twitter.sessionStore
    }

    private var hasLoggedInUsers: Bool {
        return self.sessionStore.hasLoggedInUsers()
    }

    private var existingUserSessions: [TWTRAuthSession] {
        return self.sessionStore.existingUserSessions() as? [TWTRAuthSession] ?? []
    }

    private func session(forUserID userID: String) -> TWTRAuthSession? {
        return self.sessionStore.session(forUserID: userID)
    }

    private func showComposer(text: String? = nil, image: UIImage? = nil, url: URL? = nil, on viewController: UIViewController, completion: @escaping TWTRComposerCompletion) {
        let composer = TWTRComposer()
        composer.setText(text)
        composer.setImage(image)
        composer.setURL(url)
        composer.show(from: viewController, completion: completion)
    }

    private func showShareDialog(text: String? = nil, image: UIImage? = nil, url: URL? = nil, on viewController: UIViewController, completion: @escaping ShareCompletion) {
        let users = self.loadUsers()
        let alert = UIAlertController(title: "Select a Twitter Account", message: nil, preferredStyle: .alert)

        // User
        for user in users {
            let action = UIAlertAction(title: "@\(user.screenName)", style: .default) { _ in
                self.share(as: user, text: text, image: image, url: url, on: viewController, completion: completion)
            }
            alert.addAction(action)
        }

        // Account management
        let accountManagementAction = UIAlertAction(title: "Manage your accounts", style: .default) { _ in
            self.showAccountManagement(on: viewController)
        }
        alert.addAction(accountManagementAction)

        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true, completion: nil)
    }

    private func showAccountManagement(on viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "AccountViewController", bundle: nil)
        if let accountViewController = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as? AccountViewController {
            viewController.present(accountViewController, animated: true, completion: nil)
        }
    }

    private func share(as user: TwitterUser, text: String? = nil, image: UIImage? = nil, url: URL? = nil, on viewController: UIViewController, completion: @escaping ShareCompletion) {
        self.changeDefaultUser(to: user) { _ in
            self.showComposer(text: text, image: image, url: url, on: viewController) { result in
                switch result {
                case .cancelled: completion(.cancelled)
                case .done: completion(.done)
                }
            }
        }
    }

    private func changeDefaultUser(to user: TwitterUser, completion: @escaping (_ success: Bool) -> Void) {
        guard let session = self.session(forUserID: user.id) else {
            completion(false)
            return
        }
        self.sessionStore.save(session) { (_, _) in
            completion(true)
        }
    }

    private func save(_ users: [TwitterUser]) {
        Realms.commit { (realm) in
            let entityUsers = users.map(EntityTwitterUser.init)
            realm.add(entityUsers, update: true)
        }
    }
}
