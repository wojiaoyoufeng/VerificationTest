//
//  SeckenVoiceTrain.m
//  CreateSDK
//
//  Created by Secken_ck on 15/9/17.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SeckenVoiceTrain.h"
#import "SeckenAppConst.h"
#import "SeckenLocalized.h"
#import "SeckenBaseInfo.h"
#import "SeckenSDK.h"

@interface SeckenVoiceTrain () <IFlyISVDelegate>
{
    
    IFlyISVRecognizer      * isvRec;      //atention 声纹类的单例模式 atention
    int                    ivppwdt;       //atention  声纹密码类型参数
    NSArray                * _codeArray;
    
    
    UILabel                * _numberLab;
    UILabel                * _descNumLab;
    NSString               * _auth_id;
    
    UIImageView            * _imgVoice;
    UIImageView            * _imgTip;
    
    void (^copyResultBlock)(id opera);

}
@property (nonatomic, strong)   UIButton    * voiceBtn;
@end

@implementation SeckenVoiceTrain

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
    
        self.backgroundColor = [UIColor colorWithRed:60/255.0 green:143/255.0 blue:218/255.0 alpha:1];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 60,
                                     24,
                                     120,
                                     30);
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor whiteColor];
        if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
            _titleLab.text = VOICE_CONFIRM_TITLE_SECKEN_CN;
        }else{
            _titleLab.text = VOICE_CONFIRM_TITLE_SECKEN_EN;
        }
        [self addSubview:_titleLab];
        
        
        _numberLab = [[UILabel alloc] init];
        _numberLab.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100,
                                      _titleLab.frame.origin.y + _titleLab.frame.size.height + 50,
                                      200,
                                      50);
        _numberLab.backgroundColor = [UIColor whiteColor];
        _numberLab.textColor = [UIColor blueColor];
        _numberLab.textAlignment = NSTextAlignmentCenter;
        _numberLab.layer.masksToBounds = YES;
        _numberLab.layer.cornerRadius = 15;
        _numberLab.font = [UIFont systemFontOfSize:23];
        if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
            _numberLab.text = VOICE_CONFIRM_TIP_LOAD_SECKEN_CN;
        }else{
            _numberLab.text = VOICE_CONFIRM_TIP_LOAD_SECKEN_EN;
        }
        [self addSubview:_numberLab];
        
        
        _descNumLab = [[UILabel alloc] init];
        _descNumLab.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 150,
                                       _numberLab.frame.origin.y + _numberLab.frame.size.height + 15,
                                       300,
                                       30);
        _descNumLab.textAlignment = NSTextAlignmentCenter;
        _descNumLab.backgroundColor = [UIColor clearColor];
        _descNumLab.textColor = [UIColor whiteColor];
        _descNumLab.font = [UIFont systemFontOfSize:12];
        if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
            _descNumLab.text = VOICE_CONFIRM_TIP_READ_NUM_SECKEN_CN;
        }else{
            _descNumLab.text = VOICE_CONFIRM_TIP_READ_NUM_SECKEN_EN;
        }
        [self addSubview:_descNumLab];
        
        
        
        //NSString * path = [[NSBundle mainBundle] pathForResource:@"SeckenSDK" ofType:@"framework"];
        NSString *path = [[NSBundle mainBundle] resourcePath];

        _imgTip = [[UIImageView alloc] init];
        if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
            //_imgTip.image = [UIImage imageNamed:@"SeckenSDK.framework/btn_tip"];
            _imgTip.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"SeckenImage.bundle/btn_tip"]];
        }else{
            //_imgTip.image = [UIImage imageNamed:@"SeckenSDK.framework/btn_tip_en"];
            _imgTip.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"SeckenImage.bundle/btn_tip_en"]];
        }
        _imgTip.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 40,
                                   [UIScreen mainScreen].bounds.size.height - 215,
                                   80,
                                   40);
        [self addSubview:_imgTip];
        [self bringSubviewToFront:_imgTip];
        
        
        
        _imgVoice = [[UIImageView alloc] init];
        _imgVoice.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 35,
                                     [UIScreen mainScreen].bounds.size.height - 155,
                                     70,
                                     70);
        //_imgVoice.image =  [UIImage imageNamed:@"SeckenSDK.framework/btn_hold_one"];
        _imgVoice.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"SeckenImage.bundle/btn_hold_one"]];
        _imgVoice.userInteractionEnabled = YES;
        
        /*
         _imgVoice.animationImages = [NSArray arrayWithObjects:
         [UIImage imageNamed:@"SeckenSDK.framework/btn_hold_one"],
         [UIImage imageNamed:@"SeckenSDK.framework/btn_hold_two"],
         [UIImage imageNamed:@"SeckenSDK.framework/btn_hold_thr"],
         nil];
         */
        
        _imgVoice.animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"SeckenImage.bundle/btn_hold_one"]],
                                    [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"SeckenImage.bundle/btn_hold_two"]],
                                    [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"SeckenImage.bundle/btn_hold_thr"]],
                                    nil];
        
        _imgVoice.animationDuration = 0.7;
        [self addSubview:_imgVoice];
        
        
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 30,
                                     [UIScreen mainScreen].bounds.size.height - 150,
                                     60,
                                     60);
        //UIImage * micImage =  [UIImage imageNamed:@"SeckenSDK.framework/btn_mic"];
        UIImage * micImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"SeckenImage.bundle/btn_mic"]];
        [_voiceBtn setImage:micImage forState:UIControlStateNormal];
        
        
        //UIImage * selMicImage =  [UIImage imageNamed:@"SeckenSDK.framework/btn_mic_sel"];
        UIImage * selMicImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"SeckenImage.bundle/btn_mic_sel"]];
        [_voiceBtn setImage:selMicImage forState:UIControlStateSelected];
        [self addSubview:_voiceBtn];
        
        UILongPressGestureRecognizer * pan=[[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                        action:@selector(longGes:)];
        pan.minimumPressDuration=0.2;
        [_voiceBtn addGestureRecognizer:pan];
        
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(20,
                                      [UIScreen mainScreen].bounds.size.height - 50,
                                      [UIScreen mainScreen].bounds.size.width - 40,
                                      40);
        [_cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _cancelBtn.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:253/255.0 alpha:1];
        if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
            [_cancelBtn setTitle:CANCEL_SECKEN_CN forState:UIControlStateNormal];
        }else{
            [_cancelBtn setTitle:CANCEL_SECKEN_EN forState:UIControlStateNormal];
        }
        [self addSubview:_cancelBtn];
        
        
        
        
        [IFlySetting setLogFile:LVL_ALL];
        
        //输出在console的log开关
        [IFlySetting showLogcat:YES];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        //设置msc.log的保存路径
        [IFlySetting setLogFilePath:cachePath];
        
        NSString *initString = [[NSString alloc] initWithFormat:@"server_url=http://isv.openspeech.cn/index.htm,appid=%@",iflyMSC_APPID_VALUE];

        [IFlySpeechUtility createUtility:initString];

        
        isvRec=[IFlyISVRecognizer sharedInstance];  // 创建声纹对象 attention isv
        ivppwdt = PWDT_NUM_CODE;
        isvRec.delegate=self;
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getCodeArray];
        });
        
    }
    return self;
}



