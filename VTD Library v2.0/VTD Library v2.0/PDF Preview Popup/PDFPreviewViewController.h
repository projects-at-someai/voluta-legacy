//
//  PDFPreviewViewController.h
//  VTDLibrary
//
//  Created by Francis Bowen on 7/1/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaPopoverViewController.h"

#define PDFPREVIEW_PORTRAIT             CGRectMake(0.0f, 0.0f, 768.0f, 1024.0f)
#define PDFPREVIEW_LANDSCAPE            CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)
#define PDFWEBVIEW_PORTRAIT             CGRectMake(0.0f, 50.0f, 768.0f, 924.0f)
#define PDFWEBVIEW_LANDSCAPE            CGRectMake(0.0f, 50.0f, 1024.0f, 668.0f)
#define PDFPREVIEW_DONE_PORTRAIT        CGRectMake(334.0f, 979.0f, 100.0f, 40.0f)
#define PDFPREVIEW_DONE_LANDSCAPE       CGRectMake(462.0f, 723.0f, 100.0f, 40.0f)
#define PDFPREVIEW_TITLE_PORTRAIT       CGRectMake(0.0f, 0.0f, 768.0f, 50.0f)
#define PDFPREVIEW_TITLE_LANDSCAPE      CGRectMake(0.0f, 0.0f, 1024.0f, 50.0f)

@protocol PDFPreviewPopupDelegate
@required
- (void)PDFPreviewComplete;

- (UIDeviceOrientation)getDeviceOrientation;
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation;

@end

@interface PDFPreviewViewController : VolutaPopoverViewController <PopoverRotationDelegate>
{
    NSString *_PDFNameWithPath;
    NSString *_Title;
}

@property (nonatomic, weak) id<PDFPreviewPopupDelegate> delegate;

@property (retain) UIWebView *PDFWebView;
@property (retain) UIButton *DoneButton;
@property (retain) UILabel *TitleLabel;

- (id)initWithPDFPath:(NSString *)PDFNameWithPath withTitle:(NSString *)Title;

@end
