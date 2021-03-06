//
//  OutDealDetailViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "OutDealDetailViewController.h"

@interface OutDealDetailViewController ()

@end

@implementation OutDealDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"出库选择";
    [self showOrder];
    UITapGestureRecognizer *checkAllTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkAll:)];
    self.checkLabel.userInteractionEnabled = YES;
    [self.checkLabel addGestureRecognizer:checkAllTap];
    
    [self.confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UITapGestureRecognizer *chooseConsumerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseConsumer:)];
    self.consumerLabel.userInteractionEnabled = YES;
    [self.consumerLabel addGestureRecognizer:chooseConsumerTap];
}

/**
 *  跳转到确认界面
 *
 *  @param sender <#sender description#>
 */
-(void)confirm:(id)sender {
    if(selArray.count==0){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"请先选择物料信息!"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{
        [self performSegueWithIdentifier:@"confirmout" sender:self];
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
    matArray = [PuOrderChild findByCriteria:[NSString stringWithFormat:@" WHERE orderid = '%@' and isFinish = 0 order by xsxh",self.order.id]];
    unSelArray = [[NSMutableArray alloc] init];
    for(PuOrderChild *inMat in matArray){
        double source = [inMat.sourceQty doubleValue];
        double ck = [inMat.ckQty doubleValue];
        if(ck<source){
            [unSelArray addObject:inMat];
        }
    }
    
    unSelArray = [[NSMutableArray alloc] initWithArray:matArray];
    for(PuOrderChild *inMat in unSelArray){
        
        double cur = [inMat.curQty doubleValue];
        double source = [inMat.sourceQty doubleValue];
        double ck = [inMat.ckQty doubleValue];
        
        
        cur = source-ck;//默认当前的入库数量为订单上的sourceQty-已入库数量;如果<0,则,为0
        if(cur<0){
            cur = 0;
        }
        inMat.curQty = [NSString stringWithFormat:@"%f",cur];
    }
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
    if([segue.identifier isEqualToString:@"confirmout"]){
        ConfirmOutViewController *viewController = segue.destinationViewController;
        viewController.unSelArray = unSelArray;
        viewController.selArray = selArray;
        viewController.order = self.order;
        viewController.consumer = self.consumer;
    }else if([segue.identifier isEqualToString:@"outdetailtochoose"]){
        ChooseConsumerViewController *viewController = segue.destinationViewController;
        if([self.order.type isEqualToString:@"rkck"]){
            viewController.orderid = self.order.sourceid;
        }else{
            viewController.orderid = self.order.OrderId;
        }
        viewController.flag = 0;
        viewController.delegate = self;
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
    PuOrderChild *outMat = unSelArray[indexPath.row];
    [cell showCell:outMat];
    cell.addBtn.tag = 1000+indexPath.row;
    [cell.addBtn addTarget:self action:@selector(addToCheck:) forControlEvents:UIControlEventTouchUpInside];
    
    //减号"-"事件
    cell.delLabel.tag = 2000+indexPath.row;
    [cell.delLabel addTarget:self action:@selector(delQty:) forControlEvents:UIControlEventTouchUpInside];
    
    //加号"+"事件
    cell.addLabel.tag = 3000+indexPath.row;[cell.addLabel addTarget:self action:@selector(addQty:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //弹出对话框,填写数量
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 4000+indexPath.row;
    PuOrderChild *outMat = unSelArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    //尾数去0
    countText.text = [StringUtil changeFloat:outMat.curQty];
    [alert show];
}

-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    PuOrderChild *outMat = unSelArray[tag];
    
    
//    double limit = 0;
    //获取最终上限
//    if([outMat.limitQty doubleValue]<=0)
//    {
//        limit = [outMat.sourceQty doubleValue];
//    } else {
//        limit = [outMat.limitQty doubleValue];
//    }
    double cur = [outMat.curQty doubleValue];
    double source = [outMat.sourceQty doubleValue];
    double ck = [outMat.ckQty doubleValue];

    
    
    if(cur-1<=0){
        cur = source-ck;
    }else{
        cur = cur-1;
    }
    outMat.curQty = [NSString stringWithFormat:@"%f",cur];
    [self.tableView reloadData];
}

-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-3000;
    PuOrderChild *outMat = unSelArray[tag];
    
    
    double cur = [outMat.curQty doubleValue];
    double source = [outMat.sourceQty doubleValue];
    double ck = [outMat.ckQty doubleValue];
    
    if(cur+1>source-ck){
        cur = source-ck;
        [self.view makeToast:@"数量超过上限!" duration:3.0 position:CSToastPositionCenter];
    }else{
        cur = cur+1;
    }
    outMat.curQty = [NSString stringWithFormat:@"%f",cur];
    [self.tableView reloadData];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==alertView.firstOtherButtonIndex){
        NSInteger tag = alertView.tag-4000;
        UITextField *countText = [alertView textFieldAtIndex:0];
        NSString *count = countText.text;
        PuOrderChild *outMat = unSelArray[tag];
        double qty = [count doubleValue];
        
        double cur = [outMat.curQty doubleValue];
        double source = [outMat.sourceQty doubleValue];
        double ck = [outMat.ckQty doubleValue];
        
        if(qty==0){
            //如果用户输入无效的字符串或者0
            cur = source-ck;
        }else{
            if(qty+ck>source){
                //数量过大
                cur = source-ck;
                [self.view makeToast:@"数量超过上限!" duration:3.0 position:CSToastPositionCenter];
            }else{
                cur = qty;
            }
        }
        
        outMat.curQty = [NSString stringWithFormat:@"%f",cur];
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

/**
 *  选择领料商
 *
 *  @param sender <#sender description#>
 */
-(void)chooseConsumer:(id)sender{
    [self performSegueWithIdentifier:@"outdetailtochoose" sender:self];
}

-(void)pass:(id)value {
    self.consumer = value;
    if(self.consumer){
        self.consumerLabel.text = self.consumer.Name;
    }
}
@end
