//
//  IDVerifyViewController.h
//  PRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseWithOptionsButtonViewController.h"
#import "PDFPreviewViewController.h"

#define IDVERIFY_IMGVIEW_PORTRAIT                  CGRectMake(123.0f, 78.0f, 525.0f, 294.0f)
#define IDVERIFY_STARTOVER_BUTTON_PORTRAIT         CGRectMake(90.0f, 490.0f, 147.0f, 50.0f)
#define IDVERIFY_RETAKE_BUTTON_PORTRAIT            CGRectMake(310.0f, 490.f, 147.0f, 50.0f)
#define IDVERIFY_USE_BUTTON_PORTRAIT               CGRectMake(533.0f, 490.0f, 147.0f, 50.0f)

#define IDVERIFY_IMGVIEW_LANDSCAPE                 CGRectMake(254.0f, 54.0f, 525.0f, 294.0f)
#define IDVERIFY_STARTOVER_BUTTON_LANDSCAPE        CGRectMake(220.0f, 470.0f, 147.0f, 50.0f)
#define IDVERIFY_RETAKE_BUTTON_LANDSCAPE           CGRectMake(440.0f, 470.0f, 147.0f, 50.0f)
#define IDVERIFY_USE_BUTTON_LANDSCAPE              CGRectMake(663.0f, 470.0f, 147.0f, 50.0f)

@protocol RetakeViewControllerDelegate <NSObject>
@required

- (void)RetakeID;

@end

@interface IDVerifyViewController : BaseWithOptionsButtonViewController <
    BaseViewControllerDelegate,
    BaseViewControllerBackgroundDelegate,
    BaseOptionsDelegate,
    PDFPreviewPopupDelegate
>
{
    bool _WillShowAdditionalForm;
}

@property (assign) id<RetakeViewControllerDelegate> RetakeDelegate;

@property (retain) UIImageView *IDImgView;
@property (retain) UIButton *StartOverButton;
@property (retain) UIButton *RetakePhotoButton;
@property (retain) UIButton *UsePhotoButton;

@property (retain) PDFPreviewViewController *PDFPreviewVC;

- (void)ConfirmID:(id)sender;
- (void)RetakeID:(id)sender;

- (void)StartOver:(id)sender;
- (void)Help:(id)sender;

@end
