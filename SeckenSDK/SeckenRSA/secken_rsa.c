//
//  secken_rsa.c
//  SeckenSDK
//
//  Created by Secken_ck on 15/9/14.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#include "secken_rsa.h"
#include <stdio.h>
#include <string.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include "secken_base_64.h"


char *secken_private_decrypt(const char *cipher_text, const char *private_key_path) {
    RSA *rsa_privateKey = NULL;
    FILE *fp_privateKey;
    int rsa_private_len;
    
    //    if ((fp_privateKey = fopen(private_key_path, "r")) == NULL) {
    //        printf("Could not open %s\n", private_key_path);
    //        return '\0';
    //    }
    
    if (!cipher_text) {
        return '\0';
    }
    
    // ===============================================
    char * private_keyyy=(char *)private_key_path;
    BIO *bp_private = BIO_new_mem_buf(private_keyyy,(int)strlen(private_keyyy));
    //BIO *bp_private = BIO_new_file(private_key_path, "r");
    if ((rsa_privateKey = PEM_read_bio_RSAPrivateKey(bp_private, NULL, NULL, NULL)) == NULL) {
        if ((rsa_privateKey = PEM_read_RSAPrivateKey(fp_privateKey, NULL, NULL, NULL)) == NULL) {
            printf("Error loading RSA Private Key File.");
            return '\0';
        }
    }
    BIO_free(bp_private);
    // ===============================================
    
    
    
    //    if ((rsa_privateKey = PEM_read_RSAPrivateKey(fp_privateKey, NULL, NULL, NULL)) == NULL) {
    //        printf("Error loading RSA Private Key File.");
    //        return '\0';
    //    }
    //fclose(fp_privateKey);
    
    //printf("Cipher text: %s\n", cipher_text);
    
    rsa_private_len = RSA_size(rsa_privateKey);
    //printf("RSA private length: %d\n", rsa_private_len);
    
    size_t crypt_len = 0;
    
    unsigned char *crypt = secken_base64_decode(cipher_text, strlen(cipher_text), &crypt_len);
    
    //printf("Decoded cipher: %s\nCrypt length: %ld\n", crypt, crypt_len);
    
    // If no static, it will cause "address of stack memory associated with local variable ...", which mean the variable will released from memory after the end of this function
    char *plain_char = malloc(crypt_len);
    // initialize
    strcpy(plain_char, "");
    
    char *err = NULL;
    for (int i = 0; i < crypt_len; i += rsa_private_len) {
        unsigned char *crypt_chunk = malloc(rsa_private_len + 1);
        memcpy(&crypt_chunk[0], &crypt[i], rsa_private_len);
        
        //printf("Crypt chunk: %s\n", crypt_chunk);
        
        unsigned char *result_chunk = malloc(crypt_len + 1);
        int result_length = RSA_private_decrypt(rsa_private_len, crypt_chunk, result_chunk, rsa_privateKey, RSA_PKCS1_PADDING);
        free(crypt_chunk);
        // chunk length should be the size of privatekey (in bytes) minus 11 (overhead during encryption)
        if (result_length == -1) {
            free(crypt);
            //printf("私钥解密失败，result_lenth == -1");
            return '\0';
        }
        //printf("Result chunk: %s\nChunk length: %d\n", result_chunk, result_length);
        
        // this is to omit the dummy character behind
        // i.e. Result chunk: ABC-1234567-201308101427371250-abcdefghijklmnopqrstuv\240Z
        //      Chunk length: 53
        //      New chunk: ABC-1234567-201308101427371250-abcdefghijklmnopqrstuv
        //
        // by copying the chunk to a temporary variable with an extra length (i.e. in this case is 54)
        // and then set the last character of temporary variable to NULL
        char tmp_result[result_length + 1];
        memcpy(tmp_result, result_chunk, result_length);
        tmp_result[result_length] = '\0';
        //printf("New chunk: %s\n", tmp_result);
        free(result_chunk);
        if (result_length == -1) {
            ERR_load_CRYPTO_strings();
            fprintf(stderr, "Error %s\n", ERR_error_string(ERR_get_error(), err));
            fprintf(stderr, "Error %s\n", err);
        }
        
        strcat(plain_char, tmp_result);
    }
    free(crypt);
    RSA_free(rsa_privateKey);
    //printf("Final result: %s\n", plain_char);
    
    return plain_char;
}

