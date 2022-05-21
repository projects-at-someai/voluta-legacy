//
//  IdleSlideshowViewController.m
//  TRF
//
//  Created by Francis Bowen on 4/23/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import "IdleSlideshowViewController.h"

@interface IdleSlideshowViewController ()

@end

@implementation IdleSlideshowViewController

@synthesize delegate;
@synthesize singleTapGesture;
@synthesize SlideshowView;
@synthesize IdleTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    /*
     UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
     
     UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
     orientation == UIDeviceOrientationPortraitUpsideDown ||
     orientation == UIDeviceOrientationLandscapeLeft ||
     orientation == UIDeviceOrientationLandscapeRight) ? orientation : [[sharedData sharedInstance] getDeviceOrientation];
     */
    
    UIDeviceOrientation LastOrientation = [delegate getDeviceOrientation];

    self.view.backgroundColor = [UIColor blackColor];

    IdleTitle = [[UILabel alloc] init];
    IdleTitle.frame = (LastOrientation == UIDeviceOrientationLandscapeLeft || LastOrientation == UIDeviceOrientationLandscapeRight) ? CGRectMake(0.0f, 0.0f, 1024.0f, 30.0f) : CGRectMake(0.0f, 0.0f, 768.0f, 30.0f);
    IdleTitle.textColor = [UIColor whiteColor];
    IdleTitle.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:IdleTitle];
    
    self.SlideshowView = [[UIImageView alloc] init];
    self.SlideshowView.frame = (LastOrientation == UIDeviceOrientationLandscapeLeft || LastOrientation == UIDeviceOrientationLandscapeRight) ? IDLE_SLIDESHOWVIEW_LANDSCAPE : IDLE_SLIDESHOWVIEW_PORTRAIT;
    self.SlideshowView.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:SlideshowView];
    
    //Setup gesture recognizer
    // Add gesture recogniser
    self.singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGesture.delegate = self;
    
    [self.view addGestureRecognizer:singleTapGesture];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    fullScreenProcessResultBlock = ^(ALAsset *theAsset) {
        
        /*
         UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
         
         UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
         orientation == UIDeviceOrientationPortraitUpsideDown ||
         orientation == UIDeviceOrientationLandscapeLeft ||
         orientation == UIDeviceOrientationLandscapeRight) ? orientation : [[sharedData sharedInstance] getDeviceOrientation];
         */
        
        UIDeviceOrientation LastOrientation = [weakSelf.delegate getDeviceOrientation];
        
        CGRect WindowBounds = [UIScreen mainScreen].bounds;
        CGFloat FrameWidth = WindowBounds.size.width;
        CGFloat FrameHeight = WindowBounds.size.height;
        
        if (LastOrientation == UIDeviceOrientationLandscapeLeft || LastOrientation == UIDeviceOrientationLandscapeRight) {
            
            FrameWidth = MAX(WindowBounds.size.width, WindowBounds.size.height);
            FrameHeight = MIN(WindowBounds.size.width, WindowBounds.size.height);
            
        }
        else
        {
            
            FrameWidth = MIN(WindowBounds.size.width, WindowBounds.size.height);
            FrameHeight = MAX(WindowBounds.size.width, WindowBounds.size.height);
        }
        
        ALAssetRepresentation *rep = [theAsset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        
        CGSize imageDimensions = rep.dimensions;
        
        CGFloat screenWidth = FrameWidth;
        CGFloat screenHeight = FrameHeight - 30.0f;
        
        CGFloat widthScale = 1.0;
        CGFloat heightScale = 1.0;
        
        if (imageDimensions.width > screenWidth) {
            
            widthScale = screenWidth / imageDimensions.width;
        }
        
        if (imageDimensions.height > screenHeight) {
            
            heightScale = screenHeight / imageDimensions.height;
        }
        
        CGFloat scale = MIN(widthScale, heightScale);
        
        CGSize newDimensions;
        newDimensions.width = imageDimensions.width * scale;
        newDimensions.height = imageDimensions.height * scale;
        
        if (iref) {
            
            CGFloat newX = (screenWidth - newDimensions.width) / 2.0;
            CGFloat newY = 30.0f + (screenHeight - newDimensions.height) / 2.0;
            
            weakSelf.SlideshowView.frame = CGRectMake(newX, newY, newDimensions.width, newDimensions.height);
            
            weakSelf.SlideshowView.image = [UIImage imageWithCGImage:iref scale:scale
                                           orientation:(UIImageOrientation)rep.orientation];
            
            //UIImageView animation
            CATransition *transition = [CATransition animation];
            transition.duration = 2.0f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            
            [weakSelf.SlideshowView.layer addAnimation:transition forKey:nil];

        }
    };
    
    //[self didRotate:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    CLS_LOG(@"screensaver active");
    
    IdleTitle.text = [delegate GetSlideshowTitle];
    
    currentImageIndex = 0;
    
    ImageListManager *ImageManager = [delegate GetImageListManager];
    NSMutableArray *ImageList = [ImageManager getImageList];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ImageDelay = [defaults objectForKey:SLIDESHOW_DELAY_KEY];
    
    if ([ImageList count] == 0) {
        
        ImageChangeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(WaitForImageList) userInfo:nil repeats:NO];
    }
    else
    {
        ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:[ImageList objectAtIndex:0]
                       resultBlock:fullScreenProcessResultBlock
                      failureBlock:nil];
        
        ImageChangeTimer = [NSTimer scheduledTimerWithTimeInterval:[ImageDelay intValue] target:self selector:@selector(ImageChangeTimerExpired) userInfo:nil repeats:YES];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    _CoreDataManager = [delegate GetCoreDataManager];
    
    if ([_CoreDataManager IsUsingICloud]) {
        
        SyncTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(SyncCoreData) userInfo:nil repeats:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self didRotate:nil withForceLayout:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [ImageChangeTimer invalidate];
    
    if (SyncTimer) {
        [SyncTimer invalidate];
    }
}

