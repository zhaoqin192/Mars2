//
//  ZSBExerciseVideoModel.h
//  Mars
//
//  Created by zhaoqin on 6/27/16.
//  Copyright © 2016 Muggins_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSBExerciseVideoModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *participateCount;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *tag1;
@property (nonatomic, strong) NSString *tag2;
@property (nonatomic, strong) NSString *tag3;
@property (nonatomic, strong) NSString *tag4;
@property (nonatomic, strong) NSString *type;

@end
