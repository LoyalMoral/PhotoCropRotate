//
//  ViewController.swift
//  PhotoRotate
//
//  Created by Luan on 11/3/16.
//  Copyright © 2016 Shutta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var imageContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let storyboard = UIStoryboard(name: "PhotoRotation", bundle: nil)
        
        let vc: PhotoRotationViewController = storyboard.instantiateInitialViewController() as! PhotoRotationViewController
        
        self.addChildViewController(vc)
        self.imageContainerView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.imageContainerView.addConstraints([
            NSLayoutConstraint(item: imageContainerView,
                               attribute: NSLayoutAttribute.top,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: vc.view,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: imageContainerView,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: vc.view,
                               attribute: NSLayoutAttribute.bottom,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: imageContainerView,
                               attribute: NSLayoutAttribute.leading,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: vc.view,
                               attribute: NSLayoutAttribute.leading,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: imageContainerView,
                               attribute: NSLayoutAttribute.trailing,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: vc.view,
                               attribute: NSLayoutAttribute.trailing,
                               multiplier: 1,
                               constant: 0),
            
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

