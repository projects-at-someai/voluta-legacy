//
//  InkThinnerManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

#define DEFAULTINKTHINNERLIST  @"DefaultInkThinners"
#define INKTHINNERLIST_PLIST   @"InkThinnerList"

@interface InkThinnerListManager : NSObject
{
    NSString *_DocumentsDir;
    NSArray *_InkThinnerListCSV;
    NSMutableArray *_InkThinnerList;
}

- (NSArray *)GetInkThinners;

- (void)AddInkThinner:(NSString *)Thinner;

- (void)RemoveInkThinner:(NSString *)Thinner;

- (void)SaveToPList;

- (void)RestoreDefaults;

- (void)RemoveAll;

@end
