//
//  FastTutorialViewController.h
//  PRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseWithOptionsButtonViewController.h"
#import "VolutaBaseViewController.h"
#import "Camera.h"

#define LOGO_PORTRAIT                       CGRectMake(161.0f, 660.0f, 450.0f, 300.0f)
#define NEW_CLIENT_BUTTON_PORTRAIT          CGRectMake(135.0f, 20.0f, 500.0f, 130.0f)
#define RETURN_CLIENT_SEARCHBAR_PORTRAIT    CGRectMake(155.0f, 305.0f, 460.0f, 55.0f)
#define WELCOME_BUTTON_PORTRAIT             CGRectMake(135.0f, 400.0f, 500.0f, 210.0f)

#define LOGO_LANDSCAPE                      CGRectMake(522.0f, 55.0f, 450.0f, 300.0f)
#define NEW_CLIENT_BUTTON_LANDSCAPE         CGRectMake(20.0f, 20.0f, 450.0f, 130.0f)
#define RETURN_CLIENT_SEARCHBAR_LANDSCAPE   CGRectMake(40.0f, 315.0f, 410.0f, 55.0f)
#define WELCOME_BUTTON_LANDSCAPE            CGRectMake(500.0f, 420.0f, 500.0f, 210.0f)

@interface FastTutorialViewController : BaseWithOptionsButtonViewController <
    BaseViewControllerDelegate,
    BaseViewControllerBackgroundDelegate,
    BaseOptionsDelegate
>
{
    
}

@property (retain) UIImageView *LogoImg;
@property (retain) UIButton *NewClientButton;
@property (retain) UIButton *WelcomeButton;

@end
