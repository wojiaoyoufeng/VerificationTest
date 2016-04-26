//
//  VoiceConfirmSDK.h
//  CreateSDK
//
//  Created by Secken_ck on 15/9/25.
//  Copyright © 2015年 Secken_ck. All rights reserved.
//

#import "SeckenSDK.h"

@interface VoiceConfirmSDK : SeckenSDK

+(instancetype)currVoiceSDK;


-(void)updateBrickParamUserName:(NSString *)strUserName
                     paramToken:(NSString *)strToken
                  updateSuccess:(void (^)(id operation))success
                     updateFail:(void (^)(id operation))fail;

@end
