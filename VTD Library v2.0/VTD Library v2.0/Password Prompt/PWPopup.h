//
//  PWPopup.h
//  DIO Tattoo Forms
//
//  Created by Francis Bowen on 9/27/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KeychainWrapper.h"
//#import "sharedData.h"

@protocol PWPopupDelegate
@required
- (void)unlockWasSuccessful;
- (void)unlockWasUnsuccessful:(int)falseEntryCode afterAttemptNumber:(int)attemptNumber;
- (void)unlockWasCancelled;

@optional
- (void)attemptsExpired;
@end

@interface PWPopup : UIViewController
{
    NSString *mainTitle;
    NSString *subTitle;
    bool hasAttempLimit;
    int attemptLimit;

    NSString *PWType;
    
    bool hasCancel;
    bool hasDone;
    
    UIButton *cancelButton;
    
    UIView *KeypadView;
    CGFloat XOffset;
    CGFloat YOffset;
}

@property (nonatomic, weak) id<PWPopupDelegate> delegate;

- (id)initWithDelegate:(id<PWPopupDelegate>)aDelegate withXOfffset:(CGFloat)x withYOffset:(CGFloat)y;
- (void)resetAttempts;
- (void)resetLockScreen;

- (void)setMainTitle:(NSString *)title;
- (void)setSubTitle:(NSString *)sTitle;
- (void)setHasAttemptLimit:(bool)hasAL;
- (void)setAttemptLimit:(int)limit;
- (void)setPWType:(NSString *)type;
- (void)setHasCancel:(bool)hasCnl;
- (void)setHasDone:(bool)hasDn;

@end
