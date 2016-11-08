//
//  Utilities.h
//  PhotoRotate
//
//  Created by Luan on 11/7/16.
//  Copyright © 2016 Shutta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface Utilities : NSObject

+ (UIImage *)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize;


+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)aperture withOrientation:(UIImageOrientation)orientation;

@end
