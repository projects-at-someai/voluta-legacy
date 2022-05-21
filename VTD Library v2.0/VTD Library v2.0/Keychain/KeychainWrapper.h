//
//  KeychainWrapper.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/31/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>

// Used to specify the application used in accessing the Keychain.
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

// Used to help secure the PIN.
// Ideally, this is randomly generated, but to avoid the unnecessary complexity and overhead of storing the Salt separately, we will standardize on this key.
// !!KEEP IT A SECRET!!
#define SALT_HASH @"FvTivqTqZXsgLLx1v3P8TGRyVBeLlA1pvfm02wvGadj7RLHV8GrfxaHaRpEr8RsKdNRpxdAojRyAlSAj"


@interface KeychainWrapper : NSObject

+ (BOOL)checkForKey:(NSString *)key;

// Generic exposed method to search the keychain for a given value.  Limit one result per search.
+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier;
+ (NSData *)searchKeychainCopyMatchingIdentifierInShared:(NSString *)identifier;
+ (NSData *)getKeychainData:(NSString *)identifier;

// Calls searchKeychainCopyMatchingIdentifier: and converts to a string value.
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier;

// Simple method to compare a passed in Hash value with what is stored in the keychain.
// Optionally, we could adjust this method to take in the keychain key to look up the value
+ (BOOL)compareKeychainValueForMatchingPIN:(NSUInteger)pinHash withPWIdentifier:(NSString *)ID withPWType:(NSString *)PWType;

// Default initializer to store a value in the keychain.  
// Associated properties are handled for you (setting Data Protection Access, Company Identifer (to uniquely identify string, etc).
+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;
+ (BOOL)createKeychainValueFromData:(NSData *)data forIdentifier:(NSString *)identifier;
+ (BOOL)createKeychainValueFromDataInShared:(NSData *)data forIdentifier:(NSString *)identifier;

// Updates a value in the keychain.  If you try to set the value with createKeychainValue: and it already exists
// this method is called instead to update the value in place.
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;
+ (BOOL)updateKeychainValueFromData:(NSData *)data forIdentifier:(NSString *)identifier;
+ (BOOL)updateKeychainValueFromDataInShared:(NSData *)data forIdentifier:(NSString *)identifier;

// Delete a value in the keychain
+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier;

// Generates an SHA256 (much more secure than MD5) Hash
+ (NSString *)securedSHA256DigestHashForPIN:(NSUInteger)pinHash withPWType:(NSString *)PWType;
+ (NSString*)computeSHA256DigestForString:(NSString*)input;


@end
