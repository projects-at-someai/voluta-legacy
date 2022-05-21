//
//  InAppReviewManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 1/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface InAppReviewManager : NSObject
{

}

- (bool)CheckForReview;
- (void)IncrementNumberForms;

@end
