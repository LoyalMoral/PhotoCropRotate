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

struct Padding {
    
    var top: CGFloat = 0
    var right: CGFloat = 0
    var bottom: CGFloat = 0
    var left: CGFloat = 0
    
    init(t: CGFloat = 0, r: CGFloat = 0, b: CGFloat = 0, l: CGFloat = 0) {
        
        top = t
        right = r
        bottom = b
        left = l
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
    
    @IBOutlet weak var cropBorderView: UIView!
    
    @IBOutlet weak var gridLinesView: UIView!
    
    @IBOutlet weak var verticalGridsView: UIView!
    
    @IBOutlet weak var horizontalGridsView: UIView!
    
    // MARK: - Style Constraints
    
    @IBOutlet weak var cropCornerTopLeftHHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cropCornerTopLeftHWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cropCornerTopLeftHTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cropCornerTopLeftHLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cropCornerTopLeftVWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cropCornerTopLeftVHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cropCornerTopRightHTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cropCornerBottomRightHBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    weak var photoRotationContainer: PhotoRotationContainerViewController!
    
    var image: UIImage! = UIImage(named: "page1_background")!
    
    var didResetImage = false
    
    let minCropPadding: CGFloat = 20
    let minCropSize: CGFloat = 80
    let maxRotateAngle = CGFloat(M_PI_2)
    
    let kCropAreaBorderWidth: CGFloat = 1
    let kCropCornerThick: CGFloat = 2
    let kCropCornerLength: CGFloat = 22
    let kGridThick: CGFloat = 1 / UIScreen.main.scale
    
    
    var activePanCrop = ActivePanCrop()
    
    var previousCropPanLocation: CGPoint!
    
    var panCropGesture: UIPanGestureRecognizer!
    var rotateGesture: UIRotationGestureRecognizer!
    
    var previousScrollViewFrame = CGRect.zero
    var previousScrollViewOffset = CGPoint.zero
    
    var scrollRotatedAngle: CGFloat = 0
    var currentRotateAngle: CGFloat = 0
    
    // The size of crop area will fit the image and screen, padding, ...
    var maxSize = UIScreen.main.bounds.size
    
    // zoomToCropAreaIfNeeded() can be called in many place (change crop area, rotate image, scroll, zoom)
    // but only in pan or change crop area needs to actually update
    var needZoomToCropArea = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.imageView.image = image
        
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForScrollView()
        
        if !didResetImage {
            didResetImage = true
            reset()
        }
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
        imageScrollView.maximumZoomScale = CGFloat.greatestFiniteMagnitude
        imageScrollView.scrollsToTop = false
        
//        imageScrollView.layer.borderColor = UIColor.white.cgColor
//        imageScrollView.layer.borderWidth = 1
        
        cropBorderView.layer.borderColor = UIColor.white.cgColor
        cropBorderView.layer.borderWidth = kCropAreaBorderWidth
        
        photoRotationContainer.rotateSlider.minimumValue = -(Float)(maxRotateAngle)
        photoRotationContainer.rotateSlider.maximumValue = Float(maxRotateAngle)
        photoRotationContainer.rotateSlider.value = 0
        
        // Style
//        let kCropAreaBorderWidth: CGFloat = 1
//        let kCropCornerThick: CGFloat = 3
//        let kCropCornerLength: CGFloat = 20
//        let kGridThick: CGFloat = 1 / UIScreen.main.scale
        
        cropCornerTopLeftHWidthConstraint.constant = kCropCornerLength
        cropCornerTopLeftHHeightConstraint.constant = kCropCornerThick
        cropCornerTopLeftHLeadingConstraint.constant = -kCropCornerThick
        cropCornerTopLeftHTopConstraint.constant = -kCropCornerThick
        
        cropCornerTopLeftVWidthConstraint.constant = kCropCornerThick
        cropCornerTopLeftVHeightConstraint.constant = kCropCornerLength
        
        cropCornerTopRightHTrailingConstraint.constant = -kCropCornerThick
        
        cropCornerBottomRightHBottomConstraint.constant = -kCropCornerThick
        
        horizontalGridsView.layer.borderColor = UIColor.white.cgColor
        horizontalGridsView.layer.borderWidth = 1 / UIScreen.main.scale // 1 pixel
        
        verticalGridsView.layer.borderColor = UIColor.white.cgColor
        verticalGridsView.layer.borderWidth = 1 / UIScreen.main.scale // 1 pixel
        
        showGrid(showed: false, animated: false)
    }
    
