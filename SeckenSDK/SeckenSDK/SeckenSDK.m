//
//  SeckenSDK.m
//  CreateSDK
//
//  Created by Secken_ck on 15/9/13.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import "SeckenSDK.h"
#import "SeckenAppConst.h"
#import "SeckenNetApi.h"
#import "SeckenBaseInfo.h"
#import "SeckenSingleton.h"
#import "SeckenOpenSSLRSAWrapper.h"
#import "SeckenParamsEncrypt.h"
#import "SeckenAESCrypt.h"
#import "SecKenKeychain.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SeckenLocalized.h"


static SeckenSDK        * seckenSDK = nil;
@interface SeckenSDK ()
{
    
    NSString            * _strSverResKey;
    SeckenBaseInfo      * _baseInfo;
}
@end

@implementation SeckenSDK



+(instancetype)registerAppID:(NSString *)appID appKey:(NSString *)appKey
{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if(nil == seckenSDK)  {
                seckenSDK = [[SeckenSDK alloc] initWithAppID:appID appKey:appKey];
            }
        });
    return seckenSDK;
}



+(instancetype)currSeckenSDK{
    return seckenSDK;
}

-(instancetype)initWithAppID:(NSString *)appID appKey:(NSString *)appKey{
    
    if (self = [super init]) {
                
        if (appID.length == 0 || appKey.length == 0) {
            
            NSLog(@"Error(错误) AppID AppKey Error");
            return nil;
            
        }
        
        
        _baseInfo = [SeckenBaseInfo sharedBaseInfo];
        _baseInfo.strAppID = [appID stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        _baseInfo.strAppKey = [appKey stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self soketConnect];
            
        });
        
    }
    return self;
}


-(void)observeResultPullBlock:(void (^)(id))result{

    
    [[SeckenSingleton sharedInstance] resultBlock:^(id operation) {
        
        if (result) {
            result(operation);
        }
        
    }];
    
//    [SeckenSingleton sharedInstance].resultBlock = ^(id opera){
//        if (result) {
//            result(opera);
//        }
//    };
    
}

-(void)soketConnect{
    
    
    // 在连接前先进行手动断开
    [[SeckenSingleton sharedInstance] cutOffSocket];
    
    //先去长连接。
    if(![SeckenSingleton sharedInstance].socket.isConnected)
    {
        // 在连接前先进行手动断开
        [[SeckenSingleton sharedInstance] cutOffSocket];
        
        [SeckenSingleton sharedInstance].socketHost = hostSocket;// host设定
        [SeckenSingleton sharedInstance].socketPort = portSocket;// port设定
        
        // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
        [SeckenSingleton sharedInstance].socket.userData = SocketOfflineByServer;
        [[SeckenSingleton sharedInstance] socketConnectHost];
      
    }
}

