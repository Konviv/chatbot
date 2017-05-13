//
//  HistoryItemTableViewCell.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 10/5/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class HistoryItemTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var lblAmount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
