//
//  PDFPreviewViewController.m
//  VTDLibrary
//
//  Created by Francis Bowen on 7/1/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "PDFPreviewViewController.h"

@interface PDFPreviewViewController ()

@end

@implementation PDFPreviewViewController

@synthesize PDFWebView;
@synthesize DoneButton;
@synthesize TitleLabel;
@synthesize delegate;

- (id)initWithPDFPath:(NSString *)PDFNameWithPath withTitle:(NSString *)Title {
    
    self = [super init];
    
    if (self) {
        
        _PDFNameWithPath = PDFNameWithPath;
        _Title = Title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.RotationDelegate = self;
    
    TitleLabel = [[UILabel alloc] init];
    TitleLabel.text = _Title;
    TitleLabel.textAlignment = NSTextAlignmentCenter;
    TitleLabel.font = [UIFont fontWithName:VTD_FONT size:28.0f];
    TitleLabel.backgroundColor = [UIColor lightGrayColor];
    TitleLabel.textColor = [UIColor blackColor];
    [self.DialogView addSubview:TitleLabel];
    
    PDFWebView = [[UIWebView alloc] init];
    [self.DialogView addSubview:PDFWebView];
    
    DoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    DoneButton.alpha = 1.0f;
    DoneButton.backgroundColor = [UIColor whiteColor];
    [DoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [DoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [DoneButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    DoneButton.titleLabel.font = [UIFont fontWithName:VTD_FONT size:24.0f];
    DoneButton.layer.cornerRadius = 5.0f;
    DoneButton.layer.borderWidth=1.0f;
    DoneButton.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    [DoneButton addTarget:self
                   action:@selector(DoneButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.DialogView addSubview:DoneButton];
    
    self.LandscapeFrame = PDFPREVIEW_LANDSCAPE;
    self.PortraitFrame = PDFPREVIEW_PORTRAIT;
    
    [self setupFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self LoadPDF];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)LoadPDF {
    
    NSURL *url = [NSURL fileURLWithPath:_PDFNameWithPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [PDFWebView loadRequest:request];
    [PDFWebView setScalesPageToFit:YES];
}

- (void)DoneButtonTapped:(id)sender {
    
    if (delegate) {
        [delegate PDFPreviewComplete];
    }
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {

    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        [PDFWebView setFrame:PDFWEBVIEW_LANDSCAPE];
        [DoneButton setFrame:PDFPREVIEW_DONE_LANDSCAPE];
        [TitleLabel setFrame:PDFPREVIEW_TITLE_LANDSCAPE];
        
    }
    else {
        
        [PDFWebView setFrame:PDFWEBVIEW_PORTRAIT];
        [DoneButton setFrame:PDFPREVIEW_DONE_PORTRAIT];
        [TitleLabel setFrame:PDFPREVIEW_TITLE_PORTRAIT];
    }
    
    [self LoadPDF];
}

- (UIDeviceOrientation)getDeviceOrientation {
    
    return [delegate getDeviceOrientation];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
    
    [delegate setDeviceOrientation:orientation];
}

@end
