//
//  InkListExtractor.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 2/25/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "InkListManager.h"

@implementation InkListManager

@synthesize datasource;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _DocumentsDir = [documentPaths objectAtIndex:0];
        
        [self LoadPList];
    }
    
    return self;
}

- (id)initWithDataSource:(id <InkListDatasource>)source {

    datasource = source;

    return [self init];
}

- (bool)CheckForPList:(NSString *)PlistName {
    

    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *path = [_DocumentsDir stringByAppendingPathComponent:PlistName];
    
    return [fm fileExistsAtPath:path isDirectory:nil];
}

- (void)LoadPList {
    
    if (![self CheckForPList:[NSString stringWithFormat:@"%@.plist",INKLIST_PLIST]]) {
        
        [self RestoreDefaults];
        
    }
    else {
        
        _InkList = [NSMutableDictionary dictionaryWithContentsOfFile:
                    [NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,INKLIST_PLIST]];
    }
}

- (void)SaveToPList {
    
    [_InkList writeToFile:[NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,INKLIST_PLIST]
               atomically:NO];
}

- (void)RestoreDefaults {
    
    NSLog(@"Loading default ink list");
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:TRFLISTBUNDLE ofType:@"bundle"];

    if (datasource) {

        NSString *bundlename = [datasource GetInkListBundle];

        if (bundlename) {
            bundlePath = [[NSBundle mainBundle] pathForResource:bundlename ofType:@"bundle"];
        }
    }
    
    NSString *DefaultCSVPath = [[NSBundle bundleWithPath:bundlePath]
                                pathForResource:DEFAULTINKLIST
                                ofType:@"csv"];

    if (datasource) {

        NSString *fn = [datasource GetInkListFileName];

        if (fn) {
            DefaultCSVPath = [[NSBundle bundleWithPath:bundlePath]
                              pathForResource:fn
                              ofType:@"csv"];
        }
    }

    _InkListCSV = [NSArray arrayWithContentsOfCSVFile:DefaultCSVPath options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
    
    if (_InkList == nil) {
        
        _InkList = [[NSMutableDictionary alloc] init];
    }
    
    [_InkList removeAllObjects];
    
    for (int i = 1; i < [_InkListCSV count]; i++) {
        
        NSArray *entry = [_InkListCSV objectAtIndex:i];
        
        if ([entry count ] == 3) {
            
            NSString *brand = [entry objectAtIndex:0];
            NSString *category = [entry objectAtIndex:1];
            NSString *color = [entry objectAtIndex:2];
            
            [self AddInkFromBrand:brand inCategory:category withColor:color];
            
        }
        
    }
    
    [self SaveToPList];
}

- (NSArray *)GetBrands {
    
    return [_InkList allKeys];
}

- (NSArray *)GetCategoriesFromBrand:(NSString *)Brand {
    
    NSMutableDictionary *InkBrand = [_InkList objectForKey:Brand];
    
    return [InkBrand allKeys];
}

- (NSArray *)GetColorsFromBrand:(NSString *)Brand andCategory:(NSString *)Category {
    
    NSMutableDictionary *InkBrand = [_InkList objectForKey:Brand];
    
    return [[InkBrand objectForKey:Category] copy];
}

- (void)AddInkFromBrand:(NSString *)Brand
             inCategory:(NSString *)Category
              withColor:(NSString *)Color {
    
    NSMutableDictionary *inkbrand = [_InkList objectForKey:Brand];
    
    if (inkbrand == nil) {
        
        inkbrand = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *colors = [[NSMutableArray alloc] init];
        [colors addObject:Color];
        
        [inkbrand setObject:colors forKey:Category];
        [_InkList setObject:inkbrand forKey:Brand];
    }
    else {

        if ([inkbrand objectForKey:Category] == nil) {
            
            NSMutableArray *colors = [[NSMutableArray alloc] init];
            [colors addObject:Color];
            
            [inkbrand setObject:colors forKey:Category];
        }
        else {
            
            NSMutableArray *colors = [inkbrand objectForKey:Category];
            
            NSInteger index = [colors indexOfObjectIdenticalTo:Color];
            
            if (index == NSNotFound) {
                
                [colors addObject:Color];
            }
        }
    }
}

- (void)RemoveInkFromBrand:(NSString *)Brand
                inCategory:(NSString *)Category
                 withColor:(NSString *)Color {
    
    NSMutableArray *colors = [[_InkList objectForKey:Brand] objectForKey:Category];

    NSUInteger index = [colors indexOfObject:Color];

    if (index != NSNotFound)
    {
        [colors removeObjectAtIndex:index];

        if ([colors count] == 0) {

            [[_InkList objectForKey:Brand] removeObjectForKey:Category];

            if ([[[_InkList objectForKey:Brand] allKeys] count] == 0) {

                [_InkList removeObjectForKey:Brand];
            }
        }
    }

}

- (void)RemoveAll {
    
    [_InkList removeAllObjects];
}


@end
