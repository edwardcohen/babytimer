//
//  Setting.swift
//  Goodnight Moon
//
//  Created by Eddie Cohen & Jason Toff on 8/11/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import Foundation
import CoreData


class Setting: NSManagedObject {
    @NSManaged var playOnLaunch: NSNumber!
    @NSManaged var fadeTime: NSNumber!
    @NSManaged var timerDefault: NSNumber!
    @NSManaged var soundName: NSString!
}
