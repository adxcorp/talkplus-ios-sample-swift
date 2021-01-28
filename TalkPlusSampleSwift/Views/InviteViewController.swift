//
//  InviteViewController.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/13.
//

import UIKit

class InviteViewController: UITableViewController {
    var channelType = ""
    var channelName: String?
    var invitationCode: String?
    
    private var users: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Invite"
        navigationItem.rightBarButtonItems = [ UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction)),
                                               UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction)) ]
    }
    
    // MARK: - Action
    @objc func addAction() {
        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "User ID" }
        
        let actions = [ UIAlertAction(title: "Add", style: .default,
                                      handler: { [weak self] action in
                                        if let userId = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userId.isEmpty {
                                            self?.users.append(userId)
                                            self?.tableView.reloadData()
                                        }
                                      }),
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil) ]
        actions.forEach { alert.addAction($0) }
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func doneAction() {
        if channelType == TP_CHANNEL_TYPE_PRIVATE {
            if users.count > 0 {
                createChannel()
                
            } else {
                showToast("유저를 추가해주세요.")
            }
            
        } else {
            createChannel()
        }
    }
    
    // MARK: - Channel
    func createChannel() {
        TalkPlus.sharedInstance()?.createChannel(withUserIds: users, channelId: nil, reuseChannel: true, maxCount: 20, hideMessagesBeforeJoin: false, channelType: channelType, channelName: channelName, invitationCode: invitationCode, imageUrl: nil, metaData: nil, success: { [weak self] tpChannel in
            self?.performSegue(withIdentifier: "UnwindToMain", sender: nil)
            
        }, failure: { (errorCode, error) in
        })
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, index) in
            self?.users.remove(at: index.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [index], with: .automatic)
            tableView.endUpdates()
        }
        
        return [delete]
    }
}
