//
//  YJHScoketTool.h
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <Reachability/Reachability.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ScoketGetDataBlock)(GCDAsyncSocket *socket, NSData *data, long a);
#define HEADER_TAG_RESPONSE  0  // 报文头
#define BODY_TAG_RESPONSE 1 // 报文内容
static const uint readSize = 4;
static const NSInteger heartBeatTimeinterval = 10;

@interface YJHScoketTool : NSObject
@property(nonatomic,strong) NSString *kConnectorHost;
@property (nonatomic, assign) int kConnectorPort;
@property(nonatomic,assign) NSTimeInterval timeout;
@property(nonatomic,assign) int kTimeOut;
@property(nonatomic,strong) GCDAsyncSocket *clientSocket;
@property(nonatomic,assign) int connectStatus;
@property(nonatomic,strong) NSTimer *beatTimer;
@property(nonatomic,assign) BOOL applicationDidEnterBackground;
@property(nonatomic,copy) ScoketGetDataBlock scoketGetDataBlock;
@property(nonatomic,strong) NSData *beatData;
@property(nonatomic,assign) BOOL heartBeatFlag;
@property (nonatomic,assign) BOOL isDisConnect;
@property(nonatomic,assign) BOOL networkReachabilityFlag;
@property(nonatomic,strong) Reachability *reach;

+ (YJHScoketTool *)sharedInstance ;
- (void)connectToHost:(NSString*)host port:(int)port timeOut:(int)timeOut;
-(void)disconnect;
- (void)socketWriteDataToServer:(NSData*)data;
// 长连发心跳
- (void)socketBeginSendBeat;

@end

NS_ASSUME_NONNULL_END
