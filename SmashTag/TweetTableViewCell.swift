//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 08/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import Twitter


class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    public func configureCellWithTweet(_ tweet: Twitter.Tweet) {
        let mainText = tweet.text
        var attributeText = ""
        var range = (mainText as NSString).range(of: attributeText)
        let attributedString = NSMutableAttributedString(string:mainText)
        
        for i in 0 ..< tweet.urls.count {
            attributeText = tweet.urls[i].description
            range = (mainText as NSString).range(of: attributeText)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.brown, range: range)
        }
        for i in 0 ..< tweet.hashtags.count {
            attributeText = tweet.hashtags[i].description
            range = (mainText as NSString).range(of: attributeText)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: range)
        }
        for i in 0 ..< tweet.userMentions.count {
            attributeText = tweet.userMentions[i].description
            range = (mainText as NSString).range(of: attributeText)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: range)
        }
        tweetTextLabel.attributedText = attributedString
        tweetUserLabel?.text = tweet.user.description
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
            else {
                self?.tweetProfileImageView?.image = nil
            }
        }
        let formatter = DateFormatter()
        if Date().timeIntervalSince(tweet.created) > 24*60*60 {
            formatter.dateStyle = .short
        } else {
            formatter.timeStyle = .short
        }
        tweetCreatedLabel?.text = formatter.string(from: tweet.created)
    }
}
