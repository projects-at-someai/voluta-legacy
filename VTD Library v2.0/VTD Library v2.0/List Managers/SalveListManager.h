//
//  SalveListManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

#define DEFAULTDSALVELIST  @"DefaultSalves"
#define SALVELIST_PLIST   @"SalveList"

@interface SalveListManager : NSObject
{
    NSString *_DocumentsDir;
    NSArray *_SalveListCSV;
    NSMutableArray *_SalveList;
}

- (NSArray *)GetSalves;

- (void)AddSalve:(NSString *)Salve;

- (void)RemoveSalve:(NSString *)Salve;

- (void)SaveToPList;

- (void)RestoreDefaults;

- (void)RemoveAll;

@end
