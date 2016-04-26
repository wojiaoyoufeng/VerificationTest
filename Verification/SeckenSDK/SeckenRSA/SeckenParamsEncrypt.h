//
//  ParamsEncrypt.h
//  Secken
//
//  Created by 张雪剑 on 15/2/10.
//  Copyright (c) 2015年 Secken, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeckenParamsEncrypt : NSObject

#pragma mark 给参数字典转为RSA加密后的参数字典。
+ (NSDictionary *)encryptParams:(NSDictionary *)dictionary;

#pragma mark 返回参数解密
+ (NSString *)decryptParams:(NSDictionary *)dictionary;

@end
