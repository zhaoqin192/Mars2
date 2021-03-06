//
//  WXTestOnLineResultViewController.m
//  Mars
//
//  Created by 王霄 on 16/6/12.
//  Copyright © 2016年 Muggins_. All rights reserved.
//

#import "WXTestOnLineResultViewController.h"
#import "WXCategoryTestViewController.h"
#import "WXTestKnowledgeViewController.h"

@interface WXTestOnLineResultViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, copy) NSArray *knowledgeList;
@end

@implementation WXTestOnLineResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"线上测试";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.backButton.layer.cornerRadius = self.backButton.height/2;
    self.backButton.layer.masksToBounds = YES;
    [self.backButton bk_whenTapped:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    self.myTableView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"informationCell"];
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
    NSURL *url = [NSURL URLWithString:[URL_PREFIX stringByAppendingString:@"Test/Baiding/getLabel"]];
    NSDictionary *parameters = nil;
    [manager POST:url.absoluteString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if([responseObject[@"code"] isEqualToString:@"200"]) {
            self.knowledgeList = responseObject[@"points"];
            [self.myTableView reloadData];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return self.knowledgeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"informationCell"];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    [cell.textLabel setTextColor:WXTextGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"单元测试";
                break;
            case 1:
                cell.textLabel.text = @"进阶测试";
                break;
            case 2:
                cell.textLabel.text = @"模拟测试";
                break;
        }
    }
    else {
        cell.textLabel.text = self.knowledgeList[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                WXCategoryTestViewController *vc = [[WXCategoryTestViewController alloc] init];
                vc.title = @"单元测试";
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 1:{
                WXCategoryTestViewController *vc = [[WXCategoryTestViewController alloc] init];
                vc.title = @"进阶测试";
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 2:{
                WXCategoryTestViewController *vc = [[WXCategoryTestViewController alloc] init];
                vc.title = @"模拟测试";
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
        }
    }
    else {
        WXTestKnowledgeViewController *vc = [[WXTestKnowledgeViewController alloc] init];
        vc.myTitle = self.knowledgeList[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 37)];
    view.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = WXTextGrayColor;
    label.frame = CGRectMake(15, 15, kScreenWidth, 12);
    [view addSubview:label];
    if (section == 0) {
        label.text = @"推荐测试";
    }
    else if (section == 1) {
        label.text = @"知识点推荐";
    }
    return view;
}

@end
