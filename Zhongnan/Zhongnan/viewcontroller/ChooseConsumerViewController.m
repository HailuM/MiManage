//
//  ChooseSupplierViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "ChooseConsumerViewController.h"

@interface ChooseConsumerViewController ()

@end

@implementation ChooseConsumerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择领料商";
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSArray *array;
    if(self.flag==1){
        //查询inconsumer
        array = [Consumer findByCriteria:[NSString stringWithFormat:@" WHERE Orderid = '%@'",self.orderid]];
    }else{
        //查询outconsumer
        array = [Consumer findByCriteria:[NSString stringWithFormat:@" WHERE Orderid = '%@'",self.orderid]];
    }
    self.consumerArray = [NSArray arrayWithArray:array];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.consumerArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableSampleIdentifier = @"ConsumerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    NSString *name;
    id value = self.consumerArray[row];
    name = ((Consumer *)value).Name;
    cell.textLabel.text = name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        [self.delegate pass:self.consumerArray[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
