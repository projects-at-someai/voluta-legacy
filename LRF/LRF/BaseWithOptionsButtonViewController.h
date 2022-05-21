//
//  BaseWithOptionsButtonViewController.h
//  LRF
//
//  Created by Francis Bowen on 5/25/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaBaseViewController.h"
#import "SearchResultsViewController.h"

#define OPTIONS_BUTTON_PORTRAIT         CGRectMake(660.0f, 920.0f, 80.0f, 80.0f)
#define OPTIONS_BUTTON_LANDSCAPE        CGRectMake(920.0f, 660.0f, 80.0f, 80.0f)

@class BaseWithOptionsButtonViewController;

@protocol BaseOptionsDelegate <NSObject>

@required
- (void)OptionsTapped:(BaseWithOptionsButtonViewController *)VC withPasswordPromptTitle:(NSString *)Title;

@end

@interface BaseWithOptionsButtonViewController : VolutaBaseViewController <
    BasePasswordDelegate,
    UISearchBarDelegate,
    UITextFieldDelegate,
    SearchResultsPopupDelegate
>
{
    NSString *_PasswordPromptTitle;
    NSString *_PasswordPromptSubTitle;
    NSString *_PasswordPromptType;
    bool _PasswordPromptHasCancelButton;
    NSString *_SearchText;
    bool _IsSearching;
    NSArray *_SearchResults;
}

@property (assign) id<BaseOptionsDelegate> OptionsDelegate;

@property (assign) bool RequiresPassword;
@property (retain) UIButton *OptionsButton;
@property (retain) UISearchBar *SearchBar;
@property (retain) SearchResultsViewController *SearchResultsVC;

- (void)RotationDetected:(UIDeviceOrientation)orientation;
- (void)SetupPasswordPromptParameters:(NSString *)Title withSubTitle:(NSString *)SubTitle withType:(NSString *)Type withHasCancel:(bool)PasswordHasCancelButton;

- (BOOL)IsResubmitting;
- (void)SetResubmitting:(BOOL)Resubmitting;

@end
