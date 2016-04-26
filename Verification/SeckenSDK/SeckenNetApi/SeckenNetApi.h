//
//  SKNetworkApi.h
//  SeckenSDK
//
//  Created by Secken_ck on 15/9/9.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define BASE_API    @"http://172.1.33.236:8080"
//#define BASE_API    @"http://192.168.0.106:8080"
//#define BASE_API @"http://test-appapi.yangcong.com"
#define BASE_API @"https://appapi.sdk.yangcong.com"
//#define BASE_API @"https://stable-appapi1-sdk.yangcong.com"


typedef enum : NSUInteger {
    
    API_BIND,               //绑定
    API_UN_BIND,            //解除绑定
    API_QR_AUTH,            //二维码授权
    API_QR_CONFIRM,         //二维码验证
    API_PULL,               //拉取推送消息
    API_GET_PUBLIC_KEY,     //获取公用的key
    API_UPDATE_PUSH_ID,     //更新推送id
    API_FACE_TRAIN,         //人脸训练
    API_FACE_DELETE,        //删除人脸
    API_FACE_COMPARE,       //匹配人脸
    API_VOICE_TRAIN,        //声纹训练
    API_VOICE_DELETE,       //删除声音
    API_QUERUY_BALANCE,     //查询余额
    API_UPDATE_BRICK,       //扣费
} ApiType;

@interface SeckenNetApi : NSObject
+(NSString *)getNetworkPath:(ApiType)type;
@end
