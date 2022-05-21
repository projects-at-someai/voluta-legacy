//
//  VolutaBaseViewController.h
//  TRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWPopup.h"
#import "SharedData.h"
#import "AlertManager.h"
#import "Utilities.h"
#import "IdleSlideshowViewController.h"
#import "TimerUIApplication.h"
#import <Crashlytics/Crashlytics.h>

#define HELP_BUTTON_PORTRAIT        CGRectMake(30.0f, 920.0f, 60.0f, 80.0f)
#define HELP_BUTTON_LANDSCAPE       CGRectMake(20.0f, 660.0f, 60.0f, 80.0f)

@class VolutaBaseViewController;

@protocol BaseViewControllerBackgroundDelegate <NSObject>
@required

- (NSString *)backgroundFileNamePortrait;
- (NSString *)backgroundFileNameLandscape;

@optional
- (void)RotationDetected:(UIDeviceOrientation)orientation;

@end

@protocol BaseViewControllerDelegate <NSObject>

@optional
- (void)VCComplete:(VolutaBaseViewController *)VC destinationViewController:(NSString *)VCName;

@end

@protocol BasePasswordDelegate <NSObject>

@optional
- (void)PasswordSuccessful:(NSString *)PasswordPromptTitle withSuccess:(bool)Success;
- (void)PasswordPromptCanceled:(NSString *)PasswordPromptTitle;
- (void)PasswordPromptMaxAttempts:(NSString *)PasswordPromptTitle;

@end

@interface VolutaBaseViewController : UIViewController <PWPopupDelegate, IdleSlideshowDelegate>
{
    UIDeviceOrientation _PreviousOrientation;
    
    bool _NoBackground;
    
    NSString *_PasswordTitle;
    
    NSString *_UsingSlideshow;
    BOOL _DisableSlideshow;
}

//Properties
@property (assign) UIDeviceOrientation CurrentDeviceOrientation;

@property (assign) id<BaseViewControllerBackgroundDelegate> BaseBackgroundDelegate;
@property (assign) id<BaseViewControllerDelegate> BaseDelegate;
@property (assign) id<BasePasswordDelegate> PasswordDelegate;

@property (retain) UIImageView *backgroundImagePortrait;
@property (retain) UIImageView *backgroundImageLandscape;

@property (retain) UIButton *HelpButton;

@property (retain) PWPopup *PasswordPopup;

@property (retain) AlertManager *Alerts;

@property (retain) IdleSlideshowViewController *IdleSlideshowVC;

//Function declarations
- (id)initWithParentViewController:(UIViewController *)parentVC;

- (void)ShowPasswordPopup:(NSString*)Title withSubTitle:(NSString *)SubTitle withType:(NSString *)Type withHasCancel:(bool)HasCancelButton;

- (UIDeviceOrientation)GetDeviceOrientation;

- (BOOL)IsResubmitting;
- (void)SetResubmitting:(BOOL)Resubmitting;

//Popover delegates
- (UIDeviceOrientation)getDeviceOrientation;
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation;

@end
