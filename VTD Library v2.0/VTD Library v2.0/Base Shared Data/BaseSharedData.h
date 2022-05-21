//
//  BaseSharedData.h
//  LRF
//
//  Created by Francis Bowen on 5/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KeychainWrapper.h"
#import "AlertManager.h"
#import "ImageListManager.h"
#import "InAppPurchaseManager.h"
#import "CoreDataManager.h"
#import "FormDataManager.h"
#import "HealthItemsManager.h"
#import "LegalClausesManager.h"
#import "InAppReviewManager.h"

@interface BaseSharedData : NSObject <CoreDataManagerDatasource>
{
    bool _HasMasterPW;
    bool _HasSecondaryPW;
    bool _isRetina;
    
    UIDeviceOrientation _DeviceOrientation;
    UIDeviceOrientation _PreviousOrientation;
    
    AlertManager *_Alerts;
    
    NSString *_DocumentsPath;
    NSString *_TempPath;
    NSString *_PendingUploadsPath;
    NSString *_RestorePath;
    
    bool _goToResubmitVC;
    
    ImageListManager *_ImageListManager;
    
    NSString *_DeviceID;
    
    InAppPurchaseManager *_IAPManager;
    
    UIViewController *_SettingsVC;
    
    CoreDataManager *_CoreDataManager;
    
    FormDataManager *_FormDataManager;
    
    bool _isResubmitting;
    bool _isRetakingPhoto;
    
    HealthItemsManager *_HealthItemsManager;
    LegalClausesManager *_LegalClauseManager;
    NSString *_DestViewController;

    InAppReviewManager *_InAppReviewMgr;

}

- (void)StartNewForm;
- (void)LoadForm:(FormDataManager *)frm;
- (void)EndCurrentForm;

- (void)InitManagers;

- (bool)GetHasMasterPW;
- (bool)GetHasSecondaryPW;
- (void)SetHasMasterPW:(bool)hasPW;
- (void)SetHasSecondaryPW:(bool)hasPW;

- (UIDeviceOrientation)GetDeviceOrientation;
- (UIDeviceOrientation)GetPreviousDeviceOrientation;
- (void)SetDeviceOrientation:(UIDeviceOrientation)currentOrientaiton;
- (void)SetPreviousOrientation:(UIDeviceOrientation)previousOrientation;

- (bool)GetIsRetina;
- (void)SetIsRetina:(bool)retina;

- (bool)GetIsResubmitting;
- (void)SetIsResubmitting:(bool)isresubmitting;

- (bool)GetIsRetakingPhoto;
- (void)SetIsRetakingPhoto:(bool)retakingphoto;

- (void)SetDestViewController:(NSString *)DVC;
- (NSString *)GetDestViewController;

- (bool)IsGoingToResubmitVC;
- (void)SetGoingToResubmit:(bool)isGoing;

- (AlertManager *)GetAlertManager;

- (ImageListManager *)GetImageListManager;

- (NSString *)GetDocumentsPath;
- (NSString *)GetTempPath;
- (NSString *)GetPendingUploadsPath;
- (NSString *)GetRestorePath;

- (NSString *)GetDeviceID;

- (InAppPurchaseManager *)GetIAPManager;

- (UIViewController *)GetSettingsVC;
- (void)SetSettingsVC:(UIViewController *)VC;

- (CoreDataManager *)GetCoreDataManager;

- (FormDataManager *)GetFormDataManager;


//Health and Legal Items Managers
- (NSArray *)GetAllergies;
- (NSArray *)GetDiseases;
- (NSArray *)GetHealthConditions;
- (NSMutableDictionary *)GetRequiredHealthItems;
- (void)LoadHealthItemsFromPList;
- (void)SaveRequiredHealthItems;
- (void)ReloadRequiredHealthItems;
 
- (NSArray *)LegalItems;
- (void)ReloadLegalClauses;

- (bool)CheckForReview;
- (void)IncrementReviewFormCount;

@end
