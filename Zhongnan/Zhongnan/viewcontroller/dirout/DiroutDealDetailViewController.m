//
//  DiroutDealDetailViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "DiroutDealDetailViewController.h"
#import "UIView+Toast.h"

@interface DiroutDealDetailViewController ()

@end

@implementation DiroutDealDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"直入直出选择";
    
    [self showOrder];
    UITapGestureRecognizer *checkAllTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkAll:)];
    self.checkLabel.userInteractionEnabled = YES;
    [self.checkLabel addGestureRecognizer:checkAllTap];
    
    UITapGestureRecognizer *chooseConsumerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseConsumer:)];
    self.consumerLabel.userInteractionEnabled = YES;
    [self.consumerLabel addGestureRecognizer:chooseConsumerTap];
    
    
    [self.confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
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
        if(self.consumer){
            self.consumerLabel.text = self.consumer.Name;
        }
        [self initData];
    }
}

/**
 *  选择领料商
 *
 *  @param sender <#sender description#>
 */
-(void)chooseConsumer:(id)sender{
    [self performSegueWithIdentifier:@"diroutdetailtochoose" sender:self];
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
        [self performSegueWithIdentifier:@"confirmdirout" sender:self];
    }
}
/**
 *  查询订单上的材料
 */
-(void)initData {
    matArray = [SCOrderInMat findByCriteria:[NSString stringWithFormat:@" WHERE orderid = '%@' and isFinish = 0 ",self.order.id]];
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
    if([segue.identifier isEqualToString:@"confirmdirout"]){
        ConfirmDiroutViewController *viewController = segue.destinationViewController;
        viewController.unSelArray = unSelArray;
        viewController.selArray = selArray;
        viewController.order = self.order;
        viewController.consumer = self.consumer;
    }else if([segue.identifier isEqualToString:@"diroutdetailtochoose"]){
        ChooseConsumerViewController *viewController = segue.destinationViewController;
        viewController.flag = 1;
        viewController.orderid = self.order.id;
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
    SCOrderInMat *inMat = unSelArray[indexPath.row];
    [cell showCell:inMat];
    cell.addBtn.tag = 1000+indexPath.row;
    [cell.addBtn addTarget:self action:@selector(addToCheck:) forControlEvents:UIControlEventTouchUpInside];
    //减号"-"事件
    UITapGestureRecognizer *delTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delQty:)];
    cell.delLabel.tag = 2000+indexPath.row;
    cell.delLabel.userInteractionEnabled = YES;
    [cell.delLabel addGestureRecognizer:delTap];
    //加号"+"事件
    UITapGestureRecognizer *addTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addQty:)];
    cell.addLabel.tag = 3000+indexPath.row;
    cell.addLabel.userInteractionEnabled = YES;
    [cell.addLabel addGestureRecognizer:addTap];

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //弹出对话框,填写数量
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 2000+indexPath.row;
    SCOrderInMat *inMat = unSelArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    countText.text = [NSString stringWithFormat:@"%f",inMat.qty];
    [alert show];
}
/**
 *  减号 不能小于0
 *
 *  @param sender <#sender description#>
 */
-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    SCOrderInMat *inMat = unSelArray[tag];
    if(inMat.qty-1<=0){
        inMat.qty = 0.0;
    }else{
        inMat.qty = inMat.qty-1;
    }
    [self.tableView reloadData];
}


/**
 *  加号  不能大于limitQty-hasQty
 *
 *  @param sender <#sender description#>
 */
-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    SCOrderInMat *inMat = unSelArray[tag];
    if(inMat.qty+1>inMat.limitQty-inMat.hasQty){
        inMat.qty = inMat.limitQty-inMat.hasQty;
    }else{
        inMat.qty = inMat.qty+1;
    }
    [self.tableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==alertView.firstOtherButtonIndex){
        NSInteger tag = alertView.tag-2000;
        UITextField *countText = [alertView textFieldAtIndex:0];
        NSString *count = countText.text;
        SCOrderInMat *inMat = unSelArray[tag];
        double qty = [count doubleValue];
        if(qty!=inMat.sourceQty){
            //数量过大
            [self.view makeToast:@"出库数量应与订单一致!" duration:3.0 position:CSToastPositionCenter];
        }else{
            inMat.qty = qty;
        }
        [self.tableView reloadData];
    }
}
-(void)pass:(id)value {
    self.consumer = value;
    if(self.consumer){
        self.consumerLabel.text = self.consumer.Name;
    }
}


- (void)addToCheck:(id)sender {
    UIButton *btn = sender;
    NSInteger position = btn.tag - 1000;
    [selArray addObject:unSelArray[position]];
    [unSelArray removeObjectAtIndex:position];
    [self.tableView reloadData];
}
@end