-(void)baseInfo{
    
    
    // 通过钥匙链里是否有uuid判断程序是否是第一次安装
    if ([SecKenKeychain passwordForService:kUUID account:kUUID] == nil) {
        NSString * nsID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [SecKenKeychain setPassword:nsID forService:kUUID account:kUUID];
    }
    
    _baseInfo.strUUID = [SecKenKeychain passwordForService:kUUID account:kUUID];
    if (_baseInfo.strUUID.length == 0) {
        NSString * nsID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [SecKenKeychain setPassword:nsID forService:kUUID account:kUUID];
        _baseInfo.strUUID = nsID;
    }
    
    
    if ([SecKenKeychain passwordForService:kPUSH_ID account:kPUSH_ID].length == 0) {
        NSString * strUUID = [SecKenKeychain passwordForService:kUUID account:kUUID];
        if (strUUID == nil) {
            strUUID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }else{
            strUUID = [strUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }
        _baseInfo.strPushID = [NSString stringWithFormat:@"I%@", strUUID];
    }else{
        NSString * string = [SecKenKeychain passwordForService:kPUSH_ID account:kPUSH_ID];
        if (string == nil) {
            string = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }else{
            string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }
        _baseInfo.strPushID = [NSString stringWithFormat:@"I%@", string];
    }
    
    
    if (_baseInfo.strUUID.length == 0) {
        _baseInfo.strUUID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [SecKenKeychain setPassword: _baseInfo.strUUID forService:kUUID account:kUUID];
        
    }
    
    if (_baseInfo.strUUID.length == 0) {
        NSLog(@"Error 获取设备ID失败，请从新尝试");
        return;
    }
    
    //判断本地是否存在私钥
    if([_baseInfo deLocalPrivateKey] && ![[_baseInfo deLocalPrivateKey] isEqualToString:@""]){
        
        //把本地的私钥取出来
        NSString * strLocalPrivate = [_baseInfo deLocalPrivateKey];
        _baseInfo.strLocalPrivateKey = strLocalPrivate;
        //把本地的公钥取出来
        NSString * strLocalPublic = [_baseInfo deLocalPublicKey];
        _baseInfo.strLocalPublicKey = strLocalPublic;
        
    }else{
        
        //  首次进入app，生成密钥对
        SeckenOpenSSLRSAWrapper * wrapper = [[SeckenOpenSSLRSAWrapper alloc]init];
        [wrapper generateRSAKeyPairWithKeySize:1024];
        [wrapper exportRSAKeys];
        
        
        
        SLog(@"public = %@",wrapper.publicKeyBase64);
        SLog(@"private = %@",wrapper.privateKeyBase64);
        
        
        _baseInfo.strLocalPrivateKey = wrapper.privateKeyBase64;
        _baseInfo.strLocalPublicKey = wrapper.publicKeyBase64;
        
        //获取32位随机数
        NSString * strRandomPrivate = [_baseInfo getBitStringLength:32];
        //通过随机数对私钥加密
        NSString * aesPrivate = [SeckenAESCrypt encrypt:wrapper.privateKeyBase64 password:strRandomPrivate];
        //打乱随机数
        NSString * randomRandom = [_baseInfo enLocalString:strRandomPrivate];
        //然后吧随机数加密
        NSString * strAESRandomPrivate = [SeckenAESCrypt encrypt:randomRandom password:kPrivateRandom];
        //然后拼成字典
        NSDictionary * saveDict = @{@"private":aesPrivate, @"random":strAESRandomPrivate};
        //进行归档，dataPV表示， Data Private
        NSString * path = [DocumentsDir stringByAppendingPathComponent:@"dataPV"];
        [NSKeyedArchiver archiveRootObject:saveDict toFile:path];
        
        
        //首先获取32位随机数
        NSString * strRandomPublic = [_baseInfo getBitStringLength:32];
        //通过随机数对公钥加密
        NSString * aesPublic = [SeckenAESCrypt encrypt:wrapper.publicKeyBase64 password:strRandomPublic];
        //打乱随机数
        NSString * publicRandomRandom = [_baseInfo enLocalString:strRandomPublic];
        //然后把打乱的随机数进行加密
        NSString * strAESRandomPublic = [SeckenAESCrypt encrypt:publicRandomRandom password:kPublicRandom];
        //然后拼成字典
        NSDictionary * savePublicDict = @{@"public":aesPublic, @"random":strAESRandomPublic};
        //进行归档，dataPB 表示  Data Public
        NSString * pathPublic = [DocumentsDir stringByAppendingPathComponent:@"dataPB"];
        [NSKeyedArchiver archiveRootObject:savePublicDict toFile:pathPublic];
        
        [[NSFileManager defaultManager] removeItemAtPath:OpenSSLRSAPublicKeyFile error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:OpenSSLRSAPrivateKeyFile error:nil];
    }
    
    //拼接格式
    NSString * head = @"-----BEGIN PUBLIC KEY-----";
    NSString * end = @"-----END PUBLIC KEY-----";
    _baseInfo.strLocalPublicKey = [NSString stringWithFormat:@"%@\n%@\n%@", head,_baseInfo.strLocalPublicKey, end];
    
}


-(void)getPubKeyResult:(void(^)(id operation))result{
    
    SeckenAFHTTPRequestOperationManager * manager = [[SeckenAFHTTPRequestOperationManager alloc]init];
    NSSet *contentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"text/json", nil];
    manager.responseSerializer.acceptableContentTypes = contentTypes;
    
    NSString * address = [SeckenNetApi getNetworkPath:API_GET_PUBLIC_KEY];
    [manager GET:address parameters:nil success:^(SeckenAFHTTPRequestOperation *operation, id responseObject) {
        
        //从服务器返回的数据，然后取出pubkey，然后从字符A中分隔成2个元素的数组
        //然后加密存储到钥匙串。
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSString *pubkey = dict[@"pubkey"];
        if ([[pubkey componentsSeparatedByString:@"-----"] objectAtIndex:2]) {
            _strSverResKey = [[pubkey componentsSeparatedByString:@"-----"] objectAtIndex:2];
        }else{
            _strSverResKey = @"";
        }
        NSString * strAES = [SeckenAESCrypt encrypt:_strSverResKey password:kPublic];
        
        
        [[NSFileManager defaultManager] removeItemAtPath:
         [DocumentsDir stringByAppendingPathComponent:@"dataSPB"] error:nil];
        
        //dataSPB 表示 Data Server Public
        NSString * pathPublic = [DocumentsDir stringByAppendingPathComponent:@"dataSPB"];
        [NSKeyedArchiver archiveRootObject:strAES toFile:pathPublic];
        result(_strSverResKey);
        
    } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
        
        NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];
        
        if ([dicCode objectForKey:@"code"]) {
            
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
                NSString * title = ALTER_TIP_SECKEN_CN;
                NSString * confirm = CONFIRM_SECKEN_CN;
                NSString * code = [dicCode objectForKey:@"code"];
                NSString * msg = [dicCode objectForKey:@"message"];
                
                UIAlertView * alter = [[UIAlertView alloc] initWithTitle:title
                                                                 message:[NSString stringWithFormat:@"code:%@, message:%@", code, msg]
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:confirm, nil];
                [alter show];
                
            }else{
                
                NSString * title = ALTER_TIP_SECKEN_EN;
                NSString * confirm = CONFIRM_SECKEN_EN;
                NSString * code = [dicCode objectForKey:@"code"];
                NSString * msg = [dicCode objectForKey:@"message"];
                
                UIAlertView * alter = [[UIAlertView alloc] initWithTitle:title
                                                                 message:[NSString stringWithFormat:@"code:%@, message:%@", code, msg]
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:confirm, nil];
                [alter show];
                
            }
            //SLog(@"error %@", error);
        }
        
        
    }];
}

