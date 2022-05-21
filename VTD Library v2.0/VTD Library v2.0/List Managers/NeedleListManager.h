//
//  NeedleListManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

#define DEFAULTNEEDLELIST  @"DefaultNeedles"
#define NEEDLELIST_PLIST   @"NeedleList"

@interface NeedleListManager : NSObject
{
    NSString *_DocumentsDir;
    NSArray *_NeedleListCSV;
    NSMutableDictionary *_NeedleList;
}

- (NSArray *)GetConfigurations;
- (NSArray *)GetTypeFromConfiguration:(NSString *)Configuration;
- (NSArray *)GetSizesFromConfiguration:(NSString *)Configuration andType:(NSString *)Type;

- (void)AddNeedleFromConfiguration:(NSString *)Configuration
                            inType:(NSString *)Type
                          withSize:(NSString *)Size;

- (void)RemoveNeedleFromConfiguration:(NSString *)Configuration
                               inType:(NSString *)Type
                             withSize:(NSString *)Size;

- (void)SaveToPList;

- (void)RestoreDefaults;

- (void)RemoveAll;

@end
