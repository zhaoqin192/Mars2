//
//  RootTabViewController.m
//  Mars
//
//  Created by 王霄 on 16/4/25.
//  Copyright © 2016年 Muggins_. All rights reserved.
//

#import "RootTabViewController.h"
#import "RDVTabBarItem.h"
#import "testViewController.h"
#import "WXMeViewController.h"
#import "WXExercisesViewController.h"
#import "WXTestViewController.h"
#import "HomeViewController.h"

@interface RootTabViewController ()

@end

@implementation RootTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewControllers];
}

#pragma mark Private_M

- (void)setupViewControllers {
    WXMeViewController *meVC = [[WXMeViewController alloc] init];
    UINavigationController *meNVC = [[UINavigationController alloc] initWithRootViewController:meVC];
    WXExercisesViewController *exercisesVC = [[WXExercisesViewController alloc] init];
    UINavigationController *exercisesNVC = [[UINavigationController alloc] initWithRootViewController:exercisesVC];
    WXTestViewController *testVC = [[WXTestViewController alloc] init];
    UINavigationController *testNVC = [[UINavigationController alloc] initWithRootViewController:testVC];
    
    UIStoryboard *homeStoryboard = [UIStoryboard storyboardWithName:@"home" bundle:nil];
    HomeViewController *homeVC = [homeStoryboard instantiateViewControllerWithIdentifier:HomeViewControllerIdentifier];
    UINavigationController *homeRoot = [[UINavigationController alloc] initWithRootViewController:homeVC];
    
    [self setViewControllers:@[homeRoot, testNVC, exercisesNVC, meNVC]];
    [self customizeTabBarForController];
    self.delegate = self;
}

- (void)customizeTabBarForController {
    UIImage *backgroundImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"#FFFFFF"]];
    NSArray *tabBarItemImages = @[@"计划", @"测试", @"练习", @"我的"];
    NSArray *tabBarItemTitles = @[@"计划", @"测试", @"知识库", @"我的"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        item.titlePositionAdjustment = UIOffsetMake(0, 3);
        [item setBackgroundSelectedImage:backgroundImage withUnselectedImage:backgroundImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_2",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_1",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        [item setTitle:[tabBarItemTitles objectAtIndex:index]];
        item.selectedTitleAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#383F4D"]};
        item.unselectedTitleAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#ACB0C7"]};
        index++;
    }
}

#pragma mark RDVTabBarControllerDelegate

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return YES;
}

@end