-(void)bindUserName:(NSString *)strUserName bindSuccess:(void (^)(id))success bindFail:(void (^)(id))fail{
    
    if (strUserName.length == 0) {
        
        NSDictionary * dictFail = @{@"error":@"Parameter Error(参数错误)"};
        if (fail != nil) {
            fail(dictFail);
        }
        return;
    }

    //进行base的相关信息。
    [self baseInfo];
    
    //如果本地没有服务器的公钥，就去请求。
    if ([[_baseInfo deServerPublicKey] isEqualToString:@""] || [_baseInfo deServerPublicKey] == nil) {
        [self getPubKeyResult:^(id operation) {
            _baseInfo.strPublicKey = _strSverResKey;
            
            NSString * secret = [[_baseInfo getTimesteamp] stringByAppendingFormat:@".%@", [_baseInfo getBitStringLength:6]];
            NSDictionary * parameters = @{@"secret": secret,
                                          @"app_id":_baseInfo.strAppID,
                                          @"username":strUserName,
                                          @"device_id":_baseInfo.strUUID,
                                          @"pubkey":_baseInfo.strLocalPublicKey,
                                          @"push_id":_baseInfo.strPushID,
                                          @"device_hostname":_baseInfo.strDevice_name,
                                          @"device_type":_baseInfo.strDevice_type,
                                          @"device_os":_baseInfo.strDevice_OS,
                                          @"device_version":_baseInfo.strSystemVersion,
                                          };
            
            NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
            NSString * strApi = [SeckenNetApi getNetworkPath:API_BIND];
            
            SeckenAFHTTPRequestOperationManager * manager = [self retAFNetworkForOutTime:5];
            [manager POST:strApi parameters:param success:^(SeckenAFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary * tmpDic=(NSDictionary *)responseObject;
                NSString * string = [SeckenParamsEncrypt decryptParams:tmpDic];
                if (string == nil) {
                    if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
                    if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
                        NSString * msg = ERROR_CODE_60005_SECKEN_CN;
                        NSDictionary * failDict = @{@"msg":msg};
                        fail(failDict);
                    }else{
                        NSString * msg = ERROR_CODE_60005_SECKEN_EN;
                        NSDictionary * failDict = @{@"msg":msg};
                        fail(failDict);
                    }
                    return ;
                }
                
                NSMutableDictionary * dictFordata = [[NSMutableDictionary alloc]initWithDictionary:[self jsonObjectWithString:strData]];
                NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictFordata];
                
                
                
                NSString * faceID = [dictFordata objectForKey:@"face_id"];
                NSString * voiceID = [dictFordata objectForKey:@"voice_id"];
                NSString * regID = [dictFordata objectForKey:@"reg_id"];
                
                _baseInfo.strVoice_id = voiceID;
                _baseInfo.strReg_id = regID;
                _baseInfo.strFaceID = faceID;
                
                
                
                if (![faceID isKindOfClass:[NSNull class]] && faceID.length != 0) {
                    [dictFordata removeObjectForKey:@"face_id"];
                    [dictFordata setObject:@"1" forKey:@"hasFace"];
                }else{
                    [dictFordata removeObjectForKey:@"face_id"];
                    [dictFordata setValue:@"0" forKey:@"hasFace"];
                }
                
                
                if (![voiceID isKindOfClass:[NSNull class]] && voiceID.length != 0) {
                    [dictFordata removeObjectForKey:@"voice_id"];
                    [dictFordata setObject:@"1" forKey:@"hasVoice"];
                }else{
                    [dictFordata removeObjectForKey:@"voice_id"];
                    [dictFordata setObject:@"0" forKey:@"hasVoice"];
                }
                
                
                if (![regID isKindOfClass:[NSNull class]] && voiceID.length != 0) {
                    [dictFordata removeObjectForKey:@"reg_id"];
                    [dictFordata setObject:@"1" forKey:@"hasRegID"];
                }else{
                    [dictFordata removeObjectForKey:@"reg_id"];
                    [dictFordata setObject:@"0" forKey:@"hasRegID"];
                }
                
                NSString * strForData = [self jsonObjectWithDict:dictFordata];
                
                _baseInfo.strUserName = strUserName;
                _baseInfo.strToken = [dictFordata objectForKey:@"token"];
                
                //服务器返回的错误，然后提示。
                if ([[dicCode objectForKey:@"code"] intValue] != 200 && fail != nil) {
                    fail(dicCode);
                }else if ([[dicCode objectForKey:@"code"] intValue] == 200 && success != nil) {

                    if (dictFordata.count != 0) {
                        success(dictFordata);
                    }else{
                        success(strForData);
                    }
                    
                }
                
                
            } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
                
                NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
                NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];
                
                if ([dicCode objectForKey:@"code"]) {
                    fail(dicCode);
                }else if (fail != nil) {
                    fail(dicCode);
                }
                //SLog(@"error %@", error);
            }];
            
        }];
    }else{
        //把Server返回的Pubkey取出来。
        NSString * strServerPub = [_baseInfo deServerPublicKey];
        _baseInfo.strPublicKey = strServerPub;
        
        
        NSString * secret = [[_baseInfo getTimesteamp] stringByAppendingFormat:@".%@", [_baseInfo getBitStringLength:6]];
        NSDictionary * parameters = @{@"secret": secret,
                                      @"app_id":_baseInfo.strAppID,
                                      @"username":strUserName,
                                      @"device_id":_baseInfo.strUUID,
                                      @"pubkey":_baseInfo.strLocalPublicKey,
                                      @"push_id":_baseInfo.strPushID,
                                      @"device_hostname":_baseInfo.strDevice_name,
                                      @"device_type":_baseInfo.strDevice_type,
                                      @"device_os":_baseInfo.strDevice_OS,
                                      @"device_version":_baseInfo.strSystemVersion,
                                      };
        
        NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
        NSString * strApi = [SeckenNetApi getNetworkPath:API_BIND];
        
        SeckenAFHTTPRequestOperationManager * manager = [self retAFNetworkForOutTime:5];
        [manager POST:strApi parameters:param success:^(SeckenAFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary * tmpDic=(NSDictionary *)responseObject;
            NSString * string = [SeckenParamsEncrypt decryptParams:tmpDic];
            if (string == nil) {
                if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
                if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
                    NSString * msg = ERROR_CODE_60005_SECKEN_CN;
                    NSDictionary * failDict = @{@"msg":msg};
                    fail(failDict);
                }else{
                    NSString * msg = ERROR_CODE_60005_SECKEN_EN;
                    NSDictionary * failDict = @{@"msg":msg};
                    fail(failDict);
                }
                return ;
            }
            
            NSMutableDictionary * dictFordata = [NSMutableDictionary dictionaryWithDictionary:[self jsonObjectWithString:strData]];
            NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictFordata];
            
            
            
            NSString * faceID = [dictFordata objectForKey:@"face_id"];
            NSString * voiceID = [dictFordata objectForKey:@"voice_id"];
            NSString * regID = [dictFordata objectForKey:@"reg_id"];

            _baseInfo.strVoice_id = voiceID;
            _baseInfo.strReg_id = regID;
            _baseInfo.strFaceID = faceID;
            
            
            
            if (![faceID isKindOfClass:[NSNull class]] && faceID.length != 0) {
                [dictFordata removeObjectForKey:@"face_id"];
                [dictFordata setObject:@"1" forKey:@"hasFace"];
            }else{
                [dictFordata removeObjectForKey:@"face_id"];
                [dictFordata setValue:@"0" forKey:@"hasFace"];
            }

            
            if (![voiceID isKindOfClass:[NSNull class]] && voiceID.length != 0) {
                [dictFordata removeObjectForKey:@"voice_id"];
                [dictFordata setObject:@"1" forKey:@"hasVoice"];
            }else{
                [dictFordata removeObjectForKey:@"voice_id"];
                [dictFordata setObject:@"0" forKey:@"hasVoice"];
            }
            
            
            if (![regID isKindOfClass:[NSNull class]] && voiceID.length != 0) {
                [dictFordata removeObjectForKey:@"reg_id"];
                [dictFordata setObject:@"1" forKey:@"hasRegID"];
            }else{
                [dictFordata removeObjectForKey:@"reg_id"];
                [dictFordata setObject:@"0" forKey:@"hasRegID"];
            }
            
            
            NSString * strForData = [self jsonObjectWithDict:dictFordata];
            
            _baseInfo.strUserName = strUserName;
            _baseInfo.strToken = [dictFordata objectForKey:@"token"];
            
            //服务器返回的错误，然后提示。
            if ([[dicCode objectForKey:@"code"] intValue] != 200 && fail != nil) {
                fail(dicCode);
            }else if ([[dicCode objectForKey:@"code"] intValue] == 200 && success != nil) {
                
                if (dictFordata.count != 0) {
                    success(dictFordata);
                }else{
                    success(strForData);
                }
                
            }
            
            
        } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
            
            NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
            NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];
            
            if ([dicCode objectForKey:@"code"]) {
                
                fail(dicCode);
            }else if (fail != nil) {
                fail(dicCode);
            }
            //SLog(@"error %@", error);
        }];
        
    }
}




