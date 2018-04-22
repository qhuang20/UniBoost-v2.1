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
        case schoolName
        case isSharingHintsShowed
    }
    
    
    
    func setSchool(value: String?) {
        set(value, forKey: UserDefaultsKeys.schoolName.rawValue)
    }
    
    func getSchool() -> String? {
        return string(forKey: UserDefaultsKeys.schoolName.rawValue)
    }
    
    
    
    func setEyeSelected(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isEyeSelected.rawValue)
    }
    
    func isEyeSelected() -> Bool {
        return bool(forKey: UserDefaultsKeys.isEyeSelected.rawValue)
    }
    
    
    
    func setSharingHintShowed(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isSharingHintsShowed.rawValue)
    }
    
    func isSharingHintShowed() -> Bool {
        return bool(forKey: UserDefaultsKeys.isSharingHintsShowed.rawValue)
    }
    
}



