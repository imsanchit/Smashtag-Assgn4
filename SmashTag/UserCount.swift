//
//  UserCount.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 24/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreData

class UserCount: NSManagedObject {


    static func CreateUser(_ searchTerm: String , _ user: String, in context: NSManagedObjectContext) throws -> UserCount {
            let userCount = UserCount(context: context)
            userCount.searchTerm = searchTerm
            userCount.user = user
            return userCount
    }
}
