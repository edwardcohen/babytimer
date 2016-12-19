//
//  InAppHelper.swift
//  Goodnight Moon
//
//  Created by Yogesh Prajapati on 12/16/16.
//  Copyright © 2016 Jason Toff. All rights reserved.
//

import Foundation


class InAppHelper {
    
    static let shared = InAppHelper()
    
    func getRemoveAdProductId() -> String {
        return "custimizable"
    }
    
    func isRemoveAdPurchased() -> Bool {
        return UserDefaults.standard.bool(forKey: getRemoveAdProductId())
    }
    
    func setRemoveAdPurchased() {
        UserDefaults.standard.set(true, forKey: getRemoveAdProductId())
    }
}
