//
//  SharedData.m
//  CRF
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
        
        _InkListManager = [[InkListManager alloc] initWithDataSource:self];
        _NeedleListManager = [[NeedleListManager alloc] init];
        _InkThinnerListManager = [[InkThinnerListManager alloc] init];
        _BladeListManager = [[BladeListManager alloc] init];
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
    
    return @"fdgt6pj4tnwmqugzybmsdvfm0mdlker1";
}

- (NSString *)GetBoxClientSecret {
    
    return @"zt5yTomEZWqdOYBSaDxDM4KVd6dAl968";
}

- (NSString *)GetDropboxClientID {
    
    //Note: Also need to change app plist file if this changes
    return @"90yozfbi78wea3s";
}

- (NSString *)GetDropboxClientSecret {
    
    return @"yxs5aq5z6b11ly2";
}

- (NSString *)GetGoogleDriveClientID {
    
    //812594052420-etr94t3te4modjblso8pj4r8j48bljmi.apps.googleusercontent.com
    //return @"308146171079-rk8pcnkdelre4ta42q7u2bct3ni4pktb";

    //245989830177-358hee1m2vf56p154ill1v3024njglir.apps.googleusercontent.com
    return @"245989830177-358hee1m2vf56p154ill1v3024njglir";
}

- (NSString *)GetGoogleDriveClientSecret {
    
    //Note: Not used anymore?
    return @"";
}

- (NSString *)GetOAuth2KeychainName {
    
    return @"CRF-Gmail-OAuth2-key";
}

- (NSString *)GetOneDriveClientID {
    
    return @"000000004C1E7961";
}

- (void)SetAuthorizationFlow:(OIDAuthorizationService *)CurrentFlow {
    
    if (self.delegate) {
        [self.delegate SetAuthorizationFlow:CurrentFlow];
    }
}

#pragma mark - CoreDataManager
- (NSString *)GetICloudStoreContainer {
    
    return @"iCloud.com.VolutaDigital.CRF";
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

- (BladeListManager *)GetBladeListManager {

    if (!_BladeListManager) {
        _BladeListManager = [[BladeListManager alloc] init];
    }

    return _BladeListManager;
}

- (SalveListManager *)GetSalveListManager {

    if (!_SalveListManager) {
        _SalveListManager = [[SalveListManager alloc] init];
    }

    return _SalveListManager;
}

#pragma mark - InkListDatasource
- (NSString *)GetInkListFileName {

    return @"CRFDefaultInks";
}

- (NSString *)GetInkListBundle {

    return @"CRFListBundle";
}

@end
