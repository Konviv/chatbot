//
//  UserAccountsTableViewCell.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 8/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class UserAccountsTableViewCell: UITableViewCell {

    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var amount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
