//
//  PhotoRotationViewController.swift
//  PhotoRotate
//
//  Created by Luan on 11/3/16.
//  Copyright © 2016 Shutta. All rights reserved.
//

import UIKit

struct ActivePanCrop {
    
    var top = false
    var right = false
    var bottom = false
    var left = false
    
    mutating func setActive(t: Bool? = nil, r: Bool? = nil, b: Bool? = nil, l: Bool? = nil) {
        
        top = t ?? top
        right = r ?? right
        bottom = b ?? bottom
        left = l ?? left
    }
    
    mutating func reset() {
        
        setActive(t: false, r: false, b: false, l: false)
    }
    
    func isActive() -> Bool {
        
        let activeCrop = top || right || bottom || left
        return activeCrop
    }
}

class PhotoRotationViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var topCropConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftCropConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightCropConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomCropConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topLeftPanCropView: UIView!
    
    @IBOutlet weak var topPanCropView: UIView!
    
    @IBOutlet weak var topRightPanCropView: UIView!
    
    @IBOutlet weak var rightPanCropView: UIView!
    
    @IBOutlet weak var bottomRightPanCropView: UIView!
    
    @IBOutlet weak var bottomPanCropView: UIView!
    
    @IBOutlet weak var bottomLeftPanCropView: UIView!
    
    @IBOutlet weak var leftPanCropView: UIView!
    
    @IBOutlet weak var cropMaskView: UIView!
    
    @IBOutlet weak var imageScrollView: PhotoRotationScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cropAreaView: UIView!
    
    
    // MARK: - Properties
    
    var image: UIImage! = UIImage(named: "page1_background")!
    
    
    var activePanCrop = ActivePanCrop()
    
    var beganCropPanLocation = CGPoint(x: 0, y: 0)
    var previousCropPanLocation: CGPoint!
    
    var panCropGesture: UIPanGestureRecognizer!
    var rotateGesture: UIRotationGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.imageView.image = image
        
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForScrollView()
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

    // MARK: - Methods
    
    func setupUI() {
        
        panCropGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanCropGesture(_:)))
        panCropGesture.maximumNumberOfTouches = 1
        panCropGesture.minimumNumberOfTouches = 1
        panCropGesture.delegate = self
