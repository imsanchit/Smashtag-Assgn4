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

class MentionCountTableViewController: UITableViewController {
    var mention: String? {
        didSet {
            updateUI()
        }
    }
    //    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet { updateUI() } }
    var usersRecord: [String: Int] = [:]
    var hashtagsRecord: [String: Int] = [:]
    var sortedUserRecords:[(key: String, value: Int)] = []
    var sortedHashtagRecords:[(key: String, value: Int)] = []
    fileprivate var tweets : [Twitter.Tweet] = [] {
        didSet {
            for tweet in tweets {
                for item in tweet.userMentions {
                    usersRecord[item.description] = (usersRecord[item.description] ?? 0) + 1
                }
                for item in tweet.hashtags {
                    hashtagsRecord[item.description] = (hashtagsRecord[item.description] ?? 0) + 1
                }
            }
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
    
    func startAnimating() {
        if let refreshControl = tableView.refreshControl {
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.bounds.height), animated: true)
            refreshControl.beginRefreshing()
        }
    }
    
    func stopAnimating() {
        if let refreshControl = tableView.refreshControl {
            refreshControl.endRefreshing()
        }
    }
}


/*Core data stuff
 
 private func getUsers(){
 
 
 
 
 //    find all users ever mentioned in tweets searched with this searched term
 
 
 
 if let context = container?.viewContext, mention != nil {
 let request: NSFetchRequest<UserCount> = UserCount.fetchRequest()
 request.predicate = NSPredicate(format: "searchTerm = %@", mention!)
 request.returnsDistinctResults = true
 request.resultType = NSFetchRequestResultType.dictionaryResultType
 let sumED = NSExpressionDescription()
 sumED.expression = NSExpression(format: "count:(user)")
 sumED.name = "countOfUser"
 sumED.expressionResultType = .stringAttributeType
 request.propertiesToFetch = ["user", sumED]
 request.propertiesToGroupBy = ["user"]
 request.sortDescriptors = [NSSortDescriptor(
 key: "user",
 ascending: true,
 selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
 )]
 
 do {
 let results = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
 
 for a in results {
 var c = (a as AnyObject).description!
 c = c.replacingOccurrences(of: "{\n    ", with: "")
 c = c.replacingOccurrences(of: ";\n    ", with: "")
 c = c.replacingOccurrences(of: ";\n}", with: "")
 c = c.replacingOccurrences(of: "countOfUser = ", with: "")
 c = c.replacingOccurrences(of: "user = ", with: " ")
 c = c.replacingOccurrences(of: "\"", with: "")
 let words = c.components(separatedBy: " ")
 let firstName = Int(words[0])
 if(firstName! > 1){
 users.append(words[1])
 uc.append(firstName!)
 }
 }
 var swapped = false
 if users.count > 0 {
 for i in 0 ..< users.count-1 {
 swapped = false
 for j in 0 ..< users.count-i-1 {
 if (uc[j] < uc[j+1]) {
 swap(&uc[j], &uc[j+1]);
 swap(&users[j], &users[j+1]);
 swapped = true;
 }
 }
 if (swapped == false){
 break
 }
 }
 }
 }catch{
 print("Cannot fetch")
 }
 }
 private func getHashtags(){
 if let context = container?.viewContext, mention != nil {
 let request: NSFetchRequest<HashtagCount> = HashtagCount.fetchRequest()
 request.returnsDistinctResults = true
 request.predicate = NSPredicate(format: "searchTerm = %@", mention!)
 request.resultType = .dictionaryResultType
 let sumED = NSExpressionDescription()
 sumED.expression = NSExpression(format: "count:(hashTag)")
 sumED.name = "countOfHashtag"
 sumED.expressionResultType = .stringAttributeType
 request.propertiesToFetch = ["hashTag", sumED]
 request.propertiesToGroupBy = ["hashTag"]
 request.sortDescriptors = [NSSortDescriptor(
 key: "hashTag",
 ascending: true,
 selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
 )]
 
 do {
 let results = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
 
 for a in results {
 var c = (a as AnyObject).description!
 c = c.replacingOccurrences(of: "{\n    ", with: "")
 c = c.replacingOccurrences(of: ";\n    ", with: "")
 c = c.replacingOccurrences(of: ";\n}", with: "")
 c = c.replacingOccurrences(of: "countOfHashtag = ", with: "")
 c = c.replacingOccurrences(of: "hashTag = ", with: " ")
 c = c.replacingOccurrences(of: "\"", with: "")
 let words = c.components(separatedBy: " ")
 let firstName = Int(words[0])
 if(firstName! > 1){
 hashtags.append(words[1])
 hc.append(firstName!)
 }
 }
 var swapped = false
 if hashtags.count > 0 {
 for i in 0 ..< hashtags.count-1 {
 swapped = false
 for j in 0 ..< hashtags.count-i-1 {
 if (hc[j] < hc[j+1]) {
 swap(&hc[j], &hc[j+1]);
 swap(&hashtags[j], &hashtags[j+1]);
 swapped = true;
 }
 }
 if (swapped == false){
 break
 }
 }
 }
 }catch{
 print("Cannot fetch")
 }
 
 }
 }*/
