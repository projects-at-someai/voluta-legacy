//
//  SettingsAndOptionsViewController.h
//  TRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseWithOptionsButtonViewController.h"
#import "AboutView.h"
#import "SettingsView.h"
#import "InAppPurchasesView.h"
#import "SettingsAndOptionsPropertyListManager.h"
#import "TableCellManager.h"
#import "FormDataManager.h"
#import "EmployeeListManager.h"
#import "KeychainWrapper.h"
#import "Emailer.h"
#import "InkListManager.h"
#import "NeedleListManager.h"
#import "InkThinnerListManager.h"
#import "DisposableGripListManager.h"
#import "DisposableTubeListManager.h"
#import "AppDelegate.h"

@interface SettingsAndOptionsViewController : BaseWithOptionsButtonViewController <
    BaseViewControllerDelegate,
    BaseViewControllerBackgroundDelegate,
    BaseOptionsDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    TableCellManagerDatasource,
    CloudServiceLinkDelegate,
    CloudServiceUploadDelegate,
    IAPViewDelegate,
    EmailerDelegate,
    SettingsViewDelegate,
    DataSyncDelegate,
    CloudServicePendingUploadDelegate
>
{
    UIDeviceOrientation _CurrentOrientation;
    
    UIView *_CurrentView;
    AboutView *_AboutView;
    SettingsView *_SettingsView;
    InAppPurchasesView *_InAppPurchasesView;
    
    SettingsAndOptionsPropertyListManager *_PropertyListManager;
    NSArray *_PageTitles;
    NSMutableArray *_MenuButtons;
    NSUInteger _PreviousPageNumber;
    NSUInteger _CurrentPageNumber;
    
    NSMutableArray *_SettingsTableSections;
    NSMutableArray *_SettingsSectionNames;
    
    TableCellManager *_CellManager;
    
    //CloudServiceManager *_CloudServiceManager;
    BOOL _isAuthenticatingCloudService;
    
    BOOL _isShowingPasswordPrompt;
    
    BOOL _isCancelingPasswordPrompt;
    
    UIAlertController *_BusyAlert;
    
    UIAlertController *_CloudAlert;
    
    Emailer *_Emailer;
    BOOL _isAuthenticatingEmailer;
    
    NSMutableDictionary *_CloudServiceCells;
    
    FormDataManager *_FormDataManager;
    CoreDataManager *_CoreDataManager;
    
    UIAlertController *_UploadBusyAlert;
    NSUInteger _NumToUpload;
}

- (void)ShowCloudLinkedAlert;

@end
