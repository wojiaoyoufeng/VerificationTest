//
//  Singleton.h
//  socket
//
//  Created by Secken_ck on 15/6/15.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import "SeckenAsyncSocket.h"
#import "SeckenGCDAsyncSocket.h"
#import <UIKit/UIKit.h>

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t onceToken = 0; \
__strong static id sharedInstance = nil; \
dispatch_once(&onceToken, ^{ \
sharedInstance = block(); \
}); \
return sharedInstance; \

enum{
    SocketOfflineByServer=0,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

@interface SeckenSingleton : NSObject<AsyncSocketDelegate>
{
        dispatch_source_t  _timer;
}

+ (SeckenSingleton *)sharedInstance;
-(void)socketConnectHost;       // socket连接
-(void)cutOffSocket;            // 断开socket连接
-(void)resultBlock:(void(^)(id operation))opera;

@property (atomic, copy)   void (^resultBlock)(id operation);
@property (nonatomic, assign) int count;
@property (nonatomic, strong) SeckenGCDAsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot
@property (nonatomic, copy) NSString * timestamp;
@property (nonatomic, assign)int timeoutCount;
@end
