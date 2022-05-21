//
//  IDVerifyViewController.m
//  LRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "IDVerifyViewController.h"

@interface IDVerifyViewController ()

@end

@implementation IDVerifyViewController

@synthesize InfoVC;
@synthesize IDImgView;
@synthesize StartOverButton;
@synthesize RetakePhotoButton;
@synthesize UsePhotoButton;
@synthesize RetakeDelegate;
@synthesize PDFPreviewVC;

- (void)viewDidLoad {
    
    self.BaseBackgroundDelegate = self;
    self.OptionsDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    InfoVC = [[InfoViewController alloc] init];
    InfoVC.BaseDelegate = self;
    
    IDImgView = [[UIImageView alloc] init];
    [self.view addSubview:IDImgView];
    
    StartOverButton = [[UIButton alloc] init];
    StartOverButton.backgroundColor = [UIColor clearColor];
    [StartOverButton addTarget:self action:@selector(StartOver:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:StartOverButton];
    
    RetakePhotoButton = [[UIButton alloc] init];
    RetakePhotoButton.backgroundColor = [UIColor clearColor];
    [RetakePhotoButton addTarget:self action:@selector(RetakeID:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:RetakePhotoButton];
    
    UsePhotoButton = [[UIButton alloc] init];
    UsePhotoButton.backgroundColor = [UIColor clearColor];
    [UsePhotoButton addTarget:self action:@selector(ConfirmID:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:UsePhotoButton];
    
    //Add help button from base view controller to view
    [self.view addSubview:self.HelpButton];
    
    //Setup options button
    [self SetupPasswordPromptParameters:@"App Options"
                           withSubTitle:@"Enter Specialist Passcode"
                               withType:SECONDARY_PW_TYPE
                          withHasCancel:YES];
    self.RequiresPassword = YES;

    _DisableSlideshow = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    IDImgView.image = [_FormDataManager GetFormImagesValue:CLIENT_ID_IMAGE];
    
    NSString *additionalform = [[NSUserDefaults standardUserDefaults] objectForKey:USING_ADDITIONAL_FORM_KEY];
    NSString *pdf = [[NSUserDefaults standardUserDefaults] objectForKey:ADD_FORM_FILENAME_KEY];
    
    _WillShowAdditionalForm = (pdf != nil &&
                               additionalform != nil &&
                               [additionalform isEqualToString:@"Yes"]);
    
    if ([_FormDataManager GetIsResubmitting]) {
        
        [self presentViewController:self.InfoVC
                           animated:YES
                         completion:NULL];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    IDImgView.image = nil;
}

- (NSString *)backgroundFileNamePortrait {
    
    return IDVERIFY_PORTRAIT;
}

- (NSString *)backgroundFileNameLandscape {
    
    return IDVERIFY_LANDSCAPE;
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {
    
    //DLog(@"orientation: %ld", orientation);
    
    [super RotationDetected:orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        [IDImgView setFrame:IDVERIFY_IMGVIEW_LANDSCAPE];
        [StartOverButton setFrame:IDVERIFY_STARTOVER_BUTTON_LANDSCAPE];
        [RetakePhotoButton setFrame:IDVERIFY_RETAKE_BUTTON_LANDSCAPE];
        [UsePhotoButton setFrame:IDVERIFY_USE_BUTTON_LANDSCAPE];
    }
    else {
        
        [IDImgView setFrame:IDVERIFY_IMGVIEW_PORTRAIT];
        [StartOverButton setFrame:IDVERIFY_STARTOVER_BUTTON_PORTRAIT];
        [RetakePhotoButton setFrame:IDVERIFY_RETAKE_BUTTON_PORTRAIT];
        [UsePhotoButton setFrame:IDVERIFY_USE_BUTTON_PORTRAIT];
    }
}

- (void)ShowAdditionalForm {
    
    NSString *pdf = [[NSUserDefaults standardUserDefaults] objectForKey:ADD_FORM_FILENAME_KEY];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *dataPath = [documentsDir stringByAppendingFormat:@"/%@",pdf];
    
    PDFPreviewVC = [[PDFPreviewViewController alloc] initWithPDFPath:dataPath withTitle:@"Please read through this before you start. Click on the button below to acknowledge."];
    PDFPreviewVC.delegate = self;
    
    [self presentViewController:PDFPreviewVC animated:NO completion:nil];
}

- (void)ConfirmID:(id)sender
{
    
    if (_WillShowAdditionalForm) {
        
        [self ShowAdditionalForm];
    }
    else {
    
        [self presentViewController:self.InfoVC
                           animated:YES
                         completion:NULL];
    }
    
}

- (void)RetakeID:(id)sender
{
    if (RetakeDelegate) {
        
        [RetakeDelegate RetakeID];
    }
}


- (void)StartOver:(id)sender
{
    
    UIAlertController *StartOverAlert = [self.Alerts CreateYesNoAlert:^(UIAlertAction *action) {
        
        if (self.BaseDelegate) {
            [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
        }
    }
                                                        withNoHandler:^(UIAlertAction *action) {
                                                            
                                                        }
                                                            withTitle:@"Start Over"
                                                          withMessage:@"Are you sure you want to start over?"];
    
    [self presentViewController:StartOverAlert animated:NO completion:nil];
    
}

- (void)Help:(id)sender
{
    UIAlertController *helpAlert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Help" withMessage:@"START OVER:\nBack to the main screen\n\nRETAKE PHOTO:\nWe'd love a clear bright photo.\n\nUSE PHOTO:\nThis will use your photo and move you to the next page in our app.\n\nLIGHT-SPEED FOR RETURN CLIENTS :\nSearch for you a the top of the screen by your first or last name. Your specialist will authorize the search to ensure client privacy. You can look over your old form and if it looks good, re-sign and your done. If you need to change anything you can make a new form from scratch."];
    
    [self presentViewController:helpAlert animated:NO completion:nil];
    
}

- (void)VCComplete:(VolutaBaseViewController *)VC destinationViewController:(NSString *)VCName {
    
    [VC dismissViewControllerAnimated:NO completion:^(){
        
        if (self.BaseDelegate) {
            [self.BaseDelegate VCComplete:self destinationViewController:VCName];
        }
        
    }];
    
}

- (void)OptionsTapped:(BaseWithOptionsButtonViewController *)VC withPasswordPromptTitle:(NSString *)Title
{
    if ([Title isEqualToString:@"App Options"]) {
        
        UIAlertController *OptionsAlert = [self.Alerts CreateOptionsAlert:^(UIAlertAction *action){}
                                                      withStartOverAction:^(UIAlertAction *action){
                                                          
                                                          [self SetResubmitting:NO];
                                                          
                                                          if (self.BaseDelegate) {
                                                              [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
                                                          }
                                                          
                                                      }
                                                       withSettingsAction:^(UIAlertAction *action) {
                                                           
                                                           [self SetResubmitting:NO];
                                                           
                                                           if (self.BaseDelegate) {
                                                               [self.BaseDelegate VCComplete:self destinationViewController:SETTINGS_VIEWCONTROLLER];
                                                           }
                                                           
                                                       }];
        
        [self presentViewController:OptionsAlert animated:NO completion:nil];
    }
    
}

#pragma mark - PDFPreviewPopupDelegate
- (void)PDFPreviewComplete {
    
    [PDFPreviewVC dismissViewControllerAnimated:NO completion:^(){
        
        [self presentViewController:self.InfoVC
                           animated:YES
                         completion:NULL];
        
    }];
}

@end