-(void)unBindUserName:(NSString *)strUserName
                token:(NSString *)strToken
        unBindSuccess:(void (^)(id))success
           unBindFail:(void (^)(id))fail{
    
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
                                  @"username":strUserName,
                                  @"device_id":_baseInfo.strUUID,
                                  @"pubkey":_baseInfo.strLocalPublicKey,
                                  @"token":strToken,
                                  };
    
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    NSString * strApi = [SeckenNetApi getNetworkPath:API_UN_BIND];
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
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        
        if ([strData isKindOfClass:[NSString class]]) {
            
            NSDictionary * dictFordata = [self jsonObjectWithString:strData];
            NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictFordata];
            //服务器返回的错误，然后提示。
            if ([[dicCode objectForKey:@"code"] intValue] != 200) {
                fail(dicCode);
            }else{
                
                [self delSaveLocal];
                
                if (success != nil) {
                    success(dictFordata);
                }
            }
        }
        
    } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
        
        NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];
        
        if ([dicCode objectForKey:@"code"]) {
            
            fail(dicCode);
            
        }else if (fail != nil) {
            fail(dicCode);
        }
        //SLog(@"error %@", error);
    }];
}






-(void)authQR:(NSString *)strQR
        token:(NSString *)strToken
     userName:(NSString *)strUserName
    longitude:(NSString *)strLon
     latitude:(NSString *)strLat
  authSuccess:(void (^)(id))success authFail:(void (^)(id))fail
{
    
    if (strLon.length == 0 || strLat.length == 0 ||
        strQR.length == 0 || strToken.length == 0 || strUserName.length == 0) {
        
        NSDictionary * dictFail = @{@"error":@"Parameter Error(参数错误)"};
        if (fail != nil) {
            fail(dictFail);
        }
        return ;
    }
    
    [[SeckenAFNetworkReachabilityManager sharedManager] startMonitoring];
    
    if ([strQR hasPrefix:@"http://yc.im/"] || [strQR hasPrefix:@"https://yc.im/"]) {
        NSString * secret = [[_baseInfo getTimesteamp] stringByAppendingFormat:@".%@", [_baseInfo getBitStringLength:6]];
        NSDictionary * parameters =
        @{@"secret":secret,
          @"app_id":_baseInfo.strAppID,
          @"username":strUserName,
          @"device_id":_baseInfo.strUUID,
          @"token":strToken,
          @"qrdata":strQR,
          @"language":[_baseInfo getCurrentLanguage],
          @"longitude":strLon,
          @"latitude":strLat,
          };
        
        NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
        NSString * strApi = [SeckenNetApi getNetworkPath:API_QR_AUTH];
        
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
                if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
            
            if ([dicCode objectForKey:@"code"]) {
                fail(dicCode);
            }else if (fail != nil) {
                fail(dicCode);
            }
            //SLog(@"error %@", error);
        }];
        
    }else{
        
        NSDictionary * dictFail = @{@"code":[NSString stringWithFormat:@"%i", 40008]};
        if (fail != nil) {
            fail([_baseInfo showStatusErrorCode:dictFail]);
        }
    }
}





