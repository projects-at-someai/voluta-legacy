//
//  HomeScreenViewController.m
//  MRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "HomeScreenViewController.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

@synthesize SingleTapGesture;
@synthesize FastTutorialVC;
@synthesize SettingsAndOptionsVC;
@synthesize ResubmitVC;
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
    
    FastTutorialVC = [[FastTutorialViewController alloc] init];
    FastTutorialVC.BaseDelegate = self;
    SettingsAndOptionsVC = [[SettingsAndOptionsViewController alloc] init];
    SettingsAndOptionsVC.BaseDelegate = self;
    ResubmitVC = [[ResubmitViewController alloc] init];
    ResubmitVC.BaseDelegate = self;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:@"appDidBecomeActive"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    //Note: for testing
    //[KeychainWrapper deleteItemFromKeychainWithIdentifier:VIP_KEY];
    
    //Note: For testing
    //[[[SharedData SharedInstance] GetIAPManager] ClearAllForms];
    
    //Note: For testing
    //[[[SharedData SharedInstance] GetIAPManager] LoadForms];
    
    NSString *docsdir = [[SharedData SharedInstance] GetDocumentsPath];
    NSLog(@"Documents:\n%@", docsdir);
    
    NSString *imgsdir = [Utilities GetImagesPath];
    NSLog(@"Imgs:\n%@", imgsdir);

    FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
    
    if (![self IsResubmitting] && ![[SharedData SharedInstance] IsGoingToResubmitVC]) {
        
        [_FormDataManager ClearAll];
        
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
        
        
    }

    [self didBecomeActive];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([Utilities IsUsingDataSync]) {
        
        if (_CoreDataManager) {
            
            [_CoreDataManager StopMergeTimer];
        }
        
    }
}

- (void) didBecomeActive {

    [self CheckSharedDirectory];
}

- (void)CheckSharedDirectory {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *datatransferred = [defaults objectForKey:@"MRF_DATA_TRANSFERRED_KEY"];
    NSString *crfstatus = [self CheckCRFAvailability];

    if((datatransferred == nil || ![datatransferred isEqualToString:@"yes"]) &&
       (![crfstatus isEqualToString:@"no"] && ![crfstatus isEqualToString:@""])) {

        NSString *shareddir = [Utilities GetSharedLocationPath:@"group.com.VolutaDigital"];
        NSLog(@"Shared dir:\n%@", shareddir);

        //backup settings
        NSLog(@"Creating MRF settings in shared dir");

        NSString *settingsfile = [NSString stringWithFormat:@"%@/MRFSettings",shareddir];
        SettingsBackupManager *backupmanager = [[SettingsBackupManager alloc] init];
        backupmanager.datasource = self;

        NSString *backupfilepath = [backupmanager ExportSettings];

        NSFileManager *FileManager = [[NSFileManager alloc] init];

        [FileManager copyItemAtPath:backupfilepath toPath:settingsfile error:nil];

        [FileManager removeItemAtPath:backupfilepath error:nil];

        //backup database
        NSLog(@"Backing up database to shared directory");
        NSString *backuppath = [[[SharedData SharedInstance] GetCoreDataManager] CreateBackup];

        NSString *MRFbackuppath = [NSString stringWithFormat:@"%@/MRFDatabase",shareddir];

        [FileManager copyItemAtPath:backuppath toPath:MRFbackuppath error:nil];

        [FileManager removeItemAtPath:backuppath error:nil];

        //transfer forms
        NSLog(@"Transferring forms to keychain");
        InAppPurchaseManager *iapmgr = [[SharedData SharedInstance] GetIAPManager];
        [iapmgr TransferIAPIntoShared];

        [defaults setObject:@"yes" forKey:@"MRF_DATA_TRANSFERRED_KEY"];
    }

    if([crfstatus isEqualToString:@"crf installed"]) {

        //prompt user to use the installed app
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
        {
            [self presentViewController:SettingsAndOptionsVC
                               animated:NO
                             completion:nil];
        }
                                                    withTitle:@"CRF Installed"
                                                  withMessage:@"Cosmetic Release Forms is currently installed. Please use CRF.Your settings and forms will automatically be transferred to CRF."];

        [self presentViewController:alert animated:NO completion:nil];

    }
    else if (![crfstatus isEqualToString:@"no"] && ![crfstatus isEqualToString:@""]) {

        //prompt user to install crf
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
                                    {
                                        [self presentViewController:SettingsAndOptionsVC
                                                           animated:NO
                                                         completion:nil];
                                    }
                                                    withTitle:@"CRF Available"
                                                  withMessage:@"Cosmetic Release Forms is currently available in the app store. Please install CRF and your settings, forms, and purchases will be transferred automatically"];

        [self presentViewController:alert animated:NO completion:nil];
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
    
    if (!hasForms && (_NumPending > 0)) {
        
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
    [self presentViewController:self.SettingsAndOptionsVC
                       animated:NO
                     completion:nil];
}

