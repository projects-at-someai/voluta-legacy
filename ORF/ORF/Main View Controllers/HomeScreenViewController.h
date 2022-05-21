//
//  HomeScreenViewController.h
//  ORF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseWithOptionsButtonViewController.h"
#import "FastTutorialViewController.h"
#import "SettingsAndOptionsViewController.h"
#import "ResubmitViewController.h"

#define SETTINGS_BUTTON_PORTRAIT          CGRectMake(660.0f, 920.0f, 80.0f, 80.0f)
#define SETTINGS_BUTTON_LANDSCAPE         CGRectMake(920.0f, 660.0f, 80.0f, 80.0f)

#define VERSION_LABEL_PORTRAIT            CGRectMake(0.0f, 965.0f, 768.0f, 50.0f)
#define VERSION_LABEL_LANDSCAPE           CGRectMake(0.0f, 713.0f, 1024.0f, 50.0f)

@interface HomeScreenViewController : BaseWithOptionsButtonViewController
<
    BaseViewControllerBackgroundDelegate,
    BaseViewControllerDelegate,
    UIGestureRecognizerDelegate,
    BaseOptionsDelegate,
    CloudServicePendingUploadDelegate
>
{
    CoreDataManager *_CoreDataManager;
    UIAlertController *_PendingAlert;
    NSUInteger _NumPending;
    NSArray *_PendingList;
}

@property (retain) UIGestureRecognizer *SingleTapGesture;

@property (retain) FastTutorialViewController *FastTutorialVC;
@property (retain) SettingsAndOptionsViewController *SettingsAndOptionsVC;
@property (retain) ResubmitViewController *ResubmitVC;

@property (retain) UILabel *VersionLabel;

@end
