//
//  DisposableGripListManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

#define DEFAULTDGRIPLIST  @"DefaultDisposableGrips"
#define DGRIPLIST_PLIST   @"DisposableGripList"

@interface DisposableGripListManager : NSObject
{
    NSString *_DocumentsDir;
    NSArray *_DisposableGripListCSV;
    NSMutableArray *_DisposableGripList;
}

- (NSArray *)GetDisposableGrips;

- (void)AddDisposableGrip:(NSString *)Grip;

- (void)RemoveDisposableGrip:(NSString *)Grip;

- (void)SaveToPList;

- (void)RestoreDefaults;

- (void)RemoveAll;

@end
