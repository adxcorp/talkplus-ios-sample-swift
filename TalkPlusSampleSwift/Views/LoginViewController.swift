//
//  LoginViewController.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/06.
//

import UIKit
import TalkPlus

class LoginViewController: UIViewController {
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userId = UserDefaults.standard.string(forKey: "KeyUserID"),
           let userName = UserDefaults.standard.string(forKey: "KeyUserName") {
            userIdTextField.text = userId
            nicknameTextField.text = userName
            
            login()
        }
    }
    
    // MARK: - Action
    @IBAction func loginAction(_ sender: Any) {
        login()
    }
    
    // MARK: - Login
    private func login() {
        guard let userId = userIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let userName = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !userId.isEmpty, !userName.isEmpty else { return }

        TalkPlus.sharedInstance()?.login(withAnonymous: userId, username: userName, profileImageUrl: nil, metaData: nil,
                                         success: { [weak self] tpUser in
                                            guard let tpUser = tpUser, let userId = tpUser.getId(),
                                                  let userName = tpUser.getUsername() else { return }
                                            
                                            PushManager.shared.registerFCMToken();
                                            
                                            UserDefaults.standard.set(userId, forKey: "KeyUserID")
                                            UserDefaults.standard.set(userName, forKey: "KeyUserName")
                                            UserDefaults.standard.synchronize()
                                            
                                            self?.performSegue(withIdentifier: "SegueMain", sender: nil)

                                         }, failure: { [weak self] (errorCode, error) in
                                            self?.showToast("로그인에 실패하였습니다")
                                         })
    }
}
