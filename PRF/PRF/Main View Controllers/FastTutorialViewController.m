//
//  FastTutorialViewController.m
//  LRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "FastTutorialViewController.h"

@interface FastTutorialViewController ()

@end

@implementation FastTutorialViewController

@synthesize LogoImg;
@synthesize NewClientButton;
@synthesize WelcomeButton;

- (void)viewDidLoad {
    
    self.BaseBackgroundDelegate = self;
    self.OptionsDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Add help button from base view controller to view
    [self.view addSubview:self.HelpButton];
    
    [self LoadLogoImage];
    
    NewClientButton = [[UIButton alloc] init];
    [NewClientButton setBackgroundImage:nil forState:UIControlStateNormal];
    [NewClientButton addTarget:self action:@selector(BeginApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:NewClientButton];
    
    WelcomeButton = [[UIButton alloc] init];
    [WelcomeButton setBackgroundImage:nil forState:UIControlStateNormal];
    [WelcomeButton addTarget:self action:@selector(BeginLongTutorial:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:WelcomeButton];

    //Setup options button
    [self SetupPasswordPromptParameters:@"App Options"
                           withSubTitle:@"Enter Artist Passcode"
                               withType:SECONDARY_PW_TYPE
                          withHasCancel:YES];
    self.RequiresPassword = YES;
    
    _DisableSlideshow = YES;
    
    //Add search bar to view
    [self.view addSubview:self.SearchBar];
    
}

- (void)viewDidAppear:(BOOL)animated {

    CLS_LOG(@"fast tutorial vc");
    
    [super viewDidAppear:animated];
    
    if ([self IsResubmitting]) {
        
        [self BeginApp:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)backgroundFileNamePortrait {
    
    return FASTTUTORIAL_PORTRAIT;
}

- (NSString *)backgroundFileNameLandscape {
    
    return FASTTUTORIAL_LANDSCAPE;
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {
    
    //NSLog(@"orientation: %ld", orientation);
    
    [super RotationDetected:orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        [NewClientButton setFrame:NEW_CLIENT_BUTTON_LANDSCAPE];
        [WelcomeButton setFrame:WELCOME_BUTTON_LANDSCAPE];
        [LogoImg setFrame:LOGO_LANDSCAPE];
        [self.SearchBar setFrame:RETURN_CLIENT_SEARCHBAR_LANDSCAPE];
    }
    else {
        
        [NewClientButton setFrame:NEW_CLIENT_BUTTON_PORTRAIT];
        [WelcomeButton setFrame:WELCOME_BUTTON_PORTRAIT];
        [LogoImg setFrame:LOGO_PORTRAIT];
        [self.SearchBar setFrame:RETURN_CLIENT_SEARCHBAR_PORTRAIT];
    }
}

- (void)BeginApp:(id)sender
{
    [self GoToCaptureOrInfo];
    
}

- (void)GoToCaptureOrInfo {
    
    NSString *IDCapture = [[NSUserDefaults standardUserDefaults] objectForKey:CAPTURE_ID_KEY];
    
    if ([IDCapture isEqualToString:@"Yes"]) {
        
        bool CameraAvailable = NO;
        
#if !(TARGET_OS_SIMULATOR)
        
        CameraAvailable = [Camera CheckForPermission];
        
#else
        
        CameraAvailable = YES;
        
#endif
        
        if (CameraAvailable) {
            
            [self.BaseDelegate VCComplete:self destinationViewController:IDCAPTURE_VIEWCONTROLLER];

        }
        else {
        
            UIAlertController *alert = [self.Alerts
                                        CreateOKAlert:^(UIAlertAction *action)
            {
                [Camera PresentAuthDialog];
            
            }
                                        withTitle:@"Camera Error"
                                        withMessage:@"PRF does not have access to your camera. You can grant access in the next dialog\nOR\nGo to iPad Settings > Left Pane, scroll down to PRF > Tap PRF icon, slide camera to Green. Enjoy!"];
            
            [self presentViewController:alert animated:NO completion:nil];
            
        }

    }
    else {
        
        [self.BaseDelegate VCComplete:self destinationViewController:INFO_VIEWCONTROLLER];
    }
    
}

- (void)BeginLongTutorial:(id)sender
{
    [self.BaseDelegate VCComplete:self destinationViewController:LONGTUTORIAL_VIEWCONTROLLER];
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

- (void)LoadLogoImage
{
    if (self.LogoImg == nil) {
        
        self.LogoImg = [[UIImageView alloc] init];
    }
    
    NSString *hasLogo = [[NSUserDefaults standardUserDefaults] objectForKey:USING_LOGO_KEY];
    
    if (hasLogo != nil && [hasLogo isEqualToString:@"Yes"])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"logo.png"]; //Add the file name
        
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        
        self.LogoImg.image = [UIImage imageWithData:pngData];
        self.LogoImg.backgroundColor = [UIColor blackColor];
        self.LogoImg.contentMode = UIViewContentModeScaleAspectFit;
        self.LogoImg.clipsToBounds = YES;
        
        pngData = nil;
        
        [self.view addSubview:LogoImg];
    }
    
}

- (void)Help:(id)sender
{
    UIAlertController *helpAlert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Help" withMessage:@"HELP: Told you we'd be here for you!"];
    
    [self presentViewController:helpAlert animated:NO completion:nil];
    
}

@end
