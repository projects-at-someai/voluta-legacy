//
//  SharedData.m
//  LRF
//
//  Created by Francis Bowen on 5/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData

+ (id)SharedInstance {
    static SharedData *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id) init {
    
    self = [super init];
    
    if (self) {
        
        _IAPManager = [[InAppPurchaseManager alloc] initWithDatasource:self];
        
        _LTRCoreDataManager = [[LTRCoreDataManager alloc] init];
        
        NSMutableDictionary *EnabledServices = [[NSMutableDictionary alloc] init];
        [EnabledServices setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USING_DROPBOX_KEY] forKey:@"Dropbox"];
        [EnabledServices setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USING_GOOGLEDRIVE_KEY] forKey:@"Google Drive"];
        [EnabledServices setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USING_ONEDRIVE_KEY] forKey:@"OneDrive"];
        [EnabledServices setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USING_BOX_KEY] forKey:@"Box"];
        
        _CloudServiceManager = [[CloudServiceManager alloc] initWithEnableList:[EnabledServices copy]
                                                                  withDelegate:self];
        
        _Emailer = [[Emailer alloc] initWithDelegate:self];
    }
    
    return self;
}

- (LTRCoreDataManager *)GetLTRCoreDataManager {
    
    return _LTRCoreDataManager;
}

- (CloudServiceManager *)GetCloudServices {
    
    return _CloudServiceManager;
}

- (void)LoadTreatmentRecord {
        
    NSDictionary *FormData = [[[SharedData SharedInstance] GetFormDataManager] GetFormData];
    NSString *FirstName = [FormData objectForKey:@"First Name"];
    NSString *LastName = [FormData objectForKey:@"Last Name"];
    NSString *DateOfBirth = [FormData objectForKey:@"Date of Birth"];
    
    [[[SharedData SharedInstance] GetLTRCoreDataManager] LoadTreatmentRecord:FirstName
                                                                withLastName:LastName
                                                                     withDoB:DateOfBirth];
}

#pragma mark - CloudServiceDelegate
- (NSString *)GetAppFolderName {
    
    return VTD_APP_FOLDER;
}

- (NSString *)GetBoxClientID {
    
    return @"ypzob6wcrml4qt6cnj487gy3jaolprbj";
}

- (NSString *)GetBoxClientSecret {
    
    return @"OP3kdl2hMl7zrzoGzEIhm85PeXGYkwp8";
}

- (NSString *)GetDropboxClientID {
    
    //Note: Also need to change app plist file if this changes
    return @"bpnppa0xbu15r43";
}

- (NSString *)GetDropboxClientSecret {
    
    return @"qohimh74tt45z6x";
}

- (NSString *)GetGoogleDriveClientID {
    
    return @"225154805410-dk5gjp4bdqrq3hr8tkpkbac0d67kq8lh.apps.googleusercontent.com";
}

- (NSString *)GetGoogleDriveClientSecret {
    
    return @"uxk9Mih4gnKXak17PsbZVYzS";
}

- (NSString *)GetOAuth2KeychainName {
    
    return @"LRF-Gmail-OAuth2-key";
}

- (NSString *)GetOneDriveClientID {
    
    return @"000000004016E807";
}

#pragma mark - FormDataManagerDatasource
- (NSString *)GetICloudStoreContainer {
    
    return ICLOUD_CONTAINER;
}

- (NSString *)GetAppID {
    
    return APP_ID;
}

#pragma mark - IAPManagerDatasource
- (NSString *)GetKeychainKey {
    
    return IAP_KEY;
}

#pragma mark - Emailer
- (Emailer *)GetEmailer {
    
    return _Emailer;
}

@end
