//
//  IDCaptureViewController.h
//  LRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseWithOptionsButtonViewController.h"
#import "IDVerifyViewController.h"
#import "Camera.h"

#define IDCAPTURE_IMGVIEW_PORTRAIT                  CGRectMake(123.0f, 78.0f, 525.0f, 294.0f)
#define IDCAPTURE_STARTOVER_BUTTON_PORTRAIT         CGRectMake(90.0f, 490.0f, 147.0f, 50.0f)
#define IDCAPTURE_CAMERA_SEGMENT_PORTRAIT           CGRectMake(285.0f, 490.0f, 200.0f, 50.0f)
#define IDCAPTURE_TAKE_PICTURE_BUTTON_PORTRAIT      CGRectMake(533.0f, 490.0f, 147.0f, 50.0f)

#define IDCAPTURE_IMGVIEW_LANDSCAPE                 CGRectMake(254.0f, 54.0f, 525.0f, 294.0f)
#define IDCAPTURE_STARTOVER_BUTTON_LANDSCAPE        CGRectMake(220.0f, 470.0f, 147.0f, 50.0f)
#define IDCAPTURE_CAMERA_SEGMENT_LANDSCAPE          CGRectMake(420.0f, 470.0f, 200.0f, 50.0f)
#define IDCAPTURE_TAKE_PICTURE_BUTTON_LANDSCAPE     CGRectMake(663.0f, 470.0f, 147.0f, 50.0f)

@interface IDCaptureViewController : BaseWithOptionsButtonViewController <
    BaseViewControllerDelegate,
    BaseViewControllerBackgroundDelegate,
    BaseOptionsDelegate,
    RetakeViewControllerDelegate,
    CameraCompleteDelegate,
    UIGestureRecognizerDelegate
>
{
    
}

@property (retain) UIGestureRecognizer *SingleTapGesture;
@property (retain) IDVerifyViewController *IDVerifyVC;
@property (retain) Camera *IDCamera;
@property (retain) NSString *CameraType;

@property (retain) UIView *VideoPreviewView;
@property (retain) UIButton *TakePictureButton;
@property (retain) UIButton *StartOverButton;
@property (retain) UISegmentedControl *CameraTypeSegment;
@property (retain) UIButton *GoBackButton;

@end
