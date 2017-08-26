//
//  HashtagCount.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 24/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreData

class HashtagCount: NSManagedObject {
    
    
    
    static func CreateHashtag(_ searchTerm: String , _ hashtag: String, in context: NSManagedObjectContext) throws -> HashtagCount {
        let hashtagCount = HashtagCount(context: context)
        hashtagCount.searchTerm = searchTerm
        hashtagCount.hashTag = hashtag
        return hashtagCount
    }
}
