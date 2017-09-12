//
//  ImageTweetDetailsTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 17/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import Twitter

enum sectionTypes {
    case images
    case urls
    case hashtags
    case users
    
    func sectionTitle(_ tweet: Twitter.Tweet) -> String? {
        switch self {
        case .images:
            return tweet.media.count > 0 ? "Images" : nil
        case .urls:
            return tweet.urls.count > 0 ? "Urls" : nil
        case .hashtags:
            return tweet.hashtags.count > 0 ? "Hashtags" : nil
        case .users:
            return tweet.userMentions.count > 0 ? "User Mentions" : nil
        }
    }
    
    func numberOfRow(_ tweet: Twitter.Tweet) -> Int {
        switch self {
        case .images:
            return tweet.media.count
        case .urls:
            return tweet.urls.count
        case .hashtags:
            return tweet.hashtags.count
        case .users:
            return tweet.userMentions.count
        }
    }
    
    func description(for tweet : Twitter.Tweet , at indexPath: IndexPath) -> String {
        switch self {
        case .users:
            return tweet.userMentions[indexPath.row].description
        case .urls:
            return tweet.urls[indexPath.row].description
        case .hashtags:
            return tweet.hashtags[indexPath.row].description
        default:
            return ""
        }
    }
}



class ImageTweetDetailsTableViewController: UITableViewController{
    let sectionTypes: [sectionTypes] = [.images, .urls, .hashtags, .users]
    var tweet: Twitter.Tweet! {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45.0
        let nib = UINib(nibName: "ImageTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "imageCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTypes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sectionTypes[section]
        return sectionType.numberOfRow(tweet)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = sectionTypes[section]
        return sectionType.sectionTitle(tweet)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = sectionTypes[indexPath.section]

        switch sectionType {
        case .images:
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
            cell.configureCellWithMedia(tweet.media[indexPath.row])
            return cell
        case .hashtags, .urls, .users:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            cell.textLabel?.text = sectionType.description(for: tweet, at: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionType = sectionTypes[indexPath.section]
        switch sectionType {
        case .images:
            let navigationController = storyboard?.instantiateViewController(withIdentifier: "ImageViewNavigationControllerIdentifier") as! UINavigationController
            let vc = navigationController.topViewController as! ImageViewController
            vc.imageURL = tweet.media[indexPath.row].url
            self.present(navigationController, animated: true, completion: nil)
            return
        case .urls:
            let searchText = sectionType.description(for: tweet, at: indexPath)
            let url = URL(string: searchText)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        case .hashtags, .users:
            let vc = storyboard?.instantiateViewController(withIdentifier: "TweetTableControlllerIdentifier") as! TweetTableViewController
            vc.searchText = sectionType.description(for: tweet, at: indexPath)
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let mediaItem = tweet.media[indexPath.row]
            let aspectRatio = mediaItem.aspectRatio
            let height = UIScreen.main.bounds.width * CGFloat(aspectRatio)
            
            return height
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