#pragma mark 下载密码
-(NSArray*)downloadPassworld:(int)pwdtParam
{
    NSArray* tmpArray=[isvRec getPasswordList:pwdtParam];  // attention isv +++
    if( tmpArray == nil ){
        //NSLog(@"in %s,请求数据有误",__func__);
        return nil;
    }
    //NSLog(@"数组，数组，  %@",tmpArray);
    return tmpArray;   //返回下载
}


#pragma mark 获取数字密码
-(void)getCodeArray
{
    
    [isvRec cancel];
    _codeArray = [NSArray arrayWithArray:[self downloadPassworld:ivppwdt]];

    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if( _codeArray.count == 0 ){
            return;
        }
        
        _numberLab.text=[NSString stringWithFormat:@"%@ %@ %@ %@   %@ %@ %@ %@",
                            [_codeArray[0] substringWithRange:NSMakeRange(0, 1)],
                            [_codeArray[0] substringWithRange:NSMakeRange(1, 1)],
                            [_codeArray[0] substringWithRange:NSMakeRange(2, 1)],
                            [_codeArray[0] substringWithRange:NSMakeRange(3, 1)],
                            [_codeArray[0] substringWithRange:NSMakeRange(4, 1)],
                            [_codeArray[0] substringWithRange:NSMakeRange(5, 1)],
                            [_codeArray[0] substringWithRange:NSMakeRange(6, 1)],
                            [_codeArray[0] substringWithRange:NSMakeRange(7, 1)]];
        [isvRec setParameter:TRAIN_SST forKey:KEY_SST];  //  attention isv ++++++++++++++++
    });
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%i", (int)a];//转为字符型
    _auth_id = [NSString stringWithFormat:@"yc%@%@", timeString, [self getBitStringLength:6]];
    [self trainOrVerifyNumCode:TRAIN_SST];
    
}



