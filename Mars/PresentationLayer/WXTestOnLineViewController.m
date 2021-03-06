//
//  WXTestOnLineViewController.m
//  Mars
//
//  Created by 王霄 on 16/5/19.
//  Copyright © 2016年 Muggins_. All rights reserved.
//

#import "WXTestOnLineViewController.h"
#import "WXTestTextFieldCell.h"
#import "userSelectCell.h"
#import "CityPickView.h"
#import "WXTestOnLineResultViewController.h"
#import "WXTestOnlineModel.h"

@interface WXTestOnLineViewController () <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,CityPickViewDelegate,CTAssetsPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) CityPickView *pickView;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, strong) WXTestOnlineModel *model;
@property (nonatomic, copy) NSString *artificial_test_id;
@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, assign) NSInteger maxCount;
@end

@implementation WXTestOnLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myTableView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    self.address = @"未选择";
    self.model = [WXTestOnlineModel onLineModel];
    self.navigationItem.title = @"线上测评";
    self.navigationItem.rightBarButtonItem = ({
        UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [commitButton setTitle:@"提交" forState:UIControlStateNormal];
        [commitButton setTitleColor:WXGreenColor forState:UIControlStateNormal];
        commitButton.frame = CGRectMake(0, 0, 40, 30);
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:commitButton];
        [commitButton bk_whenTapped:^{
            if (![self checkTableData]) {
                return ;
            }
            [SVProgressHUD show];
            [self uploadData];
        }];
        item;
    });
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    
    [self configureTableView];
    
    self.pickView = [[CityPickView alloc] initWithFrame:CGRectMake(0, kScreenHeight, self.view.bounds.size.width, 180)];;
    self.pickView.delegate = self;
    [self.view addSubview:self.pickView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

- (void)uploadData {
    AFHTTPSessionManager *manager = [[NetworkManager sharedInstance] fetchSessionManager];
    NSURL *url = [NSURL URLWithString:[URL_PREFIX stringByAppendingString:@"Test/Baiding/artificial_test"]];
    NSDictionary *parameters = @{
                                 @"name":self.model.name,
                                 @"phone":self.model.phone,
                                 @"sex":self.model.sex,
                                 @"grade":self.model.grade,
                                 @"province":self.model.province,
                                 @"city":self.model.city,
                                 @"district":self.model.district,
                                 @"school":self.model.school,
                                 @"sum_score":self.model.sum_score,
                                 @"estimate_score":self.model.estimate_score,
                                 @"interest":self.model.interest};
    [manager POST:url.absoluteString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if([responseObject[@"code"] isEqualToString:@"200"]) {
            self.artificial_test_id = responseObject[@"data"][@"artificial_test_id"];
            [self fetchImageData:0];
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

- (void)fetchImageData:(NSInteger )index {
    NSLog(@"fetch image data %d",index);
    PHAsset *asset = self.assets[index];
    PHImageManager *manager = [PHImageManager defaultManager];
    if (self.maxCount == 3) {
        [manager requestImageDataForAsset:asset options:PHImageRequestOptionsResizeModeNone resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            [self uploadImage:imageData index:index];
        }];
    }
    else {
        [manager requestAVAssetForVideo:self.assets[index] options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *avasset = (AVURLAsset *)asset;
            NSData *videoData = [NSData dataWithContentsOfURL:avasset.URL];
            [self uploadVideo:videoData index:index];
        }];
    }
}

- (void)uploadImage:(NSData *)imageData index:(NSInteger)index{
    
    AFHTTPSessionManager *manager = [[NetworkManager sharedInstance] fetchSessionManager];
    NSURL *url = [NSURL URLWithString:[URL_PREFIX stringByAppendingString:@"Test/Baiding/artificial_upload"]];
    NSDictionary *parameters = @{
                                 @"artificial_test_id":self.artificial_test_id};
    [manager POST:url.absoluteString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        [formData appendPartWithFileData:imageData name:@"photo" fileName:fileName mimeType:@"image/png"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if([responseObject[@"code"] isEqualToString:@"200"]) {
            if (index == self.assets.count-1) {
                [SVProgressHUD dismiss];
                WXTestOnLineResultViewController *vc = [[WXTestOnLineResultViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                dispatch_after(1.0, dispatch_get_main_queue(), ^{
                    [self fetchImageData:index+1];
                });
            }
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

- (void)uploadVideo:(NSData *)videoData index:(NSInteger)index{
    NSLog(@"upload video");
    AFHTTPSessionManager *manager = [[NetworkManager sharedInstance] fetchSessionManager];
    NSURL *url = [NSURL URLWithString:[URL_PREFIX stringByAppendingString:@"Test/Baiding/artificial_upload"]];
    NSDictionary *parameters = @{
                                 @"artificial_test_id":self.artificial_test_id};
    [manager POST:url.absoluteString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.mov", str];
        [formData appendPartWithFileData:videoData name:@"photo" fileName:fileName mimeType:@"video/quicktime"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if([responseObject[@"code"] isEqualToString:@"200"]) {
            [SVProgressHUD dismiss];
            WXTestOnLineResultViewController *vc = [[WXTestOnLineResultViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
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

- (BOOL)checkTableData {
    if (self.model.phone.length != 11) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD dismiss];
        } afterDelay:1.5];
        return false;
    }
    if(!self.model.name.length) {
        [SVProgressHUD showErrorWithStatus:@"请输入姓名"];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD dismiss];
        } afterDelay:1.5];
        return false;
    }
    if (!self.model.province.length) {
        [SVProgressHUD showErrorWithStatus:@"请选择省份"];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD dismiss];
        } afterDelay:1.5];
        return false;
    }
    if (!self.model.sum_score.length) {
        [SVProgressHUD showErrorWithStatus:@"请输入文化课总分"];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD dismiss];
        } afterDelay:1.5];
        return false;
    }
    if (!self.model.estimate_score.length) {
        [SVProgressHUD showErrorWithStatus:@"请输入分数估值"];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD dismiss];
        } afterDelay:1.5];
        return false;
    }
    if (!self.assets.count) {
        [SVProgressHUD showErrorWithStatus:@"请上传作品"];
        [self bk_performBlock:^(id obj) {
            [SVProgressHUD dismiss];
        } afterDelay:1.5];
        return false;
    }
    return true;
}

