//
//  MainViewController.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/08.
//

import UIKit
import TalkPlus

class MainViewController: UITableViewController {
    private var channels: [TPChannel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "TalkPlus"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_more"), style: .plain, target: self, action: #selector(channelAction(_:)))
        
        tableView.refreshControl?.addTarget(self, action: #selector(reloadChannelList), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        channelList(last: nil)
    }
    
    // MARK: - Action
    @objc func channelAction(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.popoverPresentationController?.barButtonItem = sender
        actionSheet.popoverPresentationController?.permittedArrowDirections = .any
        
        let actions = [ UIAlertAction(title: "Create Private Channel", style: .default,
                                      handler: { [weak self] action in
                                        self?.performSegue(withIdentifier: "SegueCreate", sender: TP_CHANNEL_TYPE_PRIVATE)
                                      }),
                        UIAlertAction(title: "Create Public Channel", style: .default,
                                      handler: { [weak self] action in
                                        self?.performSegue(withIdentifier: "SegueCreate", sender: TP_CHANNEL_TYPE_PUBLIC)
                                      }),
                        UIAlertAction(title: "Create invitationCode Channel", style: .default,
                                      handler: { [weak self] action in
                                        self?.performSegue(withIdentifier: "SegueCreate", sender: TP_CHANNEL_TYPE_INVITATION_ONLY)
                                      }),
                        UIAlertAction(title: "Join Public Channel", style: .default,
                                      handler: { [weak self] action in
                                        self?.joinPublicChannel()
                                      }),
                        UIAlertAction(title: "Join invitationCode Channel", style: .default,
                                      handler: { [weak self] action in
                                        self?.joinInvitationCodeChannel()
                                      }),
                        UIAlertAction(title: "Logout", style: .destructive,
                                      handler: { [weak self] action in
                                        self?.logout()
                                      }),
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil) ]
        
        actions.forEach { actionSheet.addAction($0) }
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - Channel
    private func channelList(last: TPChannel?) {
        tableView.refreshControl?.endRefreshing()
        if last == nil {
            self.channels = []
        }
        /// 현재 참여중인 채널 목록 조회
        TalkPlus.sharedInstance()?.getChannels(last, success: { [weak self] tpChannels, hasNext in
            self?.channels.append(contentsOf: tpChannels!)
            if hasNext {
                self?.channelList(last: tpChannels!.last)
                return
            }
            self?.tableView.reloadData()
        }, failure: { (errorCode, error) in
            print("getChannels failed, \(errorCode)")
        })
    }
    
    @objc private func reloadChannelList() {
        channelList(last: nil)
    }
    
    private func joinPublicChannel() {
        let alert = UIAlertController(title: "Join Public Channel", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Channel ID" }
        
        let actions = [ UIAlertAction(title: "Join", style: .default,
                                      handler: { action in
                                        if let channelId = alert.textFields?.first?.text, !channelId.isEmpty {
                                            TalkPlus.sharedInstance()?.joinChannel(channelId, success: { [weak self] tpChannel in
                                                self?.performSegue(withIdentifier: "SegueChannel", sender: tpChannel)
                                                
                                            }, failure: { (errorCode, error) in
                                            })
                                        }
                                      }),
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil) ]
        actions.forEach { alert.addAction($0) }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func joinInvitationCodeChannel() {
        let alert = UIAlertController(title: "Join invitationCode Channel", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Channel ID" }
        alert.addTextField { $0.placeholder = "InvitationCode" }
        
        let actions = [ UIAlertAction(title: "Join", style: .default,
                                      handler: { action in
                                        if let channelId = alert.textFields?.first?.text, !channelId.isEmpty,
                                           let invitationCode = alert.textFields?.last?.text, !invitationCode.isEmpty {
                                            TalkPlus.sharedInstance()?.joinChannel(channelId, invitationCode: invitationCode, success: { [weak self] tpChannel in
                                                self?.performSegue(withIdentifier: "SegueChannel", sender: tpChannel)
                                                
                                            }, failure: { (errorCode, error) in
                                            })
                                        }
                                      }),
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil) ]
        actions.forEach { alert.addAction($0) }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func logout() {
        TalkPlus.sharedInstance()?.logout({ [weak self] in
            UserDefaults.standard.setValue(nil, forKey: "KeyUserID")
            UserDefaults.standard.setValue(nil, forKey: "KeyUserName")
            
            self?.dismiss(animated: true)
            
        }, failure: { (errorCode, error) in
        })
    }
    
    // MARK: - Navigation
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        reloadChannelList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
           let createViewController = navigationController.topViewController as? CreateViewController,
           let channelType = sender as? String {
            createViewController.channelType = channelType
            
        } else if let channelViewController = segue.destination as? ChannelViewController,
                  let channel = sender as? TPChannel {
            channelViewController.channel = channel
        }
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MainCell = tableView.dequeueReusableCell(withIdentifier: "MainCell") as! MainCell
        let channel = channels[indexPath.row]
        
        let names = channel.getMembers()?.compactMap { ($0 as? TPUser)?.getUsername() }
        cell.nameLabel.text = names?.joined(separator: ", ")
        
        let message = channel.getLastMessage()?.getText()?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let message = message, !message.isEmpty {
            cell.messageLabel.text = message
            
            if let time = channel.getLastMessage()?.getCreatedAt() {
                let date = Date(milliseconds: time)
                cell.dateLabel.text = date.toFormat("yyyy. MM. dd HH:mm")
            }
        } else {
            cell.messageLabel.text = "No message"
            cell.dateLabel.text = ""
        }
        
        let unreadCount = channel.getUnreadCount()
        
        if unreadCount > 0 {
            cell.unreadCountView.isHidden = false
            cell.unreadCountLabel.text = "\(unreadCount)"
            
        } else {
            cell.unreadCountView.isHidden = true
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: "SegueChannel", sender: channel)
    }
}
