//
//  CreateViewController.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/15.
//

import UIKit
import TalkPlus

class CreateViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    
    var channelType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Create"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextAction))
        
        if channelType == TP_CHANNEL_TYPE_PRIVATE {
            titleLabel.text = "Private Channel"
            codeTextField.isHidden = true
            
        } else if channelType == TP_CHANNEL_TYPE_PUBLIC {
            titleLabel.text = "Public Channel"
            codeTextField.isHidden = true
            
        } else if channelType == TP_CHANNEL_TYPE_INVITATION_ONLY {
            titleLabel.text = "Invitation Code Channel"
            codeTextField.isHidden = false
        }
    }
    
    // MARK: - Action
    @objc func closeAction() {
        dismiss(animated: true)
    }
    
    @objc func nextAction() {
        if channelType == TP_CHANNEL_TYPE_INVITATION_ONLY {
            guard let code = codeTextField.text?.trimmingCharacters(in: .whitespaces), !code.isEmpty else {
                showToast("Invitation Code를 입력하세요")
                return
            }
        } 
        performSegue(withIdentifier: "SegueInvite", sender: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let inviteViewController = segue.destination as? InviteViewController {
            inviteViewController.channelType = channelType
            inviteViewController.channelName = nameTextField.text?.trimmingCharacters(in: .whitespaces)
            inviteViewController.invitationCode = codeTextField.text?.trimmingCharacters(in: .whitespaces)
        }
    }
}
