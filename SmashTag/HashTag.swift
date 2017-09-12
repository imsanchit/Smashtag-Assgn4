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
    static func findOrCreateUserHashtag(matching twitterInfo: Mention , in context: NSManagedObjectContext) throws -> HashTag {
        let hashtag = HashTag(context: context)
        hashtag.desc = twitterInfo.description
        hashtag.keyword = twitterInfo.keyword
        return hashtag
    }
}