    /*----------------------------------------------------------------------------
     Description:   reset crop tool to fit image, 
                    call this after views have been layouted (to get correct superview's frame)
     -----------------------------------------------------------------------------*/
    func reset() {
        
        cancelZoomToCropArea()
        
        scrollRotatedAngle = 0
        currentRotateAngle = 0
        photoRotationContainer.rotateSlider.value = 0
        
        let imageSize = image.size
        maxSize = CGSize(width: cropMaskView.bounds.size.width - 2 * minCropPadding,
                             height: cropMaskView.bounds.size.height - 2 * minCropPadding)
        
        let fitRatio = min(maxSize.width / imageSize.width, maxSize.height / imageSize.height)
        let fitSize = CGSize(width: imageSize.width * fitRatio, height: imageSize.height * fitRatio)
        
        let minHorizontalConstraint = 0.5 * (cropMaskView.bounds.size.width - fitSize.width)
        let minVerticalConstraint = 0.5 * (cropMaskView.bounds.size.height - fitSize.height)
        
        topCropConstraint.constant = minVerticalConstraint
        bottomCropConstraint.constant = minVerticalConstraint
        rightCropConstraint.constant = minHorizontalConstraint
        leftCropConstraint.constant = minHorizontalConstraint
        
        imageScrollView.transform = CGAffineTransform.identity
        
        scaleScrollViewToMatchCropArea()
        updateMinZoomScaleForScrollView()
        imageScrollView.zoomScale = imageScrollView.minimumZoomScale
    }
    
