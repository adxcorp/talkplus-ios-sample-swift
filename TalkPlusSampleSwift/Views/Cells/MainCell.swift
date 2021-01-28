//
//  MainCell.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/08.
//

import UIKit

class MainCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var unreadCountView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unreadCountView.layer.cornerRadius = unreadCountView.frame.height / 2
        unreadCountView.layer.masksToBounds = true
    }
}
