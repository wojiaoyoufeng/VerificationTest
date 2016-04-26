//
//  SeckenBaseInfo.m
//  CreateSDK
//
//  Created by Secken_ck on 15/9/14.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import "SeckenBaseInfo.h"
#import "SeckenAESCrypt.h"
#import "SecKenKeychain.h"
#import "SeckenLocalized.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

@implementation SeckenBaseInfo

+ (SeckenBaseInfo *)sharedBaseInfo
{
    static SeckenBaseInfo * baseInfo = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        baseInfo = [[SeckenBaseInfo alloc] init];
    });
    return baseInfo;
}

-(instancetype)init{
    
    if (self = [super init]) {
        
        _strUUID = @"";
        _strPushID = @"I";
        _strDevice_type = @"ios";
        _strDevice_OS = [UIDevice currentDevice].systemName;
        _strSystemVersion = [UIDevice currentDevice].systemVersion;
        _strDevice_name = [UIDevice currentDevice].name;
        _strModel = @"";
        _strLocalizedLanguage = @"";
        
        _strPublicKey = @"";
        _strLocalPrivateKey = @"";
        _strLocalPublicKey = @"";
        _strRandmStr = @"";
        
        _strAppID = @"";
        _strAppKey = @"";
        _strUserName = @"";
        _strToken = @"";
    }
    return self;
}


//显示错误码
-(NSDictionary *)showStatusErrorCode:(NSDictionary *)dictData{
    
    
    int statusCode = [[dictData objectForKey:@"code"] intValue];
    NSString * msg = @"";

    switch (statusCode) {
        case 40001:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40001_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40001_SECKEN_EN;
            }
            break;
            
        case 40002:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40002_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40002_SECKEN_EN;
            }
            break;
        case 40003:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40003_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40003_SECKEN_EN;
            }
            break;
        case 40004:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40004_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40004_SECKEN_EN;
            }
            break;
        case 40005:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40005_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40005_SECKEN_EN;
            }
            break;
        case 40006:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40006_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40006_SECKEN_EN;
            }
            break;
        case 40007:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40007_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40007_SECKEN_EN;
            }
            break;
            
        case 40008:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40008_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40008_SECKEN_EN;
            }
            break;
            
        case 40009:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40009_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40009_SECKEN_EN;
            }
            break;
            
        case 40010:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40010_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40010_SECKEN_EN;
            }
            break;
            
        case 40011:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40011_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40011_SECKEN_EN;
            }
            break;
            
        case 40012:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40012_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40012_SECKEN_EN;
            }
            break;
            
        case 40013:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40013_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40013_SECKEN_EN;
            }
            break;
            
        case 40014:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40014_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40014_SECKEN_EN;
            }
            break;
            
        case 40015:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40015_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40015_SECKEN_EN;
            }
            break;
            
        case 40016:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_40016_SECKEN_CN;
            }else{
                msg = ERROR_CODE_40016_SECKEN_EN;
            }
            break;
       
        case 50001:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_50001_SECKEN_CN;
            }else{
                msg = ERROR_CODE_50001_SECKEN_EN;
            }
            break;
            
        case 3840:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_3840_SECKEN_CN;
            }else{
                msg = ERROR_CODE_3840_SECKEN_EN;
            }
            break;
            
        case -1001:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_3840_SECKEN_CN;
            }else{
                msg = ERROR_CODE_3840_SECKEN_EN;
            }
            break;
            
        case -1003:
            
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_3840_SECKEN_CN;
            }else{
                msg = ERROR_CODE_3840_SECKEN_EN;
            }
            break;
            
        case -1005:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_3840_SECKEN_CN;
            }else{
                msg = ERROR_CODE_3840_SECKEN_EN;
            }
            break;
            
        case -1009:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_3840_SECKEN_CN;
            }else{
                msg = ERROR_CODE_3840_SECKEN_EN;
            }
            break;
            
        case -1022:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_3840_SECKEN_CN;
            }else{
                msg = ERROR_CODE_3840_SECKEN_EN;
            }
            break;
        case 60001:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_60001_SECKEN_CN;
            }else{
                msg = ERROR_CODE_60001_SECKEN_CN;
            }
            break;
            
        case 60002:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_60002_SECKEN_CN;
            }else{
                msg = ERROR_CODE_60002_SECKEN_EN;
            }
            break;
            
        case 60003:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_60003_SECKEN_CN;
            }else{
                msg = ERROR_CODE_60003_SECKEN_EN;
            }
            break;
        case 60004:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_60004_SECKEN_CN;
            }else{
                msg = ERROR_CODE_60004_SECKEN_EN;
            }
            break;
            
        case 60005:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_60005_SECKEN_CN;
            }else{
                msg = ERROR_CODE_60005_SECKEN_EN;
            }
            break;
            
        case 60006:
            if ([[self getCurrentLanguage] isEqualToString:@"cn"]) {
                msg = ERROR_CODE_60006_SECKEN_CN;
            }else{
                msg = ERROR_CODE_60006_SECKEN_EN;
            }
            break;
        default:
            statusCode = 0;
            break;
    }
    
    if (0 == statusCode) {
        return dictData;
    }
    
    NSDictionary * dict = @{@"code": [NSString stringWithFormat:@"%i", statusCode], @"message":msg};
    return dict;
    
}