//        panCropGesture.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(panCropGesture)
        
        rotateGesture = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotateGesture(_:)))
        self.view.addGestureRecognizer(rotateGesture)
 
        imageScrollView.delegate = self
        imageScrollView.maximumZoomScale = 2
        imageScrollView.scrollsToTop = false
        
        imageScrollView.layer.borderColor = UIColor.white.cgColor
        imageScrollView.layer.borderWidth = 3
        
        syncScrollViewConstraintWithCropMask()
        
        
        
    }
    
    func resetActivePanCropDirections() {
        
        activePanCrop.setActive(t: false, r: false, b: false, l: false)
    }
    
    func updateMinZoomScaleForScrollView() {
        
        let imageSize: CGSize = image.size
        if (image == nil || imageSize.width <= 0 || imageSize.height <= 0) {
            imageScrollView.minimumZoomScale = 1
            return
        }
        
        let minScaleWith = imageScrollView.bounds.size.width / imageSize.width
        let minScaleHeight = imageScrollView.bounds.size.height / imageSize.height
        imageScrollView.minimumZoomScale = max(minScaleWith, minScaleHeight)
        
        if imageScrollView.zoomScale < imageScrollView.minimumZoomScale {
            imageScrollView.zoomScale = imageScrollView.minimumZoomScale
        }
    }
    
    
    /*----------------------------------------------------------------------------
     Description:   <#description#>
     -----------------------------------------------------------------------------*/
    func checkActivePanCropDirection(with gesture: UIPanGestureRecognizer) -> ActivePanCrop {
        
        let location = gesture.location(in: cropMaskView)
        
        var tempActiveCrop = ActivePanCrop()
        
        if topLeftPanCropView.frame.contains(location) {
            tempActiveCrop.top = true
            tempActiveCrop.left = true
        } else if topPanCropView.frame.contains(location) {
            tempActiveCrop.top = true
        } else if topRightPanCropView.frame.contains(location) {
            tempActiveCrop.top = true
            tempActiveCrop.right = true
        } else if rightPanCropView.frame.contains(location) {
            tempActiveCrop.right = true
        } else if bottomRightPanCropView.frame.contains(location) {
            tempActiveCrop.right = true
            tempActiveCrop.bottom = true
        } else if bottomPanCropView.frame.contains(location) {
            tempActiveCrop.bottom = true
        } else if bottomLeftPanCropView.frame.contains(location) {
            tempActiveCrop.bottom = true
            tempActiveCrop.left = true
        } else if leftPanCropView.frame.contains(location) {
            tempActiveCrop.left = true
        }
        
        return tempActiveCrop
    }
    
    /*----------------------------------------------------------------------------
     Description:   input parameter is
     -----------------------------------------------------------------------------*/
    func updateCropMask(withChangedLocation changeLocation: CGPoint) {
        
        var limitVariable: CGFloat = 0
        let minConstraint: CGFloat = 50
        let minCropSize: CGFloat = 80
        let maxViewSize = self.cropMaskView.bounds.size
        let totalSize = CGPoint(x: maxViewSize.width - minCropSize, y: maxViewSize.height - minCropSize)
        
        var currentOffset = imageScrollView.bounds.origin
        
        if activePanCrop.top == true {
            limitVariable = topCropConstraint.constant + changeLocation.y
            limitVariable = min(max(limitVariable, minConstraint), totalSize.y - bottomCropConstraint.constant)
            topCropConstraint.constant = limitVariable
            
//            if changeLocation.y > 0 {
//                
//            }
            currentOffset.y += changeLocation.y
            currentOffset.y = max(currentOffset.y, 0)
        }
        
        if activePanCrop.right == true {
            limitVariable = rightCropConstraint.constant - changeLocation.x
            limitVariable = min(max(limitVariable, minConstraint), totalSize.x - leftCropConstraint.constant)
            rightCropConstraint.constant = limitVariable
        }
        if activePanCrop.bottom == true {
            limitVariable = bottomCropConstraint.constant - changeLocation.y
            limitVariable = min(max(limitVariable, minConstraint), totalSize.y - topCropConstraint.constant)
            bottomCropConstraint.constant = limitVariable
        }
        if activePanCrop.left == true {
            limitVariable = leftCropConstraint.constant + changeLocation.x
            limitVariable = min(max(limitVariable, minConstraint), totalSize.x - rightCropConstraint.constant)
            leftCropConstraint.constant = limitVariable
            
//            if changeLocation.x > 0 {
//                
//            }
            currentOffset.x += changeLocation.x
            currentOffset.x = max(currentOffset.x, 0)
        }
        
        
        //imageScrollView.bounds.origin = currentOffset
        
//        print(imageScrollView.bounds)
//        imageScrollView.scrollRectToVisible(<#T##rect: CGRect##CGRect#>, animated: <#T##Bool#>) = currentOffset

        
        syncScrollViewConstraintWithCropMask()
        
        if imageViewTopConstraint.constant > topCropConstraint.constant {
            
        }
        if imageViewBottomConstraint.constant > bottomCropConstraint.constant {
            
        }
        if imageViewLeadingConstraint.constant > leftCropConstraint.constant {
            
        }
        if imageViewTrailingConstraint.constant > rightCropConstraint.constant {
            
        }
    }
    
    func syncScrollViewConstraintWithCropMask() {
        
//        scrollViewTopConstraint.constant = topCropConstraint.constant
//        scrollViewBottomConstraint.constant = bottomCropConstraint.constant
//        scrollViewLeadingConstraint.constant = leftCropConstraint.constant
//        scrollViewTrailingConstraint.constant = rightCropConstraint.constant
        
        scaleScrollViewToMatchCropArea()
    }
    
    func scaleScrollViewToMatchCropArea() {
        
        let cropSize = cropAreaView.frame.size
        let angle = rotateAngle(from: imageScrollView.transform)
        let w1 = fabs(sin(angle) * cropSize.height)
        let h1 = fabs(cos(angle) * cropSize.height)
        let h2 = fabs(sin(angle) * cropSize.width)
        let w2 = fabs(cos(angle) * cropSize.width)
        
        let newSize = CGSize(width: w1 + w2, height: h1 + h2)
        
//        let scaleRatio = cos(angle) * 2
//        let newSize = CGSize(width: cropSize.width * scaleRatio, height: cropSize.height * scaleRatio)
        
        let offsetSize = CGSize(width: 0.5 * (newSize.width - cropSize.width), height: 0.5 * (newSize.height - cropSize.height))
        
        scrollViewTopConstraint.constant = topCropConstraint.constant - offsetSize.height
        scrollViewBottomConstraint.constant = bottomCropConstraint.constant - offsetSize.height
        scrollViewLeadingConstraint.constant = leftCropConstraint.constant - offsetSize.width
        scrollViewTrailingConstraint.constant = rightCropConstraint.constant - offsetSize.width
        
//        let newTransform = imageScrollView.transform.scaledBy(x: scaleRatio, y: scaleRatio)
//        imageScrollView.transform = newTransform
    }
    
    // MARK: - Utilities
    
    func rotateAngle(from transform: CGAffineTransform) -> CGFloat {
        
        return atan2(transform.b, transform.a)
    }
    
    
    // MARK: - Gestures
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let activeCrop = checkActivePanCropDirection(with: panCropGesture)
        if activeCrop.isActive() {
            imageScrollView.panGestureRecognizer.isEnabled = false
            imageScrollView.panGestureRecognizer.isEnabled = true
        } else {
            panCropGesture.isEnabled = false
            panCropGesture.isEnabled = true
        }
        
        return true
    }
    
    /*----------------------------------------------------------------------------
     Description:   Adjust the crop area
     -----------------------------------------------------------------------------*/
    func handlePanCropGesture(_ gesture: UIPanGestureRecognizer) {
        
        let location = gesture.location(in: cropMaskView)
        
        switch gesture.state {
        case .began:
            beganCropPanLocation = location
            previousCropPanLocation = location
            
            activePanCrop = checkActivePanCropDirection(with: gesture)
            
        case .changed:
            
            let changeLocation = CGPoint(x: location.x - previousCropPanLocation.x,
                                         y: location.y - previousCropPanLocation.y)
            
            updateCropMask(withChangedLocation: changeLocation)
            
            previousCropPanLocation = location
            
        default:
            break
        }
    }
    
    
    /*----------------------------------------------------------------------------
     Description:   Rotate scroll view (image)
     -----------------------------------------------------------------------------*/
    var scrollRotatedAngle: CGFloat = 0
    var currentRotateAngle: CGFloat = 0
    
    func handleRotateGesture(_ gesture: UIRotationGestureRecognizer) {
        
        print(gesture.rotation)
        
        switch gesture.state {
        case .began:
            scrollRotatedAngle = rotateAngle(from: imageScrollView.transform)
            
        case .changed:
            
            currentRotateAngle = rotateAngle(from: imageScrollView.transform)
            
//            currentRotateAngle = gesture.rotation
//            scrollRotatedAngle += gesture.rotation
            let currentTranform = imageScrollView.transform.rotated(by: scrollRotatedAngle + gesture.rotation - currentRotateAngle)
//            let rotationTranform = CGAffineTransform(rotationAngle: scrollRotatedAngle + gesture.rotation - currentRotateAngle)
//            let newTransform = currentTranform.concatenating(rotationTranform)
            
            imageScrollView.transform = currentTranform
            
            
            scaleScrollViewToMatchCropArea()
            
        default:
            break
        }
        
        
    }
    
    // MARK: - ScrollView Delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        let size = scrollView.bounds.size
