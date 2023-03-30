//
//  YJHSocketBusiness.m
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import "YJHSocketBusiness.h"

#import "YJHScoketTranslateTool.h"
#import "YJHScoketTool.h"
#import "YJHNetWorkingModelTool.h"

#if DEBUG
//static NSString * const kVSNChatHost = @"test-im.get88.cn";
static const NSInteger kVSNChatPort = 9527;
static const NSTimeInterval kVSNChatTimeout = 3.0;
#else
//static NSString * const kVSNChatHost = @"im.get88.cn";
static const NSInteger kVSNChatPort = 9527;
static const NSTimeInterval kVSNChatTimeout = 3.0;
#endif
NSString * kVSNChatHost = @"im.get88.cn";
NSString * const kYJHSocketBusinessStartAuthNotification = @"kJCSocketBusinessStartAuthNotification";
NSString * const kYJHSocketBusinessDisconnectNotification = @"kJCSocketBusinessDisconnectNotification";


@interface YJHSocketBusiness ()
@property (nonatomic, strong) JCSocketToAuthModel *authModel;
@end

@implementation YJHSocketBusiness

+ (YJHSocketBusiness *)sharedInstance {
    static YJHSocketBusiness *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void)initData{
    
    __weak typeof(self) weakSelf = self;
    self.socketTool = [YJHScoketTool sharedInstance];
    NSDictionary *dict = @{@"cmd":@"wd_heartbeat"};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    self.socketTool.beatData = data;
    self.socketTool.scoketGetDataBlock = ^(GCDAsyncSocket *socket, NSData *data, long a) {
        YJHScoketTranslateTool *scoketTranslateTool=[[YJHScoketTranslateTool alloc] init];
        NSDictionary *dic = [scoketTranslateTool configModelWithData:data];
        if (!dic) {
            return ;
        }
        weakSelf.ScoketGetDataBlock(([(NSNumber *)dic[@"type"] integerValue]), dic[@"obj"]);
    };
    
   
}

- (void)connect {
   [[YJHScoketTool sharedInstance] connectToHost:kVSNChatHost port:kVSNChatPort timeOut:kVSNChatTimeout];
}


- (void)disconnect{
    [self.socketTool disconnect];
    [self postDisconnectNotification];
}

- (BOOL)connectState {
    return self.socketTool.isDisConnect;
}

// 向socket发消息
- (void)sendDataToScoket:(JCSocketToAuthModel *)model{
    self.authModel = model;
    
    NSDictionary *dic = [YJHNetWorkingModelTool configDictWithResponseModel:model];
    
    NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [self.socketTool socketWriteDataToServer:data];
    
    [self postStartAuthNotification];
}

- (void)socketDidConnectBeginSendBeat{
    [self.socketTool socketBeginSendBeat];
}

- (void)heabBeatFlag:(BOOL)receive{
    self.socketTool.heartBeatFlag = receive;
}

- (void)postStartAuthNotification
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"room_id"] = self.authModel.room_id?:@"";
    dict[@"userId"] = self.authModel.userId?:@"";
    [[NSNotificationCenter defaultCenter] postNotificationName:kYJHSocketBusinessStartAuthNotification object:nil userInfo:dict];
}


- (void)postDisconnectNotification
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"room_id"] = self.authModel.room_id?:@"";
    dict[@"userId"] = self.authModel.userId?:@"";
    [[NSNotificationCenter defaultCenter] postNotificationName:kYJHSocketBusinessDisconnectNotification object:nil userInfo:dict];
}

@end
