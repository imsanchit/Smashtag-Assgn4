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
    var usersRecord: [String: Int] = [:]
    var hashtagsRecord: [String: Int] = [:]
    var sortedUserRecords:[(key: String, value: Int)] = []
    var sortedHashtagRecords:[(key: String, value: Int)] = []
    fileprivate var sectionType: [SectionType] = [.user , .hashtag]
    
    private func updateUI() {
        loadUsersAndHashtags()
        sortUsersAndHashtags()
        tableView.reloadData()
    }
    
    func loadUsersAndHashtags() {
        let request: NSFetchRequest<TweetsData> = TweetsData.fetchRequest()
        
        request.predicate = NSPredicate(format: "any text contains[c] %@", mention!)
        do {
            let fetched = try container.viewContext.fetch(request)
            print(fetched.count)
            var mentions: [UserMentions] = []
            var hashtags: [HashTag] = []
            
            for fetch in fetched {
                if let savedMentions: [UserMentions] = fetch.userMention?.allObjects as? [UserMentions] {
                    mentions.append(contentsOf: savedMentions)
                }
                if let savedMentions: [HashTag] = fetch.hashTags?.allObjects as? [HashTag] {
                    hashtags.append(contentsOf: savedMentions)
                }
            }
            for item in hashtags {
                hashtagsRecord[(String(describing: item.keyword!))] = (hashtagsRecord[(String(describing: item.keyword!))] ?? 0) + 1
            }
            for item in mentions {
                usersRecord[(String(describing: item.keyword!))] = (usersRecord[(String(describing: item.keyword!))] ?? 0) + 1
            }
        }
        catch {
            fatalError("Failed to fetch data: \(error)")
        }
    }
    
    func sortUsersAndHashtags() {
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
extension MentionCountTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionType.count 
        
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
}
