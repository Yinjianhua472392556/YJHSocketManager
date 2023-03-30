//
//  YJHNetWorkingModelTool.m
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import "YJHNetWorkingModelTool.h"
#import "NSDictionary+YJHNetWorkingUtil.h"

@import MJExtension;

@implementation YJHNetWorkingModelTool



+ (nonnull NSDictionary *)configDictWithResponseModel:(nonnull id)responseObject {
    return [[responseObject mj_keyValues] removeNullValues];
}

+ (nonnull id)configModelWithResponseObject:(nonnull id)responseObject class:(nonnull Class)cls {
    if ([NSStringFromClass(cls) isEqualToString:@"NSDictionary"] || [NSStringFromClass(cls) isEqualToString:@"NSArray"]) {
        return [responseObject mj_JSONObject];
    }
    
    if ([responseObject isKindOfClass:[NSArray class]]) {
        return  [cls mj_objectArrayWithKeyValuesArray:responseObject];
    }
    
    id responseModel = [cls mj_objectWithKeyValues:responseObject];
    return responseModel;
}

@end