-(void)confirmToken:(NSString *)strToken
           userName:(NSString *)strUserName
              agree:(NSString *)agr
            eventID:(NSString *)event_ID
        authSuccess:(void (^)(id))success
           authFail:(void (^)(id))fail
{
    
    if (strToken.length == 0 || agr.length == 0 ||
        event_ID.length == 0 || strUserName.length == 0)
    {
        NSDictionary * dictFail = @{@"error":@"Parameter Error(参数错误)"};
        if (fail != nil) {
            fail(dictFail);
        }
        return ;
    }
    
    NSString * secret = [[_baseInfo getTimesteamp] stringByAppendingFormat:@".%@", [_baseInfo getBitStringLength:6]];
    NSDictionary * parameters = @{@"secret":secret,
                                  @"app_id":_baseInfo.strAppID,
                                  @"username":strUserName,
                                  @"device_id":_baseInfo.strUUID,
                                  @"agree":agr,
                                  @"event_id":event_ID,
                                  @"token":strToken,
                                  @"language":[_baseInfo getCurrentLanguage],
                                  };
    
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    NSString * strApi = [SeckenNetApi getNetworkPath:API_QR_CONFIRM];
    
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
            
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        
        if ([dicCode objectForKey:@"code"]) {
            
            fail(dicCode);
        }else if (fail != nil) {
            fail(dicCode);
        }
        //SLog(@"error %@", error);
        
    }];
}



