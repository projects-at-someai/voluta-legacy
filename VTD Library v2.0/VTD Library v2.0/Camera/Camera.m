//
//  Camera.m
//  TRF
//
//  Created by Francis Bowen on 6/9/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import "Camera.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@interface UIImage (RotationMethods)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
@end

@implementation UIImage (RotationMethods)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
@end

@implementation Camera

@synthesize captureVideoPreviewLayer;
@synthesize capturedImage;
@synthesize delegate;
@synthesize orientation;
@synthesize session;
@synthesize parentView;
@synthesize videoDeviceInput;

- (id)initWithCameraType:(NSString *)CameraType
{
    self = [super init];
    
    if (self) {
        
        // Create the AVCaptureSession
        session = [[AVCaptureSession alloc] init];
        [self setSession:session];
        
        //orientation = AVCaptureVideoOrientationPortrait;
        
        UIDeviceOrientation device_orientation = [[UIDevice currentDevice] orientation];
        
        if (device_orientation == UIDeviceOrientationLandscapeLeft) {
            
            orientation = AVCaptureVideoOrientationLandscapeRight;
        }
        else if (device_orientation == UIDeviceOrientationLandscapeRight) {
            
            orientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        else if (device_orientation == UIDeviceOrientationPortrait) {
            
            orientation = AVCaptureVideoOrientationPortrait;
        }
        else
        {
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
        }
        
        // Check for device authorization
        [self checkDeviceAuthorizationStatus];
        
        // Dispatch the rest of session setup to the sessionQueue so that the main queue isn't blocked.
        dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        [self setSessionQueue:sessionQueue];
        
        dispatch_async(sessionQueue, ^{
            [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
            
            NSError *error = nil;

            if ([CameraType isEqualToString:@"Front"]) {
                
                videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self frontFacingCamera] error:&error];
            }
            else {
                
                videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backFacingCamera] error:&error];
            }
            

            
#ifdef DEBUG
            if (error)
            {
                NSLog(@"%@", error);
            }
#endif
            
            if ([session canAddInput:videoDeviceInput])
            {
                [session addInput:videoDeviceInput];
                [self setVideoDeviceInput:videoDeviceInput];
            }
            
#ifdef DEBUG
            if (error)
            {
                NSLog(@"%@", error);
            }
#endif
            
            AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            if ([session canAddOutput:stillImageOutput])
            {
                [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
                [session addOutput:stillImageOutput];
                [self setStillImageOutput:stillImageOutput];
            }
        });
        
        CameraRunning = NO;
        

    }
    
    return self;
}

- (void)SetupVideoPreviewView:(UIView *)videoPreviewView
{

    // Setup the preview view
    if (self.captureVideoPreviewLayer == nil) {
        
        self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    }
    
    self.captureVideoPreviewLayer.frame = videoPreviewView.bounds;
    [[self.captureVideoPreviewLayer connection] setVideoOrientation:orientation];
    //preview.videoGravity = AVLayerVideoGravityResizeAspect; // hmmm.
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [videoPreviewView.layer addSublayer: captureVideoPreviewLayer];
    
}

- (void)StartCamera
{
    
    dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		/*
		__weak takePictureViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			takePictureViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
				
			});
		}]];
        */
        
		[[self session] startRunning];
        
	});
    
    CameraRunning = YES;
}

- (void)StopCamera
{
    if (!CameraRunning) {
        return;
    }
    
    dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
	});
    
    CameraRunning = NO;
}

- (void)SetParentView:(UIView *)pView
{
    parentView = pView;
}

- (void)TakePicture
{

    [self flashScreen];
    
    /*
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:CGPointMake(360.0, 125.0) monitorSubjectAreaChange:YES];
    */
    
    
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:CGPointMake(360.0, 125.0) monitorSubjectAreaChange:YES];
    
    // Capture a still image
    
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(takeFocusedPicture:) userInfo:nil repeats:NO];
    
}

-(void)takeFocusedPicture:(id)sender
{
    //[[self captureManager] captureStillImage:capturedImage withView:self.view withParentVC:self];
    [self snapStillImage];
}

#pragma AVCAM
- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			//[self runStillImageCaptureAnimation];
		}
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
        //BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
        
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void) focusAtPoint:(CGPoint)point {
    
    AVCaptureDevice *device = [videoDeviceInput device];
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error;
        
        CGPoint focusPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
        
        if ([device lockForConfiguration:&error]) {
            
            [device setFocusPointOfInterest:CGPointMake(focusPoint.x,focusPoint.y)];
            
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            
            [device unlockForConfiguration];
            
        } else {
            
            NSLog(@"focusAtPoint error: %@", error);
            
        }        
        
    }
    else {
        
        NSLog(@"Focus point of interest not supported");
    }
    
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

