//
//  ViewController.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/28.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "LoginViewController.h"
#import "Reachability.h"
#import "WebServiceConnect.h"
#import "LoginInterface.h"
#import "MainViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //轻量级系统存储变量
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *myDictionary  = [userDefaultes  objectForKey:@"getServerInfo"];
    serverUrl=[myDictionary valueForKey:@"ServerIP"];//取出上次验证通过的用户名

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.title = @"登录";
    
    //注册键盘消失事件
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    //初始化记住密码事件
    [self autoSetLoginInfo];
    
    //第一次查看网络是否连接
    if (![self isConnectionAvailable:@"http:\\www.baidu.com"]) {
        //错误提示框的初始化
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"当前的网络连接不可用，自动转为本地登录！"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
        isHaveNet=@"0";//表示没有网络
    }else{
        isHaveNet=@"1";//表示有网络
    }
    
    
    [self.btnLogin addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    //绑定忘记密码事件
    UITapGestureRecognizer *lblSubmitGr=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toMissPassWord)];
    self.labForget.userInteractionEnabled=YES;
    [self.labForget addGestureRecognizer:lblSubmitGr];
    
    //绑定服务器配置事件
    UITapGestureRecognizer *lblSystemContrlGr=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toSystemControl)];
    self.labSetServer.userInteractionEnabled=YES;
    [self.labSetServer addGestureRecognizer:lblSystemContrlGr];
    
}
//验证网络是否通畅
-(BOOL)isConnectionAvailable:(NSString *)url{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostname:url];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    return isExistenceNetwork;
}

/*如果勾选记住密码，则自动填充*/
-(void)autoSetLoginInfo{
    //轻量级系统存储变量
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *myDictionary  = [userDefaultes  objectForKey:@"getRemeberInfo"];
    NSString *username=[myDictionary valueForKey:@"UserName"];//取出上次验证通过的用户名
    NSString *userpwd=[myDictionary valueForKey:@"UserPwd"];  //取出上次验证通过的密码
    
    
    NSInteger autologin = [userDefaultes integerForKey:@"autologin"];
    if(autologin==1){
        [self performSegueWithIdentifier:@"toMain" sender:self];
    }
    
    self.etUsername.text=username;//给文本赋值
    self.etPwd.text=userpwd;  //给文本赋值
    
    //如果有值则勾选，否则不勾选
    if (username !=nil && userpwd !=nil ) {
        [self.btnAutoLogin setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        chooseType=@"1";
    }else{
        [self.btnAutoLogin setBackgroundImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        chooseType=@"0";
    }
}

//输入框监听事件
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self.etUsername resignFirstResponder];
    [self.etPwd resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login:(id)sender{
    NSString *username=self.etUsername.text;//获取输入的用户名
    NSString *userpwd=self.etPwd.text;  //获取输入的密码
    if([isHaveNet isEqualToString:@"1"]){
        if([self LoginVerification:username :userpwd]){
            
            //保存用户信息到本地
            if ([chooseType isEqualToString:@"1"]) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSDictionary *remeberDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:username,userpwd,self.user.UserOID,nil] forKeys:[NSArray arrayWithObjects:@"UserName", @"UserPwd",@"UserOID",nil]];
                [userDefaults setObject:remeberDictionary forKey:@"getRemeberInfo"];
                [userDefaults setInteger:1 forKey:@"autologin"];//1,下次打开自动登录到首页
                                                                //0,下次打开还必须跳转到登录页
                
            }else{
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                [userDefaultes removeObjectForKey:@"getRemeberInfo"];
            }
            //跳转到首页
            [self performSegueWithIdentifier:@"toMain" sender:self];
        }
    }
}
//验证身份
-(Boolean)LoginVerification:(NSString *)username :(NSString *)userpwd{
    //输入用户名空验证
    if(username==nil || [username isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请输入用户名!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return false;
    }
    //输入密码空验证
    if(userpwd==nil || [userpwd isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请输入密码!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return false;
    }
    if([serverUrl isEqualToString:@""] || serverUrl==nil){
        serverUrl = @"fdcwzm.zhongnangroup.cn:82";
    }
    NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=ToLogin",serverUrl ];
    //连接webservice获取企业介绍的数据
    WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :[NSString stringWithFormat:
                                                                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                                                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                                                                 "<soap:Body>\n"
                                                                                 "<ToLogin xmlns=\"http://tempuri.org/\">\n"
                                                                                 "<userName>%@</userName>"
                                                                                 "<pwd>%@</pwd>\n"
                                                                                 "</ToLogin>\n"
                                                                                 "</soap:Body>\n"
                                                                                 "</soap:Envelope>\n",username,userpwd
                                                                                 ]
                                                                    :@"http://tempuri.org/ToLogin"
                                                                    :@"ToLoginResult"
                           ];
    [da getTestConnet];
    
    NSString *userString = da.tempStr;
    NSArray<NSString *> *stringArray = [userString componentsSeparatedByString:@";"];
    self.user = [[User alloc] init];
    if(stringArray[0]&&stringArray[0].length>0){
        //返回正确的用户信息
        [User clearTable];
        self.user.UserOID = stringArray[0];
        self.user.UserName = stringArray[1];
        [self.user saveOrUpdate];
    }else{
        //错误提示框的初始化
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:stringArray[2]
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
        return NO;
    }
    return YES;
}

- (IBAction)toChooseType:(id)sender {
    if ([chooseType isEqualToString:@"0"]) {
        [self.btnAutoLogin setBackgroundImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        chooseType=@"1";
        
    }else{
        [self.btnAutoLogin setBackgroundImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        chooseType=@"0";
    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if([identifier isEqualToString:@"toMain"]){
        MainViewController *viewController = segue.destinationViewController;
        viewController.user = self.user;
    }
}

//忘记密码事件
-(void)toMissPassWord{
    //错误提示框的初始化
    self.etUsername.text = @"";
    self.etPwd.text = @"";
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                  message:@"已重置密码，请重新登录！"
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil, nil];
    [alert show];//提示框的显示 必须写 不然没有任何反映
    
}

//跳转服务器配置页面
-(void)toSystemControl{
    [self performSegueWithIdentifier:@"toServer" sender:self];
}

@end
