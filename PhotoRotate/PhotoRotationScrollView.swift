//
//  PhotoRotationScrollView.swift
//  PhotoRotate
//
//  Created by Luan on 11/4/16.
//  Copyright © 2016 Shutta. All rights reserved.
//

import UIKit

class PhotoRotationScrollView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        return self
//        let extendRadius: CGFloat = 1000
//        
//        let hitFrame = CGRect(x: -extendRadius, y: -extendRadius, width: self.frame.size.width + 2 * extendRadius, height: self.frame.size.height + 2 * extendRadius)
//        
//        if hitFrame.contains(point) {
//            return self
//        }
//        return nil
    }

}
