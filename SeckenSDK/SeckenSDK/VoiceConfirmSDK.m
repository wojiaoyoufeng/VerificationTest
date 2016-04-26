//
//  VoiceConfirmSDK.m
//  CreateSDK
//
//  Created by Secken_ck on 15/9/25.
//  Copyright © 2015年 Secken_ck. All rights reserved.
//

#import "VoiceConfirmSDK.h"
#import "SeckenAppConst.h"
#import "SeckenNetApi.h"
#import "SeckenLocalized.h"

static VoiceConfirmSDK * voiceSDK = nil;

@interface VoiceConfirmSDK ()
{
    
    SeckenBaseInfo      * _baseInfo;
}

@end

@implementation VoiceConfirmSDK


- (instancetype)init
{
    self = [super init];
    if (self) {
        _baseInfo = [SeckenBaseInfo sharedBaseInfo];
    }
    return self;
}

+(instancetype)currVoiceSDK{
    
    if(nil == voiceSDK)  {
        @synchronized(self)  {
            voiceSDK = [[VoiceConfirmSDK alloc] init];
        }
    }
    return voiceSDK;
    
}

/*
 APPAPI新接口：
 
 该接口暂时不用，现在先保留，不删除。
 
 1. /user/queryBalance - 查询余额
 
 @params: secret, app_id, device_id, username, token
 @return: code, message, result(余额)
 
 */
-(void)queryBalanceParamUserName:(NSString *)strUserName
                      paramToken:(NSString *)strToken
                    querySuccess:(void (^)(id operation))success
                       qeeryFail:(void (^)(id operation))fail
{
    
    if (strUserName.length == 0 || strToken.length == 0) {
        
        NSDictionary * dictFail = @{@"error":@"Parameter Error(参数错误)"};
        if (fail != nil) {
            fail(dictFail);
        }
        return;
    }
    
    NSString * secret = [[_baseInfo getTimesteamp] stringByAppendingFormat:@".%@", [_baseInfo getBitStringLength:6]];
    NSDictionary * parameters = @{@"secret": secret,
                                  @"app_id":_baseInfo.strAppID,
                                  @"device_id":_baseInfo.strUUID,
                                  @"token":strToken,
                                  @"username":strUserName,
                                  };
    
    NSString * strApi = [SeckenNetApi getNetworkPath:API_QUERUY_BALANCE];
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    SeckenAFHTTPRequestOperationManager * manager = [self retAFNetworkForOutTime:5];
    [manager POST:strApi parameters:param success:^(SeckenAFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary * tmpDic=(NSDictionary *)responseObject;
        NSString * string = [SeckenParamsEncrypt decryptParams:tmpDic];
        if (string == nil) {
            fail(tmpDic);
            return ;
        }
        
        id value = [self jsonObjectWithString:string];
        NSString * signature = [value objectForKey:@"signature"];
        NSString * strData = [value objectForKey:@"data"];
        BOOL ret = [self data:strData secret:secret appkey:_baseInfo.strAppKey signature:signature];
        
        
        if (ret == NO) {
            
            if ([[_baseInfo getCurrentLanguage] hasPrefix:@"cn"]) {
                NSString * msg = UnknownError_SECKEN_CN;
                NSDictionary * failDict = @{@"msg":msg};
                fail(failDict);
            }else{
                NSString * msg = UnknownError_SECKEN_EN;
                NSDictionary * failDict = @{@"msg":msg};
                fail(failDict);
            }
            return ;
        }
        
        NSDictionary * dictFordata = [self jsonObjectWithString:strData];
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictFordata];
        
        
        //服务器返回的错误，然后提示。
        if ([[dicCode objectForKey:@"code"] intValue] != 200 && fail != nil) {
            fail(dicCode);
        }else if ([[dicCode objectForKey:@"code"] intValue] == 200 && success != nil) {
            success(dicCode);
        }
        
    } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
        
        NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];
        
        if (fail != nil) {
            fail(dicCode);
        }
        
        SLog(@"error %@", error);
    }];
}



/*
 
 2. /user/updateBrick - 扣费
 
 @params: secret, app_id, device_id, username, token
 @return: code, message, result(扣费)
 */
