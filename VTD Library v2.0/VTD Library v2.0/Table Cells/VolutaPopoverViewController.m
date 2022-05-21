//
//  VolutaPopoverViewController.m
//  TRF
//
//  Created by Francis Bowen on 10/29/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaPopoverViewController.h"

@interface VolutaPopoverViewController ()

@end

@implementation VolutaPopoverViewController

@synthesize RotationDelegate;
@synthesize DialogView;
@synthesize LandscapeFrame;
@synthesize PortraitFrame;
@synthesize ParentLandscapeFrame;
@synthesize ParentPortraitFrame;
@synthesize value;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect WindowBounds = [UIScreen mainScreen].bounds;
    CGFloat FrameWidth = WindowBounds.size.width;
    CGFloat FrameHeight = WindowBounds.size.height;
    
    FrameWidth = MAX(WindowBounds.size.width, WindowBounds.size.height);
    FrameHeight = MIN(WindowBounds.size.width, WindowBounds.size.height);
    
    LandscapeFrame = CGRectMake(0.0f, 0.0f, FrameWidth, FrameHeight);
    ParentLandscapeFrame = CGRectMake(0.0f, 0.0f, FrameWidth, FrameHeight);
    
    FrameWidth = MIN(WindowBounds.size.width, WindowBounds.size.height);
    FrameHeight = MAX(WindowBounds.size.width, WindowBounds.size.height);
    
    PortraitFrame = CGRectMake(0.0f, 0.0f, FrameWidth, FrameHeight);
    ParentPortraitFrame = CGRectMake(0.0f, 0.0f, FrameWidth, FrameHeight);
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    DialogView = [[UIView alloc] init];
    [self.view addSubview:DialogView];
    
    _AlertManager = [[AlertManager alloc] init];

}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self didRotate:nil withForceLayout:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *orientation_value = [defaults objectForKey:ORIENTATION_KEY];
    
    if ([orientation_value isEqualToString:ORIENTATION_AUTO]) {
        
        return YES;
    }
    
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    //return UIInterfaceOrientationMaskAll;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *orientation_value = [defaults objectForKey:ORIENTATION_KEY];
    
    if ([orientation_value isEqualToString:ORIENTATION_PORTRAIT]) {
        
        return UIInterfaceOrientationMaskPortrait;
    }
    else if ([orientation_value isEqualToString:ORIENTATION_LANDSCAPE]) {
        
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) didRotate:(NSNotification *)notification
{
    [self didRotate:notification withForceLayout:NO];
}

- (void) didRotate:(NSNotification *)notification withForceLayout:(bool)forceLayout
{
    UIDeviceOrientation LastOrientation = [RotationDelegate getDeviceOrientation];
    
    if (PreviousOrientation == LastOrientation && forceLayout != YES) {
        return;
    }
    
    PreviousOrientation = LastOrientation;
    [RotationDelegate setDeviceOrientation:LastOrientation];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *orientation_value = [defaults objectForKey:ORIENTATION_KEY];
    
    if ([orientation_value isEqualToString:ORIENTATION_PORTRAIT] && LastOrientation != UIDeviceOrientationPortrait && LastOrientation != UIDeviceOrientationPortraitUpsideDown) {
        
        LastOrientation = UIDeviceOrientationPortrait;
        
    }
    else if ([orientation_value isEqualToString:ORIENTATION_LANDSCAPE] && LastOrientation != UIDeviceOrientationLandscapeLeft && LastOrientation != UIDeviceOrientationLandscapeRight) {
        
        LastOrientation = UIDeviceOrientationLandscapeLeft;
    }

    
    if (LastOrientation == UIDeviceOrientationLandscapeLeft || LastOrientation == UIDeviceOrientationLandscapeRight)
    {
        
        [self.view setFrame:ParentLandscapeFrame];
        [DialogView setFrame:LandscapeFrame];
        
    }
    else
    {
        [self.view setFrame:ParentPortraitFrame];
        [DialogView setFrame:PortraitFrame];
        
    }
    
    if (self.RotationDelegate) {
        [self.RotationDelegate RotationDetected:LastOrientation];
    }


}

- (void)setupFrame {
    
    /*
     UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
     
     UIDeviceOrientation LastOrientation = (orientation == UIDeviceOrientationPortrait ||
     orientation == UIDeviceOrientationPortraitUpsideDown ||
     orientation == UIDeviceOrientationLandscapeLeft ||
     orientation == UIDeviceOrientationLandscapeRight) ? orientation : [[sharedData sharedInstance] getDeviceOrientation];
     */
    
    UIDeviceOrientation LastOrientation = [RotationDelegate getDeviceOrientation];
    
    PreviousOrientation = LastOrientation;
    //[[sharedData sharedInstance] setDeviceOrientation:LastOrientation];
    [RotationDelegate setDeviceOrientation:LastOrientation];
    
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
    
    if (LastOrientation == UIDeviceOrientationLandscapeLeft || LastOrientation == UIDeviceOrientationLandscapeRight)
    {
        
        FrameWidth = MAX(WindowBounds.size.width, WindowBounds.size.height);
        FrameHeight = MIN(WindowBounds.size.width, WindowBounds.size.height);
        
        [self.view setFrame:ParentLandscapeFrame];
        [DialogView setFrame:LandscapeFrame];
        
    }
    else
    {
        FrameWidth = MIN(WindowBounds.size.width, WindowBounds.size.height);
        FrameHeight = MAX(WindowBounds.size.width, WindowBounds.size.height);
        
        [self.view setFrame:ParentPortraitFrame];
        [DialogView setFrame:PortraitFrame];
        
    }
}

@end
