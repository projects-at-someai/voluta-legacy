//
//  InAppReviewManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 1/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "InAppReviewManager.h"

@implementation InAppReviewManager

- (bool)CheckForReview {

    bool didCheck = NO;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    long numForms = [defaults integerForKey:NUM_FORMS_REVIEW_KEY];

    if (numForms >= REVIEW_THRESHOLD) {

        [self DisplayReviewController];

        didCheck = YES;
    }

    return didCheck;
}

- (void)IncrementNumberForms {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    long numForms = [defaults integerForKey:NUM_FORMS_REVIEW_KEY];
    numForms = numForms + 1;

    [defaults setInteger:numForms forKey:NUM_FORMS_REVIEW_KEY];

}

- (void)DisplayReviewController {

    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    }
    else  {

        //iOS 9

    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setInteger:0 forKey:NUM_FORMS_REVIEW_KEY];

}


@end
