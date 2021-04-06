//
//  AliyunRtcView.h
//  AliyunRtc
//
//  Created by Jason Law on 2020/8/12.
//  Copyright © 2020 Facebook. All rights reserved.
//

#ifndef AliyunRtcView_h
#define AliyunRtcView_h

#import <UIKit/UIKit.h>
#import <AliRTCSdk/AliRtcEngine.h>
#import <React/RCTView.h>

@interface AliyunRtcView : AliRenderView <AliRtcEngineDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong,nonatomic) NSDictionary *settings;

@property (nonatomic, copy) RCTBubblingEventBlock onChange;


-(int)startPreview;
-(int)stopPreview;

-(int)switchCamera;

-(int)joinBegin;
-(int)leaveChannel;

@end

@interface RemoterUserView : UICollectionViewCell

/**
 @brief 用户流视图
 
 @param view renderview
 */
- (void)updateUserRenderview:(AliRenderView *)view;

/**
 @brief Switch点击事件回调
 */
@property(nonatomic,copy) void(^switchblock)(BOOL);


/**
 @brief 灰色底View
 */
@property (nonatomic,strong) UIView *view;

/**
 @brief 视频(屏幕)镜像开关
 */
@property (nonatomic,strong) UISwitch *CameraMirrorSwitch;

/**
 @brief 视频(屏幕)镜像描述
 */
@property (nonatomic,strong) UILabel *CameraMirrorLabel;

- (void)onCameraMirrorClicked:(UISwitch *)switchView;


@end


#endif /* AliyunRtcView_h */
