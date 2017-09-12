//
//  UserMentions.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 12/09/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class UserMentions: NSManagedObject {
        static func findOrCreateUserMention(matching twitterInfo: Mention , in context: NSManagedObjectContext) throws -> UserMentions {
        let userMention = UserMentions(context: context)
        userMention.keyword = twitterInfo.keyword
        userMention.desc = twitterInfo.description
        return userMention
    }
}
