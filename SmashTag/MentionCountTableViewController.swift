//
//  MentionCountTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 24/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreData
import Twitter

enum SectionType {
    case user
    case hashtag
    
    func sectionTitle() -> String {
        switch self {
        case .user:
            return "User"
        case .hashtag:
            return "HashTag"
        }
    }
}

class MentionCountTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var mention: String? {
        didSet {
            updateUI()
        }
    }
    var container: NSPersistentContainer = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer { didSet { updateUI() } }
    var fetchedResultsController: NSFetchedResultsController<UserMentions>?
    var usersRecord: [String: Int] = [:]
    var hashtagsRecord: [String: Int] = [:]
    var sortedUserRecords:[(key: String, value: Int)] = []
    var sortedHashtagRecords:[(key: String, value: Int)] = []
    fileprivate var tweets : [Twitter.Tweet] = [] {
        didSet {
            loadUsersAndHashtags()
            sortUsersAndHashtags()
            tableView.reloadData()
        }
    }
    fileprivate var sectionType: [SectionType] = [.user , .hashtag]
    @IBAction func refresh(_ sender: UIRefreshControl) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData(){
        let request = Twitter.Request(search: mention!, count: 100)
        startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            request.fetchTweets { [weak self] newTweets in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.tweets = newTweets
                    strongSelf.stopAnimating()
                }
            }
        }
    }
    private func updateUI() {
//      getUsers()
//      getHashtags()
//      tableView.reloadData()
    }
    
}
extension MentionCountTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count > 0 ? sectionType.count : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionType[section].sectionTitle()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionType[section] {
        case .user:
            return sortedUserRecords.count
        case .hashtag:
            return sortedHashtagRecords.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mention count", for: indexPath)
        switch sectionType[indexPath.section] {
        case .user:
            cell.textLabel?.text = sortedUserRecords[indexPath.row].key
            cell.detailTextLabel?.text = String(sortedUserRecords[indexPath.row].value)
        case .hashtag:
            cell.textLabel?.text = sortedHashtagRecords[indexPath.row].key
            cell.detailTextLabel?.text = String(sortedHashtagRecords[indexPath.row].value)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TweetTableControlllerIdentifier") as! TweetTableViewController
        switch sectionType[indexPath.section] {
        case .user:
            vc.searchText = sortedUserRecords[indexPath.row].key
        case .hashtag:
            vc.searchText = sortedHashtagRecords[indexPath.row].key
        }
        navigationController?.pushViewController(vc, animated: true)        
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
    
    fileprivate func loadUsersAndHashtags() {
        let request: NSFetchRequest<UserMentions> = UserMentions.fetchRequest()
        
        request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention!)
        do {
            let fetched = try container.viewContext.fetch(request)
            print(fetched.count)
        }
        catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        for tweet in tweets {
            for item in tweet.userMentions {
                usersRecord[item.description] = (usersRecord[item.description] ?? 0) + 1
            }
            for item in tweet.hashtags {
                hashtagsRecord[item.description] = (hashtagsRecord[item.description] ?? 0) + 1
            }
        }
    }
    
    fileprivate func sortUsersAndHashtags() {
        sortedUserRecords = usersRecord.sorted(by: {
            if $0.value != $1.value {
                return $0.value > $1.value
            } else {
                return String($0.key) < String($1.key)
            }
        })
        sortedHashtagRecords = hashtagsRecord.sorted(by: {
            if $0.value != $1.value {
                return $0.value > $1.value
            } else {
                return String($0.key) < String($1.key)
            }
        })
        sortedUserRecords = sortedUserRecords.filter({ $0.value != 1 })
        sortedHashtagRecords = sortedHashtagRecords.filter({ $0.value != 1 })

    }
}
