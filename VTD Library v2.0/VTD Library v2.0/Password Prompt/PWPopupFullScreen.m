//
//  PWPopupFullScreen.m
//  TRF
//
//  Created by Francis Bowen on 11/11/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import "PWPopupFullScreen.h"

@implementation PWPopupFullScreen

@synthesize PWPrompt;
@synthesize delegate;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        PWPrompt = [[PWPopup alloc] initWithDelegate:self withXOfffset:0.0f withYOffset:0.0f];
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    //Display passcode popup
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        [PWPrompt setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [PWPrompt setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    
    [PWPrompt setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:PWPrompt animated:YES completion:nil];
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

#pragma mark - ABPadLockScreen Delegate methods

- (void)unlockWasSuccessful
{
    [PWPrompt dismissViewControllerAnimated:YES completion:^(){
        
        if (delegate) {
            [delegate unlockWasSuccessful];
        }
    }];
}

- (void)unlockWasUnsuccessful:(int)falseEntryCode afterAttemptNumber:(int)attemptNumber
{
    //Tells you that the user performed an unsuccessfull unlock and tells you the incorrect code and the attempt number. ABLockScreen will display an error if you have
    //set an attempt limit through the datasource method, but you may wish to make a record of the failed attempt.
    
    [PWPrompt dismissViewControllerAnimated:YES completion:^(){
        
        if (delegate) {
            [delegate unlockWasUnsuccessful:falseEntryCode afterAttemptNumber:attemptNumber];
        }
    }];
    
    
}

- (void)unlockWasCancelled
{
    //This is a good place to remove the ABLockScreen
    
    [PWPrompt dismissViewControllerAnimated:YES completion:^(){
        
        if (delegate) {
            [delegate unlockWasCancelled];
        }
    }];
    
}

-(void)attemptsExpired
{
    //If you want to perform any action when the user has failed all their attempts, do so here. ABLockPad will automatically lock them from entering in any more
    //pins.
    
    [PWPrompt dismissViewControllerAnimated:YES completion:^(){
        
        if (delegate) {
            [delegate unlockWasCancelled];
        }
    }];
    
}

- (void)setPWType:(NSString *)type
{
    PWType = type;
    [PWPrompt setPWType:type];
}

- (void)setMainTitle:(NSString *)mTitle
{
    MainTitle = mTitle;
    [PWPrompt setMainTitle:mTitle];
}

- (void)setSubTitle:(NSString *)sTitle
{
    SubTitle = sTitle;
    [PWPrompt setSubTitle:sTitle];
}

- (void)setHasDone:(bool)done
{
    hasDone = done;
    [PWPrompt setHasDone:done];
}

- (void)setHasCancel:(bool)cancel
{
    hasCancel = cancel;
    [PWPrompt setHasCancel:cancel];
}


@end
