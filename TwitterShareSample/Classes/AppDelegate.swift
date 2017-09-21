//
//  AppDelegate.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/08/31.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import UIKit
import TwitterKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Twitters.shared.start(consumerKey: "yourConsumerKey", consumerSecret: "yourConsumerSecret")
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if Twitters.shared.application(app, open: url, options: options) {
            return true
        }
        return false
    }
}

