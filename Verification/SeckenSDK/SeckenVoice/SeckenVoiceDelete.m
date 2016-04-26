//
//  SeckenVoiceDelete.m
//  CreateSDK
//
//  Created by Secken_ck on 15/9/19.
//  Copyright © 2015年 Secken_ck. All rights reserved.
//

#import "SeckenVoiceDelete.h"
#import "SeckenAppConst.h"
#import "SeckenLocalized.h"


@interface SeckenVoiceDelete ()
{
    
    IFlyISVRecognizer      * isvRec;      //atention 声纹类的单例模式 atention
    int                    ivppwdt;       //atention  声纹密码类型参数
    NSString               * _auth_id;

    void (^copySuccessBlock)(id opera);
    void (^copyFailBlock)(id opera);
    

}
@end

@implementation SeckenVoiceDelete




- (instancetype)initAndVoiceDelSuccessBlock:(void (^)(id))success delFailBlock:(void (^)(id))fail
{
    self = [super init];
    if (self) {
        
        
        copySuccessBlock = [success copy];
        copyFailBlock = [fail copy];
        
        NSString * strAes = [SecKenKeychain passwordForService:kLocalAuthID account:kLocalAuthID];
        _auth_id = [SeckenAESCrypt decrypt:strAes password:kLocalAuthID];
        
        if (_auth_id == nil || _auth_id.length == 0) {
            _auth_id = [SeckenBaseInfo sharedBaseInfo].strReg_id;
        }
        
        if (_auth_id != nil || _auth_id.length != 0) {
            
            [IFlySetting setLogFile:LVL_ALL];
            
            //输出在console的log开关
            [IFlySetting showLogcat:NO];
            //NSLog(@"使用didfinishlaunching    xxnxxnxxxnxxxxxxxxxxxxxxxxxxnnnnxxxxxxxxnnnnn");
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachePath = [paths objectAtIndex:0];
            //设置msc.log的保存路径
            [IFlySetting setLogFilePath:cachePath];
            
            NSString *initString = [NSString stringWithFormat:
                                    @"server_url=http://isv.openspeech.cn/index.htm,appid=%@",iflyMSC_APPID_VALUE];
            [IFlySpeechUtility createUtility:initString];
            
            
            isvRec=[IFlyISVRecognizer sharedInstance];  // 创建声纹对象 attention isv
            ivppwdt = PWDT_NUM_CODE;
            
            [self startRequestNumCode:DEL];
            [SecKenKeychain deletePasswordForService:kLocalAuthID account:kLocalAuthID];

            
        }else{
            if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
                [self showAlertTitle:ALTER_TIP_SECKEN_CN
                                 msg:VOICE_CONFIRM_TIP_TRAIN_SECKEN_CN
                              cancel:nil
                             comfirm:CONFIRM_SECKEN_CN
                                 tag:0];
            }else{
                [self showAlertTitle:ALTER_TIP_SECKEN_EN
                                 msg:VOICE_CONFIRM_TIP_TRAIN_SECKEN_EN
                              cancel:nil
                             comfirm:CONFIRM_SECKEN_EN
                                 tag:0];
            }
        }

    }
    return self;
}


-(void)showAlertTitle:(NSString *)title msg:(NSString *)msg cancel:(NSString *)cancel comfirm:(NSString *)comfirm tag:(int)tag{
    
    UIAlertView * al = [[UIAlertView alloc] initWithTitle:title
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:cancel
                                        otherButtonTitles:comfirm, nil];
    if (tag != 0) {
        al.tag = tag;
    }
    [al show];
}

//数字密码查询或者删除
-(void)startRequestNumCode:(NSString *)queryMode
{
    if( ![queryMode isEqualToString: QUERY] && ![queryMode isEqualToString:DEL] ){
        //NSLog(@"in %s,queryMode 参数错误",__func__);
        return;
    }
    int err;
    BOOL ret=[isvRec sendRequest:queryMode authid:_auth_id pwdt:PWDT_NUM_CODE ptxt:nil vid:nil err:&err];  // attention isv +++
    
    UIAlertView * al = nil;

    if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
        if (ret) {
            al = [[UIAlertView alloc] initWithTitle:ALTER_TIP_SECKEN_CN
                                            message:VOICE_DELETE_CN
                                           delegate:nil
                                  cancelButtonTitle:CONFIRM_SECKEN_CN
                                  otherButtonTitles:nil, nil];
            [al show];
            NSDictionary * resultDict = @{@"ret":@"0",@"msg":VOICE_DELETE_CN};
            if (copySuccessBlock != nil) {
                copySuccessBlock(resultDict);
            }
            
        }else{
            al = [[UIAlertView alloc] initWithTitle:ALTER_TIP_SECKEN_CN
                                            message:VOICE_DELETE_FAIL_CN
                                           delegate:nil
                                  cancelButtonTitle:CONFIRM_SECKEN_CN
                                  otherButtonTitles:nil, nil];
            [al show];
            NSDictionary * resultDict = @{@"ret":@"",@"msg":VOICE_DELETE_FAIL_CN};
            if (copyFailBlock != nil) {
                copyFailBlock(resultDict);
            }
        }

    
    }else{
    
        if (ret) {
            al = [[UIAlertView alloc] initWithTitle:ALTER_TIP_SECKEN_EN
                                            message:VOICE_DELETE_EN
                                           delegate:nil
                                  cancelButtonTitle:CONFIRM_SECKEN_EN
                                  otherButtonTitles:nil, nil];
            [al show];
            NSDictionary * resultDict = @{@"ret":@"0",@"msg":VOICE_DELETE_EN};
            if (copySuccessBlock != nil) {
                copySuccessBlock(resultDict);
            }
            
        }else{
            al = [[UIAlertView alloc] initWithTitle:ALTER_TIP_SECKEN_EN
                                            message:ALTER_TIP_SECKEN_EN
                                           delegate:nil
                                  cancelButtonTitle:CONFIRM_SECKEN_EN
                                  otherButtonTitles:nil, nil];
            [al show];
            NSDictionary * resultDict = @{@"ret":@"",@"msg":VOICE_DELETE_FAIL_EN};
            if (copyFailBlock != nil) {
                copyFailBlock(resultDict);
            }
        }

    }
    
   
}


@end
