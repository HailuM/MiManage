//
//  ImageToBase64.h
//  Portal
//
//  Created by Emi-iMac on 15/3/30.
//  Copyright (c) 2015年 emi365. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageToBase64 : NSObject

/**
 *  将字符串转图片
 *
 *  @param data 待解码的字符串
 *
 *  @return 图片
 */
+(UIImage *)base64ToImage:(NSString *)data;

/**
 *  图片转base64字符串(压缩)
 *
 *  @param img 图片
 *
 *  @return base64字符串
 */
+(NSString *)imageToBase64:(UIImage *)img;

/**
 *  图片转base64字符串(不压缩)
 *
 *  @param img 图片
 *
 *  @return base64字符串
 */
+(NSString *)imageWithNoCompressToBase64:(UIImage *)img;

@end
