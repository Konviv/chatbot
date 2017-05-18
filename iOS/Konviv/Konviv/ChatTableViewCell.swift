//
//  ChatTableViewCell.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 8/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var bubbleReceiveTextView: UITextView!
    @IBOutlet weak var bubbleSendTextView: UITextView!
    @IBOutlet weak var btnLinkAccount: UIButton!
    @IBOutlet weak var iconChat: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
               // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
