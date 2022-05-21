//
//  HomeScreenViewController.m
//  PRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "HomeScreenViewController.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

@synthesize SingleTapGesture;
@synthesize VersionLabel;

- (void)viewDidLoad {
    
    self.BaseBackgroundDelegate = self;
    self.OptionsDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Setup gesture recognizer
    // Add gesture recogniser
    SingleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    SingleTapGesture.delegate = self;
    
    [self.view addGestureRecognizer:SingleTapGesture];

    _ViewControllers = [[NSMutableDictionary alloc] init];

    _FastTutorialVC = [[FastTutorialViewController alloc] init];
    _FastTutorialVC.BaseDelegate = self;
    [_ViewControllers setObject:_FastTutorialVC forKey:FASTUTORIAL_VIEWCONTROLLER];

    _IDCaptureVC = [[IDCaptureViewController alloc] init];
    _IDCaptureVC.BaseDelegate = self;
    [_ViewControllers setObject:_IDCaptureVC forKey:IDCAPTURE_VIEWCONTROLLER];

    _IDVerifyVC = [[IDVerifyViewController alloc] init];
    _IDVerifyVC.BaseDelegate = self;
    [_ViewControllers setObject:_IDVerifyVC forKey:IDVERIFY_VIEWCONTROLLER];

    _InfoVC = [[InfoViewController alloc] init];
    _InfoVC.BaseDelegate = self;
    [_ViewControllers setObject:_InfoVC forKey:INFO_VIEWCONTROLLER];

    _FinalizeVC = [[FinalizeViewController alloc] init];
    _FinalizeVC.BaseDelegate = self;
    [_ViewControllers setObject:_FinalizeVC forKey:FINALIZE_VIEWCONTROLLER];

    _SettingsVC = [[SettingsAndOptionsViewController alloc] init];
    _SettingsVC.BaseDelegate = self;
    [_ViewControllers setObject:_SettingsVC forKey:SETTINGS_VIEWCONTROLLER];

    _HowToVC = [[HowToViewController alloc] init];
    _HowToVC.BaseDelegate = self;
    [_ViewControllers setObject:_HowToVC forKey:HOWTO_VIEWCONTROLLER];

    _ResubmitVC = [[ResubmitViewController alloc] init];
    _ResubmitVC.BaseDelegate = self;
    [_ViewControllers setObject:_ResubmitVC forKey:RESUBMIT_VIEWCONTROLLER];

    _LongTutorialVC = [[LongTutorialViewController alloc] init];
    _LongTutorialVC.BaseDelegate = self;
    [_ViewControllers setObject:_LongTutorialVC forKey:LONGTUTORIAL_VIEWCONTROLLER];

    //FastTutorialVC = [[FastTutorialViewController alloc] init];
    //FastTutorialVC.BaseDelegate = self;
    //SettingsAndOptionsVC = [[SettingsAndOptionsViewController alloc] init];
    //SettingsAndOptionsVC.BaseDelegate = self;
    //ResubmitVC = [[ResubmitViewController alloc] init];
    //ResubmitVC.BaseDelegate = self;

    //Setup options button
    self.RequiresPassword = NO;
    
    _CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];
    
    VersionLabel = [[UILabel alloc] init];
    VersionLabel.backgroundColor = [UIColor clearColor];
    VersionLabel.font = [UIFont fontWithName:VTD_FONT size:32.0f];
    VersionLabel.textColor = VTD_LIGHT_BLUE;
    VersionLabel.textAlignment = NSTextAlignmentCenter;
    
