//
//  YJHSocketBaseModel.h
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class JCSocketAuthResultModel;

typedef NS_ENUM(NSUInteger, JCSocketCmdType) {
    JCSocketCmdTypeAuth1,
    JCSocketCmdTypeLiveStart,
    JCScoketCmdHearBeat,
    JCSocketCmdTypeNone
};

@interface JCSocketBaseModel : NSObject
@property(nonatomic,copy)NSString*cmd;
@end

@interface JCSocketAuthModel : NSObject
@property(nonatomic,assign)int msg_id;
@property(nonatomic,copy)NSString*cmd;
@property(nonatomic,strong)JCSocketAuthResultModel *result;
@end

@interface JCSocketAuthResultModel : NSObject

@property(nonatomic,copy)NSString*seed;

@end

@interface JCIMMessObjectModel : NSObject

@property (nonatomic, strong)NSDictionary *teacherNicknameMap;
@property (nonatomic, strong)NSDictionary *teacherHeadImgMap;
@property (nonatomic, assign) NSInteger  sourceId;//来源
@property (nonatomic, assign) NSInteger  isRecommend;
@property (nonatomic, assign) NSInteger  isSlip;
@property (nonatomic, copy) NSString *msgType;//"1：文字消息；2：图片消息；3：语音消息；7：在线人数"； 9: 回复提醒
@property (nonatomic, copy) NSString * orgName;
@property (nonatomic, copy) NSString * atMsgInfo;
@property (nonatomic, copy) NSString * sourceTypeName;
@property (nonatomic, copy) NSString * sourceName;
@property (nonatomic, copy) NSString * teacherIdentity;
@property (nonatomic, copy) NSString * userPic;//发送者头像
@property (nonatomic, assign) NSInteger roomId;//聊天室的id
@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * contents; //多广告位
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, assign) NSInteger  sendUserId;//发送人在聊天室的id
@property (nonatomic, assign) long long createTime;
@property (nonatomic, copy) NSString  *sendJdsUserId;//发送人的jds业务id
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger isTeacher;//"1：老师消息"
@property (nonatomic, copy) NSString * textFormat;
@property (nonatomic, copy) NSString * atUserId; //@用户
@property (nonatomic, assign) NSInteger thirdShow;//1时展示 2 不展示 值没有的话也展示
@property (nonatomic, copy) NSString *fileName; //文件名称
@property (nonatomic, assign) NSInteger fileSize;//文件大小
///高亮股票列表
@property(nonatomic, strong) NSArray *stockIdentifyList;

///是否允许点赞：0-否 1-是
@property(nonatomic, assign) NSInteger isAllowLike;
///消息点赞id
@property(nonatomic, assign) NSInteger messageLikeId;
///用户是否完成了点赞：0-否 1-是
@property(nonatomic, assign) NSInteger isFinishLike;
///点赞总数
@property(nonatomic, assign) NSInteger likeCount;

@end

@interface StockIdentifyList : NSObject

@property(nonatomic, copy) NSString *stockCode;
@property(nonatomic, copy) NSString *stockId;
@property(nonatomic, copy) NSString *stockMarket;
@property(nonatomic, copy) NSString *stockName;

@end

@interface JCIMMessUserModel : NSObject
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString * icon;
@end

@interface JCIMMessResultModel : NSObject
@property (nonatomic, strong) JCIMMessObjectModel *message;
@property (nonatomic, strong) JCIMMessUserModel *user;
@end



@interface JCSocketLiveStartModel : NSObject

@property (nonatomic, copy) NSString *room_id;
@property (nonatomic, strong) JCIMMessResultModel *result;
@property (nonatomic, copy) NSString *cmd;
@property (nonatomic, assign) long long time;
//@property(nonatomic,assign)int msg_id;
//@property(nonatomic,copy)NSString *cmd;
//@property(nonatomic,copy)NSString *room_id;
@end

@interface JCSocketToAuthModel : NSObject
@property(nonatomic,assign)int msg_id;
@property(nonatomic,copy)NSString *cmd;
@property(nonatomic,copy)NSString *authCode;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *room_id;
@end


NS_ASSUME_NONNULL_END
