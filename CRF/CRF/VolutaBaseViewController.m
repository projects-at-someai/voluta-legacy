//
//  VolutaBaseViewController.m
//  CRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaBaseViewController.h"

@interface VolutaBaseViewController ()

@end

@implementation VolutaBaseViewController

@synthesize BaseDelegate;
@synthesize BaseBackgroundDelegate;
@synthesize backgroundImageLandscape;
@synthesize backgroundImagePortrait;
@synthesize CurrentDeviceOrientation;
@synthesize HelpButton;
@synthesize PasswordPopup;
@synthesize PasswordDelegate;
@synthesize Alerts;
@synthesize IdleSlideshowVC;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _DisableSlideshow = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *fileNamePortrait = [BaseBackgroundDelegate backgroundFileNamePortrait];
    
    _NoBackground = [fileNamePortrait isEqualToString:NO_BACKGROUND_IMAGE];
    
    if (!_NoBackground) {
        
        UIImage *imagePortrait = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:fileNamePortrait ofType:@"png"]];
        backgroundImagePortrait = [[UIImageView alloc] initWithImage:imagePortrait];
        
        NSString *fileNameLandscape = [BaseBackgroundDelegate backgroundFileNameLandscape];
        UIImage *imageLandscape = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:fileNameLandscape ofType:@"png"]];
        backgroundImageLandscape = [[UIImageView alloc] initWithImage:imageLandscape];
        
    }
    
    //create help button
    //Note: Inheritted view controllers must add help button to subview and implement Help selector
    HelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [HelpButton setBackgroundColor:[UIColor clearColor]];
    [HelpButton addTarget:self action:@selector(Help:) forControlEvents:UIControlEventTouchUpInside];
    
    Alerts = [[SharedData SharedInstance] GetAlertManager]; // This the
    
    IdleSlideshowVC = [[IdleSlideshowViewController alloc] init];
    IdleSlideshowVC.delegate = self;
    
    [self SetInitialDeviceOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self didRotate:nil withForceLayout:YES];
    
    //Idle time out notifications
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _UsingSlideshow = [defaults objectForKey:USING_SLIDESHOW_KEY];
    
    if (_UsingSlideshow != nil && [_UsingSlideshow isEqualToString:@"Yes"]) {
        
        NSString *TimeoutValue = [defaults objectForKey:SLIDESHOW_TIMEOUT_KEY];
        
        if (TimeoutValue == nil) {
            TimeoutValue = @"30 secs.";
        }
        
        CGFloat timeout = 0.0;
        
        if ([TimeoutValue isEqualToString:@"30 secs."]) {
            
            timeout = 0.5;
        }
        else
        {
            timeout = (CGFloat)[TimeoutValue intValue];
        }
        
        ((TimerUIApplication *)[UIApplication sharedApplication]).MinutesToTimeout = timeout;
        
        [(TimerUIApplication *)[UIApplication sharedApplication] resetIdleTimer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidTimeoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (BOOL)shouldAutorotate
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *orientation_value = [defaults objectForKey:ORIENTATION_KEY];
    
    if ([orientation_value isEqualToString:ORIENTATION_AUTO]) {
        
        return YES;
    }
    
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    //return UIInterfaceOrientationMaskAll;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *orientation_value = [defaults objectForKey:ORIENTATION_KEY];
    
    if ([orientation_value isEqualToString:ORIENTATION_PORTRAIT]) {
        
        return UIInterfaceOrientationMaskPortrait;
    }
    else if ([orientation_value isEqualToString:ORIENTATION_LANDSCAPE]) {
        
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
    
}

- (void) didRotate:(NSNotification *)notification
{
    [self didRotate:notification withForceLayout:NO];
}

- (void) didRotate:(NSNotification *)notification withForceLayout:(bool)forceLayout
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
                                           orientation == UIDeviceOrientationPortraitUpsideDown ||
                                           orientation == UIDeviceOrientationLandscapeLeft ||
                                           orientation == UIDeviceOrientationLandscapeRight) ? orientation : CurrentDeviceOrientation;
    
    if (_PreviousOrientation == LastOrientation && forceLayout != YES) {
        return;
    }
    
    _PreviousOrientation = LastOrientation;
    CurrentDeviceOrientation = LastOrientation;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *orientation_value = [defaults objectForKey:ORIENTATION_KEY];
    
    if ([orientation_value isEqualToString:ORIENTATION_PORTRAIT] && LastOrientation != UIDeviceOrientationPortrait && LastOrientation != UIDeviceOrientationPortraitUpsideDown) {
        
        LastOrientation = UIDeviceOrientationPortrait;
        
    }
    else if ([orientation_value isEqualToString:ORIENTATION_LANDSCAPE] && LastOrientation != UIDeviceOrientationLandscapeLeft && LastOrientation != UIDeviceOrientationLandscapeRight) {
        
        LastOrientation = UIDeviceOrientationLandscapeLeft;
    }
    
    
    if (LastOrientation == UIDeviceOrientationLandscapeLeft || LastOrientation == UIDeviceOrientationLandscapeRight) {
        
        if (!_NoBackground) {
            
            [backgroundImagePortrait removeFromSuperview];
            [self.view addSubview:backgroundImageLandscape];
            [self.view sendSubviewToBack:backgroundImageLandscape];
            [HelpButton setFrame:HELP_BUTTON_LANDSCAPE];
        }
        
    }
    else
    {
        
        if (!_NoBackground) {
            
            [backgroundImageLandscape removeFromSuperview];
            [self.view addSubview:backgroundImagePortrait];
            [self.view sendSubviewToBack:backgroundImagePortrait];
            [HelpButton setFrame:HELP_BUTTON_PORTRAIT];
        }

    }
    
    if (BaseBackgroundDelegate) {
        [BaseBackgroundDelegate RotationDetected:LastOrientation];
    }

    
}