- (void)configureTableView {
    [self.myTableView registerNib:[UINib nibWithNibName:NSStringFromClass([WXTestTextFieldCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WXTestTextFieldCell class])];
    [self.myTableView registerNib:[UINib nibWithNibName:@"userSelectCell" bundle:nil] forCellReuseIdentifier:@"userSelectCell"];
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"informationCell"];
    
    self.myTableView.tableFooterView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        view.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
        
        self.uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.uploadButton.frame = CGRectMake(15, 20, kScreenWidth - 30, 60);
        self.uploadButton.backgroundColor = [UIColor colorWithHexString:@"#cccccc"];
        [self.uploadButton setTitle:@"点击上传照片或视频" forState:UIControlStateNormal];
        [self.uploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.uploadButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.uploadButton bk_whenTapped:^{
            [self showActionSheet];
        }];
        [view addSubview:self.uploadButton];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 90, [UIScreen mainScreen].bounds.size.width-30, 100)];
        label.text = @"考生/家长您好！这里是线上评测区:\n1、如果您学过美术，请上传您的绘画作品照片（素描速写色彩各一张\n2、如果您的颜值高，请发三张近期正面素颜生活照\n3、如果您嗓音条件出众，请上传自备稿件朗读视频（一分钟以内)\n4、如果您演唱水平高超，请上传声乐演唱视频。\n5、如果您有器乐演奏特长，请上传器乐演奏视频\n专家老师会根据您的表现进行评测，给予专业上的建议和指导，指出您的不足。明确告知您适合学习哪个专业。\n如果有时间您还可以和专家老师细致沟通，没准儿跟你指导两下就会有不小的进步。";
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 0;
        label.textColor = [UIColor colorWithHexString:@"#666666"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5.0f];//调整行间距
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [label.text length])];
        label.attributedText = attributedString;
        [label sizeToFit];
        view.frame = CGRectMake(0, 0, kScreenWidth, 90 + label.frame.size.height + 10);
        [view addSubview:label];
        view;
    });
}