- (void)singleTap:(UITapGestureRecognizer *)sender {
    
    //check for default settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:APP_SETUP_KEY] == nil)
    {

        [self presentViewController:SettingsAndOptionsVC
                           animated:NO
                         completion:nil];
    }
    else
    {
        [self presentViewController:self.FastTutorialVC
                           animated:NO
                         completion:nil];

    }
    
}

- (void)VCComplete:(VolutaBaseViewController *)VC destinationViewController:(NSString *)VCName {
    
    [VC dismissViewControllerAnimated:NO completion:^(){
    
        if ([VCName isEqualToString:SETTINGS_VIEWCONTROLLER]) {
            
            [self presentViewController:self.SettingsAndOptionsVC
                               animated:NO
                             completion:nil];
            
        }
        else if ([VCName isEqualToString:RESUBMIT_VIEWCONTROLLER]) {
            
            [self presentViewController:self.ResubmitVC
                               animated:NO
                             completion:nil];
        }
        else if ([VCName isEqualToString:INFO_VIEWCONTROLLER] ||
                 [VCName isEqualToString:FINALIZE_VIEWCONTROLLER] ) {
            
            [self presentViewController:self.FastTutorialVC
                               animated:NO
                             completion:nil];
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

- (NSString *)CheckCRFAvailability {

    NSFileManager *FileManager = [[NSFileManager alloc] init];
    BOOL isDirectory = NO;

    NSString *crffile = [NSString stringWithFormat:@"%@/CRF",[Utilities GetSharedLocationPath:@"group.com.VolutaDigital"]];

    if([FileManager fileExistsAtPath:crffile isDirectory:&isDirectory]) {

        return @"crf installed";

    }
    else {

        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://volutadigitalvip.com/crfchk/crf_check.php"]];
        [req setHTTPMethod:@"POST"];

        NSURLResponse * response = nil;
        NSError *error;

        NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

        if (data) {

            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            // Convert the responseString into a dictionary and pull out the receipt data.
            NSDictionary *server_response = [self dictionaryFromJSONData:[responseString dataUsingEncoding:NSUTF8StringEncoding]];

            NSString *status = [server_response objectForKey:@"status"];
            NSString *appstore = [server_response objectForKey:@"app_store_link"];

            if([status isEqualToString:@"yes"])
                return appstore;
            else
                return status;
        }
    }

    return @"";
}

- (NSDictionary *)dictionaryFromJSONData:(NSData *)data
{
    NSError *error;
    NSDictionary *dictionaryParsed = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:&error];
    if (!dictionaryParsed)
    {

#ifdef DEBUG

        if (error)
        {
            NSLog(@"Error parsing dictionary");
        }

#endif

        return nil;
    }
    return dictionaryParsed;
}

#pragma mark - SettingsBackupManagerDatasource
- (NSString *)GetAppID {

    return APP_ID;
}

@end
