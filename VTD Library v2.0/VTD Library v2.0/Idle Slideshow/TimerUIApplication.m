//
//  TimerUIApplication.m
//  TRF
//
//  Created by Francis Bowen on 4/22/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import "TimerUIApplication.h"

@implementation TimerUIApplication

@synthesize MinutesToTimeout;

//here we are listening for any touch. If the screen receives touch, the timer is reset
-(void)sendEvent:(UIEvent *)event
{
    if (!IdleTimer)
    {
        [self resetIdleTimer];
    }
    
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0)
    {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan)
        {
            [self resetIdleTimer];
        }
        
    }

    [super sendEvent:event];
}
//as labeled...reset the timer
-(void)resetIdleTimer
{
    if (IdleTimer)
    {
        [IdleTimer invalidate];
    }
    //convert the wait period into seconds rather than minutes
    //int timeout = kApplicationTimeoutInMinutes * 60;
    int timeout = self.MinutesToTimeout * 60;
    IdleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];
    
}
//if the timer reaches the limit as defined in kApplicationTimeoutInMinutes, post this notification
-(void)idleTimerExceeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidTimeoutNotification object:nil];
}


@end
