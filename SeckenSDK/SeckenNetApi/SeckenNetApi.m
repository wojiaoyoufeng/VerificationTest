//
//  SKNetworkApi.m
//  SeckenSDK
//
//  Created by Secken_ck on 15/9/9.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import "SeckenNetApi.h"

static SeckenNetApi * networkApi = nil;
@implementation SeckenNetApi

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+(NSString *)getNetworkPath:(ApiType)type{
 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkApi = [[SeckenNetApi alloc] init];
    });
    return [networkApi apiPath:type];
}


-(NSString *)apiPath:(ApiType)type{
    NSString * address = nil;
    switch (type) {
        case API_BIND:
            address = @"/user/bind";
            break;
        case API_UN_BIND:
            address = @"/user/unbind";
            break;
        case API_QR_AUTH:
            address = @"/user/authcode";
            break;
        case API_QR_CONFIRM:
            address = @"/user/confirm";
            break;
        case API_PULL:
            address = @"/user/pull";
            break;
        case API_GET_PUBLIC_KEY:
            address = @"/user/pubkey";
            break;
        case API_UPDATE_PUSH_ID:
            address = @"/user/update_pushid";
            break;
        case API_FACE_TRAIN:
            address = @"/face/train";
            break;
        case API_FACE_DELETE:
            address = @"/face/delete";
            break;
        case API_FACE_COMPARE:
            address = @"/face/compare";
            break;
        case API_VOICE_TRAIN:
            address = @"/voice/train";
            break;
        case API_VOICE_DELETE:
            address = @"/voice/delete";
            break;
        case API_QUERUY_BALANCE:
            address = @"/user/queryBalance";
            break;
        case API_UPDATE_BRICK:
            address = @"/user/updateBrick";
            break;
        default:
            address = @"";
            break;
    }
    return [BASE_API stringByAppendingString:address];
}
@end
