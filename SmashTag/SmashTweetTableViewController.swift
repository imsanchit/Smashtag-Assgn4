//
//  SmashTweetTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 09/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {

    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]){
        print("starting database load")
        container?.performBackgroundTask { [weak self] context in
            for twitterInfo in tweets {
                _ = try? Tweet.findOrCreateTweet(matching: twitterInfo, in: context)
            }
            try? context.save()
            print("done loading database")
            self?.printDatabaseStatistics()
        }
    }
    
    private func printDatabaseStatistics(){
        if let context = container?.viewContext {
            context.perform {
                if let tweetCount = try? context.count(for: Tweet.fetchRequest()) {
                    print("\(tweetCount) tweets")
                }
                if let tweeterCount = try? context.count(for : TwitterUser.fetchRequest()) {
                    print("\(tweeterCount) twitter users")
                }
            }
        }
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
