//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 08/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//
import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController , UINavigationControllerDelegate {
    private var container: NSPersistentContainer = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer)!
    fileprivate var tweets : [Twitter.Tweet] = [] {
        didSet {
            saveTweets(tweets)
            tableView.reloadData()
        }
    }
    var searchText: String? {
        didSet {
            searchForTweets(searchText: searchText!)
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets(searchText: searchText ?? "")
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45.0
        title = "Search Tweets"
        searchTextField?.text = searchText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchTextField.resignFirstResponder()
        
        if segue.identifier == "SmashTweetersTableViewControllerIdentifier" {
            if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.container = container
            }
        }
        else if segue.identifier == "tweetDetails" {
            if let _ = segue.destination as? ImageTweetDetailsTableViewController {
                if let cell = sender as? TweetTableViewCell , let indexPath = tableView.indexPath(for: cell) {
                    let tweet: Twitter.Tweet = tweets[indexPath.row]
                    let tdvc = segue.destination as! ImageTweetDetailsTableViewController
                    tdvc.tweet = tweet
                }
            }
        }
    }
    
    private func searchForTweets(searchText: String) {
        guard !searchText.isEmpty else {
            stopAnimating()
            return
        }
        
        let request = Twitter.Request(search: searchText, count: 100)
        startAnimating()

        DispatchQueue.global(qos: .userInitiated).async {
            request.fetchTweets { [weak self] newTweets in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.stopAnimating()
                    strongSelf.addSearchedTermToUserDefault(searchText: searchText)
                    strongSelf.tweets = newTweets
                }
            }
        }
    }
    
    fileprivate func startAnimating() {
        if let refreshControl = tableView.refreshControl {
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.bounds.height), animated: true)
            refreshControl.beginRefreshing()
        }
    }

    fileprivate func stopAnimating() {
        if let refreshControl = tableView.refreshControl {
            refreshControl.endRefreshing()
        }
    }
    
    func saveTweets(_ newTweets: [Twitter.Tweet]) {
        for tweet in newTweets{
            updateDatabase(with: tweet)
        }
        printDatabaseStatistics()
    }
    
    
    private func updateDatabase(with tweets: Twitter.Tweet){
        container.performBackgroundTask {context in
            _ = try? TweetsData.findOrCreateTweet(matching: tweets, in: context)
            try? context.save()
        }
    }
    
    private func printDatabaseStatistics(){
            container.viewContext.perform {
            if let tweetCount = try? self.container.viewContext.count(for: TweetsData.fetchRequest()) {
                print("\(tweetCount) tweets")
            }
            if let tweeterCount = try? self.container.viewContext.count(for : TwitterUser.fetchRequest()) {
                print("\(tweeterCount) twitter users")
            }
            if let userCount = try? self.container.viewContext.count(for : UserMentions.fetchRequest()) {
                print("\(userCount)  users")
            }
            if let hashtagCount = try? self.container.viewContext.count(for : HashTag.fetchRequest()) {
                print("\(hashtagCount) hashtags")
            }
        }
    }
    
    private func addSearchedTermToUserDefault(searchText: String) {
        let defaults = UserDefaults.standard
        var searchedTweets: [String] = defaults.stringArray(forKey: "searchedTweets") ?? []
        
        
        if searchedTweets.count == 100 {
            searchedTweets.removeLast()
        }
        
        searchedTweets.insert(searchText, at: 0)
        defaults.set(searchedTweets, forKey: "searchedTweets")
    }
}

extension TweetTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "test", for: indexPath) as! TweetTableViewCell
        cell.configureCellWithTweet(tweets[indexPath.row])
        
        return cell
    }
}

extension TweetTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchText = textField.text
        searchTextField.resignFirstResponder()
        
        return true
    }
}
