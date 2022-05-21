//
//  FormCells.m
//  VTDLibrary 2.0
//
//  Created by Francis Bowen on 9/8/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "FormCells.h"

@implementation FormCells

@synthesize Datasource;
@synthesize TableCellsDictionary;
@synthesize RequiredCellsDictionary;
@synthesize PaddingCountDictionary;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        TableCellsDictionary = [[NSMutableDictionary alloc] init];
        RequiredCellsDictionary = [[NSMutableDictionary alloc] init];
        PaddingCountDictionary = [[NSMutableDictionary alloc] init];
        
        _PropertyListManager = [[TablePropertyListManager alloc] init];
        _PageTitles = [_PropertyListManager GetCategoryNames];
        
        //Check for region change
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![[Utilities GetCountryName] isEqualToString:[defaults objectForKey:REGION_KEY]]) {
            
            [defaults setObject:[Utilities GetCountryName] forKey:REGION_KEY];
        }
        
        _CellManager = [[TableCellManager alloc] init];
        _CellManager.Datasource = self;
        
        _IsInternational = NO;
    }
    
    return self;
}

- (NSArray *)GetPageTitles {
    
    return _PageTitles;
}

- (void)ReloadTableCells {
    
    for (int i = 0; i < [_PageTitles count]; i++) {
        [self ReloadTableCellsForPage:i];
    }
}

- (void)ReloadTableCellsForPage:(NSUInteger)index {
    [self LoadTable:index];
}

- (void)ReloadInternationalTableCells {
    
    for (int i = 0; i < [_PageTitles count]; i++) {
        [self ReloadInternationalTableCellsForPage:i];
    }
}

- (void)ReloadInternationalTableCellsForPage:(NSUInteger)index {
    
    [self ReloadInternationalTable:index];
}