char *secken_public_encrypt(const char *plain_text, const char *public_key_path) {
    RSA *rsa_publicKey;
    FILE *fp_publicKey;
    int rsa_public_len;
    
    if ((fp_publicKey = fopen(public_key_path, "r")) == NULL) {
        //printf("Could not open %s\n", public_key_path);
        return '\0';
    }
    
    if (strlen(plain_text) == 0) {
        return '\0';
    }
    // ==========================替换原有的方法，解决读取公钥失败的错误=======================
    //    char * public_keyyy=(char *)public_key_path;
    //    BIO *bp_public = BIO_new_mem_buf(public_keyyy,(int)strlen(public_keyyy));
    BIO *bp_public = BIO_new_file(public_key_path, "r");
    if ((rsa_publicKey = PEM_read_bio_RSAPublicKey(bp_public, NULL, NULL, NULL)) == NULL) {
        if ((rsa_publicKey = PEM_read_RSA_PUBKEY(fp_publicKey, NULL, NULL, NULL)) == NULL) {
            //printf("Error loading RSA Public Key File.");
            return '\0';
        }
        //        return '\0';
    }
    // ==========================替换原有的方法，解决读取公钥失败的错误=======================
    
    //    if ((rsa_publicKey = PEM_read_RSA_PUBKEY(fp_publicKey, NULL, NULL, NULL)) == NULL) {
    //        printf("Error loading RSA Public Key File.");
    //        return '\0';
    //    }
    //====================================================================================
    
    fclose(fp_publicKey);
    BIO_free(bp_public);
    rsa_public_len = RSA_size(rsa_publicKey);
    printf("RSA public length: %d\n", rsa_public_len);
    
    // 11 bytes is overhead required for encryption
    int chunk_length = rsa_public_len - 11;
    printf("chunk len: %d\n", chunk_length);
    // 明文长度
    int plain_char_len = strlen(plain_text);
    //printf("plain_char_len = %d\n",plain_char_len);
    // 计算块的数目
    int num_of_chunks = (strlen(plain_text) / chunk_length) + 1;
    //printf("num of cks %d\n", num_of_chunks);
    int total_cipher_length = 0;
    
    // 输出尺寸为（组块的总数）×（该密钥长度）
    int sz = 0;
    long int encrypted_size = (num_of_chunks * rsa_public_len);
    unsigned char *cipher_data = malloc(encrypted_size +1);
    
    char *err = NULL;
    for (int i = 0; i < plain_char_len; i += chunk_length) {
        // take out chunk of plain text
        unsigned char *plain_chunk = malloc(chunk_length +1);
        memset(plain_chunk, 0, chunk_length+1);
        
        if (strlen(plain_text + i) > chunk_length) {
            sz = chunk_length;
        } else {
            sz = strlen(plain_text + i);
        }
        memcpy(&plain_chunk[0], &plain_text[i], sz);
        
        //printf("f Plain chunk: %s\n", plain_chunk);
        
        unsigned char *result_chunk = malloc(rsa_public_len +1);
        
        int result_length = RSA_public_encrypt(chunk_length, plain_chunk, result_chunk, rsa_publicKey, RSA_PKCS1_PADDING);
        //printf("f Encrypted Result chunk: %s\nEncrypted Chunk length: %d\n", result_chunk, result_length);
        free(plain_chunk);
        if (result_length == -1) {
            ERR_load_CRYPTO_strings();
            fprintf(stderr, "Error %s\n", ERR_error_string(ERR_get_error(), err));
            fprintf(stderr, "Error %s\n", err);
        }
        
        memcpy(&cipher_data[total_cipher_length], &result_chunk[0], result_length);
        free(result_chunk);
        total_cipher_length += result_length;
    }
    //printf("Total cipher length: %d\n", total_cipher_length);
    
    RSA_free(rsa_publicKey);
    size_t total_len = total_cipher_length; // 0
    char *encrypted = secken_base64_encode(cipher_data, encrypted_size, &total_len);
    encrypted[total_len] = 0;
    //printf("Final result: %s", encrypted);
    free(cipher_data);
    return encrypted;
}

