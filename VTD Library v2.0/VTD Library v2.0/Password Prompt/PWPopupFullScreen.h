//
//  PWPopupFullScreen.h
//  TRF
//
//  Created by Francis Bowen on 11/11/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWPopup.h"

@protocol PWPopupFullScreenDelegate
@optional
- (void)unlockWasSuccessful;
- (void)unlockWasUnsuccessful:(int)falseEntryCode afterAttemptNumber:(int)attemptNumber;
- (void)unlockWasCancelled;
@end

@interface PWPopupFullScreen : UIViewController <PWPopupDelegate>
{
    NSString *PWType;
    NSString *MainTitle;
    NSString *SubTitle;
    bool hasDone;
    bool hasCancel;
}

@property (retain) PWPopup *PWPrompt;
@property (nonatomic, weak) id<PWPopupFullScreenDelegate> delegate;

- (void)setPWType:(NSString *)type;
- (void)setMainTitle:(NSString *)mTitle;
- (void)setSubTitle:(NSString *)sTitle;
- (void)setHasDone:(bool)done;
- (void)setHasCancel:(bool)cancel;

@end
