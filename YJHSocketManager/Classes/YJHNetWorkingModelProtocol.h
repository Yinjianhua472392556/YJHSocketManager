//
//  YJHNetWorkingModelProtocol.h
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YJHNetWorkingModelProtocol <NSObject>

// 模型变成字典
+ (NSDictionary *)configDictWithResponseModel:(id)responseObject;

// 将数据转换成模型
+ (id)configModelWithResponseObject:(id)responseObject class:(Class)cls;

@end

NS_ASSUME_NONNULL_END