char *secken_private_encrypt(const char *plain_text, const char *private_key_path) {
    RSA *rsa_privateKey = NULL;
    FILE *fp_privateKey;
    int rsa_private_len;
    
    if ((fp_privateKey = fopen(private_key_path, "r")) == NULL) {
        printf("Could not open %s\n", private_key_path);
        return '\0';
    }
    
    if ((rsa_privateKey = PEM_read_RSAPrivateKey(fp_privateKey, NULL, NULL, NULL)) == NULL) {
        printf("Error loading RSA Private Key File.");
        return '\0';
    }
    fclose(fp_privateKey);
    
    rsa_private_len = RSA_size(rsa_privateKey);
    //printf("RSA private length: %d\n", rsa_private_len);
    
    // 11 bytes is overhead required for encryption
    int chunk_length = rsa_private_len - 11;
    //printf("chunk length is %d\n", chunk_length);
    // plain text length
    int plain_char_len = strlen(plain_text);
    // calculate the number of chunks
    int num_of_chunks = (strlen(plain_text) / chunk_length) + 1;
    
    int total_cipher_length = 0;
    
    // the output size is (total number of chunks) x (the key length)
    int encrypted_size = (num_of_chunks * rsa_private_len);
    unsigned char *cipher_data = malloc(encrypted_size + 1);
    
    char *err = NULL;
    for (int i = 0; i < plain_char_len; i += chunk_length) {
        // take out chunk of plain text
        unsigned char *plain_chunk = malloc(chunk_length + 1);
        memcpy(&plain_chunk[0], &plain_text[i], chunk_length);
        
        //printf("Plain chunk: %s\n", plain_chunk);
        
        unsigned char *result_chunk = malloc(rsa_private_len + 1);
        
        int result_length = RSA_private_encrypt(chunk_length, plain_chunk, result_chunk, rsa_privateKey, RSA_PKCS1_PADDING);
        //printf("Encrypted Result chunk: %s\nEncrypted Chunk length: %d\n", result_chunk, result_length);
        free(plain_chunk);
        if (result_length == -1) {
            ERR_load_CRYPTO_strings();
            fprintf(stderr, "Error %s\n", ERR_error_string(ERR_get_error(), err));
            fprintf(stderr, "Error %s\n", err);
        }
        
        memcpy(&cipher_data[total_cipher_length], &result_chunk[0], result_length);
        free(result_chunk);
        total_cipher_length += result_length;
    }
    //printf("Total cipher length: %d\n", total_cipher_length);
    
    RSA_free(rsa_privateKey);
    size_t total_len = 0;
    char *encrypted = secken_base64_encode(cipher_data, encrypted_size, &total_len);
    //printf("Final result: %s\n Final result length: %zu\n", encrypted, total_len);
    free(cipher_data);
    return encrypted;
}

char *secken_public_decrypt(const char *cipher_text, const char *public_key_path) {
    RSA *rsa_publicKey = NULL;
    FILE *fp_publicKey;
    int rsa_public_len;
    
    if ((fp_publicKey = fopen(public_key_path, "r")) == NULL) {
        printf("Could not open %s\n", public_key_path);
        return '\0';
    }
    
    if ((rsa_publicKey = PEM_read_RSA_PUBKEY(fp_publicKey, NULL, NULL, NULL)) == NULL) {
        printf("Error loading RSA Public Key File.");
        return '\0';
    }
    fclose(fp_publicKey);
    
    //printf("Cipher text: %s\n", cipher_text);
    
    rsa_public_len = RSA_size(rsa_publicKey);
    //printf("RSA public length: %d\n", rsa_public_len);
    
    size_t crypt_len = 0;
    
    unsigned char *crypt = secken_base64_decode(cipher_text, strlen(cipher_text), &crypt_len);
    
    //printf("Decoded cipher: %s\nCrypt length: %ld\n", crypt, crypt_len);
    
    // If no static, it will cause "address of stack memory associated with local variable ...", which mean the variable will released from memory after the end of this function
    char *plain_char = malloc(crypt_len);
    // initialize
    strcpy(plain_char, "");
    
    char *err = NULL;
    for (int i = 0; i < crypt_len; i += rsa_public_len) {
        unsigned char *crypt_chunk = malloc(rsa_public_len + 1);
        memcpy(&crypt_chunk[0], &crypt[i], rsa_public_len);
        
        //printf("Crypt chunk: %s\n", crypt_chunk);
        
        unsigned char *result_chunk = malloc(crypt_len + 1);
        int result_length = RSA_public_decrypt(rsa_public_len, crypt_chunk, result_chunk, rsa_publicKey, RSA_PKCS1_PADDING);
        // chunk length should be the size of publickey (in bytes) minus 11 (overhead during encryption)
        //printf("Result chunk: %s\nChunk length: %d\n", result_chunk, result_length);
        
        // this is to omit the dummy character behind
        // i.e. Result chunk: ABC-1234567-201308101427371250-abcdefghijklmnopqrstuv\240Z
        //      Chunk length: 53
        //      New chunk: ABC-1234567-201308101427371250-abcdefghijklmnopqrstuv
        //
        // by copying the chunk to a temporary variable with an extra length (i.e. in this case is 54)
        // and then set the last character of temporary variable to NULL
        char tmp_result[result_length + 1];
        memcpy(tmp_result, result_chunk, result_length);
        tmp_result[result_length] = '\0';
        //printf("New chunk: %s\n", tmp_result);
        
        if (result_length == -1) {
            ERR_load_CRYPTO_strings();
            fprintf(stderr, "Error %s\n", ERR_error_string(ERR_get_error(), err));
            fprintf(stderr, "Error %s\n", err);
        }
        
        strcat(plain_char, tmp_result);
    }
    
    RSA_free(rsa_publicKey);
    //printf("Final result: %s\n", plain_char);
    free(crypt);
    return plain_char;
}