- (void)LoadTable:(NSUInteger)TableNumber {
    
    //Get table cells
    NSString *PageName = [NSString stringWithFormat:@"%lu_%@", (unsigned long)TableNumber, [_PageTitles objectAtIndex:TableNumber]];
    NSArray *TableCellNames = [_PropertyListManager GetCellNamesFromCategory:PageName];
    NSDictionary *TableStructureForPage = [_PropertyListManager GetPageTableStructure:PageName];
    
    NSMutableArray *CellsArray = [[NSMutableArray alloc] init];
    NSMutableArray *RequiredCells = [[NSMutableArray alloc] init];
    
    int PaddingCount = 0;
    
    for (int i = 0; i < [TableCellNames count]; i++) {
        
        NSString *CellName = [NSString stringWithFormat:@"%02lu_%@", (unsigned long)i, [TableCellNames objectAtIndex:i]];
        
        NSArray *CellProperties = [TableStructureForPage objectForKey:CellName];
        
        NSString *CellType = [CellProperties objectAtIndex:0];
        
        if ([CellType isEqualToString:@"Health Table"]) {
            
            NSMutableArray *HealthCells = [_CellManager CreateHealthItemsCells:[Datasource GetParentViewController]];
            
            [CellsArray addObjectsFromArray:HealthCells];
            
            [RequiredCells addObjectsFromArray:[[self RequiredHealthItems] allKeys]];
            
            bool isResubmitting = [Datasource IsResubmitting];
            
            if ([Datasource IsResubmitting]) {
                
                for (int i = 0; i < [HealthCells count]; i++) {
                    
                    if ([[HealthCells objectAtIndex:i] isKindOfClass:[GeneralSegmentedTableCell class]]) {
                        
                        GeneralSegmentedTableCell *cell = [HealthCells objectAtIndex:i];
                        [cell setSegmentWithTitle:[Datasource GetFormData:[cell GetDataKey]]];
                    }
                    else if ([[HealthCells objectAtIndex:i] isKindOfClass:[TextInputTableCell class]]) {
                        
                        TextInputTableCell *cell = [HealthCells objectAtIndex:i];
                        [cell assignText:[Datasource GetFormData:[cell GetDataKey]]];
                    }
                }
            }
        }
        else {
            
            NSString *ResubmitValue = @"";
            bool isResubmitting = [Datasource IsResubmitting];
            
            if ([Datasource IsResubmitting]) {
                
                ResubmitValue = [Datasource GetFormData:[CellProperties objectAtIndex:4]];
            }

            VolutaTRFCell *cell = nil;
            NSString *UserDefaultsFlag = [CellProperties objectAtIndex:10];
            NSString *Flag = @"Yes";
            
            if (![UserDefaultsFlag isEqualToString:@"*"]) {
                Flag = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsFlag];
            }
            
            bool isUsingCell = (Flag != nil && [Flag isEqualToString:@"Yes"]);
            
            if (isUsingCell) {
            
                if (_IsInternational && ![[CellProperties objectAtIndex:5] isEqualToString:@"*"]) {
                    
                    if (![[CellProperties objectAtIndex:9] isEqualToString:@"*"]) {
                        
                        ResubmitValue = [CellProperties objectAtIndex:9];
                        isResubmitting = YES;
                    }
                    
                    cell = [_CellManager CreateCell:[Datasource GetParentViewController]
                                       withCellType:[CellProperties objectAtIndex:5]
                                withCellDescription:[CellProperties objectAtIndex:6]
                                      withCellTitle:[CellProperties objectAtIndex:7]
                                     withDetailText:[CellProperties objectAtIndex:2]
                                 withIsResubmitting:isResubmitting
                                  withResubmitValue:ResubmitValue
                                        withDataKey:[CellProperties objectAtIndex:4]];
                }
                else {
                    
                    if (![[CellProperties objectAtIndex:8] isEqualToString:@"*"]) {
                        
                        ResubmitValue = [CellProperties objectAtIndex:8];
                        isResubmitting = YES;
                    }
                    
                    //NSLog(@"Creating cell %@\n",[CellProperties objectAtIndex:0]);
                    
                    cell = [_CellManager CreateCell:[Datasource GetParentViewController]
                                       withCellType:[CellProperties objectAtIndex:0]
                                withCellDescription:[CellProperties objectAtIndex:1]
                                      withCellTitle:[TableCellNames objectAtIndex:i]
                                     withDetailText:[CellProperties objectAtIndex:2]
                                 withIsResubmitting:isResubmitting
                                  withResubmitValue:ResubmitValue
                                        withDataKey:[CellProperties objectAtIndex:4]];
                }
            
                if ([[CellProperties objectAtIndex:0] isEqualToString:@"Padding"]) {
                    PaddingCount++;
                }

                bool required = NO;
                
                if ([[CellProperties objectAtIndex:3] isEqualToString:@"Required"]) {
                
                    required = YES;
                    NSString *requiredkey = [CellProperties objectAtIndex:4];
                    
                    /*
                    if ([requiredkey isEqualToString:@"How long since you last ate?"]) {
                        int  i = 0;
                        i++;
                        int j = i;
                        NSLog(@"Here");
                    }
                    */
                    
                    [RequiredCells addObject:requiredkey];
                }
                
                [cell SetRequired:required];

                if(cell)
                    [CellsArray addObject:cell];
                else
                    NSLog(@"Could not create cell: %@", [CellProperties objectAtIndex:1]);
                
            }
            
        }
        
        
    }
    
    [TableCellsDictionary removeObjectForKey:[_PageTitles objectAtIndex:TableNumber]];
    [RequiredCellsDictionary removeObjectForKey:[_PageTitles objectAtIndex:TableNumber]];
    [PaddingCountDictionary removeObjectForKey:[_PageTitles objectAtIndex:TableNumber]];
    
    [TableCellsDictionary setObject:CellsArray forKey:[_PageTitles objectAtIndex:TableNumber]];
    [RequiredCellsDictionary setObject:RequiredCells forKey:[_PageTitles objectAtIndex:TableNumber]];
    [PaddingCountDictionary setObject:[NSNumber numberWithInt:PaddingCount] forKey:[_PageTitles objectAtIndex:TableNumber]];
}

