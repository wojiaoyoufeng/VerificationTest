//
//  SeckenBase64.h
//  TestLib
//
//  Created by Secken_ck on 15/9/16.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeckenBase64 : NSObject

+ (NSData *)scBase64DataFromString:(NSString *)string;
+ (NSString *)scBase64StringFromData:(NSData *)data length:(NSUInteger)length;

@end
