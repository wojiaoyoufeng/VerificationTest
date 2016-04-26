//
//  JSRSA.m
//  RSA Example
//
//  Created by Js on 12/23/14.
//  Copyright (c) 2014 JS Lim. All rights reserved.
//

#include "secken_rsa.h"
#import "SeckenRSA.h"

#define DocumentsDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define OpenSSLRSAKeyDir [DocumentsDir stringByAppendingPathComponent:@"openssl_rsa"]
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define OpenSSLRSAPrivateKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"bb11.privateKey.pem"]
#define OpenSSLRSAPublicKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"bb11.publicKey.pem"]


@implementation SeckenRSA

#pragma mark - helper
- (NSString *)publicKeyPath
{
    if (_publicKey == nil || [_publicKey isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[_publicKey componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
        
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    return keyPath;
}

- (NSString *)privateKeyPath
{
    if (_privateKey == nil || [_privateKey isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[_privateKey componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
        
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    return keyPath;
}

#pragma mark - implementation
- (NSString *)publicEncrypt:(NSString *)plainText
{
//    NSString *keyPath = [self publicKeyPath];
    

    
    NSString *keyPath = _publicKey;
    if (keyPath == nil) return nil;
        
    char *cipherText = secken_public_encrypt([plainText UTF8String], [keyPath UTF8String]);
    
    NSString *resultStr = [NSString stringWithFormat:@"%s",cipherText];
    free(cipherText);
//    NSArray *array = [resultStr componentsSeparatedByString:@"="]; //从字符A中分隔成2个元素的数组
//    NSLog(@"截取的值为：%@",array);
//    NSString *Str;
//    NSRange range = [resultStr rangeOfString:@"="];
//
//    if (range.length<=0) {
//        Str = resultStr;
//    }else{
//        NSArray *array = [resultStr componentsSeparatedByString:@"="]; //从字符A中分隔成2个元素的数组
//        NSLog(@"截取的值为：%@",array);
//        
//        if (array.count == 2) {
//            Str = array[0];
//            Str = [Str stringByAppendingString:@"="];
//            
//        }
//        if (array.count == 3) {
//            NSString *secondStr = array[1];
//            if ([secondStr isEqualToString:@""]) {
//                Str = array[0];
//                Str = [Str stringByAppendingString:@"=="];
//            }else{
//                Str = array[0];
//                Str = [Str stringByAppendingString:@"="];
//            }
//        }
//    }
//     NSLog(@"result == %@",Str);
    
    return resultStr;
}

- (NSString *)privateDecrypt:(NSString *)cipherText
{
//    NSString *keyPath = [self privateKeyPath];
    NSString *keyPath = _privateKey;
    if (keyPath == nil) return nil;
    
    char *plainText = secken_private_decrypt([cipherText UTF8String], [keyPath UTF8String]);
    if (!plainText) {
        return nil;
    }
    long len = strlen(plainText);
    char *plain = malloc(len + 1);
    memcpy(plain, plainText, len + 1);
    //NSLog(@"result = %@",[NSString stringWithFormat:@"%s",plain]);
    free(plain);
    NSString * temp=[NSString stringWithUTF8String:plainText];
    free(plainText);
    return temp;
}

- (NSString *)privateEncrypt:(NSString *)plainText
{
    NSString *keyPath = [self privateKeyPath];
    if (keyPath == nil) return nil;
        
    char *cipherText = secken_private_encrypt([plainText UTF8String], [keyPath UTF8String]);
    
    return [NSString stringWithUTF8String:cipherText];
}

- (NSString *)publicDecrypt:(NSString *)cipherText
{
    NSString *keyPath = [self publicKeyPath];
    if (keyPath == nil) return nil;
    
    char *plainText = secken_public_decrypt([cipherText UTF8String], [keyPath UTF8String]);
    
    return [NSString stringWithUTF8String:plainText];
}

#pragma mark 生成密钥对
- (BOOL)generateRSAKeyPairWithKeySize:(int)keySize
{
    
    NSString *publicKeyPath = _publicKey;
    //NSLog(@"publickey = %@",publicKeyPath);
    NSString *privateKeyPath = _privateKey;
    //NSLog(@"privatekey = %@",privateKeyPath);

    if (publicKeyPath== nil || privateKeyPath == nil) {
        return NO;
    }
//    int result = js_generate_KeyPair(1024, [publicKeyPath UTF8String], [privateKeyPath UTF8String]);
    int result = secken_generate_key([publicKeyPath UTF8String], [privateKeyPath UTF8String]);
//    int result = js_generate_KeyPair(1024, [publicKeyPath UTF8String], [privateKeyPath UTF8String]);
    
    if (result ==1) {
        return YES;
    }
    return NO;
}


#pragma mark - instance method
+ (SeckenRSA *)sharedInstance
{
    static SeckenRSA *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

#pragma mark 返回公钥路径
- (NSString *)returnPublicKeyPath:(NSString *)publicKey
{
    
    // mkdir for key dir
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:OpenSSLRSAKeyDir])
    {
        //[fm removeItemAtPath:OpenSSLRSAKeyDir error:nil];
        [fm createDirectoryAtPath:OpenSSLRSAKeyDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //格式化公钥
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    int count = 0;
    for (int i = 0; i < [publicKey length]; ++i) {
        
        unichar c = [publicKey characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == 64) {
            [result appendString:@"\n"];
            count = 0;
        }
    }
    [result appendString:@"\n-----END PUBLIC KEY-----"];
    
    NSError * error = [[NSError alloc] init];
    [result writeToFile:OpenSSLRSAPublicKeyFile
             atomically:YES
               encoding:NSASCIIStringEncoding
                  error:&error];
    
    const char *publicKeyFileName = [OpenSSLRSAPublicKeyFile cStringUsingEncoding:NSASCIIStringEncoding];
    NSString *Str = [NSString stringWithFormat:@"%s",publicKeyFileName];
     //NSLog(@"路径 = %@",result);
    return Str;
}

#pragma mark 返回私钥路径
- (NSString *)returnPrivateKeyPath:(NSString *)privateKey
{
    
    // mkdir for key dir
//    NSFileManager *fm = [NSFileManager defaultManager];
//    if ([fm fileExistsAtPath:OpenSSLRSAKeyDir])
//    {
//        [fm removeItemAtPath:OpenSSLRSAKeyDir error:nil];
//    }
    //格式化公钥
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"-----BEGIN RSA PRIVATE KEY-----\n"];
    int count = 0;
    for (int i = 0; i < [privateKey length]; ++i) {
        
        unichar c = [privateKey characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == 64) {
            [result appendString:@"\n"];
            count = 0;
        }
    }
    [result appendString:@"\n-----END RSA PRIVATE KEY-----"];
//    [result writeToFile:OpenSSLRSAPrivateKeyFile
//             atomically:YES
//               encoding:NSASCIIStringEncoding
//                  error:NULL];
//    NSLog(@"result = %@",result);
//    const char *publicKeyFileName = [OpenSSLRSAPrivateKeyFile cStringUsingEncoding:NSASCIIStringEncoding];
//    NSString *Str = [NSString stringWithFormat:@"%s",publicKeyFileName];
    //NSLog(@"私钥路径 =========== %@",result);
    return result;
    
}


@end