- (void)ReloadInternationalTable:(NSUInteger)TableNumber {
    
    //Get table cells
    NSString *PageName = [NSString stringWithFormat:@"%lu_%@", (unsigned long)TableNumber, [_PageTitles objectAtIndex:TableNumber]];
    NSArray *TableCellNames = [_PropertyListManager GetCellNamesFromCategory:PageName];
    NSDictionary *TableStructureForPage = [_PropertyListManager GetPageTableStructure:PageName];
    
    NSMutableArray *CellsArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *TableCells = [TableCellsDictionary objectForKey:[_PageTitles objectAtIndex:TableNumber]];
    
    for (int i = 0; i < [TableCellNames count]; i++) {
        
        NSString *CellName = [NSString stringWithFormat:@"%02lu_%@", (unsigned long)i, [TableCellNames objectAtIndex:i]];
        
        NSArray *CellProperties = [TableStructureForPage objectForKey:CellName];
        
        NSString *CellType = [CellProperties objectAtIndex:0];
        
        if ([CellType isEqualToString:@"Health Table"]) {
            
            NSMutableArray *HealthCells = [_CellManager CreateHealthItemsCells:[Datasource GetParentViewController]];
            
            [CellsArray addObjectsFromArray:HealthCells];
        }
        else {
            
            NSString *ResubmitValue = @"";
            bool isResubmitting = [Datasource IsResubmitting];
            
            if ([Datasource IsResubmitting]) {
                
                ResubmitValue = [Datasource GetFormData:[CellProperties objectAtIndex:1]];
            }
            
            VolutaTRFCell *cell = nil;
            
            if (![[CellProperties objectAtIndex:5] isEqualToString:@"*"]) {
                
                if (_IsInternational) {
                    
                    if (![[CellProperties objectAtIndex:9] isEqualToString:@"*"]) {
                        
                        ResubmitValue = [CellProperties objectAtIndex:9];
                        isResubmitting = YES;
                    }
                    
                    cell = [_CellManager CreateCell:[Datasource GetParentViewController]
                                       withCellType:[CellProperties objectAtIndex:5]
                                withCellDescription:[CellProperties objectAtIndex:6]
                                      withCellTitle:[CellProperties objectAtIndex:7]
                                     withDetailText:[CellProperties objectAtIndex:2]
                                 withIsResubmitting:isResubmitting
                                  withResubmitValue:ResubmitValue
                                        withDataKey:[CellProperties objectAtIndex:4]];
                }
                else {
                    
                    if (![[CellProperties objectAtIndex:8] isEqualToString:@"*"]) {
                        
                        ResubmitValue = [CellProperties objectAtIndex:8];
                        isResubmitting = YES;
                    }
                    
                    cell = [_CellManager CreateCell:[Datasource GetParentViewController]
                                       withCellType:[CellProperties objectAtIndex:0]
                                withCellDescription:[CellProperties objectAtIndex:1]
                                      withCellTitle:[TableCellNames objectAtIndex:i]
                                     withDetailText:[CellProperties objectAtIndex:2]
                                 withIsResubmitting:isResubmitting
                                  withResubmitValue:ResubmitValue
                                        withDataKey:[CellProperties objectAtIndex:4]];
                }
                
                [TableCells replaceObjectAtIndex:i withObject:cell];
                
            }
            
            
            
        }
        
        
    }
    
    
}

- (bool)SetIsInternational:(bool)international {
    
    bool didchange = (_IsInternational != international);
    
    _IsInternational = international;
    
    return didchange;
}

- (bool)GetIsInternational {
    
    return _IsInternational;
}

- (NSMutableArray *)GetCellsForPage:(NSUInteger)index {
    
    return [TableCellsDictionary objectForKey:[_PageTitles objectAtIndex:index]];
}

- (NSMutableArray *)GetRequiredCellsForPage:(NSUInteger)index {
    
    return [RequiredCellsDictionary objectForKey:[_PageTitles objectAtIndex:index]];
}

- (NSMutableArray *)CheckForRequiredCells:(NSUInteger)PageIndex withData:(NSDictionary *)Data {
    
    NSMutableArray *MissingItems = [[NSMutableArray alloc] init];
    
    NSMutableArray *RequiredCells = [RequiredCellsDictionary objectForKey:[_PageTitles objectAtIndex:PageIndex]];
    
    for (NSString *key in RequiredCells) {
        
        NSString *value = [Data objectForKey:key];
        
        if (value == nil || [value isEqualToString:@""]) {
            
            [MissingItems addObject:key];
        }
    }
    
    return MissingItems;
}

- (int)GetNumPaddingCells:(NSUInteger)index {
    
    NSNumber *PaddingCount = [PaddingCountDictionary objectForKey:[_PageTitles objectAtIndex:index]];
    return [PaddingCount intValue];
}

- (NSArray *)GetAllergies {
    
    return [Datasource GetAllergies];
}

- (NSArray *)GetDiseases {
    
    return [Datasource GetDiseases];
}

- (NSArray *)GetHealthConditions {
    
    return [Datasource GetHealthConditions];
}

- (NSMutableDictionary *)RequiredHealthItems {
    
    return [Datasource RequiredHealthItems];
}

- (BOOL)IsResubmitting {
    
    return [Datasource IsResubmitting];
}

@end
