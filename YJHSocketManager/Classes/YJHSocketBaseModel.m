//
//  YJHSocketBaseModel.m
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import "YJHSocketBaseModel.h"

@implementation JCSocketBaseModel

@end

@implementation JCSocketAuthModel

@end

@implementation JCSocketAuthResultModel

@end
@implementation JCIMMessObjectModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"sid":@"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"stockIdentifyList" : [StockIdentifyList class]};
}

@end

@implementation JCIMMessUserModel

@end

@implementation JCIMMessResultModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"message":JCIMMessObjectModel.class,@"user":JCIMMessUserModel.class};
}
@end

@implementation JCSocketLiveStartModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"result":JCIMMessResultModel.class};
}

@end

@implementation JCSocketToAuthModel

@end

@implementation StockIdentifyList

@end
