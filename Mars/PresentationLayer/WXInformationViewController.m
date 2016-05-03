//
//  WXInformationViewController.m
//  Mars
//
//  Created by 王霄 on 16/5/3.
//  Copyright © 2016年 Muggins_. All rights reserved.
//

#import "WXInformationViewController.h"
#import "ActionSheetStringPicker.h"
#import "UserDetailViewController.h"
#import "userIconCell.h"

@interface WXInformationViewController () <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WXInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.myTitle;
    [self configureTableView];
}

- (void)configureTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"userIconCell" bundle:nil] forCellReuseIdentifier:@"userIconCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"informationCell"];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0 && indexPath.section == 0) {
        cell = (userIconCell *)[self.tableView dequeueReusableCellWithIdentifier:@"userIconCell"];
    }
    else{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"informationCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        [cell.textLabel setTextColor:[UIColor colorWithHexString:@"#666666"]];
    }
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                userIconCell *ucell = (userIconCell *)cell;
                // ucell.iconUrl = self.myAccount.avatar;
                return ucell;
                break;
            }
            case 1:
                cell.textLabel.text = @"昵称";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                //  cell.detailTextLabel.text = self.myAccount.name;
                break;
            case 2:
                cell.textLabel.text = @"手机号";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                // cell.detailTextLabel.text = self.myAccount.sex;
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"性别";
                break;
            case 1:
                cell.textLabel.text = @"年纪";
                //  cell.detailTextLabel.text = self.myAccount.name;
                break;
            case 2:
                cell.textLabel.text = @"省份";
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                // cell.detailTextLabel.text = self.myAccount.sex;
                break;
            case 3:
                cell.textLabel.text = @"高中";
                // cell.detailTextLabel.text = self.myAccount.sex;
                break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell layoutIfNeeded];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 37.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        if ([self.myTitle isEqualToString:@"填写资料"]) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 37)];
            view.backgroundColor = self.tableView.backgroundColor;
            UILabel *label = [[UILabel alloc] init];
            label.text = @"以下资料是为您提供更恰当的指导，我们会严格保密";
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithHexString:@"#666666"];
            label.frame = CGRectMake(15, 15, kScreenWidth, 12);
            [view addSubview:label];
            return view;
        }
        else {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 37)];
            view.backgroundColor = self.tableView.backgroundColor;
            UILabel *label = [[UILabel alloc] init];
            label.text = @"详细资料";
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithHexString:@"#666666"];
            label.frame = CGRectMake(15, 15, kScreenWidth/2, 12);
            [view addSubview:label];
            
            UILabel *editLabel = [[UILabel alloc] init];
            editLabel.text = @"编辑";
            editLabel.font = [UIFont systemFontOfSize:12];
            editLabel.textColor = [UIColor colorWithHexString:@"#666666"];
            editLabel.frame = CGRectMake(kScreenWidth/2-15, 15, kScreenWidth/2, 12);
            editLabel.textAlignment = NSTextAlignmentRight;
            editLabel.userInteractionEnabled = YES;
            [editLabel bk_whenTapped:^{
                NSLog(@"编辑模式");
            }];
            [view addSubview:editLabel];
            return view;
        }
    }
    return nil;
}


#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    
    if (buttonIndex == 0) {
        //        拍照
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if (buttonIndex == 1){
        //        相册
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
    
}


#pragma mark UIImagePickerControllerDelegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    // Handle a still image picked from a photo album
    //    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
    //        == kCFCompareEqualTo) {
    //
    //        editedImage = (UIImage *) [info objectForKey:
    //                                   UIImagePickerControllerEditedImage];
    //        originalImage = (UIImage *) [info objectForKey:
    //                                     UIImagePickerControllerOriginalImage];
    //
    //        if (editedImage) {
    //            imageToUse = editedImage;
    //        } else {
    //            imageToUse = originalImage;
    //        }
    //        // Do something with imageToUse
    //    }
    //    [picker dismissViewControllerAnimated:YES completion:^{
    //        [NetworkRequest uploadAvatar:imageToUse success:^{
    //            [self loadData];
    //        } failure:^{
    //            [SVProgressHUD showErrorWithStatus:@"更新头像失败，请重新尝试"];
    //            [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.5f];
    //        }];
    //    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
