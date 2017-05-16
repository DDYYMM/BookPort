//
//  ProfileViewController.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-09-26.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import UIKit
import CoreLocation
import SendBirdSDK

class ProfileViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!

    fileprivate var profilePictureWidth: CGFloat {
        return profilePictureImageView.bounds.width
    }

    fileprivate let userDefaults = UserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self

        // hide the name and email labels
        emailLabel.alpha = 0
        nameLabel.alpha = 0

        profilePictureImageView.clipsToBounds = true

        if let name = userDefaults.string(forKey: Constants.nameKey),
            let email = userDefaults.string(forKey: Constants.emailKey),
            let profileUrl = userDefaults.string(forKey: Constants.profileUrlKey) {
            // hide the signIn button
            signInButton.alpha = 0

            // show the name and email labels
            emailLabel.alpha = 1
            nameLabel.alpha = 1
            nameLabel.text = name
            emailLabel.text = email
            let image = UIImage(data: try! Data(contentsOf: URL(string: profileUrl)!))
            profilePictureImageView.image = image

        }
    }

    override func viewDidAppear(_ animated: Bool) {
        profilePictureImageView.layer.cornerRadius = profilePictureWidth / 2.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ProfileViewController: GIDSignInDelegate {
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            return
        }

        // hide the signIn button
        signInButton.alpha = 0

        // show the name and email labels
        emailLabel.alpha = 1
        nameLabel.alpha = 1

        // update the name and email labels
        if let name = user.profile.name {
            nameLabel.text = name
            userDefaults.setValue(name, forKey: Constants.nameKey)
        }

        if let email = user.profile.email {
            emailLabel.text = email
            userDefaults.setValue(email, forKey: Constants.emailKey)
        }

        // save user id
        userDefaults.setValue(user.userID, forKey: Constants.userIdKey)

        // update the profile picture image view
        if let imageURL = user.profile.imageURL(withDimension: UInt(profilePictureWidth)) {
            let image = UIImage(data: try! Data(contentsOf: imageURL))
            profilePictureImageView.image = image
            userDefaults.setValue("\(imageURL)", forKey: Constants.profileUrlKey)
        }

        // sign in with the server backend
        let session = URLSession(configuration: .ephemeral)
        if let url = URL(string: "http://thetsntech.in/ios/inserlocation.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let params = "user=\(user.userID!)&ulon=\(userDefaults.string(forKey: Constants.lonKey)!)&ulat=\(userDefaults.string(forKey: Constants.latKey)!)"
            request.httpBody = params.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if error == nil {
                    NotificationCenter.default.post(name: NotificationNames.userDidSignInNotification, object: nil)
                }
            })

            task.resume()
        }

    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error)
    }
}
