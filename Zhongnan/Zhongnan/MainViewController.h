//
//  MainViewController.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/28.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "SCDBTool.h"
#import "UartLib.h"
#import "DateTool.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "SCSoapHttpOperation.h"

@interface MainViewController : UIViewController<UIAlertViewDelegate>{
    
    NSString *isHaveNet;         //是否有网络
    NSString *serverUrl;         //服务地址
    
    
    NSString *inToken;      //入库token
    NSString *outToken;     //出库token
    
//    UIAlertView *connectAlertView;
//    UartLib *uartLib;
//    CBPeripheral *connectPeripheral;
//    NSString *printContant;
}


@property (nonatomic, strong) User *user;

@end