#pragma mark  当前语言
- (NSString *)getCurrentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage hasPrefix:@"zh"] || [currentLanguage hasPrefix:@"zh-Hans"]) {
        return @"cn";
    }
    if (currentLanguage.length == 0) {
        return @"en";
    }
    return @"en";
}

//获取时间搓
-(NSString *)getTimesteamp
{
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    return [NSString stringWithFormat:@"%llu",recordTime];
}

- (NSString *)md5Tmp:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [[NSString stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


//获取随机数
-(NSString *)getBitStringLength:(int)length
{
    char data[length];
    for (int x = 0; x < length; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}

-(NSString *)deLocalPrivateKey{
    
    NSString * path = [DocumentsDir stringByAppendingPathComponent:@"dataPV"];
    NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (path == nil || dict == nil || [dict count] == 0) {
        return nil;
    }
    
    NSString * enCryptAESPrivate = dict[@"private"];
    NSString * enCryptAESRandom = dict[@"random"];
    
    NSString * deStrRandomRandom = [SeckenAESCrypt decrypt:enCryptAESRandom password:kPrivateRandom];
    NSString * deStrRandom = [self deLocalString:deStrRandomRandom];
    NSString * aesPrivate = [SeckenAESCrypt decrypt:enCryptAESPrivate password:deStrRandom];
    return aesPrivate;
}


 -(NSString *) deLocalPublicKey{
    
    //进行归档
    NSString * pathPublic = [DocumentsDir stringByAppendingPathComponent:@"dataPB"];
    NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithFile:pathPublic];
    
    if (pathPublic == nil || dict == nil || [dict count] == 0) {
        return nil;
    }
    
    NSString * enCryptAESPublic = dict[@"public"];
    NSString * enCryptAESRandom = dict[@"random"];
    
    NSString * deStrRandomRandom = [SeckenAESCrypt decrypt:enCryptAESRandom password:kPublicRandom];
    NSString * deStrRandom = [self deLocalString:deStrRandomRandom];
    NSString * aesPrivate = [SeckenAESCrypt decrypt:enCryptAESPublic password:deStrRandom];
    return aesPrivate;
    
}

-(NSString *)deServerPublicKey{
    
    NSString * path = [DocumentsDir stringByAppendingPathComponent:@"dataSPB"];
    NSString * strAES = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (strAES == nil) {
        return  nil;
    }
    
    NSString * serverPublic = [SeckenAESCrypt decrypt:strAES password:kPublic];
    return serverPublic;
}


- (NSString *)sha1String:(NSString *)srcString{
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, [data length], digest);
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH *2];
    
    for(int i =0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}


-(NSString *)enLocalString:(NSString *)string{
    
    NSMutableString * mutableString = [[NSMutableString alloc] initWithString:string];

    if (mutableString.length >= 31) {
        
        NSString * one = [mutableString substringWithRange:NSMakeRange(0, 1)];
        NSString * five = [mutableString substringWithRange:NSMakeRange(4, 1)];
        NSString * ten = [mutableString substringWithRange:NSMakeRange(9, 1)];
        NSString * thitytwo = [mutableString substringWithRange:NSMakeRange(31, 1)];
        
        
        [mutableString deleteCharactersInRange:NSMakeRange(31, 1)];
        [mutableString deleteCharactersInRange:NSMakeRange(9, 1)];
        [mutableString deleteCharactersInRange:NSMakeRange(4, 1)];
        [mutableString deleteCharactersInRange:NSMakeRange(0, 1)];
        
        [mutableString insertString:thitytwo atIndex:0];
        [mutableString insertString:ten atIndex:4];
        [mutableString insertString:five atIndex:9];
        [mutableString insertString:one atIndex:31];
    }
    return mutableString;
}



-(NSString *)deLocalString:(NSString *)string{
    
    NSMutableString * mutableString = [[NSMutableString alloc] initWithString:string];
   
    if (mutableString.length >= 31) {
        
        NSString * one = [mutableString substringWithRange:NSMakeRange(31, 1)];
        NSString * five = [mutableString substringWithRange:NSMakeRange(9, 1)];
        NSString * ten = [mutableString substringWithRange:NSMakeRange(4, 1)];
        NSString * thitytwo = [mutableString substringWithRange:NSMakeRange(0, 1)];
        
        [mutableString deleteCharactersInRange:NSMakeRange(31, 1)];
        [mutableString deleteCharactersInRange:NSMakeRange(9, 1)];
        [mutableString deleteCharactersInRange:NSMakeRange(4, 1)];
        [mutableString deleteCharactersInRange:NSMakeRange(0, 1)];
        
        [mutableString insertString:one atIndex:0];
        [mutableString insertString:five atIndex:4];
        [mutableString insertString:ten atIndex:9];
        [mutableString insertString:thitytwo atIndex:31];
    }
    return mutableString;
}

@end
