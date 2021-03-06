//
//  AppDelegate.m
//  Mars
//
//  Created by zhaoqin on 4/24/16.
//  Copyright © 2016 Muggins_. All rights reserved.
//

#import "AppDelegate.h"
#import "LiveViewController.h"
#import "EasyLive.h"
#import "DatabaseManager.h"
#import "AccountDao.h"
#import "Account.h"

#import "RootTabViewController.h"
#import "YFStartView.h"
#import "StartButtomView.h"
#import "NetworkFetcher+Account.h"
#import "NTESService.h"

//#import <PgySDK/PgyManager.h>
//#import <PgyUpdate/PgyUpdateManager.h>

@interface AppDelegate () <EAIntroDelegate, NIMLoginManagerDelegate>
@property (nonatomic, strong) AccountDao *accountDao;
@property (nonatomic, strong) Account *account;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString *appkey = @"Tu1h3b0L3O1Yrc3J";
    NSString *appsecret = @"n0asfkGucl13E7r7BxJSFEPg67pYchwa";
    
    [EasyLiveSDK registWithAppKey:appkey appsecret:appsecret];
    
    //Umeng register
    UMConfigInstance.appKey = @"57751332e0f55afb670028b3";
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
    
    //NIM register
    [[NIMSDK sharedSDK] registerWithAppID:@"c9b4027f49a776d0590173146da2145a"
                                  cerName:@"bonan"];
    [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    
//    //Pugongying
//    //启动基本SDK
//    [[PgyManager sharedPgyManager] startManagerWithAppId:@"58aa67488c567ec816c134e13f1fabbb"];
//    //启动更新检查SDK
//    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:@"58aa67488c567ec816c134e13f1fabbb"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[RootTabViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    [self configureHUD];
    [self configureNavigationItem];
    //暂时不开引导页和启动页
//    [self configureStartView];
//     [self configureIntroView];
    return YES;
}

- (void)dealloc {
    [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
}

- (void)configureNavigationItem{
    //[[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance]  setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance]  setTintColor:WXTextBlackColor];
    [[UINavigationBar appearance]  setTitleTextAttributes:@{NSForegroundColorAttributeName: WXTextBlackColor,NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0]}];
}

- (void)configureHUD{
    [[SVProgressHUD appearance] setDefaultStyle:SVProgressHUDStyleDark];
    [[SVProgressHUD appearance] setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

- (void)configureStartView{
    YFStartView *startView = [YFStartView startView];
    startView.isAllowRandomImage = YES;
    startView.randomImages = [NSMutableArray arrayWithObjects:@"startImage4", @"startImage2", @"startImage1", @"startImage3", nil];
    startView.logoPosition = LogoPositionButtom;
    StartButtomView *startButtomView = [[[NSBundle mainBundle] loadNibNamed:@"StartButtomView" owner:self options:nil] lastObject];
    startView.logoView = startButtomView;
    [startView configYFStartView];
}

- (void)configureIntroView{
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Hello world";
    page1.desc = @"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"This is page 2";
    page2.titlePositionY = kScreenHeight/2 - 10;
    page2.desc = @"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    page2.descPositionY = kScreenHeight/2 - 50;
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title2"]];
    page2.titleIconPositionY = 70;
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"This is page 3";
    page3.titleFont = [UIFont fontWithName:@"Georgia-BoldItalic" size:20];
    page3.titlePositionY = 220;
    page3.desc = @"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    page3.descFont = [UIFont fontWithName:@"Georgia-Italic" size:18];
    page3.descPositionY = 200;
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];
    page3.titleIconPositionY = 100;
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"This is page 4";
    page4.desc = @"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:[UIScreen mainScreen].bounds andPages:@[page1,page2,page3,page4]];
    intro.bgImage = [UIImage imageNamed:@"bg2"];
    
    intro.pageControlY = 250.f;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(0, 0, 230, 40)];
    [btn setTitle:@"SKIP NOW" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.layer.borderWidth = 2.f;
    btn.layer.cornerRadius = 10;
    btn.layer.borderColor = [[UIColor whiteColor] CGColor];
    intro.skipButton = btn;
    intro.skipButtonY = 60.f;
    intro.skipButtonAlignment = EAViewAlignmentCenter;
    
    [intro setDelegate:self];
    [intro showInView:self.window.rootViewController.view animateDuration:0.3];
}

- (void)introDidFinish:(EAIntroView *)introView {
    NSLog(@"introDidFinish callback");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    _accountDao = [[DatabaseManager sharedInstance] accountDao];
    _account = [_accountDao fetchAccount];
    
    if ([_accountDao isExist]) {
        [NetworkFetcher accountSignInWithPhone:_account.phone password:_account.password success:^(NSDictionary *response) {
            if ([response[@"code"] isEqualToString:@"200"]) {
                _account.token = response[@"sid"];
                _account.sessionID = response[@"yzb_session_id"];
                _account.userID = response[@"yzb_user_id"];
                _account.role = response[@"role"];
                _account.nimAccid = response[@"wy_accid"];
                _account.nimToken = response[@"wy_token"];
                [_accountDao save];
                NSString *phone = [NSString stringWithFormat:@"86_%@", _account.phone];
                [EasyLiveSDK userLoginWithParams:@{SDK_REGIST_TOKE: phone, SDK_USER_ID: _account.userID
                                                   } start:^{
                                                   } complete:^(NSInteger responseCode, NSDictionary *result) {
                                                       AccountDao *accountDao = [[DatabaseManager sharedInstance] accountDao];
                                                       Account *account = [accountDao fetchAccount];
                                                       account.sessionID = result[@"sessionid"];
                                                   }];
                [[[NIMSDK sharedSDK] loginManager] autoLogin:_account.phone
                                                       token:_account.nimToken];
                [[NTESServiceManager sharedManager] start];
                
            } else {
                [_accountDao deleteAccount];
                [_accountDao save];
            }
        } failure:^(NSString *error) {
            [SVProgressHUD showErrorWithStatus:@"网络异常请重新登录"];
            [self bk_performBlock:^(id obj) {
                [SVProgressHUD dismiss];
            } afterDelay:1.5];
        }];
    }
}

/**
 *  自动登录失败回调
 *
 *  @param error 失败原因
 *  @discussion 自动重连不需要上层开发关心，但是如果发生一些需要上层开发处理的错误，SDK 会通过这个方法回调
 *              用户需要处理的情况包括：AppKey 未被设置，参数错误，密码错误，多端登录冲突，账号被封禁，操作过于频繁等
 */
- (void)onAutoLoginFailed:(NSError *)error {
    NSLog(@"login---%@", error);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.muggins.Mars" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Mars" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Mars.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
