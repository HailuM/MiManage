//
//  ImageToBase64.m
//  Portal
//
//  Created by Emi-iMac on 15/3/30.
//  Copyright (c) 2015年 emi365. All rights reserved.
//

#import "ImageToBase64.h"

@implementation ImageToBase64

+(UIImage *)base64ToImage:(NSString *)data {
    NSData *imageData = [[NSData alloc] initWithBase64Encoding:data];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

+(NSString *)imageToBase64:(UIImage *)img {
    NSData *data;
    data = UIImageJPEGRepresentation(img, 0.0001);
    NSString *imageStr = [data base64Encoding];
    return imageStr;
}

+(NSString *)imageWithNoCompressToBase64:(UIImage *)img {
    NSData *data;
    data = UIImageJPEGRepresentation(img, 1);
    NSString *imageStr;
    imageStr = [data base64Encoding];
    if(imageStr.length>=1024*1024*10){
        imageStr = [self imageToBase64:img];
    }else if(1024*1024*10>imageStr.length && imageStr.length>=1024*1024){
        data = UIImageJPEGRepresentation(img, 0.001);
        imageStr = [data base64Encoding];
    }else if(1024*1024>imageStr.length && imageStr.length>=100*1024){
        data = UIImageJPEGRepresentation(img, 0.01);
        imageStr = [data base64Encoding];
    }else {
        data = UIImageJPEGRepresentation(img, 1);
        imageStr = [data base64Encoding];
    }
    return imageStr;
}
@end
