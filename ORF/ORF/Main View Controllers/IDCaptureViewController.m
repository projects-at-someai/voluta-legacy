//
//  IDCaptureViewController.m
//  ORF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "IDCaptureViewController.h"

@interface IDCaptureViewController ()

@end

@implementation IDCaptureViewController

@synthesize IDVerifyVC;
@synthesize VideoPreviewView;
@synthesize TakePictureButton;
@synthesize StartOverButton;
@synthesize CameraTypeSegment;
@synthesize IDCamera;
@synthesize CameraType;
@synthesize SingleTapGesture;

- (void)viewDidLoad {
    
    self.BaseBackgroundDelegate = self;
    self.OptionsDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //Setup video preview window
    VideoPreviewView = [[UIView alloc] init];
    
    if (self.CurrentDeviceOrientation == UIDeviceOrientationUnknown) {
        
        self.CurrentDeviceOrientation = [[UIDevice currentDevice] orientation];
    }
    
    VideoPreviewView.frame = (self.CurrentDeviceOrientation == UIDeviceOrientationLandscapeLeft ||
                              self.CurrentDeviceOrientation == UIDeviceOrientationLandscapeRight) ?
                            IDVERIFY_IMGVIEW_LANDSCAPE : IDVERIFY_IMGVIEW_PORTRAIT;
    
    [self.view addSubview:VideoPreviewView];
    [self.view bringSubviewToFront:VideoPreviewView];
    
    SingleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    SingleTapGesture.delegate = self;
    [VideoPreviewView addGestureRecognizer:SingleTapGesture];
    
    //Add camera type segment
    NSArray *itemArray = [NSArray arrayWithObjects: @"Front", @"Rear", nil];
    CameraTypeSegment = [[UISegmentedControl alloc] initWithItems:itemArray];
    CameraTypeSegment.backgroundColor = [UIColor lightGrayColor];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:VTD_FONT size:24], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName, nil];
    [CameraTypeSegment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [CameraTypeSegment setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    
    [CameraTypeSegment addTarget:self action:@selector(CameraTypeSegmentChanged:) forControlEvents: UIControlEventValueChanged];
    CameraTypeSegment.layer.borderColor = [[UIColor blackColor] CGColor];
    CameraTypeSegment.layer.borderWidth = 1.0f;
    CameraTypeSegment.layer.cornerRadius = 2.0f;
    
    CameraType = [[NSUserDefaults standardUserDefaults] objectForKey:CAMERA_TYPE_KEY];
    
    if ([CameraType isEqualToString:@"Front"]) {
        
        CameraTypeSegment.selectedSegmentIndex = 0;
    }
    else {
        
        CameraTypeSegment.selectedSegmentIndex = 1;
    }
    
    [self.view addSubview:CameraTypeSegment];
    
#if !(TARGET_OS_SIMULATOR)
    
    //Setup camera
    IDCamera = [[Camera alloc] initWithCameraType:CameraType];
    [IDCamera SetParentView:self.view];
    [IDCamera SetupVideoPreviewView:VideoPreviewView];
    IDCamera.delegate = self;
    
    switch (self.CurrentDeviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            [IDCamera ChangeOrientation:@"Landscape Left"];
            break;
        case UIDeviceOrientationLandscapeRight:
            [IDCamera ChangeOrientation:@"Landscape Right"];
            break;
        case UIDeviceOrientationPortrait:
            [IDCamera ChangeOrientation:@"Portrait"];
            break;
        default:
            [IDCamera ChangeOrientation:@"Portrait Upside Down"];
            break;
    }
#endif
    
    //Setup buttons
    TakePictureButton = [[UIButton alloc] init];
    TakePictureButton.backgroundColor = [UIColor clearColor];
    [TakePictureButton addTarget:self action:@selector(TakePicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:TakePictureButton];
    
    StartOverButton = [[UIButton alloc] init];
    StartOverButton.backgroundColor = [UIColor clearColor];
    [StartOverButton addTarget:self action:@selector(StartOver:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:StartOverButton];
    
    //Add help button from base view controller to view
    [self.view addSubview:self.HelpButton];
    
    IDVerifyVC = [[IDVerifyViewController alloc] init];
    IDVerifyVC.BaseDelegate = self;
    IDVerifyVC.RetakeDelegate = self;
    
    //Setup options button
    [self SetupPasswordPromptParameters:@"App Options"
                           withSubTitle:@"Enter Driver Passcode"
                               withType:SECONDARY_PW_TYPE
                          withHasCancel:YES];
    self.RequiresPassword = YES;
    
    _DisableSlideshow = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)backgroundFileNamePortrait {
    
    return IDCAPTURE_PORTRAIT;
}

- (NSString *)backgroundFileNameLandscape {
    
    return IDCAPTURE_LANDSCAPE;
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {
    
    //NSLog(@"orientation: %ld", orientation);
    
    [super RotationDetected:orientation];
    
    NSString *cameraorient = @"";
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        [VideoPreviewView setFrame:IDCAPTURE_IMGVIEW_LANDSCAPE];
        [StartOverButton setFrame:IDCAPTURE_STARTOVER_BUTTON_LANDSCAPE];
        [CameraTypeSegment setFrame:IDCAPTURE_CAMERA_SEGMENT_LANDSCAPE];
        [TakePictureButton setFrame:IDCAPTURE_TAKE_PICTURE_BUTTON_LANDSCAPE];
        
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            
            cameraorient = @"Landscape Left";
        }
        else
        {
            cameraorient = @"Landscape Right";
        }
    }
    else {
        
        [VideoPreviewView setFrame:IDCAPTURE_IMGVIEW_PORTRAIT];
        [StartOverButton setFrame:IDCAPTURE_STARTOVER_BUTTON_PORTRAIT];
        [CameraTypeSegment setFrame:IDCAPTURE_CAMERA_SEGMENT_PORTRAIT];
        [TakePictureButton setFrame:IDCAPTURE_TAKE_PICTURE_BUTTON_PORTRAIT];
        
        if (orientation == UIDeviceOrientationPortrait) {
            
            cameraorient = @"Portrait";
        }
        else
        {
            cameraorient = @"Portrait Upside Down";
        }
    }
    
#if !(TARGET_OS_SIMULATOR)
    [IDCamera ChangeOrientation:cameraorient];
    [IDCamera SetupVideoPreviewView:VideoPreviewView];
#endif
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
    
    bool isRetakingPhoto = [[SharedData SharedInstance] GetIsRetakingPhoto];

    if (_FormDataManager && [self IsResubmitting] && !isRetakingPhoto) {
        
        [self presentViewController:IDVerifyVC animated:NO completion:nil];
    }
    else {
        
        if (![self IsResubmitting]) {
            
            [[SharedData SharedInstance] StartNewForm];
        }
        

        [IDCamera StartCamera];
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    switch (self.CurrentDeviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            [IDCamera ChangeOrientation:@"Landscape Left"];
            break;
        case UIDeviceOrientationLandscapeRight:
            [IDCamera ChangeOrientation:@"Landscape Right"];
            break;
        case UIDeviceOrientationPortrait:
            [IDCamera ChangeOrientation:@"Portrait"];
            break;
        default:
            [IDCamera ChangeOrientation:@"Portrait Upside Down"];
            break;
    }
    
    [self RotationDetected:self.CurrentDeviceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[SharedData SharedInstance] SetIsRetakingPhoto:NO];
    
    [IDCamera StopCamera];
}

- (void)TakePicture:(id)sender
{
#if TARGET_IPHONE_SIMULATOR
    
    [self presentViewController:IDVerifyVC animated:NO completion:nil];
    
#else
    
    [IDCamera TakePicture];
    
#endif
    
}

- (void)StartOver:(id)sender
{
    
    UIAlertController *StartOverAlert = [self.Alerts CreateYesNoAlert:^(UIAlertAction *action) {
    
        if (self.BaseDelegate) {
            [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
        }
    }
                                                        withNoHandler:^(UIAlertAction *action) {
                                                        
                                                        }
                                                            withTitle:@"Start Over"
                                                          withMessage:@"Are you sure you want to start over?"];
    
    [self presentViewController:StartOverAlert animated:NO completion:nil];
    
}

- (void)Help:(id)sender
{
    UIAlertController *helpAlert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Help" withMessage:@"PHOTO YOUR ID:\nDetermine which camera is active, front or rear. Carefully frame the photo-side of your ID in the viewfinder and TAKE PHOTO. Yes, you can turn your ID sideways. Retake the image if it's not clear."];
    
    [self presentViewController:helpAlert animated:NO completion:nil];
    
}

- (void)RetakeID {

    [IDVerifyVC dismissViewControllerAnimated:NO completion:nil];
}

- (void)VCComplete:(VolutaBaseViewController *)VC destinationViewController:(NSString *)VCName {
    
    [VC dismissViewControllerAnimated:NO completion:^(){
    
        if (self.BaseDelegate) {
            [self.BaseDelegate VCComplete:self destinationViewController:VCName];
        }
        
    }];
    
}

- (void)OptionsTapped:(BaseWithOptionsButtonViewController *)VC withPasswordPromptTitle:(NSString *)Title
{
    if ([Title isEqualToString:@"App Options"]) {
        
        UIAlertController *OptionsAlert = [self.Alerts CreateOptionsAlert:^(UIAlertAction *action){}
                                                 withStartOverAction:^(UIAlertAction *action){
                                                 
                                                     [self SetResubmitting:NO];
                                                     
                                                     if (self.BaseDelegate) {
                                                         [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
                                                     }
                                                 
                                                 }
                                                  withSettingsAction:^(UIAlertAction *action) {
                                                  
                                                      [self SetResubmitting:NO];
                                                      
                                                      if (self.BaseDelegate) {
                                                          [self.BaseDelegate VCComplete:self destinationViewController:SETTINGS_VIEWCONTROLLER];
                                                      }
                                                  
                                                  }];
        
        [self presentViewController:OptionsAlert animated:NO completion:nil];
    }

}

- (void)CameraTypeSegmentChanged:(UISegmentedControl *)segment
{
    if(segment.selectedSegmentIndex == 0)
    {
        // code for the first button
        [[NSUserDefaults standardUserDefaults] setObject:@"Front" forKey:CAMERA_TYPE_KEY];
        CameraType = @"Front";
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"Rear" forKey:CAMERA_TYPE_KEY];
        CameraType = @"Rear";
    }
    
#if !(TARGET_OS_SIMULATOR)
    
    [IDCamera ChangeCameraType:[[NSUserDefaults standardUserDefaults] objectForKey:CAMERA_TYPE_KEY]];
    
#endif
    
}

#pragma Camera delegate
- (void)CameraComplete:(bool)Success
{

    if (!Success) {

        UIAlertController *msg = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                  withTitle:@"Camera Not Detectede"
                                                withMessage:@"Your camera was not detected. Please close the app, restart, then try again."];

        [self presentViewController:msg animated:NO completion:nil];
    }
    else {

        UIImage *imageBuffer;

        imageBuffer = IDCamera.capturedImage;


        UIImage *subImage = nil;

        if ([CameraType isEqualToString:@"Front"]) {

            subImage = [self ProcessFrontCameraImage:imageBuffer];
        }
        else {

            subImage = [self ProcessBackCameraImage:imageBuffer];

        }

        FormDataManager *_FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
        [_FormDataManager SetFormImagesValue:subImage withKey:CLIENT_ID_IMAGE];

        imageBuffer = nil;
        subImage = nil;

        [self presentViewController:IDVerifyVC animated:NO completion:nil];
    }

}


- (UIImage *)ProcessFrontCameraImage:(UIImage *)ImageBuffer {
    
    UIImage *rotatedImage = [self scaleAndRotateImage:ImageBuffer];
    
    CGSize imageSize = ImageBuffer.size;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
                                           orientation == UIDeviceOrientationPortraitUpsideDown ||
                                           orientation == UIDeviceOrientationLandscapeLeft ||
                                           orientation == UIDeviceOrientationLandscapeRight) ? orientation : [[SharedData SharedInstance] GetDeviceOrientation];
    
    UIImage *subImage;
    
    if (UIDeviceOrientationIsLandscape(LastOrientation)) {
        
        subImage = rotatedImage;
    }
    else
    {
        float aspectRatio = MAX(imageSize.height, imageSize.width) / MIN(imageSize.height, imageSize.width);
        
        float FourToThree = 4.0 / 3.0;
        
        float difference = ABS(aspectRatio - FourToThree);
        
        CGRect subRect;
        
        if (difference < 0.1)
        {
            subRect = CGRectMake(0, 185, rotatedImage.size.width, 265);
        }
        else
        {
            subRect = CGRectMake(0, 435, rotatedImage.size.width, 410);
        }
        
        subImage =  [self cropImage:rotatedImage toRect:subRect];

    }
    
    NSData *imgData = UIImageJPEGRepresentation(subImage,0.75);
    
    subImage = [UIImage imageWithData:imgData];
    
    imgData = nil;
    rotatedImage = nil;
    
    return subImage;
    
}

- (UIImage *)ProcessBackCameraImage:(UIImage *)ImageBuffer {
    
    UIImage *rotatedImage = [self scaleAndRotateImage:ImageBuffer];
    
    CGSize imageSize = ImageBuffer.size;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
                                           orientation == UIDeviceOrientationPortraitUpsideDown ||
                                           orientation == UIDeviceOrientationLandscapeLeft ||
                                           orientation == UIDeviceOrientationLandscapeRight) ? orientation : [[SharedData SharedInstance] GetDeviceOrientation];
    
    UIImage *subImage;
    
    if (UIDeviceOrientationIsLandscape(LastOrientation)) {
        
        subImage = rotatedImage;
    }
    else
    {
        float aspectRatio = MAX(imageSize.height, imageSize.width) / MIN(imageSize.height, imageSize.width);
        
        float FourToThree = 4.0 / 3.0;
        
        float difference = ABS(aspectRatio - FourToThree);
        
        CGRect subRect;
        
        if (difference < 0.1)
        {
            subRect = CGRectMake(0, 185, rotatedImage.size.width, 265);
        }
        else
        {
            subRect = CGRectMake(0, 675, rotatedImage.size.width, 615);
        }
        
        subImage =  [self cropImage:rotatedImage toRect:subRect];
        
    }
    
    NSData *imgData = UIImageJPEGRepresentation(subImage,0.75);
    
    subImage = [UIImage imageWithData:imgData];
    
    imgData = nil;
    rotatedImage = nil;
    
    return subImage;
}

#pragma -
#pragma image utilities
-(UIImage *)scaleAndRotateImage:(UIImage *)image
{
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage*)cropImage:(UIImage *)imageToCrop toRect:(CGRect)rect {
    CGImageRef cropped = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect);
    UIImage *retImage = [UIImage imageWithCGImage: cropped];
    CGImageRelease(cropped);
    return retImage;
}

- (void)SingleTap:(UITapGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:VideoPreviewView];
    
    //NSLog(@"(%.2f,%.2f)\n",touchPoint.x,touchPoint.y);

    [IDCamera focusAtPoint:touchPoint];
}


@end
