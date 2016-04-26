//
//  secken_rsa.h
//  SeckenSDK
//
//  Created by Secken_ck on 15/9/14.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#ifndef __SeckenSDK__secken_rsa__
#define __SeckenSDK__secken_rsa__

#include <stdio.h>

char *secken_private_decrypt(const char *cipher_text, const char *private_key_path);
char *secken_public_encrypt(const char *plain_text, const char *public_key_path);
char *secken_private_encrypt(const char *plain_text, const char *private_key_path);
char *secken_public_decrypt(const char *cipher_text, const char *public_key_path);
int secken_generate_KeyPair(int keySize, const char *public_key_path, const char *private_key_path);
int secken_generate_key(const char *public_key_path, const char *private_key_path);


#endif /* defined(__SeckenSDK__secken_rsa__) */
