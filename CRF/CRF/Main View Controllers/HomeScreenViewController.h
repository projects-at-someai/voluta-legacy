//
//  HomeScreenViewController.h
//  CRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseWithOptionsButtonViewController.h"
#import "FastTutorialViewController.h"
#import "IDCaptureViewController.h"
#import "IDVerifyViewController.h"
#import "InfoViewController.h"
#import "HowToViewController.h"
#import "FinalizeViewController.h"
#import "SettingsAndOptionsViewController.h"
#import "ResubmitViewController.h"
#import "LongTutorialViewController.h"

#define SETTINGS_BUTTON_PORTRAIT          CGRectMake(660.0f, 920.0f, 80.0f, 80.0f)
#define SETTINGS_BUTTON_LANDSCAPE         CGRectMake(920.0f, 660.0f, 80.0f, 80.0f)

#define VERSION_LABEL_PORTRAIT            CGRectMake(0.0f, 960.0f, 768.0f, 50.0f)
#define VERSION_LABEL_LANDSCAPE           CGRectMake(0.0f, 700.0f, 1024.0f, 50.0f)

@interface HomeScreenViewController : BaseWithOptionsButtonViewController
<
    BaseViewControllerBackgroundDelegate,
    BaseViewControllerDelegate,
    UIGestureRecognizerDelegate,
    BaseOptionsDelegate,
    CloudServicePendingUploadDelegate,
    SettingsBackupManagerDelegate
>
{
    CoreDataManager *_CoreDataManager;
    UIAlertController *_PendingAlert;
    NSUInteger _NumPending;
    NSArray *_PendingList;

    NSMutableDictionary *_ViewControllers;

    FastTutorialViewController *_FastTutorialVC;
    IDCaptureViewController *_IDCaptureVC;
    IDVerifyViewController *_IDVerifyVC;
    LongTutorialViewController *_LongTutorialVC;
    InfoViewController *_InfoVC;
    HowToViewController *_HowToVC;
    FinalizeViewController *_FinalizeVC;
    ResubmitViewController *_ResubmitVC;
    SettingsAndOptionsViewController *_SettingsVC;

    NSString *_CurrentScreen;
}

- (void)CheckSharedDirectory;

@property (retain) UIGestureRecognizer *SingleTapGesture;

@property (retain) UILabel *VersionLabel;

@end
