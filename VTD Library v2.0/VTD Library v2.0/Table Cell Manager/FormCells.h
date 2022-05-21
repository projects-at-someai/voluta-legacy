//
//  FormCells.h
//  VTDLibrary 2.0
//
//  Created by Francis Bowen on 9/8/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TablePropertyListManager.h"
#import "TableCellManager.h"

@protocol FormCellsDatasource <NSObject>

@required
- (NSArray *)GetAllergies;
- (NSArray *)GetDiseases;
- (NSArray *)GetHealthConditions;
- (NSMutableDictionary *)RequiredHealthItems;
- (BOOL)IsResubmitting;
- (NSString *)GetFormData:(NSString *)Key;
- (UIViewController *)GetParentViewController;

@end

@interface FormCells : NSObject <TableCellManagerDatasource>
{
    bool _IsInternational;
    NSArray *_PageTitles;
    TablePropertyListManager *_PropertyListManager;
    TableCellManager *_CellManager;
}

@property (assign) id<FormCellsDatasource> Datasource;

- (NSArray *)GetPageTitles;
- (void)ReloadTableCells;
- (void)ReloadTableCellsForPage:(NSUInteger)index;
- (void)ReloadInternationalTableCells;
- (void)ReloadInternationalTableCellsForPage:(NSUInteger)index;
- (bool)SetIsInternational:(bool)international;
- (bool)GetIsInternational;
- (NSMutableArray *)GetCellsForPage:(NSUInteger)index;
- (int)GetNumPaddingCells:(NSUInteger)index;
- (NSMutableArray *)CheckForRequiredCells:(NSUInteger)PageIndex withData:(NSDictionary *)Data;

@property (retain) NSMutableDictionary *TableCellsDictionary;
@property (retain) NSMutableDictionary *RequiredCellsDictionary;
@property (retain) NSMutableDictionary *PaddingCountDictionary;

@end
