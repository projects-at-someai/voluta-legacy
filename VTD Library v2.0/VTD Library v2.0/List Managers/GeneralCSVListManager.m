//
//  GeneralCSVManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "GeneralCSVListManager.h"

@implementation GeneralCSVListManager

@synthesize datasource;

- (id)initWithDataSource:(id <GeneralCSVListDatasource>)source {
    
    self = [super init];

    datasource = source;

    _DefaultListFileName = [datasource GetDefaultListFilename];
    _ListFilename = [datasource GetListFilename];

    if (self) {
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _DocumentsDir = [documentPaths objectAtIndex:0];
        
        [self LoadPList];
    }
    
    return self;
}

- (bool)CheckForPList:(NSString *)PlistName {
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *path = [_DocumentsDir stringByAppendingPathComponent:PlistName];
    
    return [fm fileExistsAtPath:path isDirectory:nil];
}

- (void)LoadPList {
    
    if (![self CheckForPList:[NSString stringWithFormat:@"%@.plist",_ListFilename]]) {
        
        [self RestoreDefaults];
        
    }
    else {
        
        _GeneralItemList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,_ListFilename]];
    }
}

- (void)SaveToPList {
    
    [_GeneralItemList writeToFile:
     [NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,_ListFilename] atomically:NO];
}

- (void)RestoreDefaults {
    
    NSLog(@"Loading default general csv list");

    NSString *DefaultCSVPath = [[NSBundle mainBundle]
                                pathForResource:_DefaultListFileName
                                ofType:@"csv"];
    
    
    _GeneralItemListCSV = [NSArray arrayWithContentsOfCSVFile:DefaultCSVPath options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
    
    if (_GeneralItemList == nil) {
        
        _GeneralItemList = [[NSMutableArray alloc] init];
    }
    
    [_GeneralItemList removeAllObjects];
    
    for (int i = 1; i < [_GeneralItemListCSV count]; i++) {
        
        NSArray *itemArray = [_GeneralItemListCSV objectAtIndex:i];
        
        [self AddGeneralItem:[itemArray objectAtIndex:0]];
        
    }
    
    [self SaveToPList];
}

- (NSArray *)GetGeneralItems {
    
    return [_GeneralItemList copy];
}

- (void)AddGeneralItem:(NSString *)Item {
    
    NSInteger index = [_GeneralItemList indexOfObjectIdenticalTo:Item];
    
    if (index == NSNotFound) {
        
        [_GeneralItemList addObject:Item];
    }
}

- (void)RemoveGeneralItem:(NSString *)Item {
    
    NSInteger index = [_GeneralItemList indexOfObjectIdenticalTo:Item];
    
    if (index != NSNotFound) {
        
        [_GeneralItemList removeObjectAtIndex:index];
    }
}

- (void)RemoveAll {
    
    [_GeneralItemList removeAllObjects];
}

@end
