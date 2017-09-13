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
    static func findOrCreateUserMention(_ tweet : TweetsData, matching mention: Mention , in context: NSManagedObjectContext) throws  {
        let request: NSFetchRequest<UserMentions> = UserMentions.fetchRequest()
        request.predicate = NSPredicate(format: "keyword = %@", mention.keyword)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
//                assert(matches.count > 1, "UserMentions duplicate added -- database incosistency")
                
                return
            }
        }
        catch{
            throw error
        }
        
        let userMention = UserMentions(context: context)
        userMention.keyword = mention.keyword
        userMention.desc = mention.description
        userMention.tweets = tweet
    }
}
