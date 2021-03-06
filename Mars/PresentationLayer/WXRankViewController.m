//
//  WXRankViewController.m
//  Mars
//
//  Created by 王霄 on 16/5/19.
//  Copyright © 2016年 Muggins_. All rights reserved.
//

#import "WXRankViewController.h"
#import "RankCCell.h"
#import "WXRankModel.h"
#import "WXHighGradeViewController.h"
#import "WXTestDetailViewController.h"

@interface WXRankViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
//@property (strong, nonatomic)  UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (nonatomic, copy) NSArray *modelArray;
@end

@implementation WXRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"排行榜";
    [self configureCollectionView];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)loadData {
    AFHTTPSessionManager *manager = [[NetworkManager sharedInstance] fetchSessionManager];
    NSURL *url = [NSURL URLWithString:[URL_PREFIX stringByAppendingString:@"Exercise/test/getrange"]];
    AccountDao *accountDao = [[DatabaseManager sharedInstance] accountDao];
    Account *account = [accountDao fetchAccount];
    NSDictionary *parameters = @{@"sid": account.token,
                                 @"test_id":self.test_id};
    [manager POST:url.absoluteString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject[@"code"] isEqualToString:@"200"]) {
            [WXRankModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                return @{
                            @"imageArray": @"answer_image",
                            @"identifier": @"test_result_id"
                         };
            }];
            
            self.modelArray = [WXRankModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
            [self.myCollectionView reloadData];
        }
        else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
            [self bk_performBlock:^(id obj) {
                [SVProgressHUD dismiss];
            } afterDelay:1.5];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD dismiss];
        } afterDelay:1.5];
    }];
}

- (void)configureCollectionView {
//    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
//    flowLayout.minimumInteritemSpacing = 15;
//    flowLayout.minimumLineSpacing = 15;
//    self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:flowLayout];
    self.myCollectionView.delegate = self;
    self.myCollectionView.dataSource = self;
    self.myCollectionView.backgroundColor = [UIColor whiteColor];
    [self.myCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([RankCCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([RankCCell class])];
//    [self.view addSubview:self.myCollectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RankCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([RankCCell class]) forIndexPath:indexPath];
    cell.model = self.modelArray[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(165.0f / 375 * kScreenWidth, 200.0f / 667 * kScreenHeight);
}

//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    CGFloat inset = 15.0f / 375 * kScreenWidth;
//    return UIEdgeInsetsMake(inset, inset, inset, inset);
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WXRankModel *model = self.modelArray[indexPath.row];
    if ([model.type isEqualToString:@"video"]) {//高分视频
        WXHighGradeViewController *gradeVC = [[WXHighGradeViewController alloc] init];
        gradeVC.identifier = model.identifier;
        [self.navigationController pushViewController:gradeVC animated:YES];
    }
    else {//图片
        WXTestDetailViewController *vc = [[WXTestDetailViewController alloc] init];
        vc.image = model.imageArray[0];
        vc.text = @"";
        [self presentViewController:vc animated:YES completion:nil];
    }
}



@end
