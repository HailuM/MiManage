//
//  SysSettingViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/4.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "SysSettingViewController.h"
#import "SCDBTool.h"
#import "UIView+Toast.h"

@interface SysSettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *clearLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverlabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SysSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"系统设置";
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearData:)];
    self.clearLabel.userInteractionEnabled = YES;
    [self.clearLabel addGestureRecognizer:tapGr];
    
    NSArray *array = [User findAll];
    User *user = array[0];
    
    self.usernameLabel.text = user.UserName;
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *myDictionary  = [userDefaultes  objectForKey:@"getServerInfo"];
    NSString *serverUrl=[myDictionary valueForKey:@"ServerIP"];//取出上次的服务器地址
    if(serverUrl==nil||serverUrl.length==0){
        serverUrl = @"fdcwzm.zhongnangroup.cn:82";
    }
    self.serverlabel.text = serverUrl;
    
    
    self.versionLabel.text = [self getVersionFromLocal];
}

-(NSString *)getVersionFromLocal
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return currentVersion;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clearData:(id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否清除数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==1){
        //清除出入库token
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        
        [userDefaultes setObject:@"" forKey:@"rkToken"];
        
        [userDefaultes setObject:@"" forKey:@"ckToken"];
        
        //删除缓存数据
        [SCDBTool clearInData:@""];
        [SCDBTool clearOutData:@""];
        
        [self.view makeToast:@"清除数据成功" duration:3.0 position:CSToastPositionCenter];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)signOut:(id)sender {
    
}

@end
