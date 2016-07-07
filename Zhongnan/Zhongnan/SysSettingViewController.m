//
//  SysSettingViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/4.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "SysSettingViewController.h"
#import "SCDBTool.h"

@interface SysSettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *clearLabel;

@end

@implementation SysSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"系统设置";
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearData:)];
    self.clearLabel.userInteractionEnabled = YES;
    [self.clearLabel addGestureRecognizer:tapGr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clearData:(id)sender{
    //清除出入库token
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    
    //读取入库的token
    NSDictionary *tokenDic  = [userDefaultes  objectForKey:@"getToken"];
    NSString *inToken = [tokenDic valueForKey:@"rkToken"];//
    //读取出库的token
    NSString *outToken = [tokenDic valueForKey:@"ckToken"];//
    
    
    NSDictionary *rkDic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"rkToken", nil];
    [userDefaultes setObject:rkDic forKey:@"GetToken"];
    
    NSDictionary *ckDic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"ckToken", nil];
    [userDefaultes setObject:ckDic forKey:@"GetToken"];
    
    //删除缓存数据
    [SCDBTool clearInData:inToken];
    [SCDBTool clearOutData:outToken];
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                  message:@"离线数据清除成功!"
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil, nil];
    [alert show];//提示框的显示 必须写 不然没有任何反映

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
