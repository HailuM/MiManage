//
//  ViewController.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/28.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface LoginViewController : UIViewController
{
    NSString *chooseType;        //是否记住密码存放变量
    NSString *isHaveNet;         //是否有网络
    
    NSString *serverUrl;         //服务地址
}
@property (strong, nonatomic) IBOutlet UITextField *etUsername;
@property (strong, nonatomic) IBOutlet UITextField *etPwd;
@property (strong, nonatomic) IBOutlet UIButton *btnAutoLogin;
@property (strong, nonatomic) IBOutlet UILabel *labForget;
@property (strong, nonatomic) IBOutlet UILabel *labSetServer;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;


@property (nonatomic, strong) User *user;

@end

