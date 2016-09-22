//
//  SCNavigationController.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-17.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDefines.h"

@protocol SCCNavigationControllerDelegate;

@interface SCCNavigationController : UINavigationController


- (void)showCameraWithParentController:(UIViewController*)parentController;

@property (nonatomic, assign) id <SCCNavigationControllerDelegate> scNaigationDelegate;

@end



@protocol SCCNavigationControllerDelegate <NSObject>
@optional
- (BOOL)willDismissNavigationController:(SCCNavigationController*)navigatonController;

- (void)didTakePicture:(SCCNavigationController*)navigationController image:(UIImage*)image;

@end