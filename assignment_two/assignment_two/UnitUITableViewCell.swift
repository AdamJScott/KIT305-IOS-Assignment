//
//  UnitUITableViewCell.swift
//  assignment_two
//
//  Created by Swift Labourer on 10/5/21.
//

import UIKit

class UnitUITableViewCell: UITableViewCell {

    @IBOutlet var unitNameLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
