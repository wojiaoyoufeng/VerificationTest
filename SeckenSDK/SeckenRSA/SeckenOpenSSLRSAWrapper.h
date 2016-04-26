//
//  SeckenOpenSSLRSAWrapper.h
//  SeckenSDK
//
//  Created by Secken_ck on 15/9/14.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rsa.h"
#import "pem.h"

typedef enum {
    SeckenKeyTypePublic,
    SeckenKeyTypePrivate
}SeckenKeyType;

typedef enum {
    SK_RSA_PADDING_TYPE_NONE       = RSA_NO_PADDING,
    SK_RSA_PADDING_TYPE_PKCS1      = RSA_PKCS1_PADDING,
    SK_RSA_PADDING_TYPE_SSLV23     = RSA_SSLV23_PADDING
}SK_RSA_PADDING_TYPE;

@interface SeckenOpenSSLRSAWrapper : NSObject{

    RSA *_rsa;
}

/**
 Thanks to Berin with this property at link:
 http://blog.wingsofhermes.org/?p=42
 
 @property publicKeyBase64
 @discussion This property is presented by the local file.And `exportRSAKeys` should be called before get this.
 @return public key base64 encoded string.
 */
@property (nonatomic,strong) NSString *publicKeyBase64;

/**
 @property privateKeyBase64
 @discussion This property is presented by the local file.And `exportRSAKeys` should be called before get this.
 @return private key base64 encoded string.
 */
@property (nonatomic,strong) NSString *privateKeyBase64;

/**
 Creates and initializes an `OpenSSLRSAWrapper` object.
 
 *@return The newly-initialized OpenSSLRSAWrapper
 */
+ (id)shareInstance;

/**
 This method will check local filesystem whether the `publicKey.pem` or `publicKey.pem` exist.
 
 *@return can import or not.
 */
+ (BOOL)canImportRSAKeys;

/**
 Generate rsa key pair by the key size.
 
 @param keySize RSA key bits . The value could be `512`,`1024`,`2048` and so on.
 Normal is `1024`.
 */
- (BOOL)generateRSAKeyPairWithKeySize:(int)keySize;

/**
 Export the public key and the private key to local file.So that we can import the keys.
 
 @discussion The method `generateRSAKeyPairWithKeySize:` should be called before this method.
 @return Success or not.
 */
- (BOOL)exportRSAKeys;

/**
 Import rsa key pairs from local file with type.
 
 @param type `KeyTypePublic` or `KeyTypePrivate` is present.
 @discussion If the method `generateRSAKeyPairWithKeySize:` wasn't called before and also the method `exportRSAKeys`,
 This method will never success.
 @return Success or not.
 */
- (BOOL)importRSAKeyWithType:(SeckenKeyType)type;

/**
 RSA encrypt the plain text with private or public key.
 
 @param keyType `KeyTypePublic` or `KeyTypePrivate` is present.
 @param text  The string that will be encrypted.
 @return The enrypted data.
 */
- (NSData*)encryptRSAKeyWithType:(SeckenKeyType)keyType paddingType:(SK_RSA_PADDING_TYPE)padding plainText:(NSString*)text usingEncoding:(NSStringEncoding)encoding;

/**
 RSA encrypt the data with private or public key.
 
 @param keyType `KeyTypePublic` or `KeyTypePrivate` is present.
 @param data  The data that will be encrypted.
 @return The enrypted data.
 */
- (NSData*)encryptRSAKeyWithType:(SeckenKeyType)keyType paddingType:(SK_RSA_PADDING_TYPE)padding data:(NSData*)data;

/**
 RSA decrypt the data that encrypted.
 
 @param keyType `KeyTypePublic` or `KeyTypePrivate` is present.
 @param data  The data that encrypted.
 @return The plain text.
 */
- (NSString*)decryptRSAKeyWithType:(SeckenKeyType)keyType paddingType:(SK_RSA_PADDING_TYPE)padding plainTextData:(NSData*)data usingEncoding:(NSStringEncoding)encoding;

/**
 RSA decrypt the data that encrypted.
 
 @param keyType `KeyTypePublic` or `KeyTypePrivate` is present.
 @param data  The data that encrypted.
 @return The data decrypted.
 */
- (NSData*)decryptRSAKeyWithType:(SeckenKeyType)keyType paddingType:(SK_RSA_PADDING_TYPE)padding encryptedData:(NSData*)data;

@end

@interface SeckenOpenSSLRSAWrapper (C_Base)

/**
 RSA encrypt
 
 @param from Input value.
 @param flen Input data length.
 @param to  Output value.
 @return status of the encrypted.
 error code:
 -1 : `from` or `to` is NULL;rsa key is not presented.
 Otherwise,the openssl's rsa encrypted status will be presented.
 */
- (int)encryptRSAKeyWithType:(SeckenKeyType)keyType from:(const unsigned char *)from flen:(int)flen to:(unsigned char *)to padding:(SK_RSA_PADDING_TYPE)padding;

/**
 RSA decrypt
 
 @param from Input value.
 @param flen Input data length.
 @param to  Output value.
 @return status of the decrypted
 error code:
 -1 : `from` or `to` is NULL;rsa key is not presented.
 Otherwise,the openssl's rsa decrypted status will be presented.
 */
- (int)decryptRSAKeyWithType:(SeckenKeyType)keyType from:(const unsigned char *)from flen:(int)flen to:(unsigned char *)to padding:(SK_RSA_PADDING_TYPE)padding ;

@end