-(void)updateBrickParamUserName:(NSString *)strUserName
                     paramToken:(NSString *)strToken
                  updateSuccess:(void (^)(id operation))success
                     updateFail:(void (^)(id operation))fail
{
    if (strUserName.length == 0 || strToken.length == 0) {
        
        NSDictionary * dictFail = @{@"error":@"Parameter Error(参数错误)"};
        if (fail != nil) {
            fail(dictFail);
        }
        return;
    }
    NSString * secret = [[_baseInfo getTimesteamp] stringByAppendingFormat:@".%@", [_baseInfo getBitStringLength:6]];
    NSDictionary * parameters = @{@"secret": secret,
                                  @"app_id":_baseInfo.strAppID,
                                  @"device_id":_baseInfo.strUUID,
                                  @"token":strToken,
                                  @"username":strUserName,
                                  };
    
    NSString * strApi = [SeckenNetApi getNetworkPath:API_UPDATE_BRICK];
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    SeckenAFHTTPRequestOperationManager * manager = [self retAFNetworkForOutTime:5];
    [manager POST:strApi parameters:param success:^(SeckenAFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary * tmpDic=(NSDictionary *)responseObject;
        NSString * string = [SeckenParamsEncrypt decryptParams:tmpDic];
        if (string == nil) {
            fail(tmpDic);
            return ;
        }
        
        
        id value = [self jsonObjectWithString:string];
        NSString * signature = nil;
        if (![[value objectForKey:@"signature"] isKindOfClass:[NSNull class]]) {
            signature = [value objectForKey:@"signature"];
        }
        
        NSString * strData = nil;
        if (![[value objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
            strData = [value objectForKey:@"data"];
        }
        BOOL ret = [self data:strData secret:secret appkey:_baseInfo.strAppKey signature:signature];
        
        
        if (ret == NO) {
            
            if ([[_baseInfo getCurrentLanguage] hasPrefix:@"cn"]) {
                NSString * msg = UnknownError_SECKEN_CN;
                NSDictionary * failDict = @{@"msg":msg};
                fail(failDict);
            }else{
                NSString * msg = UnknownError_SECKEN_EN;
                NSDictionary * failDict = @{@"msg":msg};
                fail(failDict);
            }
            return ;
        }
        
        NSDictionary * dictFordata = [self jsonObjectWithString:strData];
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictFordata];
        
        
        //服务器返回的错误，然后提示。
        if ([[dicCode objectForKey:@"code"] intValue] != 200 && fail != nil) {
            fail(dicCode);
        }else if ([[dicCode objectForKey:@"code"] intValue] == 200 && success != nil) {
            success(dicCode);
        }
        
    } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
        
        NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];
        
        if (fail != nil) {
            fail(dicCode);
        }
        
        SLog(@"error %@", error);
    }];
}


-(SeckenAFHTTPRequestOperationManager *)retAFNetworkForOutTime:(int)outTime{
    
    SeckenAFHTTPRequestOperationManager * manager = [SeckenAFHTTPRequestOperationManager manager];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    [manager.requestSerializer setTimeoutInterval:outTime];
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSSet *set = [NSSet setWithObjects:@"text/plain", @"text/json",@"text/html", nil];
    manager.responseSerializer.acceptableContentTypes = set;
    return manager;
}

-(NSDictionary *)jsonObjectWithString:(NSString *)string{
    
    if (string == nil) {
        return nil;
    }
    NSDictionary * value = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    return value;
}

-(NSString *)jsonObjectWithDict:(NSDictionary *)dict{
    
    if (dict == nil) {
        return nil;
    }
    NSData * value = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * values = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    return values;
}

-(BOOL)data:(NSString *)strData secret:(NSString *)secret appkey:(NSString *)appkey signature:(NSString *)signature{
    
    NSString * spellSign = [NSString stringWithFormat:@"%@%@%@", strData, secret, appkey];
    NSString * signSHA = [_baseInfo sha1String:spellSign];
    
    if ([signature isEqualToString:signSHA]) {
        return YES;
    }
    return NO;
}


@end
