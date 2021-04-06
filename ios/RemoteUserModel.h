//
//  RemoteUserModel.h
//  AliyunRtc
//
//  Created by Jason Law on 2020/8/12.
//  Copyright © 2020 Facebook. All rights reserved.
//

#ifndef RemoteUserModel_h
#define RemoteUserModel_h

#import <Foundation/Foundation.h>
#import <AliRTCSdk/AliRTCSdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoteUserModel : NSObject

@property (nonatomic, strong) AliRenderView *view;

@property (nonatomic, strong) NSString *uid;

@property (nonatomic, assign) AliRtcVideoTrack track;

@end

NS_ASSUME_NONNULL_END


#endif /* RemoteUserModel_h */