- (void)SetInitialDeviceOrientation {
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        CurrentDeviceOrientation = UIDeviceOrientationLandscapeLeft;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        CurrentDeviceOrientation = UIDeviceOrientationLandscapeRight;
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        CurrentDeviceOrientation = UIDeviceOrientationPortrait;
    }
    else {
        CurrentDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
    }
    
    //NSLog(@"initial orientation: %ld",CurrentDeviceOrientation);
}

- (void)ShowPasswordPopup:(NSString*)Title withSubTitle:(NSString *)SubTitle withType:(NSString *)Type withHasCancel:(bool)HasCancelButton {
    
    PasswordPopup = [[PWPopup alloc] initWithDelegate:self withXOfffset:0.0f withYOffset:0.0f];
    [PasswordPopup setPWType:Type];
    [PasswordPopup setMainTitle:Title];
    [PasswordPopup setSubTitle:SubTitle];
    [PasswordPopup setHasCancel:HasCancelButton];
    
    _PasswordTitle = Title;
    
    [PasswordPopup setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [PasswordPopup setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:PasswordPopup animated:NO completion:nil];
}

#pragma mark - PWPopup
- (void)unlockWasSuccessful
{
    [PasswordPopup dismissViewControllerAnimated:NO completion:^(){
        
        if (PasswordDelegate && [PasswordDelegate respondsToSelector:@selector(PasswordSuccessful:withSuccess:)]) {
            [PasswordDelegate PasswordSuccessful:_PasswordTitle withSuccess:YES];
        }
    }];
    
}

- (void)unlockWasUnsuccessful:(int)falseEntryCode afterAttemptNumber:(int)attemptNumber
{
    [PasswordPopup dismissViewControllerAnimated:NO completion:^(){
    
        if (PasswordDelegate && [PasswordDelegate respondsToSelector:@selector(PasswordSuccessful:withSuccess:)]) {
            [PasswordDelegate PasswordSuccessful:_PasswordTitle withSuccess:NO];
        }
    }];
    
}

- (void)unlockWasCancelled
{
    [PasswordPopup dismissViewControllerAnimated:NO completion:^(){
       
        if (PasswordDelegate && [PasswordDelegate respondsToSelector:@selector(PasswordPromptCanceled:)]) {
            [PasswordDelegate PasswordPromptCanceled:_PasswordTitle];
        }
        
    }];
}

-(void)attemptsExpired
{
    if (PasswordDelegate && [PasswordDelegate respondsToSelector:@selector(PasswordPromptMaxAttempts:)]) {
        [PasswordDelegate PasswordPromptMaxAttempts:_PasswordTitle];
    }
    
}

- (UIDeviceOrientation)GetDeviceOrientation {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
                                           orientation == UIDeviceOrientationPortraitUpsideDown ||
                                           orientation == UIDeviceOrientationLandscapeLeft ||
                                           orientation == UIDeviceOrientationLandscapeRight) ? orientation : [[SharedData SharedInstance] GetDeviceOrientation];
    
    [[SharedData SharedInstance] SetDeviceOrientation:LastOrientation];
    
    return LastOrientation;
}

#pragma mark - PopoverRotationDelegate
- (UIDeviceOrientation)getDeviceOrientation {
    
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
    
    return orientation;
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
    
    [[SharedData SharedInstance] SetDeviceOrientation:orientation];
}

#pragma -
#pragma IdleSlideshowDelegate
- (void)SlideshowComplete
{
    [self.IdleSlideshowVC dismissViewControllerAnimated:NO completion:nil];
}

- (ImageListManager *)GetImageListManager {
    
    return [[SharedData SharedInstance] GetImageListManager];
}

- (NSString *)GetSlideshowTitle {
    
    return @"Tap to resume Cosmetic Release Forms App";
}

#pragma -
#pragma Application Timeout
-(void)applicationDidTimeout:(NSNotification *) notif
{
    NSLog (@"time exceeded!!");
    
    if (_UsingSlideshow != nil && [_UsingSlideshow isEqualToString:@"Yes"] && !_DisableSlideshow) {
        
        [self presentViewController:self.IdleSlideshowVC animated:YES completion:NULL];
    }
}

- (BOOL)IsResubmitting {
    
    /*
     FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
     
     return [_FormDataManager GetIsResubmitting];
     */
    
    return [[SharedData SharedInstance] GetIsResubmitting];
}

- (void)SetResubmitting:(BOOL)Resubmitting {
    
    /*
     FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
     
     [_FormDataManager SetIsResubmitting:Resubmitting];
     */
    
    [[SharedData SharedInstance] SetIsResubmitting:Resubmitting];
}

@end
