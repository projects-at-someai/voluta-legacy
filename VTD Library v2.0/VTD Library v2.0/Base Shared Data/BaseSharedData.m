//
//  BaseSharedData.m
//  LRF
//
//  Created by Francis Bowen on 5/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseSharedData.h"

@implementation BaseSharedData

- (id)init {

    self = [super init];
    
    if (self) {
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            // Retina display
            
            [self SetIsRetina:YES];
            
        } else {
            // non-Retina display
            
            [self SetIsRetina:NO];
        }
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        UIDeviceOrientation orientation;
        
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            orientation = UIDeviceOrientationLandscapeLeft;
        }
        else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            orientation = UIDeviceOrientationLandscapeRight;
        }
        else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            orientation = UIDeviceOrientationPortrait;
        }
        else {
            orientation = UIDeviceOrientationPortraitUpsideDown;
        }
        
        [self SetDeviceOrientation:orientation];

        
        //Force reset of passwords
        //_HasMasterPW = NO;
        //_HasSecondaryPW = NO;
        _HasMasterPW = [[NSUserDefaults standardUserDefaults] boolForKey:HAS_MASTER_PW_KEY];
        _HasSecondaryPW = [[NSUserDefaults standardUserDefaults] boolForKey:HAS_SECONDARY_PW_KEY];
        
        if (!_HasMasterPW)
        {
            NSLog(@"Storing default master pw");
            //NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:1234 withPWType:MASTER_PW_TYPE];
            //[KeychainWrapper createKeychainValue:fieldString forIdentifier:MASTER_PW_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:@"1234" forKey:MASTER_PASSCODE];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:HAS_MASTER_PW_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if (!_HasSecondaryPW)
        {
            NSLog(@"Storing default secondary pw");
            //fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:0 withPWType:SECONDARY_PW_TYPE];
            //[KeychainWrapper createKeychainValue:fieldString forIdentifier:SECONDARY_PW_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:@"0000" forKey:SECONDARY_PASSCODE];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:HAS_SECONDARY_PW_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        _Alerts = [[AlertManager alloc] init];
        
        //Setup documents path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _DocumentsPath = [paths objectAtIndex:0];
        _TempPath = [_DocumentsPath stringByAppendingString:@"/Temp"];
        _PendingUploadsPath = [_DocumentsPath stringByAppendingString:@"/Pending"];
        _RestorePath = [_DocumentsPath stringByAppendingString:@"/Restore"];
        
        _goToResubmitVC = NO;
        
        _ImageListManager = [[ImageListManager alloc] init];
        
        _DeviceID = [KeychainWrapper keychainStringFromMatchingIdentifier:DEVICEID_KEYCHAIN_KEY];
        
        if (_DeviceID == nil) {
            
            NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
            _DeviceID = [identifierForVendor UUIDString];
            
            NSLog(@"Storing device id: %@",_DeviceID);
            
            [KeychainWrapper createKeychainValue:_DeviceID forIdentifier:DEVICEID_KEYCHAIN_KEY];
        }
        
        _CoreDataManager = [[CoreDataManager alloc] initWithDatasource:self];

        _InAppReviewMgr = [[InAppReviewManager alloc] init];

        _isResubmitting = NO;
        _isRetakingPhoto = NO;

        
    }
    
    return self;
}

- (bool)GetHasMasterPW
{
    return _HasMasterPW;
}

- (bool)GetHasSecondaryPW
{
    return _HasSecondaryPW;
}

- (void)SetHasMasterPW:(bool)hasPW
{
    _HasMasterPW = hasPW;
}

- (void)SetHasSecondaryPW:(bool)hasPW
{
    _HasSecondaryPW = hasPW;
}

- (bool)GetIsRetina
{
    return _isRetina;
}

- (void)SetIsRetina:(bool)retina
{
    _isRetina = retina;
}

- (bool)GetIsResubmitting {
    
    return _isResubmitting;
}

- (bool)GetIsRetakingPhoto {
    
    return _isRetakingPhoto;
}

- (void)SetIsRetakingPhoto:(bool)retakingphoto {
    
    _isRetakingPhoto = retakingphoto;
}

- (void)SetIsResubmitting:(bool)isresubmitting {
    
    _isResubmitting = isresubmitting;
}

