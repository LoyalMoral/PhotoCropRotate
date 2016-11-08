//
//  Utilities.m
//  PhotoRotate
//
//  Created by Luan on 11/7/16.
//  Copyright © 2016 Shutta. All rights reserved.
//

#import "Utilities.h"


@implementation Utilities


+ (UIImage *)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize
{
    CGImageRef source = [Utilities newScaledImage:sourceImage
                             withOrientation:sourceOrientation
                                      toSize:sourceSize
                                 withQuality:kCGInterpolationNone];
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                            outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       , source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:resultRef];
    CGContextRelease(context);
    CGImageRelease(source);
    return image;
}


+ (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,  //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                                 );
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

// Draw a full image into a crop-sized area and offset to produce a cropped, rotated image
+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)aperture withOrientation:(UIImageOrientation)orientation {
    
    // convert y coordinate to origin bottom-left
    CGFloat orgY = aperture.origin.y + aperture.size.height - imageToCrop.size.height,
    orgX = -aperture.origin.x,
    scaleX = 1.0,
    scaleY = 1.0,
    rot = 0.0;
    CGSize size;
    
    switch (orientation) {
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            size = CGSizeMake(aperture.size.height, aperture.size.width);
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            size = aperture.size;
            break;
        default:
            assert(NO);
            return nil;
    }
    
    
    switch (orientation) {
        case UIImageOrientationRight:
            rot = 1.0 * M_PI / 2.0;
            orgY -= aperture.size.height;
            break;
        case UIImageOrientationRightMirrored:
            rot = 1.0 * M_PI / 2.0;
            scaleY = -1.0;
            break;
        case UIImageOrientationDown:
            scaleX = scaleY = -1.0;
            orgX -= aperture.size.width;
            orgY -= aperture.size.height;
            break;
        case UIImageOrientationDownMirrored:
            orgY -= aperture.size.height;
            scaleY = -1.0;
            break;
        case UIImageOrientationLeft:
            rot = 3.0 * M_PI / 2.0;
            orgX -= aperture.size.height;
            break;
        case UIImageOrientationLeftMirrored:
            rot = 3.0 * M_PI / 2.0;
            orgY -= aperture.size.height;
            orgX -= aperture.size.width;
            scaleY = -1.0;
            break;
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            orgX -= aperture.size.width;
            scaleX = -1.0;
            break;
    }
    
    // set the draw rect to pan the image to the right spot
    CGRect drawRect = CGRectMake(orgX, orgY, imageToCrop.size.width, imageToCrop.size.height);
    
    // create a context for the new image
    UIGraphicsBeginImageContextWithOptions(size, NO, imageToCrop.scale);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    // apply rotation and scaling
    CGContextRotateCTM(gc, rot);
    CGContextScaleCTM(gc, scaleX, scaleY);
    
    // draw the image to our clipped context using the offset rect
    CGContextDrawImage(gc, drawRect, imageToCrop.CGImage);
    
    // pull the image from our cropped context
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    // Note: this is autoreleased
    return cropped;
}

@end
