//
//  ChatViewController.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-11-06.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SendBirdSDK

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, CreateGroupChannelUserListViewControllerDelegate, SBDChannelDelegate, SBDConnectionDelegate {
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChannelLabel: UILabel!

    private var refreshControl: UIRefreshControl?
    private var channels: [SBDGroupChannel] = []
    private var groupChannelListQuery: SBDGroupChannelListQuery?
    private var typingAnimationChannelList: [String] = []
    private var connected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = false
        self.tableView.register(GroupChannelListTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier())
        self.tableView.register(GroupChannelListEditableTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListEditableTableViewCell.cellReuseIdentifier())

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshChannelList), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)

        self.noChannelLabel.isHidden = true

        self.connectSendBird()
    }

    private func connectSendBird() {
        guard let userId = UserDefaults().string(forKey: Constants.userIdKey) else {
            print("userId is not ready. Cannot connect")
            return
        }

        SBDMain.connect(withUserId: userId, accessToken: Constants.sendBirdApiToken) { user, error in
            guard error == nil else {
                return
            }

            self.connected = true
            self.updateUserInfo()
            self.refreshChannelList()
        }

        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)

    }

    private func updateUserInfo() {
        if let nickName = UserDefaults().string(forKey: Constants.nameKey),
            let profileUrl = UserDefaults().string(forKey: Constants.profileUrlKey) {
            SBDMain.updateCurrentUserInfo(withNickname: nickName, profileUrl: profileUrl) { error in
                if error != nil {
                    let vc = UIAlertController(title:"Error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }

                    SBDMain.disconnect(completionHandler: {

                    })

                    return
                } else {
                    print("User info updated")
                }
            }
        }

    }

    @objc private func refreshChannelList() {
        guard connected else {
            self.connectSendBird()
            return
        }

        self.channels.removeAll()

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.groupChannelListQuery?.limit = 20

        self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }

                let vc = UIAlertController(title: "Error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler:nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }

                return
            }

            for channel in channels! {
                self.channels.append(channel)
            }

            DispatchQueue.main.async {
                if self.channels.count == 0 {
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
                    self.noChannelLabel.isHidden = false
                }
                else {
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.noChannelLabel.isHidden = true
                }

                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }

    private func loadChannels() {
        if self.groupChannelListQuery != nil {
            if self.groupChannelListQuery?.hasNext == false {
                return
            }

            self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                    }

                    let vc = UIAlertController(title: "Error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }

                    return
                }

                for channel in channels! {
                    self.channels.append(channel)
                }

                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            })
        }
    }


    @objc private func createGroupChannel() {
        let vc = CreateGroupChannelUserListViewController()
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }




    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let vc = GroupChannelChattingViewController()
        vc.groupChannel = self.channels[indexPath.row]
        self.present(vc, animated: true, completion: nil)

    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?

        cell = tableView.dequeueReusableCell(withIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier()) as! GroupChannelListTableViewCell?
        if self.channels[indexPath.row].isTyping() == true {
            if self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl) == nil {
                self.typingAnimationChannelList.append(self.channels[indexPath.row].channelUrl)
            }
        }
        else {
            if self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl) != nil {
                self.typingAnimationChannelList.remove(at: self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl)!)
            }
        }

        (cell as! GroupChannelListTableViewCell).setModel(aChannel: self.channels[indexPath.row])

        if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
            self.loadChannels()
        }

        return cell!
    }

    // MARK: MGSwipeTableCellDelegate
    // TODO:
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        // 0: right, 1: left
        let row = self.tableView.indexPath(for: cell)?.row
        let selectedChannel: SBDGroupChannel = self.channels[row!] as SBDGroupChannel
        if index == 0 {
            // Hide
            selectedChannel.hide(completionHandler: { (error) in
                if error != nil {
                    let vc = UIAlertController(title: "Error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }

                    return
                }

                self.channels.remove(at: row!)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        else {
            // Leave
            selectedChannel.leave(completionHandler: { (error) in
                if error != nil {
                    let vc = UIAlertController(title: "Error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }

                    return
                }

                self.channels.remove(at: row!)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }

        return true
    }

    // MARK: CreateGroupChannelUserListViewControllerDelegate
    func openGroupChannel(channel: SBDGroupChannel, vc: UIViewController) {
        let vc = GroupChannelChattingViewController()
        vc.groupChannel = channel
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: GroupChannelChattingViewController
    func didStartReconnection() {

    }

    func didSucceedReconnection() {

    }

    func didFailReconnection() {

    }

    // MARK: SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender is SBDGroupChannel {
            let messageReceivedChannel = sender as! SBDGroupChannel
            if self.channels.index(of: messageReceivedChannel) != nil {
                self.channels.remove(at: self.channels.index(of: messageReceivedChannel)!)
            }
            self.channels.insert(messageReceivedChannel, at: 0)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {

    }

    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        let row = self.channels.index(of: sender)
        if row != nil {
            let cell = self.tableView.cellForRow(at: IndexPath(row: row!, section: 0)) as! GroupChannelListTableViewCell

            cell.startTypingAnimation()
        }
    }

    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {

    }

    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {

    }

    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {

    }

    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {

    }

    func channel(_ sender: SBDOpenChannel, userWasMuted user: SBDUser) {

    }

    func channel(_ sender: SBDOpenChannel, userWasUnmuted user: SBDUser) {

    }

    func channel(_ sender: SBDOpenChannel, userWasBanned user: SBDUser) {

    }

    func channel(_ sender: SBDOpenChannel, userWasUnbanned user: SBDUser) {

    }

    func channelWasFrozen(_ sender: SBDOpenChannel) {

    }

    func channelWasUnfrozen(_ sender: SBDOpenChannel) {

    }

    func channelWasChanged(_ sender: SBDBaseChannel) {

    }

    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {

    }

    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        
    }
}
