//
//  HashTag.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 12/09/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class HashTag: NSManagedObject {
    static func findOrCreateUserHashtag(_ tweet : TweetsData, matching hastag: Mention , in context: NSManagedObjectContext) throws {
        
        let request: NSFetchRequest<HashTag> = HashTag.fetchRequest()
        request.predicate = NSPredicate(format: "keyword = %@", hastag.keyword)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
//                assert(matches.count > 1, "hash Tags duplicate added -- database incosistency")
                
                return
            }
        }
        catch{
            throw error
        }

        let hashtag = HashTag(context: context)
        hashtag.desc = hastag.description
        hashtag.keyword = hastag.keyword
        hashtag.tweets = tweet
    }
}
