//
//  AccountViewController.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/07.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import UIKit

final class AccountViewController: UIViewController {

    private enum Section: Int {
        case user = 0
        case addAccount = 1
    }

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var editDoneButton: UIButton!

    private var users: [TwitterUser] = []

    override func loadView() {
        super.loadView()

        self.tableView.register(UINib(nibName: "TwitterUserCell", bundle: nil), forCellReuseIdentifier: "TwitterUserCell")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setEditing(false, animated: false)
        self.tableView.tableFooterView = UIView()
        self.load()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        self.tableView.setEditing(editing, animated: animated)

        UIView.animate(withDuration: 0.4) {
            self.doneButton.alpha = editing ? 0 : 1
            self.editButton.alpha = editing ? 0 : 1
            self.editDoneButton.alpha = editing ? 1 : 0
        }
    }

    private func load() {
        self.users = Twitters.shared.loadUsers()
    }

    private func addAccount() {
        Twitters.shared.login(on: self) { result in
            switch result {
            case .success(let userID):
                Twitters.shared.fetchUser(byID: userID) { result in
                    self.appendUserIfNeeded(id: userID)
                }
            default: break
            }
        }
    }

    private func appendUserIfNeeded(id: String) {
        let isExistingUser = self.users.contains { $0.id == id }
        guard !isExistingUser, let user = Twitters.shared.loadUser(id: id) else {
            return
        }
        self.users.append(user)
        let indexPath = IndexPath(row: self.users.count - 1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    private func removeUser(at indexPath: IndexPath) {
        let userID = self.users[indexPath.row].id
        self.users.remove(at: indexPath.row)
        Twitters.shared.logout(userID: userID)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    @IBAction private func done(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func edit(_ sender: UIButton) {
        self.setEditing(true, animated: true)
    }

    @IBAction private func editDone(_ sender: UIButton) {
        self.setEditing(false, animated: true)
    }
}

extension AccountViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .user: return self.users.count
        case .addAccount: return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section)! {
        case .user: return 68
        case .addAccount: return 44
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .user:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterUserCell", for: indexPath) as? TwitterUserCell else {
                break
            }
            let user = self.users[indexPath.row]
            cell.configure(with: user)
            return cell
        case .addAccount:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Add Account"
            return cell
        }
        return UITableViewCell()
    }
}

extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch Section(rawValue: indexPath.section)! {
        case .user: return tableView.isEditing ? indexPath : nil
        case .addAccount: return indexPath
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        switch Section(rawValue: indexPath.section)! {
        case .user: break
        case .addAccount:
            if tableView.isEditing {
                self.setEditing(false, animated: true)
            }
            self.addAccount()
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return Section(rawValue: indexPath.section)! == .user
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let disconnectButton = UITableViewRowAction(style: .default, title: "Disconnect") { (_, indexPath) in
            self.removeUser(at: indexPath)
        }
        return [disconnectButton]
    }
}
