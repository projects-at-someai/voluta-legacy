//
//  LongTutorialViewController.m
//  CRF
//
//  Created by Francis Bowen on 5/20/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "LongTutorialViewController.h"

@interface LongTutorialViewController ()

@end

@implementation LongTutorialViewController

@synthesize ScrollView;
//@synthesize pageControl;
@synthesize BeginButton;
@synthesize PanelNumberLabel;

- (void)viewDidLoad {
    
    self.BaseBackgroundDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ScrollView = [[UIScrollView alloc] init];
    [ScrollView setPagingEnabled:YES];
    ScrollView.showsHorizontalScrollIndicator = NO;
    ScrollView.delegate = self;
    [self.view addSubview:ScrollView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //self.pageControl = [[UIPageControl alloc] init];
    //pageControl.numberOfPages = NUM_WELCOME_PANELS;
    //pageControl.backgroundColor = [UIColor blackColor];
    //[self.view addSubview:pageControl];
    
    PanelNumberLabel = [[UILabel alloc] init];
    PanelNumberLabel.font = [UIFont fontWithName:VTD_FONT size:32.0f];
    PanelNumberLabel.textColor = VTD_LIGHT_BLUE;
    PanelNumberLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:PanelNumberLabel];
    
    _DisableSlideshow = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    CGRect frame = ScrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    [ScrollView scrollRectToVisible:frame animated:NO];
    PanelNumberLabel.text = [NSString stringWithFormat:@"1 of %d",NUM_WELCOME_PANELS];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    CLS_LOG(@"long tutorial vc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)backgroundFileNamePortrait {
    
    return NO_BACKGROUND_IMAGE;
}

- (NSString *)backgroundFileNameLandscape {
    
    return NO_BACKGROUND_IMAGE;
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {
    
    for (UIView *v in ScrollView.subviews) {
        if ([v isKindOfClass:[UIView class]]) {
            [v removeFromSuperview];
        }
    }
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        [self SetupLandscape];
        
    }
    else {
        
        [self SetupPortrait];
    }
}

- (void)beginButtonTapped:(id)sender
{
    if (self.BaseDelegate) {
        [self.BaseDelegate VCComplete:self destinationViewController:nil];
    }
}

- (void)SetupLandscape {
    
    CGRect WindowBounds = [UIScreen mainScreen].bounds;
    CGFloat FrameWidth;
    CGFloat FrameHeight;
    
    FrameWidth = MAX(WindowBounds.size.width, WindowBounds.size.height);
    FrameHeight = MIN(WindowBounds.size.width, WindowBounds.size.height);
    
    [ScrollView setFrame:CGRectMake(0.0f, 20.0f, FrameWidth, FrameHeight - 75.0f)];
    //[pageControl setFrame:CGRectMake(98.5, 10.0f, 827.0f, 50.0f)];
    //pageControl.center = CGPointMake(FrameWidth / 2.0f, FrameHeight - 125.0f);
    
    [PanelNumberLabel setFrame:CGRectMake(0.0f, FrameHeight - 150.0f, FrameWidth - 50.0f, 50.0f)];
    
    for (int i = 0; i < NUM_WELCOME_PANELS; i++)
    {
        CGFloat width = FrameWidth - 197.0f;
        CGFloat height = FrameHeight - 186.0f;
        
        CGFloat x = i * FrameWidth + 98.5;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, 5.0f, width, height)];
        
        //NSString * backgroundFileName = [NSString stringWithFormat:@"PANEL-%d.png",i+1];
        
        UIImage* howToImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"L-welcome-panel-%d",i+1] ofType:@"png"]];
        UIImageView *howToSetupView = [[UIImageView alloc] initWithImage:howToImg];
        
        [view addSubview:howToSetupView];
        
        if (i == (NUM_WELCOME_PANELS - 1)) {
            
            BeginButton = [[UIButton alloc] initWithFrame:CGRectMake(325.0f, 450.0f, 178.0f, 85.0f)];
            [BeginButton addTarget:self action:@selector(beginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [view addSubview:BeginButton];
        
        [ScrollView addSubview:view];
    }
    
    ScrollView.contentSize = CGSizeMake(FrameWidth*NUM_WELCOME_PANELS, FrameHeight-197.0f);
}

- (void)SetupPortrait {
    
    CGRect WindowBounds = [UIScreen mainScreen].bounds;
    CGFloat FrameWidth;
    CGFloat FrameHeight;
    
    FrameWidth = MIN(WindowBounds.size.width, WindowBounds.size.height);
    FrameHeight = MAX(WindowBounds.size.width, WindowBounds.size.height);
    
    [ScrollView setFrame:CGRectMake(0.0f, 0.0f, FrameWidth, FrameHeight - 125.0f)];
    //[pageControl setFrame:CGRectMake(0.0f, 0.0f, FrameWidth, 75.0f)];
    //pageControl.center = CGPointMake(FrameWidth/2, FrameHeight - 125.0f);
    
    [PanelNumberLabel setFrame:CGRectMake(0.0f, FrameHeight - 275.0f, FrameWidth, 50.0f)];
    
    for (int i = 0; i < NUM_WELCOME_PANELS; i++)
    {
        CGFloat width = FrameWidth - 200.0f;
        CGFloat height = FrameHeight - 225.0f;
        
        CGFloat x = i * FrameWidth + 100.0f;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, 50.0f, width, height)];
        
        //NSString * backgroundFileName = [NSString stringWithFormat:@"PANEL-%d.png",i+1];
        
        UIImage* howToImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"P-welcome-panel-%d",i+1] ofType:@"png"]];
        UIImageView *howToSetupView = [[UIImageView alloc] initWithImage:howToImg];
        
        [view addSubview:howToSetupView];
        
        if (i == (NUM_WELCOME_PANELS - 1)) {
            
            BeginButton = [[UIButton alloc] initWithFrame:CGRectMake(195.0f, 545.0f, 178.0f, 85.0f)];
            [BeginButton addTarget:self action:@selector(beginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [view addSubview:BeginButton];
        
        [ScrollView addSubview:view];
    }
    
    ScrollView.contentSize = CGSizeMake(FrameWidth*NUM_WELCOME_PANELS, FrameHeight-225.0f);
}

#pragma mark-
#pragma UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGRect WindowBounds = [UIScreen mainScreen].bounds;
    CGFloat FrameWidth;
    CGFloat FrameHeight;
    
    if (UIDeviceOrientationIsLandscape(self.CurrentDeviceOrientation))
    {
        FrameWidth = MAX(WindowBounds.size.width, WindowBounds.size.height);
        FrameHeight = MIN(WindowBounds.size.width, WindowBounds.size.height);
    }
    else
    {
        FrameWidth = MIN(WindowBounds.size.width, WindowBounds.size.height);
        FrameHeight = MAX(WindowBounds.size.width, WindowBounds.size.height);
    }
    
    float roundedValue = round(scrollView.contentOffset.x / FrameWidth);
    //pageControl.currentPage = roundedValue;
    
    PanelNumberLabel.text = [NSString stringWithFormat:@"%d of %d",(int)roundedValue+1,NUM_WELCOME_PANELS];
}

@end
