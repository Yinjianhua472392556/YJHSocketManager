//
//  YJHScoketTranslateTool.m
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import "YJHScoketTranslateTool.h"
#import "YJHNetWorkingModelTool.h"
#import "YJHSocketBaseModel.h"

@implementation YJHScoketTranslateTool

- (NSDictionary *)configModelWithData:(NSData*)data {
    
    NSDictionary *dicts = [YJHScoketTranslateTool returnDictionaryWithDataPath:data];
    JCSocketBaseModel *model = [YJHNetWorkingModelTool configModelWithResponseObject:dicts class:[JCSocketBaseModel class]];
    JCSocketCmdType type = [YJHScoketTranslateTool configDataWithChatTextMessage:model];
    id obj = [YJHScoketTranslateTool getClassObjectWithLiveAnswerMessageType:type chatTextMessage:model resultDict:dicts];
    if (!obj) {
        return nil;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(type) forKey:@"type"];
    [dict setObject:obj forKey:@"obj"];
    return dict;
}

+ (JCSocketCmdType)configDataWithChatTextMessage:(JCSocketBaseModel *)chatTextMessage {
    //NSLog(@"chatTextMessage = %@, cmd = %@", chatTextMessage, chatTextMessage.cmd);
   // NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    JCSocketCmdType socketCmdType = JCSocketCmdTypeNone;
    if ([chatTextMessage.cmd isEqualToString:@"auth1"]) {
        socketCmdType = JCSocketCmdTypeAuth1;
    } else if ([chatTextMessage.cmd isEqualToString:@"wd_chat"]){
         socketCmdType = JCSocketCmdTypeLiveStart;
    } else if ([chatTextMessage.cmd isEqualToString:@"wd_heartbeat"]){
        socketCmdType = JCScoketCmdHearBeat;
    }
//    else if ([chatTextMessage.cmd isEqualToString:@"wd_room"]){
//        socketCmdType = JCScoketCmdHearBeat;
//    }
    
    else{
        socketCmdType = JCSocketCmdTypeNone;
        
    }
    return socketCmdType;
}

+ (id)getClassObjectWithLiveAnswerMessageType:(JCSocketCmdType)liveAnswerMessageType chatTextMessage:(JCSocketBaseModel *)chatTextMessage resultDict:(NSDictionary *)resultDict{
    
    Class resultClass;
    switch (liveAnswerMessageType) {
        case JCSocketCmdTypeAuth1:
        {
            resultClass = [JCSocketAuthModel class];
        }
            break;
        case JCSocketCmdTypeLiveStart:
        {
            resultClass = [JCSocketLiveStartModel class];
        }
            break;
        case JCScoketCmdHearBeat:
        {
          resultClass = [JCSocketBaseModel class];
        }
            break;
        case JCSocketCmdTypeNone:
        {
            
        }
            break;
        default:
            break;
    }
    return [YJHNetWorkingModelTool configModelWithResponseObject:resultDict class:resultClass];
}

+ (NSDictionary*)returnDictionaryWithDataPath:(NSData*)data {
    
    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSData * datas = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingMutableLeaves error:nil];
    return jsonDict;
}

@end
