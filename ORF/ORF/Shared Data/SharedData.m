//
//  SharedData.m
//  ORF
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

        //Note: not using health items so we can run InitManagers. Instead we need to manually kick off legal manager
        //[self InitManagers];
        _LegalClauseManager = [[LegalClausesManager alloc]
                               initWithStudioName:[[NSUserDefaults standardUserDefaults] objectForKey:BUSINESS_NAME_KEY]];

        _GeneralCSVListManager = [[GeneralCSVListManager alloc] initWithDataSource:self];

        _RulesManager = [[RulesManager alloc] initWithStudioName:[[NSUserDefaults standardUserDefaults] objectForKey:BUSINESS_NAME_KEY]];
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
    
    return @"gz10z6x2vpm7rdoym56vizlxf5fimu4j";
}

- (NSString *)GetBoxClientSecret {
    
    return @"0C5yGZ66bvQGFmLMBG6yryU0V8P23kAT";
}

- (NSString *)GetDropboxClientID {
    
    //Note: Also need to change app plist file if this changes
    return @"4c2pz1gqpaeed34";
}

- (NSString *)GetDropboxClientSecret {
    
    return @"ai9u3arg5wal584";
}

- (NSString *)GetGoogleDriveClientID {
    
    //678406306465-fld2blsj1sa6mamigqnh3nnqbjlcla9a.apps.googleusercontent.com
    return @"678406306465-fld2blsj1sa6mamigqnh3nnqbjlcla9a";
}

- (NSString *)GetGoogleDriveClientSecret {
    
    //Note: Not used anymore?
    return @"";
}

- (NSString *)GetOAuth2KeychainName {
    
    return @"ORF-Gmail-OAuth2-key";
}

- (NSString *)GetOneDriveClientID {
    
    return @"00000000401FB3D4";
}

- (void)SetAuthorizationFlow:(id<OIDAuthorizationFlowSession>)CurrentFlow {
    
    if (self.delegate) {
        [self.delegate SetAuthorizationFlow:CurrentFlow];
    }
}

#pragma mark - CoreDataManager
- (NSString *)GetICloudStoreContainer {
    
    return @"iCloud.com.VolutaDigital.ORF";
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

#pragma mark - GeneralCSVListDatasource
- (NSString *)GetDefaultListFilename {

    return DEFAULT_ROUTES_FILENAME;
}

- (NSString *)GetListFilename {

    return ROUTES_FILENAME;
}

- (GeneralCSVListManager *)GetGeneralCSVListManager {

    return _GeneralCSVListManager;
}

- (NSArray *)RulesItems {

    return [_RulesManager GetRules];
}

- (void)ReloadRules {

    [_RulesManager ReloadRules];
}

@end
