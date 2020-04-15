//
//  TradeViewController.m
//  Finance
//
//  Created by Atimu on 2017/8/10.
//  Copyright © 2017年 finance. All rights reserved.
//
#import "TradeViewController.h"
#import "TradeBuyViewController.h"
#import "MainNewsViewController.h"
#import "TradeChangeViewController.h"
#import "TradeTransferViewController.h"
#import "FundDetailsViewController.h"
#import "ActivationViewController.h"
#import "MyWalletViewController.h"
#import "CycleCollectionCell.h"
#import "CycleViewLayout.h"
#import "WYHorScreenView.h"
#import "UIImage+GIF.h"
#import "FundModel.h"

@interface TradeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) WYHorScreenView* horScreenView;
@property (nonatomic,strong) UICollectionView *CycleView;
@property (nonatomic,strong) NSMutableArray   *dataModels;
@property (assign,nonatomic) NSInteger  buttonIndex;
@property (assign,nonatomic) NSInteger  wallatCount;

@end

@implementation TradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //k线图高度
    self.screenView.contentSize = CGSizeMake(kkScreenWidth, 0);
    self.title = self.dataModel.Name;
    CGRect frame = self.screenView.frame;
    frame.size.height = kkScreenHeight - 64 - 112 - self.buttonView.frame.size.height;
    if (kDevice_Is_iPhoneX) {
        frame.size.height = frame.size.height - 43;
    }
    self.screenView.frame = frame;
    
    //添加k线
    WYHorScreenView *horScreenView = [[WYHorScreenView alloc]initWithFrame:CGRectMake(0, 0, kkScreenWidth, self.screenView.frame.size.height) SelecIndex:0];
    horScreenView.backgroundColor = [UIColor whiteColor];
    horScreenView.clipsToBounds = YES;
    horScreenView.dataModel = self.dataModel;
    [self.screenView addSubview:horScreenView];
    self.horScreenView = horScreenView;
    //刷新K线图数据
    [self.horScreenView showProgress:@""];
    [self.horScreenView getDataWithSelectIndex];
    
    self.imageUp.image = [UIImage sd_animatedGIFNamed:@"common_up"];
    self.imageDowm.image = [UIImage sd_animatedGIFNamed:@"common_dowm"];
    NSMutableArray *array = [AppModel shareInstance].allGoodsList[self.dataIndex];
    self.dataModels = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        [self.dataModels addObjectsFromArray:array];
    }
    self.dataModel.index = self.dataModel.index + 1;
    _buttonIndex = self.dataModels.count/2 + self.dataModel.index;

    if(self.dataModel.MarketStatus == 0){
        [self.buttonBuy setBackgroundImage:[UIImage imageNamed:@"list_goods.png"] forState:(UIControlStateNormal)];
        [self.buttonGoods setBackgroundImage:[UIImage imageNamed:@"list_goods.png"] forState:(UIControlStateNormal)];
        self.buttonBuy.userInteractionEnabled = NO;
        self.buttonGoods.userInteractionEnabled = NO;
    }

    //创建布局
    CycleViewLayout *layout = [[CycleViewLayout alloc]init];
    layout.sectionInset = UIEdgeInsetsMake(0, 50, 0, 50);
    layout.itemSize = CGSizeMake(kkScrollWidth, 110);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    //创建CollectionView
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 40, kkScreenWidth, 125) collectionViewLayout:layout];
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    self.CycleView = collectionView;
    [self.buttonView addSubview:self.CycleView];
    //注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CycleCollectionCell class]) bundle:nil] forCellWithReuseIdentifier:@"CycleCell"];
    [self.CycleView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_buttonIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CycleCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CycleCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[CycleCollectionCell alloc] init];
    }
    GoodsModel *model = self.dataModels[indexPath.row];
    if (indexPath.row == self.buttonIndex) {
        cell.backImage.highlighted = YES;
    }else{
        cell.backImage.highlighted = NO;
    }
    cell.dataModel = model;
    // Configure the cell
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.CycleView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    self.buttonIndex = indexPath.row;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x/(kkScrollWidth + 0);
//    NSLog(@"滚动到：%zd",page);
    if (page == 0) {//滚动到左边
//        scrollView.contentOffset = CGPointMake(kkScrollWidth* (self.dataModels.count - 2), 0);
        page = self.dataModels.count/2-1;
        [self.CycleView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        page = page-1;
    }else if (page == self.dataModels.count - 2){//滚动到右边
        page = self.dataModels.count/2;
        [self.CycleView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        page = page-1;
    }else{
    }
    self.buttonIndex = (page + 1);
}

-(void)setButtonIndex:(NSInteger)buttonIndex{
    _buttonIndex = buttonIndex;
    //选中状态
    [self.CycleView reloadData];
//    [self.CycleView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:buttonIndex inSection:0]]];
    buttonIndex = buttonIndex%[[AppModel shareInstance].allGoodsList[self.dataIndex] count];
    GoodsModel* model = [AppModel shareInstance].allGoodsList[self.dataIndex][buttonIndex];
    NSString *MarketPrice = [UTilities formateNumber:model.MarketPrice];
    NSString* text = [NSString stringWithFormat:@"市场价%@元，资金放大约%0.f倍！", MarketPrice, model.Multiple];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    // 获取标红的位置和长度
    NSRange range = [text rangeOfString:MarketPrice];
    // 设置标签文字的属性
    [str setAttributes:@{NSForegroundColorAttributeName :textColorSelected, NSFontAttributeName : [UIFont systemFontOfSize:14]} range:range];
    range.length = [[NSString stringWithFormat:@"%.0f",model.Multiple] length];
    range.location = text.length - [[NSString stringWithFormat:@"%.0f",model.Multiple] length] - 2;
    [str setAttributes:@{NSForegroundColorAttributeName :textColorSelected, NSFontAttributeName : [UIFont systemFontOfSize:14]} range:range];
    self.labelPrice.attributedText = str;
    self.dataModel.index = buttonIndex;
    [self refreshWalletCount];
}

-(void)setCurrentState:(NSInteger)currentState{
    //刷新余额
    if (currentState == 1) {
        NSDictionary *account = [AppModel shareInstance].accountList[self.dataModel.ExchangeTypeID];
        NSString *str = [UTilities formateMoney:[account[@"Balance"] floatValue]];
        [self.buttonBalance setTitle:str forState:(UIControlStateNormal)];
    }
    
    if (currentState == 2) {
        for (GoodsModel*model in [AppModel shareInstance].priceArray) {
            if ([model.TypeCode isEqualToString:self.dataModel.TypeCode] && model.CurPrice != self.dataModel.CurPrice){
                NSLog(@"\n%@--%.1f      %@",model.Name,model.CurPrice,model.PriceTime);
                self.dataModel = model;
                self.horScreenView.dataModel = model;
                [self.horScreenView refreshWithModel];
                [self refreshData];
            }
        }
    }
}

- (void)refreshData{
    [kkTabbar setHidden:YES];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[NSNumber numberWithFloat:self.dataModel.CurPrice] forKey:@"curPrice"];
    [param setValue:self.dataModel.ExchangeTypeID forKey:@"ExchangeTypeID"];
    [param setValue:self.dataModel.TypeCode forKey:@"goodsType"];
    
    [[AFNRequest sharedInstance] get:[InvestRequestAPI getTradeRatio] ReqParam:param success:^(AFHTTPRequestOperation *operation, NSString* responseObject) {
        [self hideProgress];
        NSData *jsonData = [responseObject dataUsingEncoding:(NSUTF8StringEncoding)];
        if (jsonData == nil) {
            return ;
        }
        
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:NULL];
        if (dic == nil) {
            return ;
        }
        CGFloat up = 0,dowm = 0;
        if ([dic[@"ResultCD"] isEqualToString:@"I001"]){
            for (GoodsModel*model in [AppModel shareInstance].allGoodsList[self.dataIndex]) {
                for (NSDictionary*trade in dic[@"TradeRatios"]) {
                    up = [dic[@"TradeRatios"][0][@"BuySell1"] floatValue];
                    dowm = [dic[@"TradeRatios"][0][@"BuySell2"] floatValue];
                    if ([model.Code isEqualToString:trade[@"GoodsCode"]]) {
                        model.MarketPrice = [trade[@"MarketPrice"] floatValue];
                        CGFloat depositFee = [[AppModel shareInstance].depositDic[model.Code] floatValue];
                        model.Multiple = model.MarketPrice/depositFee - 0.5;
                    }
                }
            }
            self.buttonIndex = self.buttonIndex;
        }
        if (dowm == 0 || up == 0) {
            dowm = 50;
            up = 50;
        }
        self.originUp.constant = kkScreenWidth*dowm/(up+dowm);
        self.labelUp.text = [NSString stringWithFormat:@"看涨%.0f%%",up/(up+dowm)*100];
        self.labelDowm.text = [NSString stringWithFormat:@"看跌%.0f%%",dowm/(up+dowm)*100];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(refreshData) withObject:nil afterDelay:10];
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"priceArray"]){
        self.currentState = 2;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [kkTabbar setHidden:YES];
    kkTabbar.userInteractionEnabled = YES;
    self.navigationController.navigationBarHidden = NO;
    [self refreshData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"refreshCustomer" object:nil];
    //刷新价格
    [[AppModel shareInstance] addObserver:self forKeyPath:@"priceArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    if (kkLoginState > 0) {
        [self.buttonLogin setTitle:@"充值»" forState:(UIControlStateNormal)];
        //余额
        [self refreshInvestorList:NO];
        [self refreshWalletCount];
        //    [self addPriceTimer:@""];
    }else{
        [self.buttonLogin setTitle:@"开户领券" forState:(UIControlStateNormal)];
        [self.buttonWallet setTitle:@"代金券 --" forState:(UIControlStateNormal)];
        [self.buttonBalance setTitle:@"--" forState:(UIControlStateNormal)];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(kkCurrentViewState == CurrentView_Trade_Buy){
        [self BuyGoods:self.buttonBuy];
    }
}

- (void)refreshWalletCount{
    //判断开户
    NSDictionary *account = [AppModel shareInstance].accountList[self.dataModel.ExchangeTypeID];
    if ([account[@"isActive"] integerValue] == 0) {
        return;
    }
    GoodsModel* dataModel = self.dataModels[self.dataModel.index];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:dataModel.Code forKey:@"goodsCode"];
    [param setValue:self.dataModel.ExchangeTypeID forKey:@"ExchangeTypeID"];
    [param setValue:[AppModel shareInstance].depositDic[dataModel.Code] forKey:@"DepositFee"];
    
    [[AFNRequest sharedInstance] postRequest:[InvestRequestAPI getWalletCount] ReqParam:param success:^(AFHTTPRequestOperation *operation, NSString* responseObject) {
        NSError *error = [operation error];
        if (!error) {
            [self hideProgress];
            NSDictionary * dic = [UTilities decodeAESString:responseObject];
            if (dic == nil) {
                [self showToast:@"网络连接失败"];
                return ;
            }
            
            if ([dic[@"ResultCD"] isEqualToString:@"I001"]){
                [self.buttonWallet setTitle:[NSString stringWithFormat:@"代金券 %@",dic[@"CustomerVoucherCount"]] forState:(UIControlStateNormal)];
                self.wallatCount = [dic[@"CustomerVoucherCount"] integerValue];
            }else{
                [self showToast:dic[@"ErrorMsg"]];
            }
        }
        [self hideProgress];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideProgressFailed];
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:@"refreshCustomer"];
    [[AppModel shareInstance] removeObserver:self forKeyPath:@"priceArray"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtonPressed{
    [kkTabbar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

//订货&融货
- (IBAction)BuyGoods:(UIButton *)sender {
//    if ([self.dataModel.EndTime compare:[UTilities formateTodayDate:@"yyyy-MM-dd HH:mm:ss"]]
    if (self.dataModel.MarketStatus == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"已休市" message:@"\n交易时间为周一到周五" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if ([self checkLoginActiveState:self.dataModel.ExchangeTypeID]) {
        TradeBuyViewController*vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TradeBuyViewController"];
        vc.tradeModel = self.dataModel;
        vc.dataIndex = self.dataIndex;
        if (sender.tag == 0) {
            vc.tradeModel.dir = @"1";
        }else{
            vc.tradeModel.dir = @"2";
        }
        if (kkCurrentViewState > 0) {
            vc.type = 1;
            kkCurrentViewState = 0;
        }
        vc.providesPresentationContextTransitionStyle = YES;
        vc.definesPresentationContext = YES;
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:vc animated:NO completion:nil];
    }
}

//使用代金券
- (IBAction)goWallet:(UIButton *)sender {
    if (self.dataModel.MarketStatus == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"已休市" message:@"\n交易时间为周一到周五" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    //判断开户和登录
    if ([self checkLoginActiveState:self.dataModel.ExchangeTypeID]) {
        if (self.wallatCount == 0) {
//            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:nil];
//            MyWalletViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"MyWalletViewController"];
//            viewController.ExchangeTypeID = self.dataModel.ExchangeTypeID;
//            [self.navigationController pushViewController:viewController animated:YES];
            [self showToast:@"暂无该类型代金券"];
            return;
        }else{
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Trade" bundle:nil];
            TradeBuyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TradeBuyViewController"];
            vc.tradeModel = self.dataModel;
            vc.dataIndex = self.dataIndex;
            //代金券
            vc.type = 1;
            vc.tradeModel.dir = @"1";
            vc.tradeModel.ExchangeTypeID = self.dataModel.ExchangeTypeID;
            
            vc.definesPresentationContext = YES;
            vc.providesPresentationContextTransitionStyle = YES;
            vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:vc animated:NO completion:nil];
        }
    }
}

//充值
- (IBAction)recharge:(UIButton *)sender {
    if ([self checkLoginActiveState:self.dataModel.ExchangeTypeID]) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FindWebViewController *webView =[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webView.ExchangeTypeID = self.dataModel.ExchangeTypeID;
        webView.title = @"充值";
        [self.navigationController pushViewController:webView animated:YES];
    }
}

//持仓单
- (IBAction)fundDetails:(UIButton *)sender {
    if ([self checkLoginActiveState:self.dataModel.ExchangeTypeID]) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:nil];
        FundDetailsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"FundDetailsViewController"];
        viewController.ExchangeTypeID = self.dataModel.ExchangeTypeID;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

//盈利播报
- (IBAction)goNews:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainNewsViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"MainNewsViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
