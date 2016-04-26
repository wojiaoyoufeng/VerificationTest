//
//  Singleton.m
//  socket
//
//  Created by Secken_ck on 15/6/15.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import "SeckenSingleton.h"
#import "SeckenBaseInfo.h"
#import "SeckenSDK.h"

@implementation SeckenSingleton

+(SeckenSingleton *) sharedInstance
{
    
    static SeckenSingleton *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[self alloc] init];
    });
    return sharedInstace;
}
// socket连接
-(void)socketConnectHost{
    
    SeckenBaseInfo * _baseInfo =[SeckenBaseInfo sharedBaseInfo];
    
    if([SecKenKeychain passwordForService:kPUSH_ID account:kPUSH_ID].length == 0)
    {
        NSString * strUUID = [SecKenKeychain passwordForService:kUUID account:kUUID];
        NSString * string = [strUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
        _baseInfo.strPushID = [NSString stringWithFormat:@"I%@", string];
    }
    
    if (self.socket == nil) {
        self.socket = [[SeckenGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        self.socket.delegate=self;
        self.count=0;
        //_resultBlock = [self.resultBlock copy];
    }
    
    NSError *error = nil;
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:10 error:&error];
    //NSLog(@"socket  *******************连接error    %@",error);
}


-(void)resultBlock:(void (^)(id))opera{
    _resultBlock = [opera copy];

}

#pragma mark  - 连接成功回调
-(void)onSocket:(SeckenAsyncSocket *)sock didConnectToHost:(NSString  *)host port:(UInt16)port
{
    self.timeoutCount=0;
    [self longConnectToSocket];
    //NSLog(@"sockt.isConnected  --- %i",self.socket.isConnected);
}

// 切断socket
-(void)cutOffSocket{
    
    //NSLog(@"切断   socket");
    //NSLog(@"isConnected ----- %i",self.socket.isConnected);
    
    //self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
    //self.count=0;
    
    [self.socket disconnect];
}


- (void)onSocket:(SeckenAsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    //NSLog(@"socket----------------   %@",err);
}

-(void)onSocketDidDisconnect:(SeckenAsyncSocket *)sock
{
    //if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        self.count=0;
        NSLog(@" 服务器掉线，重连  服务器掉线，重连");
        
            //self.timeoutCount++;
    
            //if(self.timeoutCount>=6)
            //{
            //    self.timeoutCount=6;
            //}
            //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(socketConnectHost) userInfo:nil repeats:NO];
    [self performSelector:@selector(socketConnectHost) withObject:nil afterDelay:3];
    
    //}else if (sock.userData == SocketOfflineByUser) {
        // 如果由用户断开，不进行重连
        self.count = 0;
        
   // }
}


-(void)longConnectToSocket{
    
    SeckenBaseInfo * _baseInfo = [SeckenBaseInfo sharedBaseInfo];
    
    self.timestamp = [_baseInfo getTimesteamp];
    NSString * pushidMD5=[_baseInfo md5Tmp:_baseInfo.strPushID];
    NSString * hashStr=[_baseInfo md5Tmp:[NSString stringWithFormat:@"%@%@",pushidMD5,self.timestamp]];
    
    
    NSDictionary * dicTmp = @{@"version":@"sdk",
                              @"key": self.timestamp,
                              @"hash": hashStr,
                              @"device_type":@"ios",
                              @"push_id": _baseInfo.strPushID};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicTmp options:NSJSONWritingPrettyPrinted error:nil];
    [self.socket writeData:jsonData withTimeout:1 tag:1];
    
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    [self.socket readDataWithTimeout:-1 tag:0];
}


- (void)onSocket:(SeckenAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    self.count++;
    
    SeckenBaseInfo * _baseInfo = [SeckenBaseInfo sharedBaseInfo];
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSDictionary * dic=[LoginUserViewController dictionaryWithJsonString:message];
    NSData * jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    //NSLog(@"md5   str ---------------- %@",[ _baseInfo md5Tmp:[[ _baseInfo md5Tmp:[_baseInfo.strPushID stringByAppendingString:self.timestamp]] stringByAppendingString:[NSString stringWithFormat:@"%i",self.count]]]);
    
    if([[ _baseInfo md5Tmp:[[ _baseInfo md5Tmp:[ _baseInfo.strPushID stringByAppendingString:self.timestamp]] stringByAppendingString:[NSString stringWithFormat:@"%i",self.count]]] isEqualToString:[dic objectForKey:@"hash"]])
    {
        NSString * type=[NSString stringWithFormat:@"%@",[dic objectForKey:@"type"]];   
        if([type isEqualToString:@"1"])
        {
            //NSLog(@"开始去拉推送...........");
            //[GetPushProfession getPushInfoAndUpdateUI];
            //if (_resultBlock != nil) {
                _resultBlock(dic);
            //}
            
        }
    }
    else
    {
        //NSLog(@"长连接推送签名不对...........");
    }
    [self.socket readDataWithTimeout:-1 tag:0];
}





@end
