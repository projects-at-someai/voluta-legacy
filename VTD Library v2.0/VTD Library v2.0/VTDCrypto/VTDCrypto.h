//
//  VTDCrypto.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 11/2/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDecryptor.h"
#import "RNEncryptor.h"

#define SALT1 @"0j2q1g2p1n3vqTqZXsgLLx1v3P8TGRyVJ1Epnvnf1mk"
#define SALT2 @"F02EwRj7RLHV8GrfxaHaRpEr8RsKdNRpxdAojRyAlSA"

@interface VTDCrypto : NSObject
{
    NSURL *_FileURL;
    NSURL *_EncryptedURL;
    NSURL *_DecryptedURL;
}

- (NSData *)Encrypt:(NSData *)data withPassword:(NSString *)pw;
- (NSData *)Decrypt:(NSData *)data withPassword:(NSString *)pw;

- (NSString *)EncryptString:(NSString *)source withPassword:(NSString *)password;
- (NSString *)DecryptString:(NSString *)source withPassword:(NSString *)password;

- (NSString *)EncryptFileAtPath:(NSString *)FilenameAndPath withPassword:(NSString *)pw;
- (NSString *)DecryptFileAtPath:(NSString *)FilenameAndPath withPassword:(NSString *)pw;

@end
