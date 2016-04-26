//
//  SeckenAppConst.h
//  CreateSDK
//
//  Created by Secken_ck on 15/9/14.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#ifndef CreateSDK_SeckenAppConst_h
#define CreateSDK_SeckenAppConst_h


#ifdef DEBUG
#define SLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define SLog(...)
#endif


#define kPrivateRandom      @"K_PRIVATE_RANDOM"
#define kPublicRandom       @"K_PUBLIC_RANDOM"


#define kSERVER_PUBLIC_AES_PASS             @"SECKEN_SERVER_PUBLIC_AES_PASS"
#define kUUID                               @"SECKEN_UUID"
#define kPUSH_ID                            @"SECKEN_PUSH_ID"
#define kLocalPrivate                       @"SECKEN_PRIVATE"
#define kPublic                             @"SECKEN_PUBLIC"
#define kLocalPublic                        @"SECKEN_kLOCAL_PUBLIC"
#define kLocalAuthID                        @"SECKEN_LOCAL_VOICE_AUTH_ID"

//#define hostSocket                          @"23.97.68.81"
#define hostSocket                          @"longline.yangcong.com"
#define portSocket                          19583


#define DocumentsDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define OpenSSLRSAKeyDir [DocumentsDir stringByAppendingPathComponent:@"openssl_rsa"]
#define OpenSSLRSAPrivateKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"bb11.privateKey.pem"]
#define OpenSSLRSAPublicKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"bb11.publicKey.pem"]




#define iflyMSC_APPID_VALUE         @"55375a99"
#define PWDT_NUM_CODE           3     //数字密码
#pragma  key of isv
#define  KEY_PTXT           @"ptxt"
#define  KEY_RGN            @"rgn"
#define  KEY_TSD            @"tsd"
#define  KEY_SUB            @"sub"
#define  KEY_PWDT           @"pwdt"
#define  KEY_TAIL           @"vad_speech_tail"
#define  KEY_AUTHID         @"auth_id"
#define  KEY_SST            @"sst"
#define  KEY_KEYTIMEOUT     @"key_speech_timeout"
#define  KEY_VADTIMEOUT     @"vad_timeout"

#define  TRAIN_SST          @"train"
#define  VERIFY_SST         @"verify"

#define  SUC_KEY           @"suc"
#define  RGN_KEY           @"rgn"
#define  DCS                @"dcs"
#define  SUCCESS            @"success"
#define  FAIL               @"fail"

#pragma mark del or query
#define  DEL                @"del"
#define  QUERY              @"que"


#import "SeckenBaseInfo.h"
#import "SeckenAFNetworking.h"
#import "SeckenOpenSSLRSAWrapper.h"
#import "SeckenBase64.h"
#import "SeckenCommonCrypto.h"
#import "SeckenRSA.h"
#import "SeckenAESCrypt.h"
#import "SecKenKeychain.h"
#import "SeckenNetApi.h"
#import "SeckenParamsEncrypt.h"
#import "IFlySpeechError.h"
#import "IFlyISVRecognizer.h"
#import "IFlyISVDelegate.h"
#import "IFlySetting.h"
#import "IFlySpeechUtility.h"

//#import <iflyMSC/IFlySpeechError.h>
//#import <iflyMSC/iFlyISVRecognizer.h>
//#import <iflyMSC/IFlyISVDelegate.h>
//#import <iflyMSC/IFlySetting.h>
//#import <iflyMSC/IFlySpeechUtility.h>

#endif
