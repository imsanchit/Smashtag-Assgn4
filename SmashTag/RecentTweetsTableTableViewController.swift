//
//  RecentTweetsTableTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 21/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreData

class RecentTweetsTableTableViewController: UITableViewController {

    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    var searchedTweets: [String] = []
    
    override func viewDidLoad() {
//        tableView.contentInset.top = 20
        let defaults = UserDefaults.standard
        searchedTweets = defaults.stringArray(forKey: "searchedTweets") ?? [String]()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.performSegue(withIdentifier: "open mention count", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "open mention count" {
            if let indexPath = tableView.indexPathForSelectedRow{
                if let mcTVC = segue.destination as? MentionCountTableViewController {
                mcTVC.mention = self.searchedTweets[indexPath.row].description
                mcTVC.container = self.container
                }
            }
        }
    }
}
