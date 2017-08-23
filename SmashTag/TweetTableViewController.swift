//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 08/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import Twitter


class TweetTableViewController: UITableViewController , UITextFieldDelegate , ImageTweetProtocol , UINavigationControllerDelegate
{
    func updateSearchText(_ text: String) {
        print("Set")
        searchText = text
    }
    
    var tweets = [Array<Twitter.Tweet>]()
    
    
    
    
    var searchText: String? {
            didSet {
                searchTextField?.text = searchText
                searchTextField?.resignFirstResponder()
                lastTwitterRequest = nil
                tweets.removeAll()
                tableView.reloadData()
                searchForTweets()
                title = searchText
                
                let defaults = UserDefaults.standard
                var searchedTweets = defaults.stringArray(forKey: "searchedTweets") ?? [String]()
                if searchedTweets.count==100 {
                    searchedTweets.remove(at: 99)
                    
                    for i in (1...98).reversed() {
                        let element = searchedTweets.remove(at: i)
                        searchedTweets.insert(element, at: i+1)
                    }
                }
                searchedTweets.insert(searchText!, at: 0)
                defaults.set(searchedTweets, forKey: "searchedTweets")
            }
    }
    
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets , at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: query, count: 100)
        }
        return nil
    }
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest {
                        self?.tweets.insert(newTweets, at:0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
            searchForTweets()
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        } }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "test", for: indexPath)
        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.configureCellWithTweet(tweet)
        }
        return cell }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count-section)"
    }
}
