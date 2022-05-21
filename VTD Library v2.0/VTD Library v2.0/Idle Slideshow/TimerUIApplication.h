//
//  TimerUIApplication.h
//  TRF
//
//  Created by Francis Bowen on 4/22/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kApplicationTimeoutInMinutes 1
#define kApplicationDidTimeoutNotification @"AppTimeOut"

@interface TimerUIApplication : UIApplication
{
    NSTimer *IdleTimer;
}

-(void)resetIdleTimer;

@property (assign) CGFloat MinutesToTimeout;

@end
