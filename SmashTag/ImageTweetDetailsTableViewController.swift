//
//  ImageTweetDetailsTableViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 17/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import Twitter

protocol ImageTweetProtocol {
    func updateSearchText(_ text: String)
}
class ImageTweetDetailsTableViewController: UITableViewController{
    
    var delegate: ImageTweetProtocol?
    var tweet: Twitter.Tweet! { didSet { updateUI() } }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset.top = 20
        
        let nib = UINib(nibName: "ImageTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "imageCell")
    }
    
    private func updateUI(){
            print("count is \(tweet.urls.count)  \(tweet.hashtags.count)  \(tweet.userMentions.count)  ")
           tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return tweet.urls.count
        case 2:
            return tweet.hashtags.count
        case 3:
            return tweet.userMentions.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if tweet.user.profileImageURL != nil {
                return UITableViewAutomaticDimension
            }
            else{
                return 0
            }
        case 1:
            if tweet.urls.count != 0 {
                return UITableViewAutomaticDimension
            }
            else{
                return 0
            }
        case 2:
            if tweet.hashtags.count != 0 {
                return UITableViewAutomaticDimension
            }
            else{
                return 0
            }
        case 3:
            if tweet.userMentions.count != 0 {
                return UITableViewAutomaticDimension
            }
            else{
                return 0
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Images"
        case 1:
            return "Urls"
        case 2:
            return "Hashtags"
        case 3:
            return "User Mentions"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section==0 &&  indexPath.row==0 {
            return tableView.bounds.width
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
            DispatchQueue.main.async(){ [weak self] in
                if let profileImageURL = self?.tweet.user.profileImageURL {
                    if let imageData = try? Data(contentsOf: profileImageURL) {
                        cell.tweetImageView.image = UIImage(data: imageData)
                    }
                } else {
                    cell.tweetImageView.image = nil
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            cell.textLabel?.text = tweet.urls[indexPath.row].description
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            cell.textLabel?.text = tweet.hashtags[indexPath.row].description
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            cell.textLabel?.text = tweet.userMentions[indexPath.row].description
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "showImage") as! ImageViewController
                vc.imageURL = tweet.user.profileImageURL
                self.present(vc, animated: true, completion: nil)
                return
        case 1:
            let searchText = tweet.urls[indexPath.row].description
            let url = URL(string: searchText)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        case 2:
            print("Pressed \(indexPath.section)")
            self.delegate?.updateSearchText(tweet.hashtags[indexPath.row].description)
            self.navigationController?.popViewController(animated: true)
        case 3:
            print("Pressed \(indexPath.section)")
            self.delegate?.updateSearchText(tweet.userMentions[indexPath.row].description)
            self.navigationController?.popViewController(animated: true)
        default : break
        }
    }
}
