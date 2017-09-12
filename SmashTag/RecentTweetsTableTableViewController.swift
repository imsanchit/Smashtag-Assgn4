//
//  RecentTweetsTableTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 21/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreData

class RecentTweetsTableTableViewController : UITableViewController{
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    private var searchedTweets: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedRecentTerms()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recently Searched"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedTweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentTweets", for: indexPath)
        cell.textLabel?.text = searchedTweets[indexPath.row].description
        cell.accessoryType = .detailButton
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MentionCountIdentifier") as! MentionCountTableViewController
        vc.mention = searchedTweets[indexPath.row].description
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadSavedRecentTerms() {
        searchedTweets = UserDefaults.standard.stringArray(forKey: "searchedTweets") ?? [String]()
    }
}
