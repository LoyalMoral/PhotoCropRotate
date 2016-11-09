//
//  PhotoRotationContainerViewController.swift
//  PhotoRotate
//
//  Created by Luan on 11/9/16.
//  Copyright © 2016 Shutta. All rights reserved.
//

import UIKit

class PhotoRotationContainerViewController: UIViewController {
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var rotateSlider: UISlider!
    
    var photoRotationController: PhotoRotationViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let storyboard = UIStoryboard(name: "PhotoRotation", bundle: nil)
        
        let vc: PhotoRotationViewController = storyboard.instantiateInitialViewController() as! PhotoRotationViewController
        vc.photoRotationContainer = self
        photoRotationController = vc
        
        vc.image = UIImage(named: "001 - 1920x1200.jpg")!
        //        vc.image = UIImage(named: "page1_background")!
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Events
    
    @IBAction func didChangeSlider(_ sender: UISlider) {
        
        photoRotationController.didChangeSlider(sender)
    }
    
    @IBAction func didPressResetButton(_ sender: UIButton) {
        
        photoRotationController.reset()
    }
    
    @IBAction func didPressSaveButton(_ sender: UIButton) {
        
        photoRotationController.save()
    }

}
