//
//  VolutaPopoverViewController.h
//  TRF
//
//  Created by Francis Bowen on 10/29/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertManager.h"
//#import "sharedData.h"

@protocol PopoverRotationDelegate
@required
- (void)RotationDetected:(UIDeviceOrientation)orientation;

- (UIDeviceOrientation)getDeviceOrientation;
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation;

@end

@interface VolutaPopoverViewController : UIViewController
{
    UIDeviceOrientation PreviousOrientation;
    AlertManager *_AlertManager;
    
}

@property (retain) UIView *DialogView;
@property (assign) CGRect LandscapeFrame;
@property (assign) CGRect PortraitFrame;

@property (assign) CGRect ParentLandscapeFrame;
@property (assign) CGRect ParentPortraitFrame;

@property (nonatomic, strong) NSString *value;
@property (nonatomic, weak) id<PopoverRotationDelegate> RotationDelegate;

- (void)setupFrame;

@end
