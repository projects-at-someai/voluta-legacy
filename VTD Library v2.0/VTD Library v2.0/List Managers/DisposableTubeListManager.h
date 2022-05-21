//
//  DisposableTubeListManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHCSVParser.h"

#define DEFAULTDTUBELIST  @"DefaultDisposableTubes"
#define DTUBELIST_PLIST   @"DisposableTubeList"

@interface DisposableTubeListManager : NSObject
{
    NSString *_DocumentsDir;
    NSArray *_DisposableTubeListCSV;
    NSMutableArray *_DisposableTubeList;
}

- (NSArray *)GetDisposableTubes;

- (void)AddDisposableTube:(NSString *)Tube;

- (void)RemoveDisposableTube:(NSString *)Tube;

- (void)SaveToPList;

- (void)RestoreDefaults;

- (void)RemoveAll;

@end