-(void)pullUserName:(NSString *)strUserName
              token:(NSString *)strToken
        pullSuccess:(void (^)(id))success
           pullFail:(void (^)(id))fail
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
                                  @"language":[_baseInfo getCurrentLanguage],
                                  @"username":strUserName,
                                  };
    
    
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    NSString * strApi = [SeckenNetApi getNetworkPath:API_PULL];
    
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
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        
        if ([dicCode objectForKey:@"code"]) {
            fail(dicCode);
        }else if (fail != nil) {
            fail(dicCode);
        }
        //SLog(@"error %@", error);
        
    }];
    
    
}


-(void)updatePushIdUserName:(NSString *)strUserName
                      token:(NSString *)strToken
                     pushID:(NSString *)strPushID
                PushSuccess:(void (^)(id))success
                   PushFail:(void (^)(id))fail
{
    if (strUserName.length == 0 || strToken.length == 0 || strPushID.length == 0) {
        
        NSDictionary * dictFail = @{@"error":@"Parameter Error(参数错误)"};
        if (fail != nil) {
            fail(dictFail);
        }
        return;
    }
    
    NSString * newPush = [strPushID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [SecKenKeychain deletePasswordForService:kPUSH_ID account:kPUSH_ID];
    [SecKenKeychain setPassword:newPush forService:kPUSH_ID account:kPUSH_ID];
    _baseInfo.strPushID = [NSString stringWithFormat:@"I%@", newPush];
    [self soketConnect];

    
    NSString * secret = [[_baseInfo getTimesteamp] stringByAppendingFormat:@".%@", [_baseInfo getBitStringLength:6]];
    NSDictionary * parameters = @{@"secret": secret,
                                  @"app_id":_baseInfo.strAppID,
                                  @"device_id":_baseInfo.strUUID,
                                  @"username":strUserName,
                                  @"token":strToken,
                                  @"push_id":_baseInfo.strPushID,
                                  };
    
    
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    NSString * strApi = [SeckenNetApi getNetworkPath:API_UPDATE_PUSH_ID];
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
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        
        if ([dicCode objectForKey:@"code"]) {
            fail(dicCode);
        }else if (fail != nil) {
            fail(dicCode);
        }
        //SLog(@"error %@", error);
        
    }];
    
    
}



