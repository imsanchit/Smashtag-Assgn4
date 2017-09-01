//
//  MentionCountTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 24/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreData

class MentionCountTableViewController: FetchedResultsTableViewController {

    var mention: String? { didSet { updateUI() } }
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet { updateUI() } }
    var users: [String] = []
    var uc: [Int] = []
    var hashtags: [String] = []
    var hc: [Int] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
    }
    
    
    
    private func getUsers(){
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
            print("data is having count \(results.count)")
            
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
                print("data is having count \(results.count)")
                
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
    }
    
    private func updateUI() {
                getUsers()
                getHashtags()
                tableView.reloadData()
             }
   override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "User"
        case 1:
            return "HashTag"
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return users.count
        case 1:
            return hashtags.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mention count", for: indexPath)

        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = users[indexPath.row]
            cell.detailTextLabel?.text = String(uc[indexPath.row])
        case 1:
            cell.textLabel?.text = hashtags[indexPath.row]
            cell.detailTextLabel?.text = String(hc[indexPath.row])
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let navController =  self.tabBarController?.viewControllers?[0] as! UINavigationController
        let sTVC = navController.visibleViewController as! SmashTweetTableViewController
        if indexPath.section == 0 {
            sTVC.searchText = users[indexPath.row]
        }
        else {
            sTVC.searchText = hashtags[indexPath.row]
        }
        self.navigationController?.popViewController(animated: true)
        tabBarController?.selectedIndex = 0
    }
}
