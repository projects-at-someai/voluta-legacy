//
//  VTDCrypto.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 11/2/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "VTDCrypto.h"

@implementation VTDCrypto

- (NSData *)Encrypt:(NSData *)data withPassword:(NSString *)pw {
    
    NSError *error;
    
    NSData *enc = [RNEncryptor encryptData:data
                              withSettings:kRNCryptorAES256Settings
                                  password:[self SaltedKey:pw]
                                     error:&error];
    
    if (error != nil) {
        
        NSLog(@"Encrypt error: %@", error.localizedDescription);
    }
    
    return enc;
}

- (NSData *)Decrypt:(NSData *)data withPassword:(NSString *)pw {
    
    NSError *error;
    NSData *d = [RNDecryptor decryptData:data
                            withSettings:kRNCryptorAES256Settings
                                password:[self SaltedKey:pw]
                                   error:&error];
    
    if (error != nil) {
        
        NSLog(@"Decrypt error: %@", error.localizedDescription);
    }
    
    return d;
}

- (NSString *)EncryptString:(NSString *)source withPassword:(NSString *)password {

    NSData * sourceData = [source dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData * encryptedData = [RNEncryptor encryptData:sourceData
                                         withSettings:kRNCryptorAES256Settings
                                             password:password
                                                error:nil];
    
    NSString * encryptedString = [encryptedData base64EncodedStringWithOptions:0];
    
    return encryptedString;
}

- (NSString *)DecryptString:(NSString *)source withPassword:(NSString *)password {

    NSData * sourceData = [[NSData alloc] initWithBase64EncodedString:source options:0];
    
    NSData * decryptedData = [RNDecryptor decryptData:sourceData
                                         withSettings:kRNCryptorAES256Settings
                                             password:password
                                                error:nil];
    
    NSString * decryptedString = [[NSString alloc] initWithData:decryptedData
                                                       encoding:NSUTF8StringEncoding];
    return decryptedString;
}

- (NSString *)EncryptFileAtPath:(NSString *)FilenameAndPath withPassword:(NSString *)pw {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block int total = 0;
    int blockSize = 32 * 1024;
    
    NSString *encryptedFilename = [NSString stringWithFormat:@"%@.enc",FilenameAndPath];
    
    _FileURL = [[NSURL alloc] initFileURLWithPath:FilenameAndPath isDirectory:NO];
    _EncryptedURL = [[NSURL alloc] initFileURLWithPath:encryptedFilename isDirectory:NO];
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:_FileURL];
    __block NSOutputStream *outputStream = [NSOutputStream outputStreamWithURL:_EncryptedURL append:NO];
    
    __block NSError *encryptionError = nil;
    
    [inputStream open];
    [outputStream open];
    
    RNEncryptor *encryptor = [[RNEncryptor alloc] initWithSettings:kRNCryptorAES256Settings
                                                          password:[self SaltedKey:pw]
                                                           handler:^(RNCryptor *cryptor, NSData *data) {
                                                               @autoreleasepool {
                                                                   [outputStream write:data.bytes maxLength:data.length];
                                                                   dispatch_semaphore_signal(semaphore);
                                                                   
                                                                   data = nil;
                                                                   if (cryptor.isFinished) {
                                                                       [outputStream close];
                                                                       encryptionError = cryptor.error;
                                                                       // call my delegate that I'm finished with decrypting
                                                                   }
                                                               }
                                                           }];
    while (inputStream.hasBytesAvailable) {
        @autoreleasepool {
            uint8_t buf[blockSize];
            NSUInteger bytesRead = [inputStream read:buf maxLength:blockSize];
            if (bytesRead > 0) {
                NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                
                total = total + bytesRead;
                [encryptor addData:data];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
    }
    
    [inputStream close];
    [encryptor finish];
    
    //delete original file
    NSError *error;
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    [filemanager removeItemAtURL:_FileURL error:&error];

    return [_EncryptedURL path];
}

- (NSString *)DecryptFileAtPath:(NSString *)FilenameAndPath withPassword:(NSString *)pw {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block int total = 0;
    int blockSize = 32 * 1024;
    
    NSString *decryptedFilename = [FilenameAndPath stringByDeletingPathExtension];
    
    _FileURL = [[NSURL alloc] initFileURLWithPath:FilenameAndPath isDirectory:NO];
    _DecryptedURL = [[NSURL alloc] initFileURLWithPath:decryptedFilename isDirectory:NO];
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:_FileURL];
    __block NSOutputStream *outputStream = [NSOutputStream outputStreamWithURL:_DecryptedURL append:NO];
    
    __block NSError *decryptionError = nil;
    
    [inputStream open];
    [outputStream open];
    
    RNDecryptor *decryptor = [[RNDecryptor alloc] initWithPassword:[self SaltedKey:pw] handler:^(RNCryptor *cryptor, NSData *data) {
        
        @autoreleasepool {
            [outputStream write:data.bytes maxLength:data.length];
            dispatch_semaphore_signal(semaphore);
            
            data = nil;
            if (cryptor.isFinished) {
                [outputStream close];
                decryptionError = cryptor.error;
                // call my delegate that I'm finished with decrypting
            }
        }
    }];
    
    while (inputStream.hasBytesAvailable) {
        @autoreleasepool {
            uint8_t buf[blockSize];
            NSUInteger bytesRead = [inputStream read:buf maxLength:blockSize];
            if (bytesRead > 0) {
                NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                
                total = total + bytesRead;
                [decryptor addData:data];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
    }
    
    [inputStream close];
    [decryptor finish];
    
    //delete original file
    NSError *error;
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    [filemanager removeItemAtPath:FilenameAndPath error:&error];

    return decryptedFilename;

}

- (NSString *)SaltedKey:(NSString *)k {
    
    return [NSString stringWithFormat:@"%@%@%@", SALT1, k, SALT2];
}

@end