-(void)faceTrainUserName:(NSString *)strUserName
                   token:(NSString *)strToken
                    step:(NSString *)strStep
               faceImage:(UIImage *)image
       faceTraninSuccess:(void (^)(id))success
          faceTraninFail:(void (^)(id))fail
{
    
    if (strUserName.length == 0 || strToken.length == 0 || strStep.length == 0 || image == nil) {
        
        NSDictionary * dictFail = @{@"error":@"Parameter Error(参数错误)"};
        if (fail != nil) {
            fail(dictFail);
        }
        return;
    }
    
    NSString * secret = [[_baseInfo getTimesteamp] stringByAppendingFormat:@".%@", [_baseInfo getBitStringLength:6]];
    NSDictionary * parameters = @{@"secret": secret,
                                  @"app_id": _baseInfo.strAppID,
                                  @"device_id":_baseInfo.strUUID,
                                  @"token":strToken,
                                  @"step":strStep,
                                  @"username":strUserName,
                                  };
    
    NSData * faceData = UIImageJPEGRepresentation(image, 0.8);
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    NSString * strApi = [SeckenNetApi getNetworkPath:API_FACE_TRAIN];
    
    NSMutableURLRequest * request = [[SeckenAFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:strApi parameters:param constructingBodyWithBlock:^(id formData){
        
        NSString *name = [NSString stringWithFormat:@"%@",@"face"];
        NSString *nameImage = [NSString stringWithFormat:@"%@.jpeg",@"image"];
        [formData appendPartWithFileData:faceData name:name fileName:nameImage mimeType:@"image/jpeg"];
        
    } error:nil];
    request.timeoutInterval=10.0;
    
    NSLog(@"人脸训练开始请求服务器  第%@步 ---- , %@" ,strStep, [NSDate date]);
    SeckenAFHTTPRequestOperation * afOperation = [[SeckenAFHTTPRequestOperation alloc] initWithRequest:request];
    [afOperation setCompletionBlockWithSuccess:^(SeckenAFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"人脸训练接受服务器数据并解析 第%@步  ---- , %@", strStep, [NSDate date]);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        if (requestTmp == nil) {
            fail(requestTmp);
        }
        
        id dict = [self jsonObjectWithString:requestTmp];
        NSString * string = [SeckenParamsEncrypt decryptParams:dict];
        
        
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
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        
        
        NSDictionary * dictFordata = [NSMutableDictionary dictionaryWithDictionary:[self jsonObjectWithString:strData]];
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictFordata];
        
        NSLog(@"人脸训练数据解析完毕  第%@步 ---- , %@", strStep,[NSDate date]);

        
        //服务器返回的错误，然后提示。
        if ([[dicCode objectForKey:@"code"] intValue] != 200 && fail != nil) {
            fail(dicCode);
        }else if ([[dicCode objectForKey:@"code"] intValue] == 200 && success != nil) {
            
            if ([strStep isEqualToString:@"3"] ) {
                [dictFordata setValue:@"1" forKey:@"hasFace"];
            }else{
                [dictFordata setValue:@"0" forKey:@"hasFace"];
            }
            success(dicCode);
        }
        
    } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
        
        NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];
      
        NSLog(@"人脸训练请求失败  第%@步 ---- , %@", strStep,[NSDate date]);

        
        if ([dicCode objectForKey:@"code"]) {
            
            fail(dicCode);
        }else if (fail != nil) {
            fail(dicCode);
        }
    }];
    
    [afOperation start];
    
}




-(void)faceDeleteUserName:(NSString *)strUserName
                    token:(NSString *)strToken
        faceDeleteSuccess:(void (^)(id))success
           faceDeleteFail:(void (^)(id))fail
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
    
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    NSString * strApi = [SeckenNetApi getNetworkPath:API_FACE_DELETE];
    
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
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        
        if ([dicCode objectForKey:@"code"]) {
            
            fail(dicCode);
        }else if (fail != nil) {
            fail(dicCode);
        }
        
        //SLog(@"error %@", error);
        
    }];
    
}


-(void)faceCompareUserName:(NSString *)strUserName
                     token:(NSString *)strToken
                 faceImage:(UIImage *)image
        faceCompareSuccess:(void (^)(id))success
           faceCompareFail:(void (^)(id))fail
{
    if (strUserName.length == 0 || strToken.length == 0 || image == nil) {
        
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
    NSData * data = UIImageJPEGRepresentation(image, 0.8);
    NSDictionary * param = [SeckenParamsEncrypt encryptParams:parameters];
    NSString * strApi = [SeckenNetApi getNetworkPath:API_FACE_COMPARE];
    
    
    NSMutableURLRequest * request = [[SeckenAFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:strApi parameters:param constructingBodyWithBlock:^(id formData){
        
        NSString *name = [NSString stringWithFormat:@"%@",@"face"];
        NSString *nameImage = [NSString stringWithFormat:@"%@.jpeg",@"image"];
        [formData appendPartWithFileData:data name:name fileName:nameImage mimeType:@"image/jpeg"];
        
    } error:nil];
    request.timeoutInterval=10.0;
    
    NSLog(@"人脸匹配请求开始 ---- , %@",[NSDate date]);

    SeckenAFHTTPRequestOperation * afOperation = [[SeckenAFHTTPRequestOperation alloc] initWithRequest:request];
    [afOperation setCompletionBlockWithSuccess:^(SeckenAFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        if (requestTmp == nil) {
            fail(requestTmp);
        }
        NSLog(@"人脸匹配请求结束，并开始解析数据 ---- , %@",[NSDate date]);

        id dict = [self jsonObjectWithString:requestTmp];
        NSString * string = [SeckenParamsEncrypt decryptParams:dict];
        
        
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
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        
        NSLog(@"人脸匹配，解析数据完成 ---- , %@",[NSDate date]);

        //服务器返回的错误，然后提示。
        if ([[dicCode objectForKey:@"code"] intValue] != 200 && fail != nil) {
            fail(dicCode);
        }else if ([[dicCode objectForKey:@"code"] intValue] == 200 && success != nil) {
            success(dicCode);
        }
        
        
    } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
        
        NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];

        NSLog(@"人脸匹配，服务器返回失败或者超时 ---- , %@",[NSDate date]);
        
        if ([dicCode objectForKey:@"code"]) {
            fail(dicCode);
        }else if (fail != nil) {
            fail(dicCode);
        }
        
    }];
    [afOperation start];
}


