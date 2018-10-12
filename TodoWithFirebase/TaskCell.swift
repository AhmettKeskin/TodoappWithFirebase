//
//  TaskCell.swift
//  TodoWithFirebase
//
//  Created by Ahmet on 8.10.2018.
//  Copyright © 2018 Ahmet Keskin. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    
    var task: Task!
    
    func configure(task: Task) {
        self.task = task
        self.taskLabel.text = task.taskDesc
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.taskLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.taskLabel.textColor = UIColor.gray.withAlphaComponent(0.8)
        selectionStyle = .none
        
    }
    
}
