//
//  UIBarButtonItem+Extension.h
//  EMINest
//
//  Created by WongSuechang on 14-2-22.
//  Copyright (c) 2016年 emi365. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)
+ (UIBarButtonItem *)itemWithImageName:(NSString *)imageName highImageName:(NSString *)highImageName target:(id)target action:(SEL)action;
@end
