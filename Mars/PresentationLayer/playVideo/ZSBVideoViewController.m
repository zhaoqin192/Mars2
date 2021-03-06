//
//  ZSBVideoViewController.m
//  Mars
//
//  Created by zhaoqin on 6/28/16.
//  Copyright © 2016 Muggins_. All rights reserved.
//

#import "ZSBVideoViewController.h"
#import "EasyLivePlayer.h"
#import "DatabaseManager.h"
#import "AccountDao.h"
#import "Account.h"

@interface ZSBVideoViewController ()<EasyLivePlayerDelegate>
@property (nonatomic, strong) EasyLivePlayer *player;
@property (nonatomic, strong) UIView *playerContinerView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) UIImageView *playImage;
@property (nonatomic, strong) UIImageView *pauseImage;
@property (nonatomic, strong) NSTimer *timer;
@end

static NSString *HOSTADDRESS = @"http://101.200.135.129";

@implementation ZSBVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = self.navigationTitle;
    
    self.playerContinerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.playerContinerView];
    self.player = [[EasyLivePlayer alloc] init];
    self.player.delegate = self;
    self.player.playerContainView = self.playerContinerView;
    
    self.account = [[[DatabaseManager sharedInstance] accountDao] fetchAccount];
    if (!self.videoID) {
        @weakify(self)
        AFHTTPSessionManager *manager = [[NetworkManager sharedInstance] fetchSessionManager];
        NSURL *url = [NSURL URLWithString:[HOSTADDRESS stringByAppendingString:@"/zhanshibang/index.php/exercise/lesson/getLesson"]];
        NSDictionary *parameters = @{@"lesson_id": self.lessonID};
        [manager POST:url.absoluteString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([responseObject[@"code"] isEqualToString:@"200"]) {
                NSDictionary *data = responseObject[@"data"];
                @strongify(self)
                self.videoID = data[@"video_id"];
                [self.player watchstartWithParams:@{SDK_SESSION_ID: self.account.sessionID, SDK_VID: self.videoID} start:^{
                    @strongify(self)
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [self.hud show:YES];
                } complete:^(NSInteger responseCode, NSDictionary *result) {
                    @strongify(self)
                    switch (responseCode) {
                        case SDK_ERROR_SESSION_ID:
                            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            self.hud.mode = MBProgressHUDModeText;
                            self.hud.labelText = @"账号过期，请重新登录";
                            [self.hud hide:YES afterDelay:1.5f];
                            break;
                        case SDK_NETWORK_ERROR:
                            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            self.hud.mode = MBProgressHUDModeText;
                            self.hud.labelText = @"网络异常,请检查你的网络";
                            [self.hud hide:YES afterDelay:1.5f];
                            break;
                        case SDK_REQUEST_OK:
                            [_player play];
                            break;
                        default:
                            break;
                    }
                }];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            @strongify(self)
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.mode = MBProgressHUDModeText;
            self.hud.labelText = @"网络异常";
            [self.hud hide:YES afterDelay:1.5f];
        }];
    }
    else {
        @weakify(self)
        [self.player watchstartWithParams:@{SDK_SESSION_ID: self.account.sessionID, SDK_VID: self.videoID} start:^{
            @strongify(self)
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self.hud show:YES];
        } complete:^(NSInteger responseCode, NSDictionary *result) {
            @strongify(self)
            switch (responseCode) {
                case SDK_ERROR_SESSION_ID:
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    self.hud.mode = MBProgressHUDModeText;
                    self.hud.labelText = @"账号过期，请重新登录";
                    [self.hud hide:YES afterDelay:1.5f];
                    break;
                case SDK_NETWORK_ERROR:
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    self.hud.mode = MBProgressHUDModeText;
                    self.hud.labelText = @"网络异常,请检查你的网络";
                    [self.hud hide:YES afterDelay:1.5f];
                    NSLog(@"网络异常,请检查你的网络");
                    break;
                case SDK_REQUEST_OK:
                    NSLog(@"正在播放");
                    [self.hud hide:YES];
                    [_player play];
                    break;
                default:
                    break;
            }
        }];
    }
    
    self.playImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_icon"]];
    [self.playImage setFrame:CGRectMake(kScreenWidth / 2 - 15, kScreenHeight / 2 - 15, 45, 45)];
    self.playImage.userInteractionEnabled = YES;
    self.playImage.hidden = YES;
    [self.view addSubview:self.playImage];
    
    self.pauseImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pause_icon"]];
    [self.pauseImage setFrame:CGRectMake(kScreenWidth / 2 - 15, kScreenHeight / 2 - 15, 45, 45)];
    self.pauseImage.userInteractionEnabled = YES;
    self.pauseImage.hidden = YES;
    [self.view addSubview:self.pauseImage];
    @weakify(self)
    UIGestureRecognizer *playGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        [_player play];
        self.playImage.hidden = YES;
        [self showPause];
    }];
    [self.playImage addGestureRecognizer:playGesture];
    
    UIGestureRecognizer *pauseGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        [_player pause];
        [self.timer invalidate];
        self.pauseImage.hidden = YES;
        self.playImage.hidden = NO;
    }];
    [self.pauseImage addGestureRecognizer:pauseGesture];
    
    UIGestureRecognizer *containGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        if (self.playImage.isHidden) {
            [self showPause];
        }
    }];
    [self.playerContinerView addGestureRecognizer:containGesture];
    
}

- (void)showPause {
    @weakify(self)
    if (self.pauseImage.isHidden) {
        self.pauseImage.hidden = NO;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            [UIView transitionWithView:self.pauseImage
                              duration:0.25f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.pauseImage.hidden = YES;
                            } completion:nil];
            
        } repeats:NO];
    }
    else {
        [self.timer invalidate];
        [UIView transitionWithView:self.pauseImage
                          duration:0.25f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.pauseImage.hidden = YES;
                        } completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_player shutDown];
    if (self.videoID && self.account.sessionID) {
        [_player watchstopWithParams:@{SDK_SESSION_ID: self.account.sessionID, SDK_VID: self.videoID} start:nil complete:^(NSInteger responseCode, NSDictionary *result) {
            NSLog(@"关闭");
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EasyLivePlayerDelegate
- (void)easyLivePlayer:(EasyLivePlayer *)player
      didChangeedState:(EasyLivePlayerState)state {
    NSLog(@"state = %ld", (long)state);
    switch (state) {
        case EasyLivePlayerStateNeedToReconnect:
            NSLog(@"需要重连");
            [player reconnect];
            break;
        case EasyLivePlayerComplete:
            NSLog(@"完成");
            self.playImage.hidden = NO;
            break;
        case EasyLivePlayerStateUnknow:
            NSLog(@"未知错误");
            break;
        case EasyLivePlayerStateBuffering:
            NSLog(@"缓冲中");
            break;
        case EasyLivePlayerStatePlaying:
            NSLog(@"播放中");
            [self.hud hide:YES];
            [self showPause];
            break;
        default:
            NSLog(@"网络状况不佳，播放失败");
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.mode = MBProgressHUDModeText;
            self.hud.labelText = @"网络状况不佳，播放失败";
            @weakify(self)
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Do something...
                sleep(1.5);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    [self.hud hide:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
