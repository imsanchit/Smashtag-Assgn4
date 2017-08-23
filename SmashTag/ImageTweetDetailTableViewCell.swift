//
//  ImageTweetDetailTableViewCell.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 18/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import Twitter

class ImageTweetDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetProfileImageTableViewCell: ImageTableViewCell!
    
    public func configureCellWithTweet(_ tweet: Twitter.Tweet) {
        print("Entered image with tweet")
        
        if let profileImageURL = tweet.user.profileImageURL {
            if let imageData = try? Data(contentsOf: profileImageURL) {
                    tweetProfileImageTableViewCell.imageView?.image = UIImage(data: imageData)
            }
        } else {
                tweetProfileImageTableViewCell.imageView?.image = nil
        }
    }
}
