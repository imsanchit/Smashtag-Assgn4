//
//  ImageTableViewCell.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 18/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit
import Twitter

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var tweetImageView: UIImageView! {
        didSet {
            tweetImageView.layer.borderWidth = (5 / UIScreen.main.scale)
            tweetImageView.layer.borderColor = UIColor.black.cgColor
            tweetImageView.layer.masksToBounds = true
            
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .gray
            tweetImageView.addSubview(activityIndicator)
        }
    }
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    public func configureCellWithMedia(_ mediaItem: MediaItem) {
        let imageURL = mediaItem.url
        startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            do {
                let imageData = try Data(contentsOf: imageURL)
                DispatchQueue.main.async {
                    strongSelf.stopAnimating()
                    strongSelf.tweetImageView.image = UIImage(data: imageData)
                }
            } catch let error {
                print("\(error)")
            }
        }
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
