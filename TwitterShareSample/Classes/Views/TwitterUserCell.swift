//
//  TwitterUserCell.swift
//  TwitterShareSample
//
//  Created by Naoto Onagi on 2017/09/07.
//  Copyright © 2017 Naoto Onagi All rights reserved.
//

import UIKit

final class TwitterUserCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var screenNameLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView! {
        didSet {
            self.iconImageView.clipsToBounds = true
            self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
        }
    }

    func configure(with user: TwitterUser) {
        self.iconImageView.image = nil
        DispatchQueue.global().async {
            guard
                let imageURL = user.profileImageURL,
                let imageData = try? Data(contentsOf: imageURL),
                let image = UIImage(data: imageData) else {
                    return
            }
            DispatchQueue.main.async {
                self.iconImageView.image = image
            }
        }
        self.nameLabel.text = user.name
        self.screenNameLabel.text = "@\(user.screenName)"
    }
}
