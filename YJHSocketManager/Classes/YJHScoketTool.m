//
//  YJHScoketTool.m
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import "YJHScoketTool.h"

@interface YJHScoketTool ()<GCDAsyncSocketDelegate>
@property (nonatomic,assign)BOOL isNeedDisConnect;
@end

@implementation YJHScoketTool

+ (YJHScoketTool *)sharedInstance {
    static YJHScoketTool *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.heartBeatFlag = NO;
    self.networkReachabilityFlag = YES;
    self.applicationDidEnterBackground = NO;
    
    self.timeout = -1;
    _clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    return self;
}



- (void)connectToHost:(NSString *)host port:(int)port timeOut:(int)timeOut {
    self.isNeedDisConnect = YES;
    self.kConnectorHost = host;
    self.kConnectorPort = port;
    self.kTimeOut = timeOut;
    
    [self creatSocketToConnectServerHost:self.kConnectorHost port:self.kConnectorPort timeOut:self.kTimeOut];
    
    [self listenApplicationLifeCycle];
    [self checkNetworkStates];
}

-(void)creatSocketToConnectServerHost:(NSString*)host port:(int)port timeOut:(int)timeOut{
    self.connectStatus = 0;
    NSError *error = nil;
    @try {
        [self.clientSocket connectToHost:host onPort:UINT16_C(port) withTimeout:timeOut error:&error];
        NSLog(@"$$$ %@", error);
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)listenApplicationLifeCycle {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStates) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)applicationEnterBackground {
    self.connectStatus = -1;
    [self.clientSocket disconnect];
    self.applicationDidEnterBackground = YES;
}

- (void)applicationBecomeActive {
    self.connectStatus = -1;
    [self reconnect];
    self.applicationDidEnterBackground = NO;
}

- (void)checkNetworkStates {
    
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            [self.clientSocket disconnect];
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            if (self.connectStatus == -1) {
                [self reconnect];
            }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            if (self.connectStatus == -1) {
                [self reconnect];
            }
            break;
        default:
            break;
    }
    
}

- (void)reconnect {
    NSLog(@"重连### %@", self.kConnectorHost);
    [self.clientSocket disconnect];
    [self creatSocketToConnectServerHost:self.kConnectorHost port:self.kConnectorPort timeOut:self.timeout];
}

- (BOOL)isDisConnect {
    return self.clientSocket.isConnected;
}

- (void)disconnect {
    self.isNeedDisConnect = NO;
    [self.beatTimer invalidate];
    self.beatTimer = nil;
    [self.clientSocket disconnect];
}


- (void)socketBeginSendBeat {
    if (self.beatTimer) {
        [self.beatTimer invalidate];
        self.beatTimer = nil;
    }
    self.beatTimer = [NSTimer scheduledTimerWithTimeInterval:heartBeatTimeinterval target:self selector:@selector(sendBeat) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.beatTimer forMode:NSRunLoopCommonModes];
    [self.beatTimer fire];
}


- (void)sendBeat {
    if (self.heartBeatFlag) {
        [self socketWriteDataToServer:self.beatData];
    }else {
        if (self.beatTimer) {
            [self.beatTimer invalidate];
            self.beatTimer = nil;
        }
    }
}


- (void)socketWriteDataToServer:(NSData *)data {
    
    if (!data) { return; }
    
    uint32_t len = (int)data.length;
    //ntohl()、htonl()、ntohs()、htons()这几个函数的作用是进行字节顺序的转换
    len = ntohl(len);
    if (len <= 0) { return; }
    
    NSData *lenthData = [NSData dataWithBytes:&len length:sizeof(len)];
    //包长
    [self.clientSocket writeData:lenthData withTimeout:-1 tag:HEADER_TAG_RESPONSE];
    //包数据
    [self.clientSocket writeData:data withTimeout:-1 tag:BODY_TAG_RESPONSE];
    
    NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"发送### %@", str);

}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [sock readDataToLength:sizeof(int) withTimeout:-1 tag:HEADER_TAG_RESPONSE];
#ifdef DEBUG
    [self socketWriteDataToServer:self.beatData];
#endif
    if (port == 9530) {
        [self testContextForIOS];
    }
}

- (void)testContextForIOS {
    NSDictionary *dict = @{@"msg_id":@"1", @"cmd":@"authios"};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    uint32_t len = (int)data.length;
    
    len = ntohl(len);
    if (len <= 0) { return; }

    NSData *lenghData = [NSData dataWithBytes:&len length:sizeof(len)];
    [self.clientSocket writeData:lenghData withTimeout:-1 tag:HEADER_TAG_RESPONSE];
    [self.clientSocket writeData:data withTimeout:-1 tag:BODY_TAG_RESPONSE];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (!self.applicationDidEnterBackground && AFNetworkReachabilityManager.sharedManager.isReachable && self.isNeedDisConnect) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reconnect) object:nil];
        [self performSelector:@selector(reconnect) withObject:nil afterDelay:1.0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接受### %@", str);

    uint32_t len;
    [data getBytes:&len length:sizeof(len)];
    len = htonl(len);

    if (len <= 0 || len>2147483648) {
        [self.clientSocket disconnect];
        return;
    }

    if (tag == HEADER_TAG_RESPONSE) {
        [sock readDataToLength:len withTimeout:-1 tag:BODY_TAG_RESPONSE];
        return;
    }
    
    [sock readDataToLength:readSize withTimeout:self.timeout tag:HEADER_TAG_RESPONSE];
    
    if (self.scoketGetDataBlock) {
        self.scoketGetDataBlock(sock, data, tag);
    }
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
