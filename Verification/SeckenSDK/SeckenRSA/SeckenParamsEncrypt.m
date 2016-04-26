//
//  ParamsEncrypt.m
//  Secken
//
//  Created by 张雪剑 on 15/2/10.
//  Copyright (c) 2015年 Secken, Inc. All rights reserved.
//

#import "SeckenParamsEncrypt.h"
#import "SeckenAppConst.h"

@implementation SeckenParamsEncrypt

#pragma mark 给参数字典转为RSA加密后的参数字典。
+ (NSDictionary *)encryptParams:(NSDictionary *)dictionary
{
    SeckenBaseInfo *_baseInfo = [SeckenBaseInfo sharedBaseInfo];
    if (_baseInfo.strPublicKey || [_baseInfo.strPublicKey isEqualToString:@""]) {
        _baseInfo.strPublicKey = [_baseInfo deServerPublicKey];
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *parStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *result = [parStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    
    NSString * public = [[SeckenRSA sharedInstance] returnPublicKeyPath:_baseInfo.strPublicKey];
    [SeckenRSA sharedInstance].publicKey = public;
    
    parStr = [[SeckenRSA sharedInstance] publicEncrypt:result];
    NSDictionary *parDict = [NSDictionary dictionaryWithObjectsAndKeys:parStr,@"params", nil];
    [[NSFileManager defaultManager] removeItemAtPath:OpenSSLRSAPublicKeyFile error:nil];
    return parDict;
}


#pragma mark 返回参数解密
+ (NSString *)decryptParams:(NSDictionary *)dictionary
{
    
    SeckenBaseInfo *_baseInfo = [SeckenBaseInfo sharedBaseInfo];
    if (!_baseInfo.strLocalPrivateKey) {
        return nil;
    }
    NSString *encryptedStr = dictionary[@"params"];
    if ([encryptedStr isKindOfClass:[NSNull class]]) {
        return @"";
    }
    [SeckenRSA sharedInstance].privateKey = [[SeckenRSA sharedInstance] returnPrivateKeyPath:_baseInfo.strLocalPrivateKey];
    NSString *parStr = [[SeckenRSA sharedInstance] privateDecrypt:encryptedStr];
    return parStr;

    
}





@end
