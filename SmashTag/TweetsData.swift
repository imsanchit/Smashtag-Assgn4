//
//  Tweet.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 09/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class TweetsData: NSManagedObject {
    static func findOrCreateTweet(matching twitterInfo: Twitter.Tweet , in context: NSManagedObjectContext) throws -> TweetsData {
        let request: NSFetchRequest<TweetsData> = TweetsData.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.identifier)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
//                assert(matches.count > 1, "Tweet.findOrCreateTweet -- database incosistency")
                
                return matches[0]
            }
        }
        catch{
            throw error
        }
        
        let tweetsData = TweetsData(context: context)
        tweetsData.unique = twitterInfo.identifier
        tweetsData.text = twitterInfo.text
        tweetsData.created = twitterInfo.created as NSDate
        
        do {
            tweetsData.tweeter = try TwitterUser.findOrCreateTwitterUser(matching: twitterInfo.user, in: context)
            
            for userMention in twitterInfo.userMentions {
                try UserMentions.findOrCreateUserMention(tweetsData ,matching: userMention, in: context)
            }

            for hashtag in twitterInfo.hashtags {
                try HashTag.findOrCreateUserHashtag(tweetsData, matching: hashtag, in: context)
            }
        } catch {
            throw error
        }
        
        return tweetsData
    }
}
