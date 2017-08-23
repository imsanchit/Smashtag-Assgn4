//
//  TweetUser.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 09/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class TweetUser: NSManagedObject {

    static func findOrCreateTwitterUser(matching twitterInfo: Twitter.User , in context: NSManagedObjectContext) throws -> TweetUser {
        let request: NSFetchRequest<TweetUser> = TweetUser.fetchRequest()
        request.predicate = NSPredicate(format: "handle = %@", twitterInfo.screenName)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count > 1, "TweetUser.findOrCreateTwitterUser -- database incosistency")
                return matches[0]
            }
        }
        catch{
            throw error
        }
        let tweetUser = TweetUser(context: context)
        tweetUser.handle = twitterInfo.screenName
        tweetUser.name = twitterInfo.name

        return twitterUser
    }

}