#pragma mark  获取随机数
-(NSString *)getBitStringLength:(int)length
{
    char data[length];
    for (int x = 0; x < length; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}



#pragma mark 训练或者验证 数字密码
-(void)trainOrVerifyNumCode:(NSString *)sst
{
    if( [sst isEqualToString:TRAIN_SST] ){
        if( _codeArray!=nil && _codeArray.count > 0 ){
            NSString *ptString=[self numArrayToString:_codeArray];
            [self defaultSetparam:_auth_id withpdwt: PWDT_NUM_CODE withptxt:ptString trainorverify:TRAIN_SST];
        }
    }
}

#pragma mark 数字密码 把array里面的数字 串起来,ISV 固定规则
-(NSString*)numArrayToString:(NSArray *)numArrayParam
{
    if( numArrayParam == nil ){
        //NSLog(@"在%s中，numArrayParam is nil",__func__);
        return nil;
    }
    
    NSMutableString *ptxtString = [NSMutableString stringWithCapacity:1];
    [ptxtString appendString:[numArrayParam objectAtIndex:0]];
    
    for (int i = 1;i < 3 ; i++ ){
        NSString *str = [numArrayParam objectAtIndex:i];
        [ptxtString appendString:[NSString stringWithFormat:@"-%@",str]];
        
    }
    return  ptxtString;
}


#pragma mark 声纹默认参数设置
- (void)defaultSetparam:(NSString *)auth_id1 withpdwt:(int) pwdt withptxt:(NSString *) ptxt trainorverify:(NSString*)sst
{
    if( isvRec != nil ){
        [isvRec setParameter:@"ivp" forKey:KEY_SUB];
        [isvRec setParameter:[NSString stringWithFormat:@"%d",pwdt] forKey:KEY_PWDT];
        [isvRec setParameter:@"50" forKey:KEY_TSD];
        [isvRec setParameter:@"3000" forKey:KEY_VADTIMEOUT];
        [isvRec setParameter:@"700" forKey:KEY_TAIL];
        [isvRec setParameter:ptxt forKey:KEY_PTXT];
        [isvRec setParameter:_auth_id forKey:KEY_AUTHID];
        [isvRec setParameter:sst forKey:KEY_SST];            /* train or test */
        [isvRec setParameter:@"180000" forKey:KEY_KEYTIMEOUT];
        if(pwdt == PWDT_NUM_CODE){
            [isvRec setParameter:@"3" forKey:KEY_RGN];
        }else{
            [isvRec setParameter:@"1" forKey:KEY_RGN];
        }
    }else{
        //NSLog(@"isvRec is nil\n");
    }
}




#pragma mark 麦克风的长按方法
-(void)longGes:(UILongPressGestureRecognizer *)pan
{
    if(pan.state==UIGestureRecognizerStateBegan)
    {
        _imgVoice.frame = CGRectMake(_imgVoice.frame.origin.x - 15,
                                     _imgVoice.frame.origin.y - 15,
                                     100,
                                     100);
        [_imgVoice startAnimating];
        _imgTip.hidden = YES;
        [isvRec startListening];                //开始录音
    }
    if(pan.state==UIGestureRecognizerStateEnded)
    {
        _imgVoice.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 35,
                                     [UIScreen mainScreen].bounds.size.height - 155,
                                     70,
                                     70);
        [_imgVoice stopAnimating];
        _imgTip.hidden = NO;
        [isvRec stopListening];                 //停止录音
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
    }
}