    func cancelZoomToCropArea() {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(zoomToCropArea), object: nil)
    }
    
    func zoomToCropAreaIfNeeded() {
        
        self.perform(#selector(zoomToCropArea), with: nil, afterDelay: 0.5)
    }
    
    func zoomToCropArea() {
        
        if !needZoomToCropArea {
            return
        }
        
        self.view.layoutIfNeeded()
        
        self.view.isUserInteractionEnabled = false
        
        let fitRatio = min(maxSize.width / cropAreaView.frame.size.width, maxSize.height / cropAreaView.frame.size.height)
        
        let minHorizontalConstraint = 0.5 * (cropMaskView.bounds.size.width - cropAreaView.frame.size.width * fitRatio)
        let minVerticalConstraint = 0.5 * (cropMaskView.bounds.size.height - cropAreaView.frame.size.height * fitRatio)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
        
            self.topCropConstraint.constant = minVerticalConstraint
            self.bottomCropConstraint.constant = minVerticalConstraint
            self.rightCropConstraint.constant = minHorizontalConstraint
            self.leftCropConstraint.constant = minHorizontalConstraint
            
            self.scaleScrollViewToMatchCropArea()
            self.imageScrollView.zoomScale *= fitRatio
            
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) -> Void in
            
            self.needZoomToCropArea = false
            self.view.isUserInteractionEnabled = true
        })
    }
    
    func resetActivePanCropDirections() {
        
        activePanCrop.setActive(t: false, r: false, b: false, l: false)
    }
    
    func updateMinZoomScaleForScrollView() {
        
        self.view.layoutIfNeeded()
        
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
        
        let maxViewSize = self.cropMaskView.bounds.size
        let totalSize = CGPoint(x: maxViewSize.width - minCropSize, y: maxViewSize.height - minCropSize)
        
        var currentOffset = imageScrollView.bounds.origin
        
        if activePanCrop.top == true {
            limitVariable = topCropConstraint.constant + changeLocation.y
            limitVariable = min(max(limitVariable, minCropPadding), totalSize.y - bottomCropConstraint.constant)
            topCropConstraint.constant = limitVariable
            
//            if changeLocation.y > 0 {
//                
//            }
            currentOffset.y += changeLocation.y
            currentOffset.y = max(currentOffset.y, 0)
        }
        
        if activePanCrop.right == true {
            limitVariable = rightCropConstraint.constant - changeLocation.x
            limitVariable = min(max(limitVariable, minCropPadding), totalSize.x - leftCropConstraint.constant)
            rightCropConstraint.constant = limitVariable
        }
        if activePanCrop.bottom == true {
            limitVariable = bottomCropConstraint.constant - changeLocation.y
            limitVariable = min(max(limitVariable, minCropPadding), totalSize.y - topCropConstraint.constant)
            bottomCropConstraint.constant = limitVariable
        }
        if activePanCrop.left == true {
            limitVariable = leftCropConstraint.constant + changeLocation.x
            limitVariable = min(max(limitVariable, minCropPadding), totalSize.x - rightCropConstraint.constant)
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

        scaleScrollViewToMatchCropArea()
        
        keepScrollViewContentSteady()

    }
    
    /*----------------------------------------------------------------------------
     Description:   When update scrollview's frame, content will move along with it
                    so move the content to the opposite direction of the scrollview
     -----------------------------------------------------------------------------*/
    func keepScrollViewContentSteady() {
    
        // We update scrollview constraints but UI frame hasn't update yet, call layoutIfNeeded here to update frame
        self.view.layoutIfNeeded()
    
        let currentScrollViewFrame = calculateViewFrame(originalFrame: scrollViewBoundsFrame(), afterRotate: currentRotateAngle)
        
        let offset = CGPoint(x: currentScrollViewFrame.origin.x - previousScrollViewFrame.origin.x, y: currentScrollViewFrame.origin.y - previousScrollViewFrame.origin.y)
        
        let rotateOffset = CGPoint(x: offset.x * cos(currentRotateAngle) + offset.y * sin(currentRotateAngle),
                                   y: -offset.x * sin(currentRotateAngle) + offset.y * cos(currentRotateAngle))
        
        var visibleRect = CGRect.zero
        visibleRect.origin = previousScrollViewOffset
        visibleRect.origin.x += rotateOffset.x
        visibleRect.origin.y += rotateOffset.y
        
        
        
        visibleRect.size = imageScrollView.bounds.size
        //        let scale: CGFloat = 1 / imageScrollView.zoomScale
        
        //                visibleRect.origin.x *= scale
        //                visibleRect.origin.y *= scale
        //                visibleRect.size.width *= scale
        //                visibleRect.size.height *= scale
        
        visibleRect.origin.x = min(max(0, visibleRect.origin.x),
                                   imageScrollView.contentSize.width - imageScrollView.bounds.size.width)
        visibleRect.origin.y = min(max(0, visibleRect.origin.y),
                                   imageScrollView.contentSize.height - imageScrollView.bounds.size.height)
        
        
        imageScrollView.contentOffset = visibleRect.origin
        //            print(visibleRect.origin)
        //                imageScrollView.scrollRectToVisible(visibleRect, animated: false)
        //                imageScrollView.zoom(to: <#T##CGRect#>, animated: <#T##Bool#>)
        
        //                previousScrollViewFrame = imageScrollView.frame
    }

    
    func scaleScrollViewToMatchCropArea() {
        
        self.view.layoutIfNeeded()
        
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
        
    }
    
    /*----------------------------------------------------------------------------
     Description:   angle in radian
     -----------------------------------------------------------------------------*/
    func rotateScrollView(by angle: CGFloat) {
        
        var newAngle = currentRotateAngle + angle
        newAngle = max(-maxRotateAngle, min(maxRotateAngle, newAngle))
        let offSetAngle = newAngle - currentRotateAngle
        
        let currentTranform = imageScrollView.transform.rotated(by: offSetAngle)
        
        imageScrollView.transform = currentTranform
        
        currentRotateAngle = newAngle
    }
    
    /*----------------------------------------------------------------------------
     Description:   Grid
     -----------------------------------------------------------------------------*/
    func showGrid(showed: Bool = true, animated: Bool = true) -> () {
        
        let duration = animated ? 0.1 : 0
        let newAlpha: CGFloat = showed ? 1 : 0
        
        UIView.animate(withDuration: duration, animations: {
            
            self.gridLinesView.alpha = newAlpha
            
        }, completion: { (finished: Bool) -> Void in
            
        })
    }
    
    // MARK: - Utilities
    
    func rotateAngle(from transform: CGAffineTransform) -> CGFloat {
        
        return atan2(transform.b, transform.a)
    }
    
    func calculateViewFrame(originalFrame: CGRect, afterRotate angle: CGFloat) -> CGRect {
        
//        return originalFrame
        
        let cosinAngle = -angle
        
        // the coordinate of origin to it's center
        let oTC = CGPoint(x: -originalFrame.size.width * 0.5, y: originalFrame.size.height * 0.5)
//        let rotatedOriginToCenter = CGPoint(x: oTC.x * cos(cosinAngle) + oTC.y * sin(cosinAngle),
//                                            y: -oTC.x * sin(cosinAngle) + oTC.y * cos(cosinAngle))
        
        let rotatedOriginToCenter = CGPoint(x: oTC.x * cos(cosinAngle) - oTC.y * sin(cosinAngle),
                                            y: oTC.x * sin(cosinAngle) + oTC.y * cos(cosinAngle))
        
        print("----------------")
        print(oTC)
        print(rotatedOriginToCenter)
        print(imageScrollView.center)
        
        var rotatedOriginFrame = CGRect.zero
        rotatedOriginFrame.size = imageScrollView.frame.size
        
        rotatedOriginFrame.origin = CGPoint(x: imageScrollView.center.x + rotatedOriginToCenter.x,
                                            y: imageScrollView.center.y - rotatedOriginToCenter.y) // cosin axist is upside down with iOS axist
        return rotatedOriginFrame
        // (x cos alpha + y sin alpha, -x sin alpha + y cos alpha).
        
    }
    
    func scrollViewBoundsFrame() -> CGRect {
        
        var boundsFrame = imageScrollView.bounds
        boundsFrame.origin.x = imageScrollView.center.x + imageScrollView.bounds.size.width - imageScrollView.frame.size.width
        boundsFrame.origin.y = imageScrollView.center.y + imageScrollView.bounds.size.height - imageScrollView.frame.size.height
        
        return boundsFrame
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
        
        cancelZoomToCropArea()
        
        let location = gesture.location(in: cropMaskView)
        
        switch gesture.state {
        case .began:
            previousCropPanLocation = location
            
            activePanCrop = checkActivePanCropDirection(with: gesture)
            previousScrollViewFrame = calculateViewFrame(originalFrame: scrollViewBoundsFrame(), afterRotate: currentRotateAngle)
            previousScrollViewOffset = imageScrollView.contentOffset
            
            showGrid()
            
        case .changed:
            
            let changeLocation = CGPoint(x: location.x - previousCropPanLocation.x,
                                         y: location.y - previousCropPanLocation.y)
            
            updateCropMask(withChangedLocation: changeLocation)
            
            previousCropPanLocation = location
            
        default:
            needZoomToCropArea = true
            zoomToCropAreaIfNeeded()
            
            showGrid(showed: false, animated: true)
            
            break
        }
    }
    
    
    /*----------------------------------------------------------------------------
     Description:   Rotate scroll view (image)
     -----------------------------------------------------------------------------*/
    func handleRotateGesture(_ gesture: UIRotationGestureRecognizer) {
        
        cancelZoomToCropArea()
        
        switch gesture.state {
        case .began:
            scrollRotatedAngle = rotateAngle(from: imageScrollView.transform)
            showGrid()
            
        case .changed:
            
//            currentRotateAngle = rotateAngle(from: imageScrollView.transform)
//            let currentTranform = imageScrollView.transform.rotated(by: scrollRotatedAngle + gesture.rotation - currentRotateAngle)
//            imageScrollView.transform = currentTranform
            
            rotateScrollView(by: scrollRotatedAngle + gesture.rotation - currentRotateAngle)
            photoRotationContainer.rotateSlider.value = Float(currentRotateAngle)
            
            scaleScrollViewToMatchCropArea()
            
        default:
            zoomToCropAreaIfNeeded()
            showGrid(showed: false, animated: true)
            
            break
        }
        
        
    }
    
    // MARK: - ScrollView Delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.view.layoutIfNeeded()
//
//        print("----------------")
//        print("scrollView.bounds \(scrollView.bounds)")
//        print("scrollView.contentSize \(scrollView.contentSize)")
//        print("ofset \(scrollView.contentOffset)")
//        print("imageview.frame \(imageView.frame)")
//        print("\(imageViewTopConstraint.constant), \(imageViewBottomConstraint.constant), \(imageViewLeadingConstraint.constant), \(imageViewTrailingConstraint.constant), ")
        
        cancelZoomToCropArea()
        zoomToCropAreaIfNeeded()

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
        
        cancelZoomToCropArea()
        zoomToCropAreaIfNeeded()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        showGrid()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        showGrid(showed: false, animated: true)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
        showGrid()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        showGrid(showed: false, animated: true)
    }
    
    // MARK: - Events
    
    func save() {
        
        // Visible image in scrollview
        
        var visibleRect = CGRect.zero
//        visibleRect.origin = imageScrollView.contentOffset
//        visibleRect.size = imageScrollView.bounds.size
//        let scale: CGFloat = 1 / imageScrollView.zoomScale
//        
//        visibleRect.origin.x *= scale
//        visibleRect.origin.y *= scale
//        visibleRect.size.width *= scale
//        visibleRect.size.height *= scale
        
        visibleRect = imageScrollView.convert(imageScrollView.bounds, to: imageView)
        
        
        
        
//        var transform = CGAffineTransform.identity
//        
//        // translate
////        CGPoint translation = [self.photoView photoTranslation];
////        transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
//
//        transform = transform.translatedBy(x: visibleRect.origin.x, y: visibleRect.origin.y)
//        
//        // rotate
//        transform = transform.rotated(by: currentRotateAngle)
//        
//        // scale
//        let t = imageView.transform
//        let xScale: CGFloat =  sqrt(t.a * t.a + t.c * t.c)
//        let yScale: CGFloat = sqrt(t.b * t.b + t.d * t.d)
//        transform = transform.scaledBy(x: xScale, y: yScale)
////        transform = transform.scaledBy(x: imageScrollView.zoomScale, y: imageScrollView.zoomScale)
//        
//        let cropped = Utilities.newTransformedImage(transform, sourceImage: image.cgImage, sourceSize: image.size, sourceOrientation: image.imageOrientation, outputWidth: image.size.width, cropSize: cropAreaView.frame.size, imageViewSize: imageView.bounds.size)
        
        var cropped = image.atRect(visibleRect)
//        cropped = cropped.imageRotated(byRadians: currentRotateAngle)
        
        var cropSize = cropAreaView.frame.size
        cropSize.width = cropSize.width / imageScrollView.zoomScale
        cropSize.height = cropSize.height / imageScrollView.zoomScale
        cropped = cropped.imageRotated(byRadians: currentRotateAngle, size: cropSize)
        
        
        
        let imagePV = UIStoryboard.init(name: "ImagePreview", bundle: nil).instantiateInitialViewController() as! ImagePreviewViewController
        imagePV.image = cropped
        
        self.present(imagePV, animated: false, completion: {
            
        })
        
        
        
        
        
        
        
        
        
//        var transform = CGAffineTransform.identity
//        
//        // translate
//        CGPoint translation = [self.photoView photoTranslation];
//        transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
//        
//        // rotate
//        transform = CGAffineTransformRotate(transform, self.photoView.angle);
//        
//        // scale
//        CGAffineTransform t = self.photoView.photoContentView.transform;
//        CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
//        CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
//        transform = CGAffineTransformScale(transform, xScale, yScale);
//        
//        CGImageRef imageRef = [self newTransformedImage:transform
//            sourceImage:self.image.CGImage
//            sourceSize:self.image.size
//            sourceOrientation:self.image.imageOrientation
//            outputWidth:self.image.size.width
//            cropSize:self.photoView.cropView.frame.size
//            imageViewSize:self.photoView.photoContentView.bounds.size];
//        
//        UIImage *image = [UIImage imageWithCGImage:imageRef];
//        CGImageRelease(imageRef);
        
    }
    
    
    func didChangeSlider(_ sender: UISlider) {
        
        let addedAngle = CGFloat(photoRotationContainer.rotateSlider.value) - currentRotateAngle
        rotateScrollView(by: addedAngle)
        
        scaleScrollViewToMatchCropArea()
        
        cancelZoomToCropArea()
        zoomToCropAreaIfNeeded()
    }
}
