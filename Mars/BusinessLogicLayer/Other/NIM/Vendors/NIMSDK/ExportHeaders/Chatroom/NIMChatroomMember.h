//
//  NIMChatroomMember.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  聊天室用户类型
 */
typedef NS_ENUM(NSInteger, NIMChatroomMemberType) {
    /**
     *  游客
     */
    NIMChatroomMemberTypeGuest   = -2,
    /**
     *  受限用户
     */
    NIMChatroomMemberTypeLimit   = -1,
    /**
     *  普通用户
     */
    NIMChatroomMemberTypeNormal  = 0,
    /**
     *  创建者
     */
    NIMChatroomMemberTypeCreator = 1,
    /**
     *  管理员
     */
    NIMChatroomMemberTypeManager = 2,
};

/**
 *  聊天室用户
 */
@interface NIMChatroomMember : NSObject

/**
 *  用户ID
 */
@property (nonatomic,copy)   NSString *userId;

/**
 *  聊天室内的昵称字段，由用户进聊天室时提交。
 */
@property (nonatomic,copy)   NSString *roomNickname;

/**
 *  聊天室内的头像字段，由用户进聊天室时提交。
 */
@property (nonatomic,copy)   NSString *roomAvatar;

/**
 *  聊天室内预留给开发者的扩展字段，由用户进聊天室时提交。
 */
@property (nonatomic,copy)   NSString *roomExt;

/**
 *  用户类型
 */
@property (nonatomic,assign) NIMChatroomMemberType type;

/**
 *  是否被禁言
 */
@property (nonatomic,assign) BOOL isMuted;

/**
 *  是否被拉黑
 */
@property (nonatomic,assign) BOOL isInBlackList;

/**
 *  是否在线， 仅特殊成员才可能离线, 对游客用户而言只能是在线
 */
@property (nonatomic,assign) BOOL isOnline;

/**
 *  进入聊天室的时间点
 */
@property (nonatomic,assign) NSTimeInterval enterTimeInterval;

@end
