//
//  ChannelViewController.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/11.
//

import UIKit

class ChannelViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    var channel: TPChannel?
    private var messages: [TPMessage] = []
    private let userId = UserDefaults.standard.string(forKey: "KeyUserID")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Channel"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_more"), style: .plain, target: self, action: #selector(channelAction(_:)))
        
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        textView.layer.cornerRadius = 16
        textView.textContainer.lineFragmentPadding = 10
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
        TalkPlus.sharedInstance()?.add(self, tag: "TPAppDelegate")
        messageList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        markRead()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action
    @objc func channelAction(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.popoverPresentationController?.barButtonItem = sender
        actionSheet.popoverPresentationController?.permittedArrowDirections = .any
        
        let actions = [
            UIAlertAction(title: "Member Info", style: .default, handler: { [weak self] action in
                self?.performSegue(withIdentifier: "SegueMember", sender: self?.channel?.getMembers())
            }),
            UIAlertAction(title: "Copy Channel ID", style: .default, handler: { [weak self] action in
                if let channelId = self?.channel?.getId() {
                    UIPasteboard.general.string = channelId
                }
            }),
            UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self] action in
                self?.leaveChannel()
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil) ]
        actions.forEach { actionSheet.addAction($0) }
        
        present(actionSheet, animated: true)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        sendMessage()
    }
    
    // MARK: - Message
    private func markRead() {
        TalkPlus.sharedInstance()?.mark(asRead: channel, success: { [weak self] tpChannel in
            self?.channel = tpChannel
            self?.tableView.reloadData()
            
        }, failure: { (errorCode, error) in
        })
    }
    
    private func messageList(_ message: TPMessage? = nil) {
        guard let channel = channel else { return }
        
        TalkPlus.sharedInstance()?.getMessageList(channel, last: message, success: { [weak self] tpMessages in
            if let tpMessages = tpMessages, tpMessages.count > 0 {
                self?.messages = tpMessages.reversed();
                self?.tableView.reloadData()
                self?.tableView.scrollToRow(at: IndexPath(row: tpMessages.count - 1, section: 0), at: .bottom, animated: false)
            }
            
        }, failure: { (errorCode, error) in
            
        })
    }
    
    private func sendMessage() {
        guard let channel = channel, let text = textView.text, !text.isEmpty else { return }
        
        TalkPlus.sharedInstance()?.sendMessage(channel, text: text, type: TP_MESSAGE_TYPE_TEXT, metaData: nil,
                                               success: { [weak self] tpMessage in
                                                if let tpMessage = tpMessage {
                                                    self?.addMessage(tpMessage)
                                                    self?.textView.text = nil
                                                }
                                               }, failure: { (errorCode, error) in
                                                
                                               })
    }
    
    private func addMessage(_ message: TPMessage) {
        messages.append(message)
        
        DispatchQueue.main.async { [weak self] in
            let count = self?.messages.count ?? 0
            if count > 0 {
                self?.tableView.reloadData()
                self?.tableView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    private func leaveChannel() {
        guard let channel = channel else { return }
        
        TalkPlus.sharedInstance()?.leave(channel, deleteChannelIfEmpty: true, success: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            
        }, failure: { (errorCode, error) in
        })
    }
    
    // MARK: - Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        var keyboardHeight = keyboardFrame.height
        
        if #available(iOS 11.0, *) {
            keyboardHeight -= view.safeAreaInsets.bottom
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.bottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            let count = self?.messages.count ?? 0
            if count > 0 {
                self?.tableView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        self.bottomView.transform = .identity
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let memberViewController = segue.destination as? MemberViewController,
           let users = sender as? [TPUser] {
            memberViewController.users = users
            memberViewController.channel = channel
        }
    }
}

// MARK: - TPChannelDelegate
extension ChannelViewController: TPChannelDelegate {
    func memberAdded(_ tpChannel: TPChannel!, users: [TPUser]!) {
    }
    
    func memberLeft(_ tpChannel: TPChannel!, users: [TPUser]!) {
    }
    
    func messageReceived(_ tpChannel: TPChannel!, message tpMessage: TPMessage!) {
        if channel?.getId() == tpChannel.getId() {
            self.channel = tpChannel
            
            addMessage(tpMessage)
            markRead()
        }
    }
    
    func channelAdded(_ tpChannel: TPChannel!) {
    }
    
    func channelChanged(_ tpChannel: TPChannel!) {
        if channel?.getId() == tpChannel.getId() {
            self.channel = tpChannel
        }
    }
    
    func channelRemoved(_ tpChannel: TPChannel!) {
    }
    
    func publicMemberAdded(_ tpChannel: TPChannel!, users: [TPUser]!) {
    }
    
    func publicMemberLeft(_ tpChannel: TPChannel!, users: [TPUser]!) {
    }
    
    func publicChannelAdded(_ tpChannel: TPChannel!) {
    }
    
    func publicChannelChanged(_ tpChannel: TPChannel!) {
    }
    
    func publicChannelRemoved(_ tpChannel: TPChannel!) {
    }
}

// MARK: - UITableViewDataSource
extension ChannelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        guard let channel = channel, let userId = userId, let senderId = message.getUserId() else { return UITableViewCell() }
        
        let text = message.getText()
        let date = Date(milliseconds: message.getCreatedAt())
        let dateText = date.toFormat("yyyy. MM. dd HH:mm")
        
        let cellIdentifier = userId == senderId ? "ChannelCell" : "ChannelUserCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ChannelCell
        cell.nameLabel?.text = message.getUsername()
        cell.messageLabel.text = text
        cell.dateLabel.text = dateText
        
        let unreadCount = channel.getMessageUnreadCount(message)
        if unreadCount > 0 {
            cell.unreadCountLabel.text = "\(unreadCount)"
            
        } else {
            cell.unreadCountLabel.text = nil
        }
        
        return cell
    }
}
