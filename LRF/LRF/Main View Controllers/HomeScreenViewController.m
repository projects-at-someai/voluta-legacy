//
//  HomeScreenViewController.m
//  LRF
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
    
    _FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
    _CoreDataManager = [_FormDataManager GetCoreData];
    
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
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (![_FormDataManager GetIsResubmitting] && ![[SharedData SharedInstance] CheckResubmitting]) {
        
        [_FormDataManager ClearAll];
    }

#ifndef IS_UNLIMITED
    
    InAppPurchaseManager *IAPManager = [[SharedData SharedInstance] GetIAPManager];
    [IAPManager VerifySubscriptions];
    
#endif
    
    [[SharedData SharedInstance] SetGoingToResubmit:NO];
    
    [self CheckAndDeleteDirectory:[[SharedData SharedInstance] GetTempPath]];
    
    [self CheckAndServicePendingUploads];
    
}

- (void)CheckAndDeleteDirectory:(NSString *)Path {
    
    NSFileManager *FileManager = [[NSFileManager alloc] init];
    
    BOOL isDirectory = true;
    NSError *error = nil;
    
    if([FileManager fileExistsAtPath:Path isDirectory:&isDirectory]) {
        
        DLog(@"Deleting directory: %@", Path);
        [FileManager removeItemAtPath:Path error:&error];
    }
    
    
    [FileManager createDirectoryAtPath:Path
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error];
}

- (void)CheckAndServicePendingUploads {
    
    _NumPending = [_CoreDataManager NumPendingUploads];
    
    if ([Utilities HasNetworkConnectivity] && (_NumPending > 0)) {
        
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
                                                   withNoHandler:^(UIAlertAction *action){}
                                                       withTitle:@"Pending Uploads"
                                                     withMessage:[NSString stringWithFormat:@"You have %lu pending uploads. Do you want to upload them now?",(unsigned long)_NumPending]];
        
        [self presentViewController:alert animated:NO completion:nil];
        
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
        else if ([VCName isEqualToString:INFO_VIEWCONTROLLER]) {
            
            [self presentViewController:self.FastTutorialVC
                               animated:NO
                             completion:nil];
        }
        
    }];
    
}

#pragma mark - CloudServicePendingUploadDelegate
- (void)PendingUploadComplete:(bool)UploadSuccessful {
    
    if (!_LTRPendingUploader) {
        
        _LTRPendingUploader = [[LTRPendingUploader alloc] init];
        _LTRPendingUploader.delegate = self;
    }
    
    _PendingAlert.message = [NSString stringWithFormat:@"Uploading treatment record 1 of %lu\n\n\n\n\n",(unsigned long)_NumPending];
    
    [_LTRPendingUploader UploadPendingTreatmentRecords:_PendingList];
    
    /*
    [_PendingAlert dismissViewControllerAnimated:NO completion:^(){

        NSString *msg = @"All your pending forms have been uploaded";
        
        if (!UploadSuccessful) {
            msg = @"There was a problem uploading your forms. We will try again later.";
        }
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Pending Uploads" withMessage:msg];
        
        [self presentViewController:alert animated:NO completion:nil];
     
    }];
    */
}

- (void)PendingUploadProgress:(NSUInteger)CurrentPendingNum withTotal:(NSUInteger)TotalToUpload {
    
    NSString *msg = [NSString stringWithFormat:@"Uploading form %u of %d\n\n\n\n\n",(CurrentPendingNum + 1),_NumPending];
    _PendingAlert.message = msg;
}

- (FormDataManager *)GetFormDataManager {
    
    return _FormDataManager;
}

- (NSString *)GetTempPath {
    
    return [[SharedData SharedInstance] GetTempPath];
}

#pragma mark - PendingTreatmentRecordUploaderDelegate
- (void)PendingTreatmentRecordUploadComplete:(bool)UploadSuccessful {
    
    [_PendingAlert dismissViewControllerAnimated:NO completion:^(){
        
        if (!_LTRPendingUploader) {
            
            _LTRPendingUploader = [[LTRPendingUploader alloc] init];
            _LTRPendingUploader.delegate = self;
        }
        
        NSString *msg = @"All your pending forms and treatment records have been uploaded";
        
        if (!UploadSuccessful) {
            msg = @"There was a problem uploading your forms and treatment records.";
        }
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Pending Uploads" withMessage:msg];
        
        [self presentViewController:alert animated:NO completion:nil];
        
    }];
}

- (void)PendingTreatmentRecordUploadProgress:(NSUInteger)NumUploaded withTotal:(NSUInteger)TotalToUpload {
    
    NSString *msg = [NSString stringWithFormat:@"Uploading treatment record %u of %d\n\n\n\n\n",(NumUploaded + 1),_NumPending];
    _PendingAlert.message = msg;
}

- (LTRCoreDataManager *)GetLTRCoreDataManager {
    
    return [[SharedData SharedInstance] GetLTRCoreDataManager];
}

- (CloudServiceManager *)GetCloudServiceManager {

    return [[SharedData SharedInstance] GetCloudServices];
}

@end