#ifdef RELEASE
    
    VersionLabel.text = [NSString stringWithFormat:@"VERSION %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
#else
    
    VersionLabel.text = [NSString stringWithFormat:@"VERSION %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
#endif
    
    [self.view addSubview:VersionLabel];

    _CurrentScreen = HOMESCREEN_VIEWCONTROLLER;
    
    
}

- (void)viewDidAppear:(BOOL)animated {

    CLS_LOG(@"homescreen vc");

#if DEBUG
    //Note: for testing
    //[KeychainWrapper deleteItemFromKeychainWithIdentifier:VIP_KEY];
    
    //Note: For testing
    //[[[SharedData SharedInstance] GetIAPManager] ClearAllForms];
    
    //Note: For testing
    //[[[SharedData SharedInstance] GetIAPManager] LoadForms];
    
    //Note: For testing
    //[[NSUserDefaults standardUserDefaults] setObject:@"No" forKey:USING_DEVICE_SYNC_KEY];

    //Note: For testing
    //[self TestIAP];
#endif
    
    NSString *docsdir = [[SharedData SharedInstance] GetDocumentsPath];
    NSLog(@"Documents:\n%@", docsdir);
    
    NSString *imgsdir = [Utilities GetImagesPath];
    NSLog(@"Imgs:\n%@", imgsdir);
    
    //FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
       
    if ([_CurrentScreen isEqualToString:HOMESCREEN_VIEWCONTROLLER]) {
        
        //[_FormDataManager ClearAll];
        
#ifndef IS_UNLIMITED
        
        InAppPurchaseManager *IAPManager = [[SharedData SharedInstance] GetIAPManager];
        [IAPManager VerifySubscriptions];
        
#endif
        
        [[SharedData SharedInstance] SetGoingToResubmit:NO];
        
        [self CheckAndDeleteDirectory:[[SharedData SharedInstance] GetTempPath]];
        
        [self CheckAndServicePendingUploads];
        
        [self SyncICloud];
        
        [self CheckAndDeleteDBTransferBackups];
        
        //Check if google drive token needs to be refreshed
        [[[SharedData SharedInstance] GetCloudServices] CheckForExpiredGoogleDriveToken];

        bool didCheck = [[SharedData SharedInstance] CheckForReview];

        if (didCheck) {

            [Answers logCustomEventWithName:@"Ratings dialog shown"
                           customAttributes:@{}];
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([Utilities IsUsingDataSync]) {
        
        if (_CoreDataManager) {
            
            [_CoreDataManager StopMergeTimer];
        }
        
    }
}

- (void)CheckAndDeleteDirectory:(NSString *)Path {
    
    NSFileManager *FileManager = [[NSFileManager alloc] init];
    
    BOOL isDirectory = true;
    NSError *error = nil;
    
    if([FileManager fileExistsAtPath:Path isDirectory:&isDirectory]) {
        
        NSLog(@"Deleting directory: %@", Path);
        [FileManager removeItemAtPath:Path error:&error];
    }
    
    
    [FileManager createDirectoryAtPath:Path
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error];
}

- (void)CheckAndDeleteDBTransferBackups {
    
    NSLog(@"Checking for DB Transfer backups")
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    //Remove .backup_v2 files from documents directory
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.backup_v2'"];
    NSArray *onlybackups = [dirContents filteredArrayUsingPredicate:fltr];
    for (NSString *file in onlybackups) {
        NSLog(@"DB Transer Backup found and deleted");
        NSString *path = [documentsDirectory stringByAppendingPathComponent:file];
        [fm removeItemAtPath:path error:nil];
    }
}

- (void)CheckAndServicePendingUploads {
    
    _NumPending = [_CoreDataManager NumPendingUploads];
    
    InAppPurchaseManager *IAPManager = [[SharedData SharedInstance] GetIAPManager];
    bool hasForms = ([IAPManager GetNumberOfForms] >= _NumPending);
    bool hasSubscription = [IAPManager HasSubscription];
    
    if (!hasForms && !hasSubscription && (_NumPending > 0)) {
        
        NSLog(@"Not enough forms to service pending waivers");
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Error" withMessage:@"You have pending waivers but do not have enough forms to upload. More forms can be purchased through the in-app purchases"];
        
        [self presentViewController:alert animated:NO completion:nil];
        
    }
    else if ([Utilities HasNetworkConnectivity] && (_NumPending > 0)) {
        
        UIAlertController *alert = [self.Alerts CreateYesNoAlert:^(UIAlertAction *action)
        {
            _PendingList = [_CoreDataManager GetListofPendingUploads];
            CloudServiceManager *CloudServices = [[SharedData SharedInstance] GetCloudServices];
            CloudServices.pendingDelegate = self;
            
            _PendingAlert = [self.Alerts CreateBusyAlert:@"Pending Uploads" withMessage:[NSString stringWithFormat:@"Uploading form 1 of %lu",(unsigned long)_NumPending]];
            
            [self presentViewController:_PendingAlert animated:NO completion:^(){
                
                [CloudServices UploadPendingForms:[_PendingList copy]];
            }];
        
        }
                                                   withNoHandler:^(UIAlertAction *action)
        {
            NSLog(@"Pending uploads canceled");
        }
                                                       withTitle:@"Pending Uploads"
                                                     withMessage:[NSString stringWithFormat:@"You have %lu pending uploads. Do you want to upload them now?",(unsigned long)_NumPending]];
        
        [self presentViewController:alert animated:NO completion:nil];
        
    }
}

- (void)SyncICloud {
    
    if ([Utilities IsUsingDataSync]) {

        NSLog(@"Syncing iCloud");
        
        [_CoreDataManager ReloadStore];
        
        [_CoreDataManager StartMergeTimer:60];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)backgroundFileNamePortrait {
    
    return HOMESCREEN_PORTRAIT;
}

- (NSString *)backgroundFileNameLandscape {
    
    return HOMESCREEN_LANDSCAPE;
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {
    
    [super RotationDetected:orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        [VersionLabel setFrame:VERSION_LABEL_LANDSCAPE];
    }
    else {
        
        [VersionLabel setFrame:VERSION_LABEL_PORTRAIT];
    }
}

- (void)OptionsTapped:(BaseWithOptionsButtonViewController *)VC withPasswordPromptTitle:(NSString *)Title
{
    //Note: for testing
    //[[Crashlytics sharedInstance] crash];

    /*
    [self presentViewController:self.SettingsAndOptionsVC
                       animated:NO
                     completion:nil];

     */
    [self presentViewController:_SettingsVC
                       animated:NO
                     completion:nil];
}

- (void)singleTap:(UITapGestureRecognizer *)sender {
    
    //check for default settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:APP_SETUP_KEY] == nil)
    {

        [self presentViewController:_SettingsVC
                           animated:NO
                         completion:nil];
    }
    else
    {
        [self presentViewController:_FastTutorialVC
                           animated:NO
                         completion:nil];

    }
    
}

- (void)VCComplete:(VolutaBaseViewController *)VC destinationViewController:(NSString *)VCName {

    [self.view setHidden:YES];

    if (VCName) {
        _CurrentScreen = VCName;
    }
    else {
        _CurrentScreen = HOMESCREEN_VIEWCONTROLLER;
    }

    [VC dismissViewControllerAnimated:NO completion:^(){

        UIViewController *vc = nil;

        vc = [_ViewControllers objectForKey:VCName];

        if (vc) {

            int64_t delayInSeconds = 0.6;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self presentViewController:vc
                                   animated:NO
                                 completion:nil];
            });

        }
        else {

            [self.view setHidden:NO];
        }
        
    }];
    
}

#pragma mark - CloudServicePendingUploadDelegate
- (void)PendingUploadComplete:(bool)UploadSuccessful {
    
    
    [_PendingAlert dismissViewControllerAnimated:NO completion:^(){

        NSString *msg = @"All your pending forms have been uploaded";
        
        if (!UploadSuccessful) {
            msg = @"There was a problem uploading your forms. We will try again later.";
        }
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Pending Uploads" withMessage:msg];
        
        [self presentViewController:alert animated:NO completion:nil];
     
    }];

}

- (void)PendingUploadProgress:(NSUInteger)CurrentPendingNum withTotal:(NSUInteger)TotalToUpload {
    
    NSString *msg = [NSString stringWithFormat:@"Uploading form %lu of %lu\n\n\n\n\n",(CurrentPendingNum + 1),(unsigned long)_NumPending];
    _PendingAlert.message = msg;
}

- (CoreDataManager *)GetCoreDataManager {
    
    return _CoreDataManager;
}

- (NSString *)GetTempPath {
    
    return [[SharedData SharedInstance] GetTempPath];
}

- (CloudServiceManager *)GetCloudServiceManager {

    return [[SharedData SharedInstance] GetCloudServices];
}

@end