- (void) didRotate:(NSNotification *)notification
{
    [self didRotate:notification withForceLayout:NO];
}

- (void) didRotate:(NSNotification *)notification withForceLayout:(bool)forceLayout
{
    /*
     UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
     
     UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
     orientation == UIDeviceOrientationPortraitUpsideDown ||
     orientation == UIDeviceOrientationLandscapeLeft ||
     orientation == UIDeviceOrientationLandscapeRight) ? orientation : [[sharedData sharedInstance] getDeviceOrientation];
     */
    
    UIDeviceOrientation LastOrientation = [delegate getDeviceOrientation];
    
    if (previousOrientation == LastOrientation && forceLayout != YES) {
        return;
    }
    
    previousOrientation = LastOrientation;
    
    //[[sharedData sharedInstance] setDeviceOrientation:LastOrientation];
    [delegate setDeviceOrientation:LastOrientation];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *orientation_value = [defaults objectForKey:ORIENTATION_KEY];
    
    if ([orientation_value isEqualToString:ORIENTATION_PORTRAIT] && LastOrientation != UIDeviceOrientationPortrait && LastOrientation != UIDeviceOrientationPortraitUpsideDown) {
        
        LastOrientation = UIDeviceOrientationPortrait;
        
    }
    else if ([orientation_value isEqualToString:ORIENTATION_LANDSCAPE] && LastOrientation != UIDeviceOrientationLandscapeLeft && LastOrientation != UIDeviceOrientationLandscapeRight) {
        
        LastOrientation = UIDeviceOrientationLandscapeLeft;
    }
    
    CGRect WindowBounds = [UIScreen mainScreen].bounds;
    CGFloat FrameWidth = WindowBounds.size.width;
    CGFloat FrameHeight = WindowBounds.size.height;
    
    if (LastOrientation == UIDeviceOrientationLandscapeLeft || LastOrientation == UIDeviceOrientationLandscapeRight) {
        
        FrameWidth = MAX(WindowBounds.size.width, WindowBounds.size.height);
        FrameHeight = MIN(WindowBounds.size.width, WindowBounds.size.height);
        
        //[SlideshowView setFrame:IDLE_SLIDESHOWVIEW_LANDSCAPE];
        
    }
    else
    {
        
        FrameWidth = MIN(WindowBounds.size.width, WindowBounds.size.height);
        FrameHeight = MAX(WindowBounds.size.width, WindowBounds.size.height);
        
        //[SlideshowView setFrame:IDLE_SLIDESHOWVIEW_LANDSCAPE];
    }
    
    [IdleTitle setFrame:CGRectMake(0.0f, 0.0f, FrameWidth, 30.0f)];
    
    CGSize imageDimensions = SlideshowView.image.size;
    
    CGFloat screenWidth = FrameWidth;
    CGFloat screenHeight = FrameHeight - 30.0f;
    
    CGFloat widthScale = 1.0;
    CGFloat heightScale = 1.0;
    
    if (imageDimensions.width > screenWidth) {
        
        widthScale = screenWidth / imageDimensions.width;
    }
    
    if (imageDimensions.height > screenHeight) {
        
        heightScale = screenHeight / imageDimensions.height;
    }
    
    CGFloat scale = MIN(widthScale, heightScale);
    
    CGSize newDimensions;
    newDimensions.width = imageDimensions.width * scale;
    newDimensions.height = imageDimensions.height * scale;
    
    CGFloat newX = (screenWidth - newDimensions.width) / 2.0;
    CGFloat newY = 30.0f + (screenHeight - newDimensions.height) / 2.0;
        
    SlideshowView.frame = CGRectMake(newX, newY, newDimensions.width, newDimensions.height);
    
    

    
}

- (void)singleTap:(UITapGestureRecognizer *)sender
{
    if (delegate) {
        [delegate SlideshowComplete];
    }
}

- (void)SyncCoreData {
    
    NSLog(@"Syncing core data while idle");
    
    [_CoreDataManager SyncCoreData];
}

- (void)WaitForImageList
{
    ImageListManager *ImageManager = [delegate GetImageListManager];
    NSMutableArray *ImageList = [ImageManager getImageList];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ImageDelay = [defaults objectForKey:SLIDESHOW_DELAY_KEY];
    
    if ([ImageList count] == 0) {
        
        ImageChangeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(WaitForImageList) userInfo:nil repeats:NO];
    }
    else
    {
        ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:[ImageList objectAtIndex:0]
                       resultBlock:fullScreenProcessResultBlock
                      failureBlock:nil];
        
        ImageChangeTimer = [NSTimer scheduledTimerWithTimeInterval:[ImageDelay intValue] target:self selector:@selector(ImageChangeTimerExpired) userInfo:nil repeats:YES];
    }
}

- (void)ImageChangeTimerExpired
{
    ImageListManager *ImageManager = [delegate GetImageListManager];
    NSMutableArray *ImageList = [ImageManager getImageList];
    
    if ([ImageList count] > 0) {
        
        if (currentImageIndex < [ImageList count] - 1) {
            
            currentImageIndex++;
        }
        else
        {
            currentImageIndex = 0;
        }
        
        ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:[ImageList objectAtIndex:currentImageIndex]
                       resultBlock:fullScreenProcessResultBlock
                      failureBlock:nil];
    }

}

@end