int secken_generate_KeyPair(int keySize, const char *public_key_path, const char *private_key_path){
    
    
    RSA *rsa;
    int iBits = keySize; // key length
    int nid = NID_sha1;    // sign alg
    unsigned long e = RSA_F4; // here we use classical 0x010001
    BIGNUM *bne;    // store e
    unsigned char bData[100] = {0};
    unsigned char bSign[200] = {0};
    int iSignlen = sizeof(bData);
    int iDatalen = sizeof(bSign);
    int ret = 0;
    
    bne=BN_new();
    ret=BN_set_word(bne,e);
    rsa=RSA_new();
    ret=RSA_generate_key_ex(rsa,iBits,bne,NULL);
    if(ret!=1)
    {
        //printf("RSA_generate_key_ex err!/n");
        return -1;
    }
    
    ret=RSA_sign(nid,bData,iDatalen,bSign,(unsigned int *)&iSignlen,rsa);
    if(ret!=1)
    {
        //printf("RSA_sign err!/n");
        RSA_free(rsa);
        return -1;
    }
    
    ret=RSA_verify(nid,bData,iDatalen,bSign,iSignlen,rsa);
    if(ret!=1)
    {
        //printf("RSA_verify err!/n");
        RSA_free(rsa);
        return -1;
    }
    RSA_free(rsa);
    //printf("test ok!/n");
    return 0;
    
    
    /*
     RSA *_rsa = NULL;
     RSA *_rsaPrivate;
     RSA *_rsaPublic;
     
     if (NULL != _rsa)
     {
     RSA_free(_rsa);
     _rsa = NULL;
     }
     //    _rsa = RSA_generate_key(keySize,RSA_F4,NULL,NULL);
     int result = RSA_generate_key_ex(_rsa, keySize, RSA_F4, NULL);
     
     //    printf("result = %d",result);
     const char *publicKeyFileName = public_key_path;
     const char *privateKeyFileName = private_key_path;
     
     //写入私钥和公钥
     RSA_blinding_on(_rsa, NULL);
     
     BIO *priBio = BIO_new_file(privateKeyFileName, "w");
     PEM_write_bio_RSAPrivateKey(priBio, _rsa, NULL, NULL, 0, NULL, NULL);
     
     BIO *pubBio = BIO_new_file(publicKeyFileName, "w");
     PEM_write_bio_RSAPublicKey(pubBio, _rsa);
     
     BIO_free(priBio);
     BIO_free(pubBio);
     
     //分别获取公钥和私钥
     _rsaPrivate = RSAPrivateKey_dup(_rsa);
     
     _rsaPublic = RSAPublicKey_dup(_rsa);
     
     if (_rsa && _rsaPublic && _rsaPrivate)
     {
     return 1;
     }
     else
     {
     return 0;
     }
     
     */
    
}

int secken_generate_key(const char *public_key_path, const char *private_key_path)
{
    int             ret = 0;
    RSA             *r = NULL;
    BIGNUM          *bne = NULL;
    BIO             *bp_public = NULL, *bp_private = NULL;
    
    int             bits = 1024;
    unsigned long   e = RSA_F4;
    
    // 1. generate rsa key
    bne = BN_new();
    ret = BN_set_word(bne,e);
    if(ret != 1){
        goto free_all;
    }
    
    r = RSA_new();
    ret = RSA_generate_key_ex(r, bits, bne, NULL);
    if(ret != 1){
        goto free_all;
    }
    const char *publicKeyFileName = public_key_path;
    const char *privateKeyFileName = private_key_path;
    
    
    // 2. save public key
    bp_public = BIO_new_file(publicKeyFileName, "w+");
    ret = PEM_write_bio_RSAPublicKey(bp_public, r);
    
    if(ret != 1){
        goto free_all;
    }
    
    // 3. save private key
    bp_private = BIO_new_file(privateKeyFileName, "w+");
    ret = PEM_write_bio_RSAPrivateKey(bp_private, r, NULL, NULL, 0, NULL, NULL);
    
    // 4. free
free_all:
    
    BIO_free_all(bp_public);
    BIO_free_all(bp_private);
    RSA_free(r);
    BN_free(bne);
    
    return (ret == 1);
}