- (UIDeviceOrientation)GetDeviceOrientation
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIDeviceOrientation orientation;
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        orientation = UIDeviceOrientationLandscapeLeft;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        orientation = UIDeviceOrientationLandscapeRight;
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        orientation = UIDeviceOrientationPortrait;
    }
    else {
        orientation = UIDeviceOrientationPortraitUpsideDown;
    }
    
    _DeviceOrientation = orientation;
    
    return _DeviceOrientation;
}

- (UIDeviceOrientation)GetPreviousDeviceOrientation
{
    return _PreviousOrientation;
}

- (void)SetDeviceOrientation:(UIDeviceOrientation)currentOrientation
{
    _DeviceOrientation = currentOrientation;
}

- (void)SetPreviousOrientation:(UIDeviceOrientation)previousOrientation
{
    _PreviousOrientation = previousOrientation;
}

- (AlertManager *)GetAlertManager {
    
    return _Alerts;
}

- (NSString *)GetDocumentsPath {
    
    return _DocumentsPath;
}

- (NSString *)GetTempPath {
    
    return _TempPath;
}

- (NSString *)GetPendingUploadsPath {
    
    return _PendingUploadsPath;
}

- (NSString *)GetRestorePath {
    
    return _RestorePath;
}

- (bool)IsGoingToResubmitVC {
    
    return _goToResubmitVC;
}

- (void)SetGoingToResubmit:(bool)isGoing {
    
    _goToResubmitVC = isGoing;
}

- (ImageListManager *)GetImageListManager {
    
    return _ImageListManager;
}

- (NSString *)GetDeviceID {
    
    return _DeviceID;
}

- (InAppPurchaseManager *)GetIAPManager {

    return _IAPManager;
}

- (UIViewController *)GetSettingsVC {
    
    return _SettingsVC;
}

- (void)SetSettingsVC:(UIViewController *)VC {
    
    _SettingsVC = VC;
}

- (void)StartNewForm {
    
    _FormDataManager = [[FormDataManager alloc] init];
    NSLog(@"Initialize form data manager");

}

- (void)EndCurrentForm {

    _FormDataManager = nil;
}

- (void)LoadForm:(FormDataManager *)frm {
    
    _FormDataManager = frm;
}

- (void)InitManagers {
    
    _HealthItemsManager = [[HealthItemsManager alloc] init];
    [_HealthItemsManager LoadHealthItemsFromPList];
    
    _LegalClauseManager = [[LegalClausesManager alloc]
                           initWithStudioName:[[NSUserDefaults standardUserDefaults] objectForKey:BUSINESS_NAME_KEY]];
}

- (void)SetDestViewController:(NSString *)DVC {
    
    _DestViewController = DVC;
}

- (NSString *)GetDestViewController {
    
    return _DestViewController;
}

- (FormDataManager *)GetFormDataManager {
    
    return _FormDataManager;
}

- (CoreDataManager *)GetCoreDataManager {
    
    return _CoreDataManager;
}

#pragma mark - Health and Legal Clause Managers
- (NSArray *)GetAllergies {
    
    return [_HealthItemsManager GetAllergies];
}

- (NSArray *)GetDiseases {
    
    return [_HealthItemsManager GetDiseases];
}

- (NSArray *)GetHealthConditions {
    
    return [_HealthItemsManager GetHealthConditions];
}

- (NSMutableDictionary *)GetRequiredHealthItems {
    
    return [_HealthItemsManager GetRequiredHealthItems];
}

- (void)LoadHealthItemsFromPList {
    
    [_HealthItemsManager LoadHealthItemsFromPList];
}

- (void)SaveRequiredHealthItems {
    
    [_HealthItemsManager SaveRequiredHealthItems];
}

- (void)ReloadRequiredHealthItems {
    
    [_HealthItemsManager ReloadRequiredHealthItems];
}

- (NSArray *)LegalItems {
    
    return [_LegalClauseManager GetLegalClauses];
}

- (void)ReloadLegalClauses {
    
    [_LegalClauseManager ReloadLegalClauses];
}

- (bool)CheckForReview {

    return [_InAppReviewMgr CheckForReview];
}

- (void)IncrementReviewFormCount {

    [_InAppReviewMgr IncrementNumberForms];
}

@end
