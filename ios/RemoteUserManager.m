//
//  RemoteUserManager.m
//  AliyunRtc
//
//  Created by Jason Law on 2020/8/12.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RemoteUserManager.h"

@interface RemoteUserManager ()

/**
 @brief 远端用户
 */
@property(nonatomic, strong) NSMutableArray *remoteUsers;

/**
 @brief 操作锁
 */
@property(nonatomic,strong) NSRecursiveLock *arrLock;


@end


@implementation RemoteUserManager

+ (instancetype)shareManager {
    static RemoteUserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _remoteUsers = [NSMutableArray array];
        _arrLock = [[NSRecursiveLock alloc] init];
    }
    return self;
}


- (void)updateRemoteUser:(NSString *)uid forTrack:(AliRtcVideoTrack)track {
   
    [_arrLock lock];
    if (track == AliRtcVideoTrackBoth) {
        RemoteUserModel *cameraModel = [self findUser:uid forTrack:AliRtcVideoTrackCamera];
        RemoteUserModel *screenModel = [self findUser:uid forTrack:AliRtcVideoTrackScreen];
        if (!cameraModel) {
            cameraModel = [self createModel:uid forTrack:AliRtcVideoTrackCamera];
            [self.remoteUsers addObject:cameraModel];
        }
        if (!screenModel) {
            screenModel = [self createModel:uid forTrack:AliRtcVideoTrackScreen];
            [self.remoteUsers addObject:screenModel];
        }
    }else if (track == AliRtcVideoTrackScreen) {
        RemoteUserModel *screenModel = [self findUser:uid forTrack:AliRtcVideoTrackScreen];
        if (!screenModel) {
            screenModel = [self createModel:uid forTrack:AliRtcVideoTrackScreen];
            [self.remoteUsers addObject:screenModel];
        }
    }else if (track == AliRtcVideoTrackCamera){
        RemoteUserModel *cameraModel = [self findUser:uid forTrack:AliRtcVideoTrackCamera];
        RemoteUserModel *screenModel = [self findUser:uid forTrack:AliRtcVideoTrackScreen];
        if (screenModel) {
            [self.remoteUsers removeObject:screenModel];
        }
        if (!cameraModel) {
            cameraModel = [self createModel:uid forTrack:AliRtcVideoTrackCamera];
            [self.remoteUsers addObject:cameraModel];
        }
    }
    [_arrLock unlock];
}

- (AliRenderView *)cameraView:(NSString *)uid {
    AliRenderView *rendView = nil;
    [_arrLock lock];
    for (RemoteUserModel *model in self.remoteUsers) {
        if ([model.uid isEqualToString:uid] && model.track == AliRtcVideoTrackCamera) {
            rendView = model.view;
        }
    }
    [_arrLock unlock];
    return rendView;
}

- (AliRenderView *)screenView:(NSString *)uid {
    AliRenderView *rendView = nil;
    [_arrLock lock];
    for (RemoteUserModel *model in self.remoteUsers) {
        if ([model.uid isEqualToString:uid] && model.track == AliRtcVideoTrackScreen) {
            rendView = model.view;
        }
    }
    [_arrLock unlock];
    return rendView;
}

- (void)remoteUserOffLine:(NSString *)uid {
    [_arrLock lock];
    for (int i = 0; i < self.remoteUsers.count; i++) {
        RemoteUserModel *model = self.remoteUsers[i];
        if ([model.uid isEqualToString:uid]) {
            [self.remoteUsers removeObject:model];
            i--;
        }
    }
    [_arrLock unlock];
}


- (NSArray *)allOnlineUsers {
    return self.remoteUsers;
}

- (void)removeAllUser {
    [_arrLock lock];
    [self.remoteUsers removeAllObjects];
    [_arrLock unlock];
}


#pragma mark - private


/**
 @brief 创建用户流model
 @param uid 用户ID
 @param track 流类型
 @return 用户流model
 */
- (RemoteUserModel *)createModel:(NSString *)uid forTrack:(AliRtcVideoTrack)track {
    if (uid.length == 0) {
        return nil;
    }
    RemoteUserModel *model = [[RemoteUserModel alloc] init];
    model.uid   = uid;
    model.track = track;
    model.view  = [[AliRenderView alloc] init];
    return model;
}



/**
 @brief 查找用户流
 @param uid 用户ID
 @param track 流类型
 @return 用户流model
 */
- (RemoteUserModel *)findUser:(NSString *)uid forTrack:(AliRtcVideoTrack)track {
    
    for (RemoteUserModel *model in self.remoteUsers) {
        if ([model.uid isEqualToString:uid] && (model.track == track)) {
            return model;
        }
    }
    return nil;
}

@end
