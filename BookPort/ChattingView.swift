//
//  ChattingView.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/7/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

protocol ChattingViewDelegate: class {
    func loadMoreMessage(view: UIView)
    func startTyping(view: UIView)
    func endTyping(view: UIView)
    func hideKeyboardWhenFastScrolling(view: UIView)
}

class ChattingView: ReusableViewFromXib, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var chattingTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var typingIndicatorImageView: UIImageView!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var typingIndicatorContainerView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var typingIndicatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var typingIndicatorImageHeight: NSLayoutConstraint!
    
    var messages: [SBDBaseMessage] = []
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var stopMeasuringVelocity: Bool = true
    var initialLoading: Bool = true
    var lastMessageHeight: CGFloat = 0
    var scrollLock: Bool = false
    var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    var lastOffsetCapture: TimeInterval = 0
    var isScrollingFast: Bool = false
    
    var incomingUserMessageSizingTableViewCell: IncomingUserMessageTableViewCell?
    var outgoingUserMessageSizingTableViewCell: OutgoingUserMessageTableViewCell?
    var neutralMessageSizingTableViewCell: NeutralMessageTableViewCell?
    
    var delegate: ChattingViewDelegate & MessageDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.chattingTableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        self.messageTextView.textContainerInset = UIEdgeInsetsMake(15.5, 0, 14, 0)
    }
    
    func initChattingView() {
        self.typingIndicatorContainerView.isHidden = true
        self.typingIndicatorContainerViewHeight.constant = 0
        self.typingIndicatorImageHeight.constant = 0
        
        self.typingIndicatorContainerView.layoutIfNeeded()
        
        self.messageTextView.delegate = self
        
        self.chattingTableView.register(IncomingUserMessageTableViewCell.nib(), forCellReuseIdentifier: IncomingUserMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(OutgoingUserMessageTableViewCell.nib(), forCellReuseIdentifier: OutgoingUserMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(NeutralMessageTableViewCell.nib(), forCellReuseIdentifier: NeutralMessageTableViewCell.cellReuseIdentifier())
        
        self.chattingTableView.delegate = self
        self.chattingTableView.dataSource = self
        
        self.initSizingCell()
    }
    
    func initSizingCell() {
        self.incomingUserMessageSizingTableViewCell = IncomingUserMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? IncomingUserMessageTableViewCell
        self.incomingUserMessageSizingTableViewCell?.frame = self.frame
        self.incomingUserMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.incomingUserMessageSizingTableViewCell!)
        
        self.outgoingUserMessageSizingTableViewCell = OutgoingUserMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? OutgoingUserMessageTableViewCell
        self.outgoingUserMessageSizingTableViewCell?.frame = self.frame
        self.outgoingUserMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.outgoingUserMessageSizingTableViewCell!)
        
        self.neutralMessageSizingTableViewCell = NeutralMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? NeutralMessageTableViewCell
        self.neutralMessageSizingTableViewCell?.frame = self.frame
        self.neutralMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.neutralMessageSizingTableViewCell!)
        
    }
    
    func scrollToBottom() {
        if self.messages.count == 0 {
            return
        }
        
        if self.scrollLock == true {
            return
        }
        
        DispatchQueue.main.async {
            self.chattingTableView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        }
    }
    
    func scrollToPosition(position: Int) {
        if self.messages.count == 0 {
            return
        }
        
        if self.scrollLock == true {
            return
        }
        
        DispatchQueue.main.async {
            self.chattingTableView.scrollToRow(at: IndexPath.init(row: position, section: 0), at: UITableViewScrollPosition.top, animated: false)
        }
    }
    
    func startTypingIndicator(text: String) {
        // Typing indicator
        self.typingIndicatorContainerView.isHidden = false
        self.typingIndicatorLabel.text = text
        
        self.typingIndicatorContainerViewHeight.constant = 26.0
        self.typingIndicatorImageHeight.constant = 26.0
        self.typingIndicatorContainerView.layoutIfNeeded()

        if self.typingIndicatorImageView.isAnimating == false {
            var typingImages: [UIImage] = []
            for i in 1...50 {
                let typingImageFrameName = String.init(format: "%02d", i)
                typingImages.append(UIImage(named: typingImageFrameName)!)
            }
            self.typingIndicatorImageView.animationImages = typingImages
            self.typingIndicatorImageView.animationDuration = 1.5
            DispatchQueue.main.async {
                self.typingIndicatorImageView.startAnimating()
            }
            
            self.scrollToBottom()
        }
    }
    
    func endTypingIndicator() {
        DispatchQueue.main.async {
            self.typingIndicatorImageView.stopAnimating()
        }

        self.typingIndicatorContainerView.isHidden = true
        self.typingIndicatorContainerViewHeight.constant = 0
        self.typingIndicatorImageHeight.constant = 0
        
        self.typingIndicatorContainerView.layoutIfNeeded()
    }
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.messageTextView {
            if textView.text.characters.count > 0 {
                self.placeholderLabel.isHidden = true
                if self.delegate != nil {
                    self.delegate?.startTyping(view: self)
                }
            }
            else {
                self.placeholderLabel.isHidden = false
                if self.delegate != nil {
                    self.delegate?.endTyping(view: self)
                }
            }
        }
    }
    
    // MARK: UITableViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopMeasuringVelocity = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.stopMeasuringVelocity = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.chattingTableView {
            if self.stopMeasuringVelocity == false {
                let currentOffset = scrollView.contentOffset
                let currentTime = NSDate.timeIntervalSinceReferenceDate
                
                let timeDiff = currentTime - self.lastOffsetCapture
                if timeDiff > 0.1 {
                    let distance = currentOffset.y - self.lastOffset.y
                    let scrollSpeedNotAbs = distance * 10 / 1000
                    let scrollSpeed = fabs(scrollSpeedNotAbs)
                    if scrollSpeed > 0.5 {
                        self.isScrollingFast = true
                    }
                    else {
                        self.isScrollingFast = false
                    }
                    
                    self.lastOffset = currentOffset
                    self.lastOffsetCapture = currentTime
                }
                
                if self.isScrollingFast {
                    if self.delegate != nil {
                        self.delegate?.hideKeyboardWhenFastScrolling(view: self)
                    }
                }
            }
            
            if scrollView.contentOffset.y + scrollView.frame.size.height + self.lastMessageHeight < scrollView.contentSize.height {
                self.scrollLock = true
            }
            else {
                self.scrollLock = false
            }
            
            if scrollView.contentOffset.y == 0 {
                if self.messages.count > 0 && self.initialLoading == false {
                    if self.delegate != nil {
                        self.delegate?.loadMoreMessage(view: self)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        
        let msg = self.messages[indexPath.row]
        
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                if indexPath.row > 0 {
                    self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                }
                self.outgoingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                height = (self.outgoingUserMessageSizingTableViewCell?.getHeightOfViewCell())!
            }
            else {
                // Incoming
                if indexPath.row > 0 {
                    self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                }
                self.incomingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                height = (self.incomingUserMessageSizingTableViewCell?.getHeightOfViewCell())!
            }
        } else if msg is SBDAdminMessage {
            let adminMessage = msg as! SBDAdminMessage
            if indexPath.row > 0 {
                self.neutralMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
            }
            else {
                self.neutralMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
            }
            
            self.neutralMessageSizingTableViewCell?.setModel(aMessage: adminMessage)
            height = (self.neutralMessageSizingTableViewCell?.getHeightOfViewCell())!
        }
        
        if self.messages.count > 0 && self.messages.count - 1 == indexPath.row {
            self.lastMessageHeight = height
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        
        let msg = self.messages[indexPath.row]
        
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                if indexPath.row > 0 {
                    self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                }
                self.outgoingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                height = (self.outgoingUserMessageSizingTableViewCell?.getHeightOfViewCell())!
            }
            else {
                // Incoming
                if indexPath.row > 0 {
                    self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                }
                self.incomingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                height = (self.incomingUserMessageSizingTableViewCell?.getHeightOfViewCell())!
            }
        } else if msg is SBDAdminMessage {
            let adminMessage = msg as! SBDAdminMessage
            if indexPath.row > 0 {
                self.neutralMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
            }
            else {
                self.neutralMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
            }
            
            self.neutralMessageSizingTableViewCell?.setModel(aMessage: adminMessage)
            height = (self.neutralMessageSizingTableViewCell?.getHeightOfViewCell())!
        }
        
        if self.messages.count > 0 && self.messages.count - 1 == indexPath.row {
            self.lastMessageHeight = height
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let msg = self.messages[indexPath.row]
        
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                cell = tableView.dequeueReusableCell(withIdentifier: OutgoingUserMessageTableViewCell.cellReuseIdentifier())
                if indexPath.row > 0 {
                    (cell as! OutgoingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    (cell as! OutgoingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                }
                (cell as! OutgoingUserMessageTableViewCell).setModel(aMessage: userMessage)
                (cell as! OutgoingUserMessageTableViewCell).delegate = self.delegate
                
                if self.resendableMessages[userMessage.requestId!] != nil {
                    (cell as! OutgoingUserMessageTableViewCell).showMessageControlButton()
                }
                else {
                    (cell as! OutgoingUserMessageTableViewCell).hideMessageControlButton()
                }
            }
            else {
                // Incoming
                cell = tableView.dequeueReusableCell(withIdentifier: IncomingUserMessageTableViewCell.cellReuseIdentifier())
                if indexPath.row > 0 {
                    (cell as! IncomingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    (cell as! IncomingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                }
                (cell as! IncomingUserMessageTableViewCell).setModel(aMessage: userMessage)
                (cell as! IncomingUserMessageTableViewCell).delegate = self.delegate
            }
        } else if msg is SBDAdminMessage {
            let adminMessage = msg as! SBDAdminMessage
            
            cell = tableView.dequeueReusableCell(withIdentifier: NeutralMessageTableViewCell.cellReuseIdentifier())
            
            if indexPath.row > 0 {
                (cell as! NeutralMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
            }
            else {
                (cell as! NeutralMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
            }
            
            (cell as! NeutralMessageTableViewCell).setModel(aMessage: adminMessage)
        }
        
        
        return cell!
    }
}
