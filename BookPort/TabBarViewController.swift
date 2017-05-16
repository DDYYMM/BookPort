//
//  TabBarViewController.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-11-06.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    private let scanBookSegueId = "Scan new book"

    override func viewDidLoad() {
        super.viewDidLoad()

        // add the chat view tab
        let tabBarItem = UITabBarItem(title: "Chat", image: nil, tag: 2)
        let chatVC = ChatViewController()
        chatVC.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        chatVC.tabBarItem = tabBarItem
        viewControllers?.append(chatVC)


        // create a scan button
        let scanButton = UIButton(type: .roundedRect)
        let scanButtonWidth = CGFloat(75)
        let scanButtonHeight = CGFloat(75)
        let padding = CGFloat(10)
        let scanButtonX = view.bounds.width - scanButtonWidth - padding
        let scanButtonY = view.bounds.height - scanButtonHeight - tabBar.frame.height - padding

        scanButton.frame = CGRect(x: scanButtonX, y: scanButtonY, width: scanButtonWidth, height: scanButtonHeight)
        scanButton.layer.cornerRadius = scanButtonWidth / 2
        scanButton.setTitle("Scan", for: .normal)
        scanButton.backgroundColor = UIColor.green
        scanButton.setTitleColor(UIColor.white, for: .normal)
        // show the scan button
        view.addSubview(scanButton)

        // link action method for the scan button
        scanButton.addTarget(self, action: #selector(scanButtonPressed), for: .touchUpInside)

        // check log in status
        let userDefaults = UserDefaults.standard
        let userId = userDefaults.string(forKey: Constants.userIdKey)
        if userId == nil {
            let ac = UIAlertController(title: "Sign In", message: "You must sign in with Google to proceed", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                self.selectedIndex = Constants.profileTabIndex
            })
            DispatchQueue.main.async {
                self.present(ac, animated: true, completion: nil)
            }
        }

    }

    func scanButtonPressed() {
        performSegue(withIdentifier: scanBookSegueId, sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func cancelScanBarCode(segue: UIStoryboardSegue) {
        // is canceled
    }
}
