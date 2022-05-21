//
//  Camera.h
//  TRF
//
//  Created by Francis Bowen on 6/9/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "AlertManager.h"

@protocol CameraCompleteDelegate
@optional
- (void)CameraComplete:(bool)Success;
@end

@interface Camera : NSObject
{
    BOOL CameraRunning;
}

- (id)initWithCameraType:(NSString *)CameraType;
- (void)StartCamera;
- (void)StopCamera;
- (void)TakePicture;
- (void)SetParentView:(UIView *)pView;
- (void)SetupVideoPreviewView:(UIView *)videoPreviewView;
- (void)ChangeOrientation:(NSString *)new_orientation;
- (void)ChangeCameraType:(NSString *)CameraType;
- (void) focusAtPoint:(CGPoint)point;
+ (void)PresentAuthDialog;
+ (bool)CheckForPermission;


@property (retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (retain) UIImage *capturedImage;
@property (retain) UIView *parentView;
@property (assign) AVCaptureVideoOrientation orientation;
@property (weak) id<CameraCompleteDelegate> delegate;

// Session management.
@property (retain, nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (retain, nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (retain, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;


@end
