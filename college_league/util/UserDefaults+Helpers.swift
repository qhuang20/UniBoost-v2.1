//
//  UserDefaults+helpers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-18.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isEyeSelected
    }
    
    func setEyeSelected(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isEyeSelected.rawValue)
    }
    
    func isEyeSelected() -> Bool {
        return bool(forKey: UserDefaultsKeys.isEyeSelected.rawValue)
    }
    
}