- (void)showActionSheet {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择上传类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *uploadVideo = [UIAlertAction actionWithTitle:@"上传视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.maxCount = 1;
        [self showPicker:PHAssetMediaTypeVideo];
    }];
    UIAlertAction *uploadImage = [UIAlertAction actionWithTitle:@"上传图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.maxCount = 3;
        [self showPicker:PHAssetMediaTypeImage];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:uploadVideo];
    [alertVC addAction:uploadImage];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - ImagePicker

- (void)showPicker:(PHAssetMediaType *)type {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // create options for fetching photo only
            PHFetchOptions *fetchOptions = [PHFetchOptions new];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", type];
            
            // assign options
            picker.assetsFetchOptions = fetchOptions;
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
            
        });
    }];
}

// implement should select asset delegate
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = self.maxCount;
    
    // show alert gracefully
    if (picker.selectedAssets.count >= max)
    {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"提示"
                                            message:[NSString stringWithFormat:@"最多一次上传3张图片或1个视频"]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil];
        
        [alert addAction:action];
        
        [picker presentViewController:alert animated:YES completion:nil];
    }
    
    // limit selection to max
    return (picker.selectedAssets.count < max);
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    self.uploadButton.backgroundColor = WXGreenColor;
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.assets = [NSMutableArray arrayWithArray:assets];
//    if (self.assets.count) {
//        [SVProgressHUD showSuccessWithStatus:@"选择照片、视频成功！"];
//        [self bk_performBlock:^(id obj) {
//            [SVProgressHUD dismiss];
//        } afterDelay:1.5];
//    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 4;
            break;
        case 2:
            return 3;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:{
                userSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userSelectCell"];
                cell.leftButtonName = @"男生";
                cell.rightButtonName = @"女生";
                cell.contentLabel.text = @"性别";
                cell.delegateSingal = [RACSubject subject];
                @weakify(self)
                [cell.delegateSingal subscribeNext:^(NSNumber *message) {
                    @strongify(self)
                    if([message isEqual:@(0)]) {
                        self.model.sex = @"男生";
                    }
                    else {
                        self.model.sex = @"女生";
                    }
                    NSLog(@"%@",self.model.sex);
                }];
                return cell;
                break;
            }
            case 1:{
                userSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userSelectCell"];
                cell.leftButtonName = @"应届";
                cell.rightButtonName = @"复读";
                cell.contentLabel.text = @"年级";
                cell.delegateSingal = [RACSubject subject];
                @weakify(self)
                [cell.delegateSingal subscribeNext:^(NSNumber *message) {
                    @strongify(self)
                    if([message isEqual:@(0)]) {
                        self.model.grade = @"应届";
                    }
                    else {
                        self.model.grade = @"复读";
                    }
                    NSLog(@"%@",self.model.grade);
                }];
                return cell;
                break;
            }
            case 2:{
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"informationCell"];
                cell.textLabel.font = [UIFont systemFontOfSize:14.0];
                [cell.textLabel setTextColor:WXTextGrayColor];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
                [cell.detailTextLabel setTextColor:WXTextGrayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"省份";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = self.address;
                return cell;
                break;
            }
            case 3:{
                userSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userSelectCell"];
                cell.leftButtonName = @"普高";
                cell.rightButtonName = @"艺术高中";
                cell.contentLabel.text = @"高中";
                cell.delegateSingal = [RACSubject subject];
                @weakify(self)
                [cell.delegateSingal subscribeNext:^(NSNumber *message) {
                    @strongify(self)
                    if([message isEqual:@(0)]) {
                        self.model.school = @"普高";
                    }
                    else {
                        self.model.school = @"艺术高中";
                    }
                    NSLog(@"%@",self.model.school);
                }];
                return cell;
                break;
            }
        }
    }
    else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:{
                WXTestTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WXTestTextFieldCell class])];
                cell.contentLabel.text = @"文化课总分:";
                cell.contentTF.placeholder = @"请填写真实省份高考总分";
                cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
                [cell.contentTF.rac_textSignal subscribeNext:^(NSString *text) {
                    self.model.sum_score = text;
                }];
                return cell;
                break;
            }
            case 1:{
                WXTestTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WXTestTextFieldCell class])];
                cell.contentLabel.text = @"您的分数:";
                cell.contentTF.placeholder = @"请填写您的分数估值";
                cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
                [cell.contentTF.rac_textSignal subscribeNext:^(NSString *text) {
                    self.model.estimate_score = text;
                }];
                return cell;
                break;
            }
            case 2:{
                userSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userSelectCell"];
                cell.leftButtonName = @"美术方向";
                cell.rightButtonName = @"传媒方向";
                cell.otherButtonName = @"音乐方向";
                cell.contentLabel.text = @"兴趣";
                cell.delegateSingal = [RACSubject subject];
                @weakify(self)
                [cell.delegateSingal subscribeNext:^(NSNumber *message) {
                    @strongify(self)
                    NSLog(@"%@",message);
                    if([message isEqual:@(0)]) {
                        self.model.interest = @"美术方向";
                    }
                    else if([message isEqual:@(1)]){
                        self.model.interest = @"传媒方向";
                    }
                    else {
                        self.model.interest = @"音乐方向";
                    }
                    NSLog(@"%@",self.model.interest);
                }];
                return cell;
                break;
            }
        }
    }
    else {
        switch (indexPath.row) {
            case 0:{
                WXTestTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WXTestTextFieldCell class])];
                cell.contentLabel.text = @"手机号码:";
                cell.contentTF.placeholder = @"请输入您的手机号";
                cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
                [cell.contentTF.rac_textSignal subscribeNext:^(NSString *text) {
                    self.model.phone = text;
                }];
                return cell;
                break;
            }
            case 1:{
                WXTestTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WXTestTextFieldCell class])];
                cell.contentLabel.text = @"姓名:";
                cell.contentTF.placeholder = @"请输入您的姓名";
                [cell.contentTF.rac_textSignal subscribeNext:^(NSString *text) {
                    self.model.name = text;
                }];
                return cell;
                break;
            }
        }
    }
    return nil;
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
        label.text = @"联系方式";
    }
    else if (section == 1) {
        label.text = @"以下资料是为您提供更恰当的指导，我们会严格保密";
    }
    else {
        label.text = @"学习";
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 2) {
        [UIView animateWithDuration:0.25 animations:^{
            self.pickView.backgroundColor = [UIColor whiteColor];
            self.pickView.frame = CGRectMake(0, kScreenHeight-270, kScreenWidth, 270);
        } completion:nil];
    }
}

#pragma mark <scrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark <cityPickerDelegate>

- (void)cancel {
    @weakify(self)
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self)
        self.pickView.backgroundColor = [UIColor whiteColor];
        self.pickView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 270);
    } completion:nil];
}

- (void)selectCity:(NSString *)city{
    NSLog(@"%@",city);
    self.address = city;
    [self cancel];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    [self.myTableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)fetchDetail:(NSString *)province city:(NSString *)city district:(NSString *)district{
    self.model.province = province;
    self.model.city = city;
    self.model.district = district;
//    self.viewModel.province = province;
//    self.viewModel.city = city;
//    self.viewModel.district = district;
//    
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
//    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
