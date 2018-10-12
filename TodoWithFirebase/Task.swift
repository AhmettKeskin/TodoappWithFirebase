//
//  Task.swift
//  TodoWithFirebase
//
//  Created by Ahmet on 9.10.2018.
//  Copyright © 2018 Ahmet Keskin. All rights reserved.
//

import UIKit

class Task: NSObject {

    var key: String = ""
    var taskDesc: String = ""
    var date: String = ""
    
    init(dict: [String : String]?, key: String?) {
        
        guard let unwrappedDict = dict else { return }
        
        if let desc = unwrappedDict["taskDesc"] {
            self.taskDesc = desc
        }
        
        if let date = unwrappedDict["date"] {
            self.date = date
        }
        
        if let key = key {
            self.key = key
        }

    }
    
}
