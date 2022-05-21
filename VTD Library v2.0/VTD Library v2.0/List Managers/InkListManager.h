//
//  InkListExtractor.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 2/25/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

#define DEFAULTINKLIST  @"DefaultInks"
#define INKLIST_PLIST   @"InkList"

@protocol InkListDatasource
@optional
// Sent when the user selects a row in the recent searches list.
- (NSString *)GetInkListFileName;
- (NSString *)GetInkListBundle;

@end

@interface InkListManager : NSObject
{
    NSString *_DocumentsDir;
    NSArray *_InkListCSV;
    NSMutableDictionary *_InkList;
}

@property (weak) id <InkListDatasource> datasource;

- (id)initWithDataSource:(id <InkListDatasource>)source;

- (NSArray *)GetBrands;
- (NSArray *)GetCategoriesFromBrand:(NSString *)Brand;
- (NSArray *)GetColorsFromBrand:(NSString *)Brand andCategory:(NSString *)Category;

- (void)AddInkFromBrand:(NSString *)Brand
             inCategory:(NSString *)Category
              withColor:(NSString *)Color;

- (void)RemoveInkFromBrand:(NSString *)Brand
                inCategory:(NSString *)Category
                 withColor:(NSString *)Color;

- (void)RestoreDefaults;

- (void)SaveToPList;
- (void)RemoveAll;

@end
