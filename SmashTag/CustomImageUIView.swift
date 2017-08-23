//
//  CustomImageUIView.swift
//  SmashTag
//
//  Created by Sanchit Mittal on 18/08/17.
//  Copyright © 2017 Sanchit Mittal. All rights reserved.
//

import UIKit

class CustomImageUIView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("CustomImageUIView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight , .flexibleWidth]
    }

}
