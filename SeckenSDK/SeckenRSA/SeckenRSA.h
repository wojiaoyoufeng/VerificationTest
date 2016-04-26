//
//  JSRSA.h
//  RSA Example
//
//  Created by Js on 12/23/14.
//  Copyright (c) 2014 JS Lim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeckenRSA : NSObject

/*!
 * The public key file name
 */
@property (nonatomic, copy) NSString *publicKey;

/*!
 * The private key file name
 */
@property (nonatomic, copy) NSString *privateKey;



- (NSString *)publicEncrypt:(NSString *)plainText;
- (NSString *)privateDecrypt:(NSString *)cipherText;
- (NSString *)privateEncrypt:(NSString *)plainText;
- (NSString *)publicDecrypt:(NSString *)cipherText;
- (BOOL)generateRSAKeyPairWithKeySize:(int)keySize;
#pragma mark 返回公钥路径
- (NSString *)returnPublicKeyPath:(NSString *)publicKey;

#pragma mark 返回私钥路径
- (NSString *)returnPrivateKeyPath:(NSString *)privateKey;

+ (SeckenRSA *)sharedInstance;

@end
