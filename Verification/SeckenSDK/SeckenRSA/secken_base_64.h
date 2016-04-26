//
//  secken_base_64.h
//  SeckenSDK
//
//  Created by Secken_ck on 15/9/14.
//  Copyright (c) 2015年 Secken_ck. All rights reserved.
//

#ifndef __SeckenSDK__secken_base_64__
#define __SeckenSDK__secken_base_64__

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

char *secken_base64_encode(const unsigned char *data,
                           size_t input_length,
                           size_t *output_length);

unsigned char *secken_base64_decode(const char *data,
                                    size_t input_length,
                                    size_t *output_length);


#endif /* defined(__SeckenSDK__secken_base_64__) */
