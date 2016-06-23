//
//  NavViewController.m
//  MiMaterial
//
//  Created by Henry on 16/6/23.
//  Copyright © 2016年 Henry. All rights reserved.
//

#import "NavViewController.h"
@interface NavViewController ()

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *nvb = self.navigationBar;
    UIColor *color = [UIColor colorWithRed:0 green:115.0/255.0 blue:198.0/255.0 alpha:1];
    [nvb setBackgroundColor:color];
//    [nvb setBackgroundImage:[UIImage imageNamed:@"medela_main_bg"] forBarMetrics:UIBarMetricsDefault];
    //    nvb.backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mm_title_back" ] style:UIBarButtonItemStyleDone target:self action:nil];
    //    [nvb.backItem.backBarButtonItem setImage:[UIImage imageNamed:@"mm_title_back"]];
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [nvb setTitleTextAttributes:attrs];
    [nvb setTintColor:[UIColor whiteColor]];
}

/**
 *  能拦截所有push进来的子控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count > 0) { // 如果现在push的不是栈底控制器(最先push进来的那个控制器)
        viewController.hidesBottomBarWhenPushed = YES;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mm_title_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        // 设置导航栏按钮
        viewController.navigationItem.leftBarButtonItem = item;
        
    }
    [super pushViewController:viewController animated:animated];
}

- (void)back{
    [self popViewControllerAnimated:YES];
}
@end
