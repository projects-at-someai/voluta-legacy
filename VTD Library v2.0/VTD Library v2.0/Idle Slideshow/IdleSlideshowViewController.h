//
//  IdleSlideshowViewController.h
//  PRF
//
//  Created by Francis Bowen on 4/23/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "sharedData.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageListManager.h"
#import "CoreDataManager.h"
#import <Crashlytics/Crashlytics.h>

#define IDLE_TITLE_PORTRAIT              CGRectMake(0.0f, 0.0f, 768.0f, 30.0f)
#define IDLE_SLIDESHOWVIEW_PORTRAIT      CGRectMake(0.0f, 30.0f, 768.0f, 994.0f)

#define IDLE_TITLE_LANDSCAPE             CGRectMake(0.0f, 0.0f, 1024.0f, 30.0f)
#define IDLE_SLIDESHOWVIEW_LANDSCAPE     CGRectMake(0.0f, 30.0f, 1024.0f, 738.0f)

@protocol IdleSlideshowDelegate
@optional
- (void)SlideshowComplete;

@required
- (UIDeviceOrientation)getDeviceOrientation;
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation;

- (ImageListManager *)GetImageListManager;

- (NSString *)GetSlideshowTitle;

- (CoreDataManager *)GetCoreDataManager;

@end

@interface IdleSlideshowViewController : UIViewController <UIGestureRecognizerDelegate>
{
    
    
    NSTimer *ImageChangeTimer;
    
    int currentImageIndex;
    
    ALAssetsLibraryAssetForURLResultBlock fullScreenProcessResultBlock;
    
    UIDeviceOrientation previousOrientation;
    
    CoreDataManager *_CoreDataManager;
    NSTimer *SyncTimer;
}

@property (retain) UIGestureRecognizer *singleTapGesture;
@property (retain) UIImageView *SlideshowView;
@property (retain) UILabel *IdleTitle;

@property (weak) id <IdleSlideshowDelegate> delegate;

@end
