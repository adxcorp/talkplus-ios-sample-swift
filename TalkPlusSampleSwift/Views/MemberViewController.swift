//
//  MemberViewController.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/18.
//

import UIKit

class MemberViewController: UITableViewController {
    var channel: TPChannel?
    var users: [TPUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Member Info"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(AddAction))
    }
    
    // MARK: - Action
    @objc func AddAction() {
        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "User ID" }
        
        let actions = [ UIAlertAction(title: "Add", style: .default,
                                      handler: { [weak self] action in
                                        if let userId = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userId.isEmpty {
                                            self?.addMember(userId: userId)
                                        }
                                      }),
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil) ]
        actions.forEach { alert.addAction($0) }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Member
    private func addMember(userId: String) {
        TalkPlus.sharedInstance()?.addMember(to: channel, userId: userId, success: { [weak self] tpChannel in
            self?.channel = tpChannel
            if let addUser = tpChannel?.getMembers()?.first(where: { (member) -> Bool in
                guard let member = member as? TPUser else { return false }
                return member.getId() == userId
            }) as? TPUser {
                self?.users.append(addUser)
                self?.tableView.reloadData()
            }
            
        }, failure: { (errorCode, error) in
        })
    }
    
    private func removeMember(userId: String, indexPath: IndexPath) {
        if let channel = channel {
            TalkPlus.sharedInstance()?.removeMember(to: channel, userId: userId, success: { [weak self] channelItem in
                self?.users.remove(at: indexPath.row)
                self?.tableView.beginUpdates()
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.tableView.endUpdates()
                
            }, failure: { (errorCode, error) in
            })
        }
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
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.getUsername()
        
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
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, index) in
            if let userId = self?.users[index.row].getId() {
                self?.removeMember(userId: userId, indexPath: index);
            }
        }
        
        return [delete]
    }
}
