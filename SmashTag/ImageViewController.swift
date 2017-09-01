//
//  ImageViewController.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 20/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController , UIScrollViewDelegate {

    
    var imageView = UIImageView()

    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.5
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    var imageURL: URL!{
        didSet{
            fetchImage()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    self?.imageView.frame.size.height = UIScreen.main.bounds.height
                    self?.imageView.frame.size.width = UIScreen.main.bounds.width
                }
            }
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
