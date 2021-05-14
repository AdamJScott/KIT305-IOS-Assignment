//
//  StudentUITableViewCell.swift
//  assignment_two
//
//  Created by Swift Labourer on 11/5/21.
//

import UIKit

class StudentUITableViewCell: UITableViewCell {
    
    @IBOutlet var studentNameLabel: UILabel!
    
    @IBOutlet var studentGradeField: UITextField!
    
    @IBOutlet var studentIDLabel: UILabel!
    
    @IBOutlet var gradeStepper: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
