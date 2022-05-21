//
//  SharedData.m
//  TRF
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
        _DisposableGripListManager = [[DisposableGripListManager alloc] init];
        _DisposableTubeListManager = [[DisposableTubeListManager alloc] init];
        _SalveListManager = [[SalveListManager alloc] init];
        
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
    
    return @"g5iaggk8r0vhjg40y28325jw9d0lsvsc";
}

- (NSString *)GetBoxClientSecret {
    
    return @"gjzKJlEsisLYtkupWsUyFAFLNvPiWeGp";
}

- (NSString *)GetDropboxClientID {
    
    //Note: Also need to change app plist file if this changes
    return @"cda8uy13j9mhen3";
}

- (NSString *)GetDropboxClientSecret {
    
    return @"k6xxl20cw2gs548";
}

- (NSString *)GetGoogleDriveClientID {
    
    //return @"308146171079-rk8pcnkdelre4ta42q7u2bct3ni4pktb.apps.googleusercontent.com";
    return @"308146171079-rk8pcnkdelre4ta42q7u2bct3ni4pktb";
}

- (NSString *)GetGoogleDriveClientSecret {
    
    return @"-sUknmN4Bw0Ue0dbINGWBLGw";
}

- (NSString *)GetOAuth2KeychainName {
    
    return @"TRF-Gmail-OAuth2-key";
}

- (NSString *)GetOneDriveClientID {
    
    return @"0000000044161D38";
}

- (void)SetAuthorizationFlow:(OIDAuthorizationService *)CurrentFlow {

    if (self.delegate) {
        [self.delegate SetAuthorizationFlow:CurrentFlow];
    }
}

#pragma mark - CoreDataManager
- (NSString *)GetICloudStoreContainer {
    
    return @"iCloud.com.VolutaDigital.TRF";
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

- (DisposableGripListManager *)GetDisposableGripListManager {
    
    if (!_DisposableGripListManager) {
        _DisposableGripListManager = [[DisposableGripListManager alloc] init];
    }
    
    return _DisposableGripListManager;
}

- (DisposableTubeListManager *)GetDisposableTubeListManager {
    
    if (!_DisposableTubeListManager) {
        _DisposableTubeListManager = [[DisposableTubeListManager alloc] init];
    }
    
    return _DisposableTubeListManager;
}

- (SalveListManager *)GetSalveListManager {
    
    if (!_SalveListManager) {
        _SalveListManager = [[SalveListManager alloc] init];
    }
    
    return _SalveListManager;
}

@end
