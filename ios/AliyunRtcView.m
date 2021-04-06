//
//  AliyunRtcView.m
//  AliyunRtc
//
//  Created by Jason Law on 2020/8/12.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunRtcView.h"
#import "RemoteUserManager.h"
#import "RemoteUserModel.h"



@interface AliyunRtcView()
@property (nonatomic, strong) AliRtcEngine *engine;

/**
 @brief 远端用户管理
 */
@property(nonatomic, strong) RemoteUserManager *remoteUserManager;


/**
 @brief 远端用户视图
 */
@property(nonatomic, strong) UICollectionView *remoteUserView;


/**
 @brief 是否入会
 */
@property(nonatomic, assign) BOOL isJoinChannel;

@end

@implementation AliyunRtcView
    - (id)init {
      self = [super init];
      if(self) {
          _engine = [AliRtcEngine sharedInstance:self extras:@""];
          _settings = nil;
          _onChange = nil;
      }
        
      return self;
    }

//    - (instancetype)initWithFrame:(CGRect)frame {
//        NSLog(@"frame %@", NSStringFromCGRect(frame));
//
//      if ((self = [super initWithFrame:frame])) {
//        // ....
//
//        //self.delegate = self;
//      }
//
//      return self;
//    }

    -(void) onEventCallback:(nonnull id)sender event:(int)event msg:(nonnull NSString*)msg {
        if (!_onChange) {
            return;
        }
        _onChange(@{@"code": [NSNumber numberWithInteger:event], @"msg": msg});
    }

  

    -(void)setSettings:(NSDictionary *)settings {
        _settings = settings;
    }

    - (void)startPreview{
        NSLog(@"bounds %@ frame %@", self.bounds, NSStringFromCGRect(self.frame));
        
        // 设置本地预览视频
        AliVideoCanvas *canvas   = [[AliVideoCanvas alloc] init];
        AliRenderView *viewLocal = [[AliRenderView alloc] initWithFrame:self.bounds];
        //AliRenderView *viewLocal = [[AliRenderView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, 300.0f, 300.0f)];
        canvas.view = viewLocal;
        canvas.renderMode = AliRtcRenderModeAuto;
        [self addSubview:viewLocal];
        [self.engine setLocalViewConfig:canvas forTrack:AliRtcVideoTrackCamera];
        
        // 开启本地预览
        [self.engine startPreview];
    }

    -(void)stopPreview{
        [_engine stopPreview];
    }

    
    -(void)switchCamera{
        [_engine switchCamera];
    }

    #pragma mark - action (需手动填写鉴权信息)

    /**
     @brief 登陆服务器，并开始推流
     */
    - (void)joinBegin{
        
        NSLog(@"setting %@", self.settings);
        
        //AliRtcAuthInfo 配置项
        NSString *AppID   = [self.settings objectForKey:@"AppID"];
        NSString *userID  = [self.settings objectForKey:@"userID"];
        NSString *channelID  = [self.settings objectForKey:@"channelID"];
        NSString *nonce  = [self.settings objectForKey:@"nonce"];
        long long timestamp = [[self.settings objectForKey:@"timestamp"] longLongValue];
        NSString *token  =  [self.settings objectForKey:@"token"];
        NSArray <NSString *> *GSLB  =  [self.settings objectForKey:@"GSLB"];
        NSArray <NSString *> *agent =  [self.settings objectForKey:@"agent"];//@[@""];
        
        
        //配置SDK
        //设置自动(手动)模式
        [self.engine setAutoPublish:YES withAutoSubscribe:YES];
        
        //随机生成用户名，仅是demo展示使用
        NSString *userName = [NSString stringWithFormat:@"iOSUser%u",arc4random()%1234];
        
        //AliRtcAuthInfo:各项参数均需要客户App Server(客户的server端) 通过OpenAPI来获取，然后App Server下发至客户端，客户端将各项参数赋值后，即可joinChannel
        AliRtcAuthInfo *authInfo = [[AliRtcAuthInfo alloc] init];
        authInfo.appid = AppID;
        authInfo.user_id = userID;
        authInfo.channel = channelID;
        authInfo.nonce = nonce;
        authInfo.timestamp = timestamp;
        authInfo.token = token;
        authInfo.gslb = GSLB;
        authInfo.agent = agent;
        
        //加入频道
        [self.engine joinChannel:authInfo name:userName onResult:^(NSInteger errCode) {
            //加入频道回调处理
            NSLog(@"joinChannel result: %d", (int)errCode);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errCode != 0) {
                    //入会失败
                }
                
                _isJoinChannel = YES;
            });
        }];
        
        //防止屏幕锁定
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        //添加页面控件
        [self addSubviews];
    }

    /**
     @brief 离开频道
     */
    - (void)leaveChannel:(UIButton *)sender {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self leaveChannel];  //退出房间
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            //[self exitApplication];  //关闭应用
            
        });
    }

    #pragma mark - private

    /**
     @brief 离开频需要取消本地预览、离开频道、销毁SDK
     */
    - (void)leaveChannel {
        
        [self.remoteUserManager removeAllUser];
        
        //停止本地预览
        [self.engine stopPreview];
        
        if (_isJoinChannel) {
            //离开频道
            [self.engine leaveChannel];
        }

        [self.remoteUserView removeFromSuperview];
        
        //销毁SDK实例
        //[AliRtcEngine destroy];
    }

    - (void)exitApplication{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [UIView animateWithDuration:0.5f animations:^{
            window.alpha = 0;
            window.frame = CGRectMake(window.bounds.size.width/2.0, window.bounds.size.width, 0, 0);
        } completion:^(BOOL finished) {
            exit(0);
        }];
    }

    #pragma mark - uicollectionview delegate & datasource

    - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        return [self.remoteUserManager allOnlineUsers].count;
    }

    - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
        RemoterUserView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        RemoteUserModel *model =  [self.remoteUserManager allOnlineUsers][indexPath.row];
        AliRenderView *view = model.view;
        [cell updateUserRenderview:view];
        
        //记录UID
        NSString *uid = model.uid;
        //视频流类型
        AliRtcVideoTrack track = model.track;
        if (track == AliRtcVideoTrackScreen) {  //默认为视频镜像,如果是屏幕则替换屏幕镜像
            cell.CameraMirrorLabel.text = @"屏幕镜像";
        }
        
        cell.switchblock = ^(BOOL isOn) {
            [self switchClick:isOn track:track uid:uid];
        };
        
        return cell;
    }

    //远端用户镜像按钮点击事件
    - (void)switchClick:(BOOL)isOn track:(AliRtcVideoTrack)track uid:(NSString *)uid {
        AliVideoCanvas *canvas = [[AliVideoCanvas alloc] init];
        canvas.renderMode = AliRtcRenderModeFill;
        if (track == AliRtcVideoTrackCamera) {
            canvas.view = (AliRenderView *)[self.remoteUserManager cameraView:uid];
        }
        else if (track == AliRtcVideoTrackScreen) {
            canvas.view = (AliRenderView *)[self.remoteUserManager screenView:uid];
        }
        
        if (isOn) {
            canvas.mirrorMode = AliRtcRenderMirrorModeAllEnabled;
        }else{
            canvas.mirrorMode = AliRtcRenderMirrorModeAllDisabled;
        }
        [self.engine setRemoteViewConfig:canvas uid:uid forTrack:track];
    }

    #pragma mark - alirtcengine delegate

    - (void)onSubscribeChangedNotify:(NSString *)uid audioTrack:(AliRtcAudioTrack)audioTrack videoTrack:(AliRtcVideoTrack)videoTrack {
        
        //收到远端订阅回调
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.remoteUserManager updateRemoteUser:uid forTrack:videoTrack];
            
   
            NSLog(@"join callback %@", uid);
            if (videoTrack == AliRtcVideoTrackCamera) {
                NSLog(@"camera enable");
                AliVideoCanvas *canvas = [[AliVideoCanvas alloc] init];
                canvas.renderMode = AliRtcRenderModeAuto;
                canvas.view = [self.remoteUserManager cameraView:uid];
                [self.engine setRemoteViewConfig:canvas uid:uid forTrack:AliRtcVideoTrackCamera];
            } else if (videoTrack == AliRtcVideoTrackScreen) {
                AliVideoCanvas *canvas2 = [[AliVideoCanvas alloc] init];
                canvas2.renderMode = AliRtcRenderModeAuto;
                canvas2.view = [self.remoteUserManager screenView:uid];
                [self.engine setRemoteViewConfig:canvas2 uid:uid forTrack:AliRtcVideoTrackScreen];
            } else if (videoTrack == AliRtcVideoTrackBoth) {
                
                AliVideoCanvas *canvas = [[AliVideoCanvas alloc] init];
                canvas.renderMode = AliRtcRenderModeAuto;
                canvas.view = [self.remoteUserManager cameraView:uid];
                [self.engine setRemoteViewConfig:canvas uid:uid forTrack:AliRtcVideoTrackCamera];
                
                AliVideoCanvas *canvas2 = [[AliVideoCanvas alloc] init];
                canvas2.renderMode = AliRtcRenderModeAuto;
                canvas2.view = [self.remoteUserManager screenView:uid];
                [self.engine setRemoteViewConfig:canvas2 uid:uid forTrack:AliRtcVideoTrackScreen];
            }
            [self.remoteUserView reloadData];
        });
    }

    - (void)onRemoteUserOnLineNotify:(NSString *)uid {
        
    }

    - (void)onRemoteUserOffLineNotify:(NSString *)uid {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.remoteUserManager remoteUserOffLine:uid];
            [self.remoteUserView reloadData];
        });
    }

    - (void)onOccurError:(int)error {
        if (error == AliRtcErrSessionRemoved) {
             NSLog(@"Session已经被移除,请点击确定退出");
             [self leaveChannel:nil];
           
        }
        else if (error == AliRtcErrIceConnectionHeartbeatTimeout) {
            NSLog(@"信令心跳超时，请点击确定退出");
            [self leaveChannel:nil];
            
        }
        else if (error == AliRtcErrJoinBadAppId) {
             NSLog(@"AppId不存在，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrJoinInvalidAppId) {
           NSLog(@"AppId已失效，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrJoinBadChannel) {
           NSLog(@"频道不存在，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrJoinInvalidChannel) {
            NSLog(@"频道已失效，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrJoinBadToken) {
           NSLog(@"token不存在，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrJoinTimeout) {
            NSLog(@"加入频道超时，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrJoinBadParam) {
           NSLog(@"参数错误，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrMicOpenFail) {
            NSLog(@"采集设备初始化失败，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrSpeakerOpenFail) {
            NSLog(@"播放设备初始化失败，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrMicInterrupt) {
           NSLog(@"采集过程中出现异常，请重新join(仅提示");
        }
        else if (error == AliRtcErrSpeakerInterrupt) {
            NSLog(@"播放过程中出现异常，请重新join(仅提示)");
        }
        else if (error == AliRtcErrMicAuthFail) {
           NSLog(@"麦克风设备未授权，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrMicNotAvailable) {
           NSLog(@"无可用的音频采集设备，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrSpeakerNotAvailable) {
           NSLog(@"无可用的音频播放设备，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrCameraOpenFail) {
           NSLog(@"采集设备初始化失败，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrCameraInterrupt) {
            NSLog(@"采集过程中出现异常，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrDisplayOpenFail) {
           NSLog(@"渲染设备初始化失败，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrDisplayInterrupt) {
            NSLog(@"渲染过程中出现异常，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrIceConnectionConnectFail) {
           NSLog(@"媒体通道建立失败，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrIceConnectionReconnectFail) {
           NSLog(@"媒体通道重连失败，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrSdkInvalidState) {
            NSLog(@"sdk状态错误，请重新pub、sub(仅提示)");
        }
        else if (error == AliRtcErrInner) {
           NSLog(@"其他错误，请重新pub、sub(仅提示)");
        }
    }

    - (void)onBye:(int)code {
        if (code == AliRtcOnByeChannelTerminated) {
            // channel结束
        }
    }
    

    #pragma mark - add subviews

    - (void)addSubviews {
        CGRect rcScreen = [UIScreen mainScreen].bounds;
        CGRect rc = rcScreen;
        rc.origin.x = 10;
        rc.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height+20+44;
        rc.size = CGSizeMake(self.frame.size.width-20, 280);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(140, 280);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.remoteUserView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.remoteUserView.frame = rc;
        self.remoteUserView.backgroundColor = [UIColor clearColor];
        self.remoteUserView.delegate   = self;
        self.remoteUserView.dataSource = self;
        self.remoteUserView.showsHorizontalScrollIndicator = NO;
        [self.remoteUserView registerClass:[RemoterUserView class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:self.remoteUserView];
        
        _remoteUserManager = [RemoteUserManager shareManager];
        
    }
    
    

@end


@implementation RemoterUserView
{
    AliRenderView *viewRemote;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        //设置远端流界面
        CGRect rc  = CGRectMake(0, 0, 140, 200);
        viewRemote = [[AliRenderView alloc] initWithFrame:rc];
        self.backgroundColor = [UIColor clearColor];
        
        CGRect viewrc  = CGRectMake(0, 200, 140, 40);
        _view = [[UIView alloc] initWithFrame:viewrc];
        _view.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:self.view];
        
        rc.origin.x = 8;
        rc.size = CGSizeMake(70, 40);
        _CameraMirrorLabel = [[UILabel alloc] initWithFrame:rc];
        self.CameraMirrorLabel.text = @"视频镜像";  //默认
        self.CameraMirrorLabel.textAlignment = 0;
        self.CameraMirrorLabel.font = [UIFont systemFontOfSize:17];
        self.CameraMirrorLabel.textColor = [UIColor whiteColor];
        self.CameraMirrorLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:self.CameraMirrorLabel];
        
        rc.origin.x = 81;
        rc.origin.y = 4.5;
        rc.size = CGSizeMake(51, 31);
        _CameraMirrorSwitch = [[UISwitch alloc] initWithFrame:rc];
        _CameraMirrorSwitch.transform = CGAffineTransformMakeScale(0.8,0.8);
        [self.CameraMirrorSwitch addTarget:self action:@selector(onCameraMirrorClicked:)  forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.CameraMirrorSwitch];
    }
    return self;
}

- (void)updateUserRenderview:(AliRenderView *)view {
    view.backgroundColor = [UIColor clearColor];
    view.frame = viewRemote.frame;
    viewRemote = view;
    [self addSubview:viewRemote];
}

- (void)onCameraMirrorClicked:(UISwitch *)switchView{
    if (self.switchblock) {
        self.switchblock(switchView.on);
    }
}

@end
