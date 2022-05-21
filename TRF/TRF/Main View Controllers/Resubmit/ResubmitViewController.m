//
//  ResubmitViewController.m
//  TRF
//
//  Created by Francis Bowen on 6/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "ResubmitViewController.h"

@interface ResubmitViewController ()

@end

@implementation ResubmitViewController

@synthesize PDFViewer;
@synthesize Sketch_ImageView;
@synthesize signaturePadView;
@synthesize drawImage;
@synthesize signatureLineView;
@synthesize signatureLine;
@synthesize clearButton;
@synthesize points;
@synthesize SubmitButton;
@synthesize OptionsButton;
@synthesize ResubmitOptionsVC;
@synthesize CompleteDelegate;

- (void)viewDidLoad {
    
    self.BaseBackgroundDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PDFViewer = [[UIWebView alloc] init];
    [self.view addSubview:PDFViewer];
    
    // create signature pad view
    self.signaturePadView = [[UIView alloc] init];
    [signaturePadView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [signaturePadView.layer setBorderWidth:2.0];
    [signaturePadView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:signaturePadView];
    
    // create an UIImageView for signature line
    
    self.signatureLine = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"sign-line-with-x" ofType:@"png"]];
    self.signatureLineView = [[UIImageView alloc] initWithImage:signatureLine];
    [signaturePadView addSubview:signatureLineView];
    
    // create an UIImageView to let user can draw
    self.drawImage = [[UIImageView alloc] initWithImage:nil];
    [self.view addSubview:drawImage];
    
    // initial an array to store 		user painted points
    self.points = [[NSMutableArray alloc] init];
    
    //create clear button
    clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearButton setBackgroundColor:[UIColor whiteColor]];
    [clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [clearButton.titleLabel setFont:[UIFont fontWithName:VTD_FONT size:24.0f]];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearSignature:) forControlEvents:UIControlEventTouchUpInside];
    [signaturePadView addSubview:clearButton];
    
    OptionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    OptionsButton.alpha = 1.0f;
    OptionsButton.backgroundColor = [UIColor lightGrayColor];
    [OptionsButton setTitle:@"Options" forState:UIControlStateNormal];
    [OptionsButton.titleLabel setNumberOfLines:0];
    [OptionsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [OptionsButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    OptionsButton.titleLabel.font = [UIFont fontWithName:VTD_FONT size:24.0f];
    OptionsButton.layer.cornerRadius = 5.0f;
    OptionsButton.layer.borderWidth=1.0f;
    OptionsButton.layer.borderColor=[[UIColor whiteColor] CGColor];
    [OptionsButton addTarget:self
                      action:@selector(OptionsButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:OptionsButton];
    
    SubmitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    SubmitButton.alpha = 1.0f;
    SubmitButton.backgroundColor = [UIColor lightGrayColor];
    [SubmitButton setTitle:@"Resubmit Form" forState:UIControlStateNormal];
    [SubmitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [SubmitButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    SubmitButton.titleLabel.font = [UIFont fontWithName:VTD_FONT size:24.0f];
    SubmitButton.layer.cornerRadius = 5.0f;
    SubmitButton.layer.borderWidth=1.0f;
    SubmitButton.layer.borderColor=[[UIColor whiteColor] CGColor];
    [SubmitButton addTarget:self
                     action:@selector(SubmitButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:SubmitButton];

    ResubmitOptionsVC = [[ResubmitOptionsViewController alloc] init];
    ResubmitOptionsVC.delegate = self;
    ResubmitOptionsVC.RotationDelegate = self;
    
    _displayedAlert = NO;
    _isSubmitting = NO;

    _Emailer = [[SharedData SharedInstance] GetEmailer];
    _Emailer.delegate = self;
    
    _DisableSlideshow = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!_displayedAlert) {
        
        _displayedAlert = YES;
        
        FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
        
        [_FormDataManager SetFormDataValue:[Utilities GetCurrentDateSimple] withKey:@"Date"]; //update date for resubmit
        
        //Note: This assumes the Form Manager is already loaded with the returning client info.
        _FormDataManager.PDFDelegates = self;
        [_FormDataManager GeneratePDF:@"Resubmit.pdf" atPath:[[SharedData SharedInstance] GetTempPath]];
        //[_FormDataManager SetIsResubmitting:NO];
        
        [self SetResubmitting:NO];
        [[SharedData SharedInstance] SetGoingToResubmit:NO];
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
        {
            [self CheckForHealthItems];
        }
                                                    withTitle:@"Form Resubmit"
                                                  withMessage:@"Welcome back return client!\n\n1. Scroll through your previous release form to see if all looks correct.\n\n2. If no changes are needed, sign and submit! Today's date will autofill.\n\n3. If you need to change something (different location, address, health questions, etc), please tap GO BACK TO MAKE CHANGES in OPTIONS. The app will guide you throughout.\n\nThanks and enjoy your session!"];
        
        [self presentViewController:alert animated:NO completion:nil];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    CLS_LOG(@"resubmit vc");
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    NSString *path = [NSString stringWithFormat:@"%@/Resubmit.pdf",[[SharedData SharedInstance] GetTempPath]];
    NSFileManager *fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:path error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)backgroundFileNamePortrait {
    
    return RESUBMIT_PORTRAIT;
}

- (NSString *)backgroundFileNameLandscape {
    
    return RESUBMIT_LANDSCAPE;
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {
    
    UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
                                           orientation == UIDeviceOrientationPortraitUpsideDown ||
                                           orientation == UIDeviceOrientationLandscapeLeft ||
                                           orientation == UIDeviceOrientationLandscapeRight) ? orientation : [[SharedData SharedInstance] GetDeviceOrientation];
        
    _PreviousOrientation = LastOrientation;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *orientation_value = [defaults objectForKey:ORIENTATION_KEY];
    
    if ([orientation_value isEqualToString:ORIENTATION_PORTRAIT] && LastOrientation != UIDeviceOrientationPortrait && LastOrientation != UIDeviceOrientationPortraitUpsideDown) {
        
        LastOrientation = UIDeviceOrientationPortrait;
        
    }
    else if ([orientation_value isEqualToString:ORIENTATION_LANDSCAPE] && LastOrientation != UIDeviceOrientationLandscapeLeft && LastOrientation != UIDeviceOrientationLandscapeRight) {
        
        LastOrientation = UIDeviceOrientationLandscapeLeft;
    }
    
    if (LastOrientation == UIDeviceOrientationLandscapeLeft ||
        LastOrientation == UIDeviceOrientationLandscapeRight) {
        
        [PDFViewer setFrame:RESUBMIT_PDFVIEW_LANDSCAPE];
        [signaturePadView setFrame:RESUBMIT_SIGNATURE_LANDSCAPE];
        [signatureLineView setFrame:RESUBMIT_SIGNATURELINE_LANDSCAPE];
        [drawImage setFrame:RESUBMIT_SIGNATURE_LANDSCAPE];
        [clearButton setFrame:RESUBMIT_CLEAR_LANDSCAPE];
        [OptionsButton setFrame:RESUBMIT_OPTIONS_LANDSCAPE];
        [SubmitButton setFrame:RESUBMIT_SUBMIT_LANDSCAPE];
    }
    else
    {
        
        [PDFViewer setFrame:RESUBMIT_PDFVIEW_PORTRAIT];
        [signaturePadView setFrame:RESUBMIT_SIGNATURE_PORTRAIT];
        [signatureLineView setFrame:RESUBMIT_SIGNATURELINE_PORTRAIT];
        [drawImage setFrame:RESUBMIT_SIGNATURE_PORTRAIT];
        [clearButton setFrame:RESUBMIT_CLEAR_PORTRAIT];
        [OptionsButton setFrame:RESUBMIT_OPTIONS_PORTRAIT];
        [SubmitButton setFrame:RESUBMIT_SUBMIT_PORTRAIT];
        
        
    }
    
    [[SharedData SharedInstance] SetDeviceOrientation:LastOrientation];

}

- (void)SubmitButtonTapped:(id)sender
{
    
    if ([points count] > 10) {
        
        if ([Utilities HasNetworkConnectivity]) {
            
            //Check for available forms or subscription
            InAppPurchaseManager *IAPManager = [[SharedData SharedInstance] GetIAPManager];
            bool hasForms = ([IAPManager GetNumberOfForms] > 0);
            bool hasSubscription = [IAPManager HasSubscription];
            
            if (hasForms || hasSubscription) {
                
                _BusyAlert = [self.Alerts CreateBusyAlert:@"Uploading" withMessage:@"Waiver is uploading. Please wait."];
                
                [self presentViewController:_BusyAlert animated:NO completion:^(){
                    
                    FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
                    
                    [_FormDataManager SetFormImagesValue:drawImage.image withKey:CLIENT_SIGNATURE_IMAGE];
                    _displayedAlert = NO;
                    _isSubmitting = YES;
                    [self CreateAndUploadPDF];
                }];
            }
            else {
                
                UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
                                            {
                                                [self SavePendingForm];
                                                
                                                //Go back to homescreen
                                                if (self.BaseDelegate) {
                                                    [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
                                                }
                                                
                                            }
                                                            withTitle:@"No Forms Available"
                                                          withMessage:@"Unfortunately you do not have any forms available. You can purchase more forms through the in-app purchases page. Your current waiver will be saved to the pending forms queue and will be uploaded once more forms are available."];
                
                [self presentViewController:alert animated:NO completion:nil];
            }
            
        }
        else {
            
            //No internet connection, save form then display error dialog
            [self SavePendingForm];
            
            UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
                                        {
                                            //Go back to homescreen
                                            if (self.BaseDelegate) {
                                                [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
                                            }
                                        }
                                                        withTitle:@"No wifi or data connection"
                                                      withMessage:@"PENDING UPLOAD: No wifi or data connection. Your forms will upload once you connect."];
            
            [self presentViewController:alert animated:NO completion:nil];
        }
        
    }
    else {
    
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Error" withMessage:@"You must provide a valid signature to resumbit a form"];
        
        [self presentViewController:alert animated:NO completion:nil];
    }

}

- (void)SavePendingForm {
    
    CoreDataManager *_CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];
    FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
    
    [_CoreDataManager SaveForm:_FormDataManager];
    //[_FormDataManager SetIsResubmitting:NO];
    [self SetResubmitting:NO];
    
    _isSubmitting = NO;
    _displayedAlert = NO;
    
    [self clearSignature:nil];
    
    [[SharedData SharedInstance] StartNewForm];
    
    //Save to pending uploads
    NSString *FirstName = [_FormDataManager GetFormDataValue:@"First Name"];
    NSString *LastName = [_FormDataManager GetFormDataValue:@"Last Name"];
    NSString *Date = [Utilities GetCurrentDate];
    NSString *DateOfBirth = [_FormDataManager GetFormDataValue:@"Date of Birth"];
    
    [_CoreDataManager AddPendingUpload:FirstName
                          withLastName:LastName
                              withDate:Date
                               withDoB:DateOfBirth];
    
}

- (void)OptionsButtonTapped:(id)sender
{
    [self presentViewController:ResubmitOptionsVC animated:NO completion:nil];
}

- (void)CreateAndUploadPDF {
    
    FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
    
    NSString *FirstName = [_FormDataManager GetFormDataValue:@"First Name"];
    NSString *LastName = [_FormDataManager GetFormDataValue:@"Last Name"];
    NSString *Date = [Utilities GetCurrentDate];
    NSString *PDFFilename = [NSString stringWithFormat:@"%@ %@,%@.pdf",
                             Date,
                             LastName,
                             FirstName];
    
    NSString *TempPath = [[SharedData SharedInstance] GetTempPath];
    
    [_FormDataManager GeneratePDF:PDFFilename atPath:TempPath];
}

- (void)CheckForHealthItems {
    
    FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
    
    //Check for "yes" health items
    NSArray *Allergies = [[SharedData SharedInstance] GetAllergies];
    NSArray *Diseases = [[SharedData SharedInstance] GetDiseases];
    NSArray *HealthConditions = [[SharedData SharedInstance] GetHealthConditions];
    
    bool hasItems = NO;
    NSString *msg = @"The client has answered YES to the following items on the health page:\n";
    
    for (NSDictionary *item in Allergies) {
        
        NSString *key = [item objectForKey:@"HealthItemName"];
        NSString *value = [_FormDataManager GetFormDataValue:key];
        
        if (value != nil && ![value isEqualToString:@"No"]) {
            
            hasItems = YES;
            msg = [msg stringByAppendingFormat:@"%C%@\n",(unichar) 0x2022, key];
        }
    }
    
    for (NSDictionary *item in Diseases) {
        
        NSString *key = [item objectForKey:@"HealthItemName"];
        NSString *value = [_FormDataManager GetFormDataValue:key];
        
        if (value != nil && ![value isEqualToString:@"No"]) {
            
            hasItems = YES;
            msg = [msg stringByAppendingFormat:@"%C%@\n",(unichar) 0x2022, key];
        }
    }
    
    for (NSDictionary *item in HealthConditions) {
        
        NSString *key = [item objectForKey:@"HealthItemName"];
        NSString *value = [_FormDataManager GetFormDataValue:key];
        
        if (value != nil && ![value isEqualToString:@"No"]) {
            
            hasItems = YES;
            msg = [msg stringByAppendingFormat:@"%C%@\n",(unichar) 0x2022, key];
        }
    }
    
    if (hasItems) {
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Attention" withMessage:msg];
        
        [self presentViewController:alert animated:NO completion:nil];
        
    }
    
}

#pragma mark - SIGNATURE PAD FUNCTIONS
// signature capture
// This function quantize user painted points into 200x200 2d-dimention.
// the most left-top point is 0, and the most right-bottom is 40000.
- (int)quantizePoint:(CGPoint)inputP
{
    
    float x = inputP.x;
    float y = inputP.y;
    int finalX = (x-signaturePadView.frame.origin.x) * 500 / signaturePadView.frame.size.width;
    int finalY = (y-signaturePadView.frame.origin.y) * 200 / signaturePadView.frame.size.height;
    
    int returnP = finalX + finalY*500;
    
    return returnP;
}

// triggered when user touch the screen
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    
    /*
     // if user tap 2 times, clear all points
     
     if ([touch tapCount] == 2) {
     drawImage.image = nil;
     points = [[NSMutableArray alloc] init];
     return;
     }
     */
    
    _lastPoint = [touch locationInView:signaturePadView];
    
    if ((_lastPoint.x > 60 && _lastPoint.y > 30) ||
        (_lastPoint.x > 60 && _lastPoint.y <= 30) ||
        (_lastPoint.x <= 60 && _lastPoint.y > 30))
    {
        
        int tmpP = [self quantizePoint:_lastPoint];
        NSNumber *tmpN = [NSNumber numberWithInt:tmpP];
        [points addObject:tmpN];
        
        /*
         lastPoint.x *=  (double)self.view.frame.size.width /(double)signaturePadView.frame.size.width ;
         lastPoint.x -= signaturePadView.frame.origin.x * (double)self.view.frame.size.width /signaturePadView.frame.size.width;
         lastPoint.y *= (double)(self.view.frame.size.height) /(double)signaturePadView.frame.size.height;
         lastPoint.y -= (double)self.view.frame.size.height /signaturePadView.frame.size.height * signaturePadView.frame.origin.y;
         */
    }
}

- (void)clearSignature:(id)sender
{
    drawImage.image = nil;
    self.points = [[NSMutableArray alloc] init];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:signaturePadView];
    
    
    if ((currentPoint.x > 60 && currentPoint.y > 30) ||
        (currentPoint.x > 60 && currentPoint.y <= 30) ||
        (currentPoint.x <= 60 && currentPoint.y > 30)) {
        
        int tmpP = [self quantizePoint:currentPoint];
        NSNumber *tmpN = [NSNumber numberWithInt:tmpP];
        [points addObject:tmpN];
        
        UIGraphicsBeginImageContext(signaturePadView.frame.size);
        [drawImage.image drawInRect:CGRectMake(0, 0, signaturePadView.frame.size.width, signaturePadView.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 4.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _lastPoint = currentPoint;
        
    }
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!_mouseSwiped) {
        UIGraphicsBeginImageContext(signaturePadView.frame.size);
        [drawImage.image drawInRect:CGRectMake(0, 0, signaturePadView.frame.size.width, signaturePadView.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 8.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), _lastPoint.x, _lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
}

#pragma mark - ResubmitOptionsPopupDelegate
- (void)ResubmitOptionsComplete:(NSString *)txt withIndex:(NSUInteger)index {
    
    [ResubmitOptionsVC dismissViewControllerAnimated:NO completion:^(){
        
        switch (index) {
                
            case 0:
            {
                //Make changes
                
                _displayedAlert = NO;

                [self clearSignature:nil];

                [self SetResubmitting:YES];
                
                
                UIAlertController *alert = [self.Alerts
                                            CreateYesNoAlert:^(UIAlertAction *action)
                                            {
                                                if (self.BaseDelegate) {
                                                    
                                                    [[SharedData SharedInstance] SetDestViewController:IDVERIFY_VIEWCONTROLLER];

                                                    [self.BaseDelegate VCComplete:self destinationViewController:IDVERIFY_VIEWCONTROLLER];
                                                }
                                                
                                            }
                                            withNoHandler:^(UIAlertAction *action){}
                                            withTitle:@"Make Changes"
                                            withMessage:@"Are you sure you want to go back and make changes?"];
                
                [self presentViewController:alert animated:NO completion:nil];
            }
                
                break;
                
            case 1:
            {
                
                //Go to artist notes
                
                _displayedAlert = NO;

                [self clearSignature:nil];
                //[_FormDataManager SetIsResubmitting:YES];
                [self SetResubmitting:YES];
                
                UIAlertController *alert = [self.Alerts
                                            CreateYesNoAlert:^(UIAlertAction *action)
                                            {
                                                if (self.BaseDelegate) {
                                                    
                                                    [[SharedData SharedInstance] SetDestViewController:FINALIZE_VIEWCONTROLLER];
                                                    
                                                    [self.BaseDelegate VCComplete:self destinationViewController:FINALIZE_VIEWCONTROLLER];
                                                }
                                                
                                            }
                                            withNoHandler:^(UIAlertAction *action){}
                                            withTitle:@"Artist Notes"
                                            withMessage:@"Are you sure you want to go back and the artist notes?"];
                
                [self presentViewController:alert animated:NO completion:nil];
                
            }
                break;
            case 3:
            {
                //Start a new form
                
                _displayedAlert = NO;
                
                UIAlertController *alert = [self.Alerts
                         CreateYesNoAlert:^(UIAlertAction *action)
                {
                    FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
                    
                    [self clearSignature:nil];
                    [_FormDataManager ClearAll];
                    //[_FormDataManager SetIsResubmitting:NO];
                    [self SetResubmitting:NO];
                    
                    [[SharedData SharedInstance] StartNewForm];
                    
                    if (self.BaseDelegate) {
                        [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
                    }
                
                }
                         withNoHandler:^(UIAlertAction *action){}
                         withTitle:@"Start Over"
                         withMessage:@"Are you sure you want to start a new form?"];
                
                [self presentViewController:alert animated:NO completion:nil];
            }
                break;


            default:
                break;
        }
        
    }];
}

- (FormDataManager *)GetFormDataManager {
    
    return [[SharedData SharedInstance] GetFormDataManager];
}

- (void)SessionsFinancialsComplete:(SessionFinancialsTableCell *)cell
                withFinancialsData:(NSDictionary *)financials {
    
    [ResubmitOptionsVC dismissViewControllerAnimated:NO completion:^(){
        
        FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
        
        for (NSString *key in [financials allKeys]) {
            
            [_FormDataManager SetFinancialSessionDataValue:[financials objectForKey:key] withKey:key];
        }
        
        [_FormDataManager GeneratePDF:@"Resubmit.pdf" atPath:[[SharedData SharedInstance] GetTempPath]];
        
    }];
    
}

- (void)ResubmitOptionsCanceled {
    
    [self clearSignature:nil];
    [ResubmitOptionsVC dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - FormDataManagerPDFDelegates
- (void)PDFGeneratorComplete:(NSString *)PDFFilename {
    
    if (_isSubmitting) {
        
        //Upload PDF
        CloudServiceManager *CloudServices = [[SharedData SharedInstance] GetCloudServices];
        CloudServices.uploadDelegate = self;
        
        [CloudServices UploadFile:PDFFilename withFilepath:[[SharedData SharedInstance] GetTempPath]];
        
        _PDFFullPath = [NSString stringWithFormat:@"%@/%@",[[SharedData SharedInstance] GetTempPath],PDFFilename];
    }
    else {
       
        NSString *pdfFileNameFullPath = [NSString stringWithFormat:@"%@/Resubmit.pdf",
                                         [[SharedData SharedInstance] GetTempPath]];
        
        NSURL *url = [NSURL fileURLWithPath:pdfFileNameFullPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [PDFViewer loadRequest:request];
    }
    
}

- (NSArray *)GetAllergies {
    
    return [[SharedData SharedInstance] GetAllergies];
}

- (NSArray *)GetDiseases {
    
    return [[SharedData SharedInstance] GetDiseases];
}

- (NSArray *)GetHealthConditions {
    
    return [[SharedData SharedInstance] GetHealthConditions];
}

- (NSArray *)LegalItems {
    
    return [[SharedData SharedInstance] LegalItems];
}

#pragma mark - CloudServiceUploadDelegate
- (void)FileUploadComplete:(bool)UploadSuccessful {
    
    _EmailAlert = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UsingEmailers = [defaults objectForKey:USING_EMAILER_KEY];
    NSString *EmailingWaiver = [defaults objectForKey:EMAIL_WAIVER_KEY];
    NSString *EmailingPDF = [defaults objectForKey:EMAIL_PDF_KEY];
    
    if (EmailingWaiver == nil) {
        EmailingWaiver = @"No";
    }
    
    if (EmailingPDF ==  nil) {
        EmailingPDF = @"No";
    }
    
    if ([UsingEmailers isEqualToString:@"Yes"]) {
        
        _EmailsToSend = 0;
        
        if ([EmailingWaiver isEqualToString:@"Yes"]) {
            _EmailsToSend++;
        }
        
        if ([EmailingPDF isEqualToString:@"Yes"]) {
            _EmailsToSend++;
        }
        
        if (!_Emailer) {
            
            _Emailer = [[SharedData SharedInstance] GetEmailer];
            _Emailer.delegate = self;
        }
        
        if (!_BusyAlert) {
            
            _BusyAlert = [self.Alerts CreateBusyAlert:@"Automatic Emailer" withMessage:@"Sending email...\n\n\n\n\n"];
            
            [self presentViewController:_BusyAlert animated:NO completion:nil];
        }
        else {
            
            _BusyAlert.title = @"Automatic Emailer";
            _BusyAlert.message = @"Sending email...\n\n\n\n\n";
        }
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        
        FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
        
        NSString *emailaddress = [_FormDataManager GetFormDataValue:@"Email Address"];
        
        if (emailaddress != nil) {
            
            if ([EmailingPDF isEqualToString:@"Yes"]) {

                NSString *attachmentfn = [defaults objectForKey:EMAILER_ATTACHMENT_KEY];

                NSString *subject = [defaults objectForKey:EMAILER_SUBJECT_KEY];

                NSString *body = [defaults objectForKey:EMAILER_BODY_KEY];

                if (subject != nil &&
                    body != nil &&
                    emailaddress != nil &&
                    attachmentfn != nil) {

                    NSString *attachment = [NSString stringWithFormat:@"%@/%@", documentsDir, attachmentfn];

                    [_Emailer SendEmail:subject
                          withEmailBody:body
                                toEmail:emailaddress
                         withAttachment:attachment];
                }
                else {

                    NSString *infomissing = @"The Automatic Emailer is missing the following:";

                    if (subject == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Subject", infomissing, (unichar) 0x2022];
                    }

                    if (body == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Body", infomissing, (unichar) 0x2022];
                    }

                    if (emailaddress == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Address", infomissing, (unichar) 0x2022];
                    }

                    if (attachmentfn == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Attachment", infomissing, (unichar) 0x2022];
                    }

                    infomissing = [infomissing stringByAppendingString:@"\n\nPlease go into the app settings and verify the Emailer settings are correct. Please contact VTD if you need further help."];

                    UIAlertController *alert = [self.Alerts
                                                CreateOKAlert:^(UIAlertAction *action)
                                                {
                                                    [self FinishForm:UploadSuccessful];
                                                }
                                                withTitle:@"Emailer Error (1)"
                                                withMessage:infomissing];

                    [self presentViewController:alert animated:NO completion:nil];

                }


            }

            if ([EmailingWaiver isEqualToString:@"Yes"]) {

                NSString *subject = [defaults objectForKey:EMAIL_WAIVER_SUBJECT_KEY];

                NSString *body = [defaults objectForKey:EMAIL_WAIVER_BODY_KEY];

                if (subject != nil &&
                    body != nil &&
                    emailaddress != nil &&
                    _PDFFullPath) {


                    [_Emailer SendEmail:subject
                          withEmailBody:body
                                toEmail:emailaddress
                         withAttachment:_PDFFullPath];
                }
                else {

                    NSString *infomissing = @"The Automatic Emailer is missing the following:";

                    if (subject == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Subject", infomissing, (unichar) 0x2022];
                    }

                    if (body == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Body", infomissing, (unichar) 0x2022];
                    }

                    if (emailaddress == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Address", infomissing, (unichar) 0x2022];
                    }

                    if (_PDFFullPath == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Waiver Attachment", infomissing, (unichar) 0x2022];
                    }

                    infomissing = [infomissing stringByAppendingString:@"\n\nPlease go into the app settings and verify the Emailer settings are correct. Please contact VTD if you need further help."];

                    UIAlertController *alert = [self.Alerts
                                                CreateOKAlert:^(UIAlertAction *action)
                                                {
                                                    [self FinishForm:UploadSuccessful];
                                                }
                                                withTitle:@"Emailer Error (2)"
                                                withMessage:infomissing];

                    [self presentViewController:alert animated:NO completion:nil];

                }


            }

            if ([EmailingWaiver isEqualToString:@"No"] && [EmailingPDF isEqualToString:@"No"]) {

                NSString *subject = [defaults objectForKey:EMAILER_SUBJECT_KEY];

                NSString *body = [defaults objectForKey:EMAILER_BODY_KEY];

                if (subject != nil &&
                    body != nil &&
                    emailaddress != nil) {

                    [_Emailer SendEmail:subject
                          withEmailBody:body
                                toEmail:emailaddress
                         withAttachment:nil];
                }
                else {

                    NSString *infomissing = @"The Automatic Emailer is missing the following:";

                    if (subject == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Subject", infomissing, (unichar) 0x2022];
                    }

                    if (body == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Body", infomissing, (unichar) 0x2022];
                    }

                    if (emailaddress == nil) {

                        infomissing = [NSString stringWithFormat:@"%@\n%c Email Address", infomissing, (unichar) 0x2022];
                    }

                    infomissing = [infomissing stringByAppendingString:@"\n\nPlease go into the app settings and verify the Emailer settings are correct. Please contact VTD if you need further help."];

                    UIAlertController *alert = [self.Alerts
                                                CreateOKAlert:^(UIAlertAction *action)
                                                {
                                                    [self FinishForm:UploadSuccessful];
                                                }
                                                withTitle:@"Emailer Error (3)"
                                                withMessage:infomissing];
                    
                    [self presentViewController:alert animated:NO completion:nil];
                    
                }
                

            }

        }
        else {
            
            [_BusyAlert dismissViewControllerAnimated:NO completion:^(){
                
                //Email address is not stored, get email address
                [self GetEmailAddress:UploadSuccessful];
            }];

        }
        
    }
    else {
        
        [self FinishForm:UploadSuccessful];
    }
    
    
}

- (void)GetEmailAddress:(bool)UploadSuccessful {
    
    _BusyAlert = nil;
    
    //present prompt for email address
    _EmailAlert = [UIAlertController
                   alertControllerWithTitle:@"Email required for official use:"
                   message:@"We use email to communicate with you about your appointments, healing, etc. The email you provide here will not be used for social or marketing messages."
                   preferredStyle:UIAlertControllerStyleAlert];
    
    [_EmailAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Email", @"OtherPlaceholder");
         textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
         textField.keyboardAppearance = UIKeyboardAppearanceDark;
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *EmailTextField = _EmailAlert.textFields.firstObject;
                                   NSString *email = EmailTextField.text;
                                   
                                   if (![email isEqualToString:@""] && [Utilities validateEmailAddress:email]) {
                                       
                                       FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
                                       
                                       [_FormDataManager SetFormDataValue:email
                                                                  withKey:@"Email Address"];
                                       
                                       [self FileUploadComplete:UploadSuccessful];
                                       
                                   }
                                   else {
                                       
                                       UIAlertController *errorAlert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
                                                                        {
                                                                            //clear segment selection because email address is not valid
                                                                            //[((YesNoSegmentedTableCell *)cell).SegmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment ];
                                                                            
                                                                            [self GetEmailAddress:UploadSuccessful];
                                                                            
                                                                        } withTitle:@"Email Error" withMessage:@"The email address is not valid. Please try again"];
                                       
                                       [self presentViewController:errorAlert animated:NO completion:nil];
                                       
                                   }
                                   
                               }];
    
    [_EmailAlert addAction:okAction];
    
    [self presentViewController:_EmailAlert animated:NO completion:nil];
    
}


- (void)FinishForm:(bool)UploadSuccessful {

    [_BusyAlert dismissViewControllerAnimated:NO completion:^(){

        [self GoBackToHomescreen:UploadSuccessful];

    }];
    
}

- (void)GoBackToHomescreen:(bool)uploadsuccess {

    NSString *Title = @"";
    NSString *Message = @"";

    if (uploadsuccess) {

        Title = @"Upload Successful";
        Message = @"Your pdf has been uploaded.";

    }
    else {

        Title = @"Upload Error";
        Message = @"Your pdf has not been uploaded";
    }

    UIAlertController *UploadAlert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){

        CoreDataManager *_CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];
        FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];

        if (_isSubmitting) {

            [_CoreDataManager SaveForm:_FormDataManager];
        }

        //[_FormDataManager SetIsResubmitting:NO];
        [self SetResubmitting:NO];

        _isSubmitting = NO;

        [self clearSignature:nil];

        [[SharedData SharedInstance] StartNewForm];

        InAppPurchaseManager *IAPManager = [[SharedData SharedInstance] GetIAPManager];
        [IAPManager UseForm];

        [Answers logCustomEventWithName:@"Form Resubmitted"
                       customAttributes:@{}];

        [Answers logCustomEventWithName:@"Form Uploaded"
                       customAttributes:@{}];

        //Go back to homescreen
        if (self.BaseDelegate) {
            [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
        }

    }
                                                      withTitle:Title
                                                    withMessage:Message];

    [self presentViewController:UploadAlert animated:NO completion:nil];
}

#pragma mark - EmailerDelegate
- (void)EmailerAttemptingToSend {
    
}

- (void)EmailerSendSuccess {
    
    [self FinishForm:YES];
    
}

- (void)EmailerSendFailure:(NSString *)ErrorMessage {

    [_BusyAlert dismissViewControllerAnimated:NO completion:^(){

        NSString *err = [NSString stringWithFormat:@"The automatic emailer failed. The emailer settings may be incorrect. The client's form is still being saved to your cloud and device.\n\nError:%@",ErrorMessage];

        _BusyAlert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
                      {
                          [self GoBackToHomescreen:YES];    //upload was successful
                      }
                                      withTitle:@"Emailer Error"
                                    withMessage:err];

        [self presentViewController:_BusyAlert animated:NO completion:nil];
    }];

}

- (void)AuthComplete:(bool)success {
    
}

- (void)EmailerNotAuthenticated {
    
    
}

- (void)SetAuthorizationFlow:(id<OIDAuthorizationFlowSession>)CurrentFlow {

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentAuthorizationFlow = CurrentFlow;
}


#pragma mark - SessionFinancialsTableCellDelegate
- (NSDictionary *)GetInitialData {
    
    FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
    return [_FormDataManager GetSessionFinancials];
}

@end
