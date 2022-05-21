//
//  ResubmitViewController.h
//  TRF
//
//  Created by Francis Bowen on 6/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaBaseViewController.h"
#import "ResubmitOptionsViewController.h"
#import "SharedData.h"
#import "AppDelegate.h"

#define RESUBMIT_SIGNATUREPAD_WIDTH  500.0f
#define RESUBMIT_SIGNATUREPAD_HEIGHT 200.0f

#define RESUBMIT_PDFVIEW_PORTRAIT        CGRectMake(20.0f, 73.0f, 728.0f, 538.0f)
#define RESUBMIT_SIGNATURE_PORTRAIT      CGRectMake(134.0, 688.0f, 500.0f, 200.0f)
#define RESUBMIT_SIGNATURELINE_PORTRAIT  CGRectMake(25.0f, 100.0f, 450.0f, 75.0f)
#define RESUBMIT_CLEAR_PORTRAIT          CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)
#define RESUBMIT_SUBMIT_PORTRAIT         CGRectMake(419.0f, 915.0f, 329.0f, 95.0f)
#define RESUBMIT_OPTIONS_PORTRAIT        CGRectMake(20.0f, 915.0f, 329.0f, 95.0f)

#define RESUBMIT_PDFVIEW_LANDSCAPE       CGRectMake(225.0f, 75.0f, 570.0f, 375.0f)
#define RESUBMIT_SIGNATURE_LANDSCAPE     CGRectMake(260.0f, 500.0f, 500.0f, 175.0f)
#define RESUBMIT_SIGNATURELINE_LANDSCAPE CGRectMake(25.0f, 100.0f, 450.0f, 75.0f)
#define RESUBMIT_CLEAR_LANDSCAPE         CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)
#define RESUBMIT_SUBMIT_LANDSCAPE        CGRectMake(540.0f, 686.0f, 220.0f, 60.0f)
#define RESUBMIT_OPTIONS_LANDSCAPE       CGRectMake(268.0f, 686.0f, 220.0f, 60.0f)

@protocol ResubmitCompleteDelegate
@optional
- (void)ResubmitComplete;
- (void)ResubmitMakeChanges;
@end

@interface ResubmitViewController : VolutaBaseViewController <
    BaseViewControllerBackgroundDelegate,
    ResubmitOptionsPopupDelegate,
    PopoverRotationDelegate,
    FormDataManagerPDFDelegates,
    CloudServiceUploadDelegate,
    EmailerDelegate
>
{
    CGPoint _lastPoint;
    
    BOOL _mouseSwiped;
    int _mouseMoved;
    
    BOOL _displayedAlert;
    
    UIAlertController *_BusyAlert;
    
    BOOL _isSubmitting;
    
    Emailer *_Emailer;
    NSUInteger _EmailsToSend;
    NSString *_PDFFullPath;
    UIAlertController *_EmailAlert;
}

@property (strong, retain) UIWebView *PDFViewer;

@property (retain) UIImageView *Sketch_ImageView;
@property (retain) UIView *signaturePadView;

@property (retain) UIImageView *drawImage;
@property (retain) UIImageView *signatureLineView;
@property (retain) UIImage *signatureLine;
@property (retain) UIButton *clearButton;
@property (retain) NSMutableArray *points;

@property (retain) UIButton *SubmitButton;
@property (retain) UIButton *OptionsButton;

@property (retain) ResubmitOptionsViewController *ResubmitOptionsVC;

@property (weak) id<ResubmitCompleteDelegate>CompleteDelegate;

@end
