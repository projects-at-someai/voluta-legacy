//
//  SharedData.m
//  MRF
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

- (void)SetDelegate:(id<SharedDataDelegate>)adelegate {
    
    self.delegate = adelegate;
}

- (id) init {
    
    self = [super init];
    
    if (self) {
        
        _IAPManager = [[InAppPurchaseManager alloc] initWithDatasource:self];
        
        NSMutableDictionary *EnabledServices = [[NSMutableDictionary alloc] init];
        [EnabledServices setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USING_DROPBOX_KEY] forKey:@"Dropbox"];
        [EnabledServices setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USING_GOOGLEDRIVE_KEY] forKey:@"Google Drive"];
        [EnabledServices setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USING_ONEDRIVE_KEY] forKey:@"OneDrive"];
        [EnabledServices setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USING_BOX_KEY] forKey:@"Box"];
        
        _CloudServiceManager = [[CloudServiceManager alloc] initWithEnableList:[EnabledServices copy] withDelegate:self];
        _CloudServiceManager.pdfDelegate = self;
        
        _Emailer = [[Emailer alloc] initWithDelegate:self];
        
        _InkListManager = [[InkListManager alloc] init];
        _NeedleListManager = [[NeedleListManager alloc] init];
        _InkThinnerListManager = [[InkThinnerListManager alloc] init];
        
        [self InitManagers];
        
    }
    
    return self;
}

- (CloudServiceManager *)GetCloudServices {
    
    return _CloudServiceManager;
}

#pragma mark - CloudServiceDelegate
- (NSString *)GetAppFolderName {
    
    return VTD_APP_FOLDER;
}

- (NSString *)GetBoxClientID {
    
    return @"lmw1ti53i4nzlmo85q7dhhbkulsliu67";
}

- (NSString *)GetBoxClientSecret {
    
    return @"Q5vrAjEZi3ROTTOu1vi5GiaeSTrdM2Pl";
}

- (NSString *)GetDropboxClientID {
    
    //Note: Also need to change app plist file if this changes
    return @"axmy7f3i64isrg6";
}

- (NSString *)GetDropboxClientSecret {
    
    return @"baaays4a56u0lka";
}

- (NSString *)GetGoogleDriveClientID {
    
    //812594052420-etr94t3te4modjblso8pj4r8j48bljmi.apps.googleusercontent.com
    //return @"308146171079-rk8pcnkdelre4ta42q7u2bct3ni4pktb";
    return @"1083067129914-0p2jsc4rct2hc2mupjnb8racu1q69c6e";
}

- (NSString *)GetGoogleDriveClientSecret {
    
    //Note: Not used anymore?
    return @"";
}

- (NSString *)GetOAuth2KeychainName {
    
    return @"MRF-Gmail-OAuth2-key";
}

- (NSString *)GetOneDriveClientID {
    
    return @"000000004C1E7961";
}

- (void)SetAuthorizationFlow:(id<OIDAuthorizationFlowSession>)CurrentFlow {
    
    if (self.delegate) {
        [self.delegate SetAuthorizationFlow:CurrentFlow];
    }
}

#pragma mark - CoreDataManager
- (NSString *)GetICloudStoreContainer {
    
    return @"iCloud.com.VolutaDigital.MRF";
}

- (CloudServiceManager *)GetCloudServiceManager {
    
    return _CloudServiceManager;
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

#pragma mark - Managers
- (InkListManager *)GetInkListManager {
    
    if (!_InkListManager) {
        _InkListManager = [[InkListManager alloc] init];
    }
    
    return _InkListManager;
}

- (InkThinnerListManager *)GetInkThinnerListManager {
    
    if (!_InkThinnerListManager) {
        _InkThinnerListManager = [[InkThinnerListManager alloc] init];
    }
    
    return _InkThinnerListManager;
}

- (NeedleListManager *)GetNeedleListManager {
    
    if (!_NeedleListManager) {
        _NeedleListManager = [[NeedleListManager alloc] init];
    }
    
    return _NeedleListManager;
}

@end
