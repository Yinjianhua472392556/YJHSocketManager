//
//  YJHSocketBusiness.h
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import <Foundation/Foundation.h>
#import "YJHSocketBaseModel.h"
#import "YJHScoketTool.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const kYJHSocketBusinessStartAuthNotification;
FOUNDATION_EXPORT NSString * const kYJHSocketBusinessDisconnectNotification;

typedef void (^ScoketUpDataBlock)(JCSocketCmdType type, id  responseObject) ;

@interface YJHSocketBusiness : NSObject
@property(nonatomic,copy) ScoketUpDataBlock ScoketGetDataBlock;
@property(nonatomic,strong) YJHScoketTool *socketTool;
+ (YJHSocketBusiness *)sharedInstance;

- (void)initData;
- (void)sendDataToScoket:(JCSocketToAuthModel *)model;
- (void)socketDidConnectBeginSendBeat;
- (void)heabBeatFlag:(BOOL)receive;
- (void)disconnect;
- (void)connect;
- (BOOL)connectState;

@end

NS_ASSUME_NONNULL_END
