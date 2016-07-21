//
//  InDealDetailViewController.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "InDealDetailViewController.h"

@interface InDealDetailViewController ()

@end

@implementation InDealDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"入库选择";
    
    [self showOrder];
    UITapGestureRecognizer *checkAllTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkAll:)];
    self.checkLabel.userInteractionEnabled = YES;
    [self.checkLabel addGestureRecognizer:checkAllTap];
    
    [self.confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
}
/**
 *  跳转到确认界面
 *
 *  @param sender <#sender description#>
 */
-(void)confirm:(id)sender {
    if(selArray.count==0){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"尚未选择材料入库,请执行入库后再提交!"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{
        [self performSegueWithIdentifier:@"confirmin" sender:self];
    }
}

/**
 *  展示订单信息
 */
-(void)showOrder{
    if(self.order){
        self.numberLabel.text = self.order.number;
        self.supplierLabel.text = self.order.supplier;
        self.addrLabel.text = self.order.Addr;
        // todo
//        self.contactLabel.text = self.order.con
        if(!selArray){
            selArray = [[NSMutableArray alloc] init];
        }
        self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)selArray.count];
        [self initData];
    }
}

/**
 *  查询订单上的材料
 */
-(void)initData {
    matArray = [PuOrderChild findByCriteria:[NSString stringWithFormat:@" WHERE orderid = '%@' and isFinish = 0 ",self.order.id]];
    unSelArray = [[NSMutableArray alloc] initWithArray:matArray];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkAll:(id)sender{
    
    if(!selArray){
        selArray = [[NSMutableArray alloc] init];
    }
    if(selArray.count==matArray.count){
        //已经全部选择
        self.checkLabel.text = @"全选";
        [unSelArray addObjectsFromArray:selArray];
        [selArray removeAllObjects];
        [self.checkBtn setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        
    }else{
        self.checkLabel.text = @"取消全选";
        [selArray addObjectsFromArray:unSelArray];
        [unSelArray removeAllObjects];
        [self.checkBtn setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        
    }
    self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)selArray.count];
    [self.tableView reloadData];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"confirmin"]){
        ConfirmInViewController *viewController = segue.destinationViewController;
        viewController.unSelArray = unSelArray;
        viewController.selArray = selArray;
        viewController.order = self.order;
    }
}


#pragma mark - TableView 

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return unSelArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderDetailTableViewCell *cell = [OrderDetailTableViewCell cellWithTableView:tableView];
    cell.orderType = self.order.type;
    PuOrderChild *inMat = unSelArray[indexPath.row];
    inMat.curQty = inMat.sourceQty-inMat.rkQty;//默认当前的入库数量为订单上的sourceQty-已入库数量;如果<0,则,为0
    if(inMat.curQty<0){
        inMat.curQty = 0;
    }
    [cell showCell:inMat];
    cell.addBtn.tag = 1000+indexPath.row;
    [cell.addBtn addTarget:self action:@selector(addToCheck:) forControlEvents:UIControlEventTouchUpInside];
    //减号"-"事件
    cell.delLabel.tag = 2000+indexPath.row;
    [cell.delLabel addTarget:self action:@selector(delQty:) forControlEvents:UIControlEventTouchUpInside];
    
    //加号"+"事件
    cell.addLabel.tag = 3000+indexPath.row;[cell.addLabel addTarget:self action:@selector(addQty:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    PuOrderChild *inMat = unSelArray[tag];
    if(inMat.curQty-1<=0){
        inMat.curQty = 0.0;
    }else{
        inMat.curQty = inMat.curQty-1;
    }
    [self.tableView reloadData];
}

-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-3000;
    PuOrderChild *inMat = unSelArray[tag];
    if(inMat.curQty+1>inMat.limitQty-inMat.rkQty){
        inMat.curQty = inMat.limitQty-inMat.rkQty;
    }else{
        inMat.curQty = inMat.curQty+1;
    }
    [self.tableView reloadData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //弹出对话框,填写数量
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 4000+indexPath.row;
    PuOrderChild *inMat = unSelArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    //尾数去0
    countText.text = [StringUtil changeFloat:[NSString stringWithFormat:@"%f",inMat.curQty]];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==alertView.firstOtherButtonIndex){
        NSInteger tag = alertView.tag-4000;
        UITextField *countText = [alertView textFieldAtIndex:0];
        NSString *count = countText.text;
        PuOrderChild *inMat = unSelArray[tag];
        double qty = [count doubleValue];
        if(qty+inMat.rkQty>inMat.limitQty){
            //数量过大
            [self.view makeToast:@"数量超过上限,请重新输入!" duration:3.0 position:CSToastPositionCenter];
        }else{
            inMat.curQty = qty;
        }
        [self.tableView reloadData];
    }
}

- (void)addToCheck:(id)sender {
    UIButton *btn = sender;
    NSInteger position = btn.tag - 1000;
    [selArray addObject:unSelArray[position]];
    [unSelArray removeObjectAtIndex:position];
    [self.tableView reloadData];
    self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)selArray.count];
}

@end
