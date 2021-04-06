//
//  AliyunRtcViewManager.m
//  AliyunRtc
//
//  Created by Jason Law on 2020/8/13.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <React/RCTViewManager.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import "AliyunRtcView.h"

@interface AliyunRtcManager : RCTViewManager
    
@end


@implementation AliyunRtcManager
RCT_EXPORT_MODULE()

- (UIView *)view {
  return [[AliyunRtcView alloc] init];
    
    //return [AliyunRtcView new];
}

RCT_EXPORT_VIEW_PROPERTY(settings, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock);

RCT_EXPORT_METHOD(startPreview:(nonnull NSNumber *)reactTag)
{
  
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AliyunRtcView *> *viewRegistry){
     AliyunRtcView *view = viewRegistry[reactTag];
     [view startPreview];
   }];
}


RCT_EXPORT_METHOD(stopPreview:(nonnull NSNumber *)reactTag)
{
  
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AliyunRtcView *> *viewRegistry){
     AliyunRtcView *view = viewRegistry[reactTag];
     [view stopPreview];
   }];
}

RCT_EXPORT_METHOD(switchCamera:(nonnull NSNumber *)reactTag)
{
  
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AliyunRtcView *> *viewRegistry){
     AliyunRtcView *view = viewRegistry[reactTag];
     [view switchCamera];
   }];
}

RCT_EXPORT_METHOD(joinBegin:(nonnull NSNumber *)reactTag)
{
  
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AliyunRtcView *> *viewRegistry){
     AliyunRtcView *view = viewRegistry[reactTag];
     [view joinBegin];
   }];
}

RCT_EXPORT_METHOD(leaveChannel:(nonnull NSNumber *)reactTag)
{
  
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AliyunRtcView *> *viewRegistry){
     AliyunRtcView *view = viewRegistry[reactTag];
     [view leaveChannel];
   }];
}

@end