-(void)voiceTrainUserName:(NSString *)strUserName
                    token:(NSString *)strToken
        voiceTrainSuccess:(void (^)(id))success
           voiceTrainFail:(void (^)(id))fail
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
                                  @"voice_id":_baseInfo.strVoice_id,
                                  @"region_id":_baseInfo.strReg_id,
                                  };
    NSString * strApi = [SeckenNetApi getNetworkPath:API_VOICE_TRAIN];
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
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        }else if ([[dicCode objectForKey:@"code"] intValue] == 200  && success != nil) {
            success(dicCode);
        }
        
    } failure:^(SeckenAFHTTPRequestOperation *operation, NSError *error) {
        
        NSDictionary * dictError = @{@"code": [NSString stringWithFormat:@"%li", (long)error.code]};
        NSDictionary * dicCode = [_baseInfo showStatusErrorCode:dictError];
        
        if ([dicCode objectForKey:@"code"]) {
            fail(dicCode);
        }else if (fail != nil) {
            fail(dicCode);
        }
        
        //SLog(@"error %@", error);
        
    }];
}



-(void)voiceDeleteUserName:(NSString *)strUserName
                     token:(NSString *)strToken
           voiceDelSuccess:(void (^)(id))success
              voiceDelFail:(void (^)(id))fail
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
    
    NSString * strApi = [SeckenNetApi getNetworkPath:API_VOICE_DELETE];
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
            if ([[_baseInfo getCurrentLanguage] isEqualToString:@"cn"]) {
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
        
        if ([dicCode objectForKey:@"code"]) {
            fail(dicCode);
        }else if (fail != nil) {
            fail(dicCode);
        }
        
        //SLog(@"error %@", error);
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




//BOOL ret = [self data:strData signature:signature appkey:_baseInfo.strAppKey]
-(BOOL)data:(NSString *)strData secret:(NSString *)secret appkey:(NSString *)appkey signature:(NSString *)signature{
    
    NSString * spellSign = [NSString stringWithFormat:@"%@%@%@", strData, secret, appkey];
    NSString * signSHA = [_baseInfo sha1String:spellSign];
    
    if ([signature isEqualToString:signSHA]) {
        return YES;
    }
    return NO;
}


-(void)delSaveLocal{
    
    
    [SecKenKeychain deletePasswordForService:kLocalPrivate account:kLocalPrivate];
    [SecKenKeychain deletePasswordForService:kPrivateRandom account:kPrivateRandom];
    [SecKenKeychain deletePasswordForService:kLocalPublic account:kLocalPublic];
    [SecKenKeychain deletePasswordForService:kPublicRandom account:kPublicRandom];
    [SecKenKeychain deletePasswordForService:kPublic account:kPublic];
    [SecKenKeychain deletePasswordForService:kLocalAuthID account:kLocalAuthID];
    [SecKenKeychain deletePasswordForService:kPUSH_ID account:kPUSH_ID];
    
    [[NSFileManager defaultManager] removeItemAtPath:
     [DocumentsDir stringByAppendingPathComponent:@"dataPB"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:
     [DocumentsDir stringByAppendingPathComponent:@"dataPV"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:
     [DocumentsDir stringByAppendingPathComponent:@"dataSPB"] error:nil];
    
    _baseInfo.strLocalPublicKey = @"";
    _baseInfo.strLocalPrivateKey = @"";
    
    
}



@end
