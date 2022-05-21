//
//  BladeListManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "BladeListManager.h"

@implementation BladeListManager

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
    
    if (![self CheckForPList:[NSString stringWithFormat:@"%@.plist",BLADELIST_PLIST]]) {
        
        [self RestoreDefaults];
        
    }
    else {
        
        _BladeList = [NSMutableDictionary dictionaryWithContentsOfFile:
                       [NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,BLADELIST_PLIST]];
    }
}

- (void)SaveToPList {
    
    [_BladeList writeToFile:[NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,BLADELIST_PLIST]
               atomically:NO];
}

- (void)RestoreDefaults {
    
    NSLog(@"Loading default Blade list");
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:CRFLISTBUNDLE ofType:@"bundle"];
    
    NSString *DefaultCSVPath = [[NSBundle bundleWithPath:bundlePath]
                                pathForResource:DEFAULTBLADELIST
                                ofType:@"csv"];
    
    
    _BladeListCSV = [NSArray arrayWithContentsOfCSVFile:DefaultCSVPath options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
    
    if (_BladeList == nil) {
        
        _BladeList = [[NSMutableDictionary alloc] init];
    }
    
    [_BladeList removeAllObjects];
    
    for (int i = 1; i < [_BladeListCSV count]; i++) {
        
        NSArray *entry = [_BladeListCSV objectAtIndex:i];
        
        if ([entry count ] == 3) {
            
            NSString *configuration = [entry objectAtIndex:0];
            NSString *type = [entry objectAtIndex:1];
            NSString *size = [entry objectAtIndex:2];
            
            [self AddBladeFromConfiguration:configuration inType:type withSize:size];
            
        }
        
    }
    
    [self SaveToPList];
}

- (NSArray *)GetConfigurations {
    
    return [_BladeList allKeys];
}

- (NSArray *)GetTypeFromConfiguration:(NSString *)Configuration {
    
    NSMutableDictionary *BladeTypes = [_BladeList objectForKey:Configuration];
    
    return [BladeTypes allKeys];
}

- (NSArray *)GetSizesFromConfiguration:(NSString *)Configuration andType:(NSString *)Type {
    
    NSMutableDictionary *BladeTypes = [_BladeList objectForKey:Configuration];
    
    return [[BladeTypes objectForKey:Type] copy];
}

- (void)AddBladeFromConfiguration:(NSString *)Configuration
                            inType:(NSString *)Type
                          withSize:(NSString *)Size {
    
    NSMutableDictionary *BladeTypes = [_BladeList objectForKey:Configuration];
    
    if (BladeTypes == nil) {
        
        BladeTypes = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *sizes = [[NSMutableArray alloc] init];
        [sizes addObject:Size];
        
        [BladeTypes setObject:sizes forKey:Type];
        [_BladeList setObject:BladeTypes forKey:Configuration];
    }
    else {
        
        if ([BladeTypes objectForKey:Type] == nil) {
            
            NSMutableArray *sizes = [[NSMutableArray alloc] init];
            [sizes addObject:Size];
            
            [BladeTypes setObject:sizes forKey:Type];
        }
        else {
            
            NSMutableArray *sizes = [BladeTypes objectForKey:Type];
            
            NSInteger index = [sizes indexOfObjectIdenticalTo:Size];
            
            if (index == NSNotFound) {
                
                [sizes addObject:Size];
            }
        }
    }
}

- (void)RemoveBladeFromConfiguration:(NSString *)Configuration
                               inType:(NSString *)Type
                             withSize:(NSString *)Size {
    
    NSMutableArray *sizes = [[_BladeList objectForKey:Configuration] objectForKey:Type];
    [sizes removeObjectAtIndex:[sizes indexOfObject:Size]];
    
    if ([sizes count] == 0) {
        
        [[_BladeList objectForKey:Configuration] removeObjectForKey:Type];
        
        if ([[[_BladeList objectForKey:Configuration] allKeys] count] == 0) {
            
            [_BladeList removeObjectForKey:Configuration];
        }
    }
}

- (void)RemoveAll {
    
    [_BladeList removeAllObjects];
}

@end
