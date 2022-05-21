//
//  NeedleListManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "NeedleListManager.h"

@implementation NeedleListManager

- (id)init {
    
    self = [super init];
    
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
    
    if (![self CheckForPList:[NSString stringWithFormat:@"%@.plist",NEEDLELIST_PLIST]]) {
        
        [self RestoreDefaults];
        
    }
    else {
        
        _NeedleList = [NSMutableDictionary dictionaryWithContentsOfFile:
                       [NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,NEEDLELIST_PLIST]];
    }
}

- (void)SaveToPList {
    
    [_NeedleList writeToFile:[NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,NEEDLELIST_PLIST]
               atomically:NO];
}

- (void)RestoreDefaults {
    
    NSLog(@"Loading default needle list");
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:TRFLISTBUNDLE ofType:@"bundle"];
    
    NSString *DefaultCSVPath = [[NSBundle bundleWithPath:bundlePath]
                                pathForResource:DEFAULTNEEDLELIST
                                ofType:@"csv"];
    
    
    _NeedleListCSV = [NSArray arrayWithContentsOfCSVFile:DefaultCSVPath options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
    
    if (_NeedleList == nil) {
        
        _NeedleList = [[NSMutableDictionary alloc] init];
    }
    
    [_NeedleList removeAllObjects];
    
    for (int i = 1; i < [_NeedleListCSV count]; i++) {
        
        NSArray *entry = [_NeedleListCSV objectAtIndex:i];
        
        if ([entry count ] == 3) {
            
            NSString *configuration = [entry objectAtIndex:0];
            NSString *type = [entry objectAtIndex:1];
            NSString *size = [entry objectAtIndex:2];
            
            [self AddNeedleFromConfiguration:configuration inType:type withSize:size];
            
        }
        
    }
    
    [self SaveToPList];
}

- (NSArray *)GetConfigurations {
    
    return [_NeedleList allKeys];
}

- (NSArray *)GetTypeFromConfiguration:(NSString *)Configuration {
    
    NSMutableDictionary *NeedleTypes = [_NeedleList objectForKey:Configuration];
    
    return [NeedleTypes allKeys];
}

- (NSArray *)GetSizesFromConfiguration:(NSString *)Configuration andType:(NSString *)Type {
    
    NSMutableDictionary *NeedleTypes = [_NeedleList objectForKey:Configuration];
    
    return [[NeedleTypes objectForKey:Type] copy];
}

- (void)AddNeedleFromConfiguration:(NSString *)Configuration
                            inType:(NSString *)Type
                          withSize:(NSString *)Size {
    
    NSMutableDictionary *NeedleTypes = [_NeedleList objectForKey:Configuration];
    
    if (NeedleTypes == nil) {
        
        NeedleTypes = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *sizes = [[NSMutableArray alloc] init];
        [sizes addObject:Size];
        
        [NeedleTypes setObject:sizes forKey:Type];
        [_NeedleList setObject:NeedleTypes forKey:Configuration];
    }
    else {
        
        if ([NeedleTypes objectForKey:Type] == nil) {
            
            NSMutableArray *sizes = [[NSMutableArray alloc] init];
            [sizes addObject:Size];
            
            [NeedleTypes setObject:sizes forKey:Type];
        }
        else {
            
            NSMutableArray *sizes = [NeedleTypes objectForKey:Type];
            
            NSInteger index = [sizes indexOfObjectIdenticalTo:Size];
            
            if (index == NSNotFound) {
                
                [sizes addObject:Size];
            }
        }
    }
}

- (void)RemoveNeedleFromConfiguration:(NSString *)Configuration
                               inType:(NSString *)Type
                             withSize:(NSString *)Size {
    
    NSMutableArray *sizes = [[_NeedleList objectForKey:Configuration] objectForKey:Type];
    [sizes removeObjectAtIndex:[sizes indexOfObject:Size]];
    
    if ([sizes count] == 0) {
        
        [[_NeedleList objectForKey:Configuration] removeObjectForKey:Type];
        
        if ([[[_NeedleList objectForKey:Configuration] allKeys] count] == 0) {
            
            [_NeedleList removeObjectForKey:Configuration];
        }
    }
}

- (void)RemoveAll {
    
    [_NeedleList removeAllObjects];
}

@end
