//
//  SeckenBaseInfo.h
//  CreateSDK
//
//  Created by Secken_ck on 15/9/14.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//
//该类可提供一些本机（包括用户）的数据，也进行一些简单的操作，可以理解成工具类。

#import <Foundation/Foundation.h>
#import "SeckenAppConst.h"

@interface SeckenBaseInfo : NSObject

@property (nonatomic, copy)NSString     * strUUID;                  // 设备唯一标识符
@property (nonatomic, copy)NSString     * strPushID;                // 注册推送获取到的pushToken
@property (nonatomic, copy)NSString     * strSystemVersion;         // 系统版本
@property (nonatomic, copy)NSString     * strDevice_type;           // 类型
@property (nonatomic, copy)NSString     * strDevice_OS;             // 系统
@property (nonatomic, copy)NSString     * strDevice_name;           // 手机名称
@property (nonatomic, copy)NSString     * strToken;

@property (nonatomic, copy)NSString     * strModel;                 // 手机型号
@property (nonatomic, copy)NSString     * strLocalizedLanguage;     // 国际化区域名称

@property (atomic, copy)NSString        * strPublicKey;                // 服务器给的公钥
@property (atomic, copy)NSString        * strLocalPrivateKey;       // 私钥
@property (atomic, copy)NSString        * strLocalPublicKey;        // 本地生成传给服务器的公钥
@property (atomic, copy)NSString        * strRandmStr;

@property (atomic, copy)NSString        * strAppID;
@property (atomic, copy)NSString        * strAppKey;
@property (atomic, copy)NSString        * strUserName;
@property (atomic, copy)NSString        * strReg_id;                 //服务器返回的科大讯飞的authID
@property (atomic, copy)NSString        * strVoice_id;               //服务器返回的authID
@property (atomic, copy)NSString        * strFaceID;                 //服务器返回的faceID

+ (SeckenBaseInfo *)sharedBaseInfo;
-(NSDictionary *)showStatusErrorCode:(NSDictionary *)dictData;      //通过服务器返回的dictData，显示错误码。


-(NSString *)md5Tmp:(NSString *)str;            //md5加密
-(NSString *)getTimesteamp;                     //获取时间搓
-(NSString *)getBitStringLength:(int)length;    //获取随机数
-(NSString *)getCurrentLanguage;                //当前语言
-(NSString *)sha1String:(NSString *)srcString;  //sha1加密

-(NSString *)deLocalPrivateKey;                 //解密本地的私有key
-(NSString *)deLocalPublicKey;                  //解密本地公有key
-(NSString *)deServerPublicKey;                 //解密服务器公有key

-(NSString *)enLocalString:(NSString *)string;      //string for local（打乱字符串）
-(NSString *)deLocalString:(NSString *)string;      //string for local（排好随机数）

@end