#pragma  mark 正常结果返回回调
-(void)onResult:(NSDictionary *)dic
{
    [isvRec stopListening];//停止录音
    [self resultProcess:dic];
    
}


#pragma  mark 对声纹回调结果进行处理
-(void)resultProcess:(NSDictionary *)dic
{
    
    if ([[dic objectForKey:@"err"] intValue] != 0) {
        
        NSDictionary * resultDict = nil;
        
        NSString * err = [NSString stringWithFormat:@"%@", [dic objectForKey:@"err"]];
        if ([err isEqualToString:@"11600"]) {
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if ([err isEqualToString:@"11601"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if ([err isEqualToString:@"11602"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if ([err isEqualToString:@"11603"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if ([err isEqualToString:@"11604"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if ([err isEqualToString:@"11605"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if ([err isEqualToString:@"11606"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if ([err isEqualToString:@"11607"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if ([err isEqualToString:@"11608"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
            
        }else if([err isEqualToString:@"11610"]){
            resultDict = @{@"msg":@"原因如下：音频太短太小、太多噪音、音频内容与给定文本不一致(Audio is too short is too small, too much noise, audio content do not agree with the given text)",@"error":@"0"};
        }
        if (self.resultBlock) {
            self.resultBlock(resultDict);
        }
        return;
        
    }

    
    
    UIAlertView * alert = nil;
    
    if( [[dic objectForKey:@"dcs"] isEqualToString:@"success"] && [[dic objectForKey:@"score"] floatValue] >=64.){
        
        if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
            alert=[[UIAlertView alloc]initWithTitle:VOICE_CONFIRM_VOICE_ERROR_CN
                                            message:VOICE_CONFIRM_VOICE_ERROR_DESC_CN
                                           delegate:self
                                  cancelButtonTitle:VOICE_GO_ON_CN
                                  otherButtonTitles:nil, nil];
        }else {
            alert=[[UIAlertView alloc]initWithTitle:VOICE_CONFIRM_VOICE_ERROR_EN
                                            message:VOICE_CONFIRM_VOICE_ERROR_DESC_EN
                                           delegate:self
                                  cancelButtonTitle:VOICE_GO_ON_EN
                                  otherButtonTitles:nil, nil];
        }
        [alert show];
        
        return;

        
    }else{
        
        if([[dic objectForKey:@"err"] intValue] !=0 ){
            
            if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
                alert=[[UIAlertView alloc]initWithTitle:VOICE_CONFIRM_VOICE_ERROR_CN
                                                message:VOICE_CONFIRM_VOICE_ERROR_DESC_CN
                                               delegate:self
                                      cancelButtonTitle:VOICE_GO_ON_CN
                                      otherButtonTitles:nil, nil];
            }else {
                alert=[[UIAlertView alloc]initWithTitle:VOICE_CONFIRM_VOICE_ERROR_EN
                                                message:VOICE_CONFIRM_VOICE_ERROR_DESC_EN
                                               delegate:self
                                      cancelButtonTitle:VOICE_GO_ON_EN
                                      otherButtonTitles:nil, nil];
            }
            [alert show];

            return;
        }
        
        NSNumber *suc=[dic objectForKey:SUC_KEY] ;
        NSNumber *rgn=[dic objectForKey:RGN_KEY];
        
        if( [suc intValue] >= [rgn intValue] ){
            
            [isvRec cancel];
            isvRec=nil;
            [self requestVoiceInfo:dic];
            
        }else if([suc intValue]==1){
            
            if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
            
                alert=[[UIAlertView alloc]initWithTitle:VOICE_TRAIN_ONE_CN
                                                message:VOICE_TRAIN_ONE_DESC_CN
                                               delegate:self
                                      cancelButtonTitle:VOICE_GO_ON_CN
                                      otherButtonTitles:nil, nil];
            }else{
                alert=[[UIAlertView alloc]initWithTitle:VOICE_TRAIN_ONE_EN
                                                message:VOICE_TRAIN_ONE_DESC_EN
                                               delegate:self
                                      cancelButtonTitle:VOICE_GO_ON_CN
                                      otherButtonTitles:nil, nil];
                
            }

            [alert show];
            _numberLab.text=[NSString stringWithFormat:@"%@ %@ %@ %@   %@ %@ %@ %@",
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(0, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(1, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(2, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(3, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(4, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(5, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(6, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(7, 1)]];
            
        }else if([suc intValue]==2){
            
            if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
                alert=[[UIAlertView alloc]initWithTitle:VOICE_TRAIN_TWO_CN
                                                message:VOICE_TRAIN_TWO_DESC_CN
                                               delegate:self
                                      cancelButtonTitle:VOICE_GO_ON_CN
                                      otherButtonTitles:nil, nil];
                
            }else{
                alert=[[UIAlertView alloc]initWithTitle:VOICE_TRAIN_TWO_EN
                                                message:VOICE_TRAIN_TWO_DESC_EN
                                               delegate:self
                                      cancelButtonTitle:VOICE_GO_ON_CN
                                      otherButtonTitles:nil, nil];
                
            }
            [alert show];
            _numberLab.text=[NSString stringWithFormat:@"%@ %@ %@ %@   %@ %@ %@ %@",
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(0, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(1, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(2, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(3, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(4, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(5, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(6, 1)],
                             [_codeArray[[suc intValue]] substringWithRange:NSMakeRange(7, 1)]];
            
        }
    }
}




#pragma  mark 发生错误
-(void)onError:(IFlySpeechError *)errorCode
{
    __block UIAlertView * alert = nil;
    _imgVoice.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 35,
                                 [UIScreen mainScreen].bounds.size.height - 155,
                                 70,
                                 70);
    [_imgVoice stopAnimating];
    [isvRec stopListening];//停止录音
    if( errorCode.errorCode != 0 ){ //处理错误
        if(errorCode.errorCode==10118)
        {
            if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
                [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                    
                    if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
                        
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                alert = [[UIAlertView alloc]initWithTitle:nil
                                                                  message:VOICE_CONFIRM_TIP_TIME_SHORT_CN
                                                                 delegate:self
                                                        cancelButtonTitle:VOICE_CONFIRM_TIP_AGAIN_CN
                                                        otherButtonTitles:nil, nil];
                                [alert show];
                                
                            });
                        }else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                alert = [[UIAlertView alloc]initWithTitle:VOICE_CONFIRM_MIC_PERMISSIONS_CN
                                                                  message:VOICE_CONFIRM_SET_MIC_CN
                                                                 delegate:self
                                                        cancelButtonTitle:VOICE_CONFIRM_TIP_AGAIN_CN
                                                        otherButtonTitles:nil, nil];
                                [alert show];
                            });
                        }
                        
                    }else{
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                alert = [[UIAlertView alloc]initWithTitle:nil
                                                                  message:VOICE_CONFIRM_TIP_TIME_SHORT_EN
                                                                 delegate:self
                                                        cancelButtonTitle:VOICE_CONFIRM_TIP_AGAIN_EN
                                                        otherButtonTitles:nil, nil];
                                [alert show];
                                
                            });
                        }else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                alert = [[UIAlertView alloc]initWithTitle:VOICE_CONFIRM_MIC_PERMISSIONS_EN
                                                                  message:VOICE_CONFIRM_SET_MIC_EN
                                                                 delegate:self
                                                        cancelButtonTitle:VOICE_CONFIRM_TIP_AGAIN_CN
                                                        otherButtonTitles:nil, nil];
                                [alert show];
                            });
                        }
                    
                    }

                }];
            }
            
        }
        else
        {
            if ([[[SeckenBaseInfo sharedBaseInfo] getCurrentLanguage] isEqualToString:@"cn"]) {
                
                alert=[[UIAlertView alloc]initWithTitle:VOICE_CONFIRM_VOICE_ERROR_CN
                                                message:VOICE_CONFIRM_VOICE_ERROR_DESC_CN
                                               delegate:self
                                      cancelButtonTitle:VOICE_CONFIRM_TIP_AGAIN_CN
                                      otherButtonTitles:nil, nil];
                [alert show];
                
            }else{
                
                alert=[[UIAlertView alloc]initWithTitle:VOICE_CONFIRM_VOICE_ERROR_EN
                                                message:VOICE_CONFIRM_VOICE_ERROR_DESC_EN
                                               delegate:self
                                      cancelButtonTitle:VOICE_CONFIRM_TIP_AGAIN_EN
                                      otherButtonTitles:nil, nil];
                [alert show];
                
            }

        }
    }
}

#pragma  mark 音量回调
-(void)onVolumeChanged:(int)volume
{
    /*
     int index=(volume+1)/8;
     if( index == 0 ){
     [self animationSmallAndBig:30];
     }else if( index == 1 ){
     [self animationSmallAndBig:20];
     }else if( index == 2 ){
     [self animationSmallAndBig:10];
     }else if( index == 3 ){
     [self animationSmallAndBig:0];
     }
     */
}


#pragma  mark 识别中回调
-(void)onRecognition
{
    //NSLog(@"正在识别中");
}


//数字密码查询或者删除
-(BOOL)startRequestNumCode:(NSString *)queryMode
{
    if( ![queryMode isEqualToString: QUERY] && ![queryMode isEqualToString:DEL] ){
        //NSLog(@"in %s,queryMode 参数错误",__func__);
        return NO;
    }
    int err;
    BOOL ret = [isvRec sendRequest:queryMode authid:_auth_id pwdt:PWDT_NUM_CODE ptxt:nil vid:nil err:&err];
    return ret;
}


//-(void)resultBlock:(void (^)(id))opera{
//
//    copyResultBlock = [opera copy];
//    
//}


#pragma mark 请求接口
-(void)requestVoiceInfo:(NSDictionary *)dict{

    //通过随机数加密auth ID
    if ([SecKenKeychain passwordForService:kLocalAuthID account:kLocalAuthID]) {
        [SecKenKeychain deletePasswordForService:kLocalAuthID account:kLocalAuthID];
    }

    NSString * strAes = [SeckenAESCrypt encrypt:_auth_id password:kLocalAuthID];
    [SecKenKeychain setPassword:strAes forService:kLocalAuthID account:kLocalAuthID];
    
    [SeckenBaseInfo sharedBaseInfo].strVoice_id  = [dict objectForKey:@"vid"];
    [SeckenBaseInfo sharedBaseInfo].strReg_id = _auth_id;

    NSDictionary * resultDict = nil;

    if ([SeckenBaseInfo sharedBaseInfo].strVoice_id.length != 0 &&
        [SeckenBaseInfo sharedBaseInfo].strReg_id.length != 0){
        
        if (self.resultBlock) {
            resultDict = @{@"hasVoice":@"1", @"hasRegID": @"1", @"suc":@"3"};
            self.resultBlock(resultDict);
        }
    }else{
        
        if (self.resultBlock) {
            resultDict = @{@"hasVoice":@"0", @"hasRegID": @"0", @"suc":@"3"};
            self.resultBlock(resultDict);
        }
    }
    
    


    
    

}


@end
