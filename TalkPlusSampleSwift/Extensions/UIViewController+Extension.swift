//
//  UIViewController+Extension.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/20.
//

import UIKit

extension UIViewController {
    
    func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 10
            
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            alert.dismiss(animated: true)
        }
    }
}
