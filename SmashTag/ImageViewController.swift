//
//  ImageViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 20/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    fileprivate lazy var imageView = {
        return UIImageView()
    }()
    
    var imageURL: URL!{
        didSet{
            fetchImage()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.5
            scrollView.addSubview(imageView)
        }
    }
    
    @IBAction func moveBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
   
    private func fetchImage() {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let urlContents = try? Data(contentsOf: (self?.imageURL)!)
            if let imageData = urlContents {
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: imageData)
                    self?.imageView.sizeToFit()
                }
            }
        }
    }
}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
