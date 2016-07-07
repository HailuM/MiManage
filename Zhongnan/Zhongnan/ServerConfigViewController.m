//
//  ServerConfigViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/6/28.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "ServerConfigViewController.h"

@interface ServerConfigViewController ()

@end

@implementation ServerConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"编辑服务器配置";
    
    //注册键盘消失事件
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    //轻量级系统存储变量
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *myDictionary  = [userDefaultes  objectForKey:@"getServerInfo"];
    NSString *serverip=[myDictionary valueForKey:@"ServerIP"];//取出上次验证通过的用户名
    
    self.etServer.text = serverip;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//输入框监听事件
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self.etServer resignFirstResponder];
}

- (IBAction)saveServer:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *myDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.etServer.text,@"ServerIP",nil];
    [userDefaults setObject:myDictionary forKey:@"getServerInfo"];

    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