//        let yOffset: CGFloat = max(0, (size.height - imageView.frame.size.height) / 2)
//        self.imageViewTopConstraint.constant = yOffset
//        self.imageViewBottomConstraint.constant = yOffset
//        let xOffset: CGFloat = max(0, (size.width - self.imageView!.frame.size.width) / 2)
//        self.imageViewLeadingConstraint.constant = xOffset
//        self.imageViewTrailingConstraint.constant = xOffset
        self.view.layoutIfNeeded()
//
        print("----------------")
        print("scrollView.bounds \(scrollView.contentSize)")
        print("imageview.frame \(imageView.frame)")
        print("\(imageViewTopConstraint.constant), \(imageViewBottomConstraint.constant), \(imageViewLeadingConstraint.constant), \(imageViewTrailingConstraint.constant), ")

    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
//        let size = scrollView.bounds.size
//        let yOffset: CGFloat = max(0, (size.height - imageView.frame.size.height) / 2)
//        self.imageViewTopConstraint.constant = yOffset
//        self.imageViewBottomConstraint.constant = yOffset
//        let xOffset: CGFloat = max(0, (size.width - self.imageView!.frame.size.width) / 2)
//        self.imageViewLeadingConstraint.constant = xOffset
//        self.imageViewTrailingConstraint.constant = xOffset

        
        self.view.layoutIfNeeded()
//        scrollView.contentSize = CGSize(width: scrollView.contentSize.width + imageViewLeadingConstraint.constant, height: <#T##CGFloat#>)
        print("----------------")
                print("scrollView.bounds \(scrollView.contentSize)")
                print("imageview.frame \(imageView.frame)")
                print("\(imageViewTopConstraint.constant), \(imageViewBottomConstraint.constant), \(imageViewLeadingConstraint.constant), \(imageViewTrailingConstraint.constant), ")
    }
}
