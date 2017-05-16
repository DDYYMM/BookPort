//
//  BookDetailViewController.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-11-06.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import UIKit
import SendBirdSDK

class BookDetailViewController: UIViewController {

    // the image of the book cover to be shown
    var bookCoverImage: UIImage?
    // the Book instance containing all the information
    var book: Book?

    @IBOutlet weak var bookCoverImageView: UIImageView! {
        didSet {
            bookCoverImageView.image = bookCoverImage
        }
    }
    @IBOutlet weak var bookTitle: UILabel! {
        didSet {
            bookTitle.text = book?.title
        }
    }
    @IBOutlet weak var bookAuthor: UILabel! {
        didSet {
            bookAuthor.text = book?.author
        }
    }

    @IBAction func contact(_ sender: Any) {
        guard let ownerUserId = book?.user,
            let currentUserId = UserDefaults().string(forKey: Constants.userIdKey) else {
                return
        }

        SBDMain.connect(withUserId: currentUserId, accessToken: Constants.sendBirdApiToken) { user, error in
            print("connected")

            SBDGroupChannel.createChannel(withUserIds: [currentUserId, ownerUserId], isDistinct: true) { (channel, error) in
                if error != nil {
                    print(error.debugDescription)
                }
                DispatchQueue.main.async {
                    let vc = GroupChannelChattingViewController()
                    vc.groupChannel = channel
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }

    }
}
