//
//  BladeListManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

#define DEFAULTBLADELIST  @"DefaultBlades"
#define BLADELIST_PLIST   @"BladeList"

@interface BladeListManager : NSObject
{
    NSString *_DocumentsDir;
    NSArray *_BladeListCSV;
    NSMutableDictionary *_BladeList;
}

- (NSArray *)GetConfigurations;
- (NSArray *)GetTypeFromConfiguration:(NSString *)Configuration;
- (NSArray *)GetSizesFromConfiguration:(NSString *)Configuration andType:(NSString *)Type;

- (void)AddBladeFromConfiguration:(NSString *)Configuration
                            inType:(NSString *)Type
                          withSize:(NSString *)Size;

- (void)RemoveBladeFromConfiguration:(NSString *)Configuration
                               inType:(NSString *)Type
                             withSize:(NSString *)Size;

- (void)SaveToPList;

- (void)RestoreDefaults;

- (void)RemoveAll;

@end
