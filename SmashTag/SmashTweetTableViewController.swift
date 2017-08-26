//
//  SmashTweetTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 09/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import Twitter

class SmashTweetTableViewController: TweetTableViewController {

    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
    }
    
       
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tweeters mentioning search term" {
            if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.container = container
            }
        }
        else if segue.identifier == "tweetDetails" {
            if let _ = segue.destination as? ImageTweetDetailsTableViewController {
                if let cell = sender as? TweetTableViewCell , let indexPath = tableView.indexPath(for: cell) {
                    let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
                    let tdvc = segue.destination as! ImageTweetDetailsTableViewController
                        tdvc.delegate = self
                        tdvc.tweet = tweet
                }
            }
        }
    }
}