- (void)snapStillImage
{
	dispatch_async([self sessionQueue], ^{
        
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:orientation];
        
		// Capture a still image.

        AVCaptureConnection *connection = [[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo];

        if (!connection || !connection.enabled || !connection.active) {

            if (delegate) {
                [delegate CameraComplete:NO];
            }

            return;
        }

		[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:connection
                                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
			
			if (CMSampleBufferIsValid(imageDataSampleBuffer))
			{
				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                capturedImage = [[UIImage alloc] initWithData:imageData];
                imageData = nil;
                
                if (delegate) {
                    [delegate CameraComplete:YES];
                }
                
			}
		}];
	});
}

+ (void)PresentAuthDialog {
    
    NSString *mediaType = AVMediaTypeVideo;
    
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType:completionHandler:)]) {
        
        
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if (granted)
            {
                //Granted access to mediaType
                //[self setDeviceAuthorized:YES];
            }
            else
            {
                //Not granted access to mediaType
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //[self setDeviceAuthorized:NO];
                });
            }
        }];
        
    }
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType:completionHandler:)]) {
        
        
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if (granted)
            {
                //Granted access to mediaType
                [self setDeviceAuthorized:YES];
            }
            else
            {
                //Not granted access to mediaType
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self setDeviceAuthorized:NO];
                });
            }
        }];
        
    }
    else
    {
        [self setDeviceAuthorized:YES];
    }
}

-(void)flashScreen {
    /*
     CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
     NSArray *animationValues = @[ @0.8f, @0.0f ];
     NSArray *animationTimes = @[ @0.3f, @1.0f ];
     id timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
     NSArray *animationTimingFunctions = @[ timingFunction, timingFunction ];
     [opacityAnimation setValues:animationValues];
     [opacityAnimation setKeyTimes:animationTimes];
     [opacityAnimation setTimingFunctions:animationTimingFunctions];
     opacityAnimation.fillMode = kCAFillModeForwards;
     opacityAnimation.removedOnCompletion = YES;
     opacityAnimation.duration = 0.4;
     
     [whiteScreen.layer addAnimation:opacityAnimation forKey:@"animation"];
     */
    
    CATransition *shutterAnimation = [CATransition animation];
    [shutterAnimation setDelegate:self];
    [shutterAnimation setDuration:0.6];
    
    shutterAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [shutterAnimation setType:@"cameraIris"];
    [shutterAnimation setValue:@"cameraIris" forKey:@"cameraIris"];
    CALayer *cameraShutter = [[CALayer alloc]init];
    //[cameraShutter setBounds:CGRectMake(0.0, 0.0, 320.0, 425.0)];
    [cameraShutter setBounds:captureVideoPreviewLayer.frame];
    
    [parentView.layer addSublayer:cameraShutter];
    [parentView.layer addAnimation:shutterAnimation forKey:@"cameraIris"];
}

- (void)ChangeOrientation:(NSString *)new_orientation
{
    if ([new_orientation isEqualToString:@"Landscape Left"]) {
        
        NSLog(@"camera changed to landscape left");
        
        orientation = AVCaptureVideoOrientationLandscapeRight;
        
        [[captureVideoPreviewLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
    else if([new_orientation isEqualToString:@"Landscape Right"])
    {
        NSLog(@"camera changed to landscape right");
        
        orientation = AVCaptureVideoOrientationLandscapeLeft;
        
        [[captureVideoPreviewLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }
    else if([new_orientation isEqualToString:@"Portrait"])
    {
        NSLog(@"camera changed to portrait");
        
        orientation = AVCaptureVideoOrientationPortrait;
        
        [[captureVideoPreviewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    else if ([new_orientation isEqualToString:@"Portrait Upside Down"])
    {
        NSLog(@"camera changed to portrait upside down");
        
        orientation = AVCaptureVideoOrientationPortraitUpsideDown;
        
        [[captureVideoPreviewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
    }
}

- (void)ChangeCameraType:(NSString *)CameraType {
    
    [session stopRunning];
    [session removeInput:videoDeviceInput];
    
    NSError *error = nil;

    AVCaptureDevice *camera = nil;

    if (!CameraType) {
        CameraType = @"Front";
    }
    
    if ([CameraType isEqualToString:@"Front"]) {
        
        camera = [self frontFacingCamera];
    }
    else {
        
        camera = [self backFacingCamera];
    }

    if (camera) {

        videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];

        if (videoDeviceInput) {

            [session addInput:videoDeviceInput];
        }

        [session startRunning];
    }

}

+ (bool)CheckForPermission {
    
    bool HasPermission = NO;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        HasPermission = YES;
    }
    
    return HasPermission;
}

@end

