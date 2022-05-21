//
//  GeneralCSVManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

@protocol GeneralCSVListDatasource
@optional
// Sent when the user selects a row in the recent searches list.
- (NSString *)GetDefaultListFilename;
- (NSString *)GetListFilename;

@end

@interface GeneralCSVListManager : NSObject
{
    NSString *_DocumentsDir;
    NSArray *_GeneralItemListCSV;
    NSMutableArray *_GeneralItemList;

    NSString *_DefaultListFileName;
    NSString *_ListFilename;
}

@property (weak) id <GeneralCSVListDatasource> datasource;

- (id)initWithDataSource:(id <GeneralCSVListDatasource>)source;

- (NSArray *)GetGeneralItems;

- (void)AddGeneralItem:(NSString *)Item;

- (void)RemoveGeneralItem:(NSString *)Item;

- (void)SaveToPList;

- (void)RestoreDefaults;

- (void)RemoveAll;

@end
