//
//  InkThinnerManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "InkThinnerListManager.h"

@implementation InkThinnerListManager

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
    
    if (![self CheckForPList:[NSString stringWithFormat:@"%@.plist",INKTHINNERLIST_PLIST]]) {
        
        [self RestoreDefaults];
        
    }
    else {
        
        _InkThinnerList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,INKTHINNERLIST_PLIST]];
    }
}

- (void)SaveToPList {
    
    [_InkThinnerList writeToFile:
     [NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,INKTHINNERLIST_PLIST] atomically:NO];
}

- (void)RestoreDefaults {
    
    NSLog(@"Loading default ink thinner list");
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:TRFLISTBUNDLE ofType:@"bundle"];
    
    NSString *DefaultCSVPath = [[NSBundle bundleWithPath:bundlePath]
                                pathForResource:DEFAULTINKTHINNERLIST
                                ofType:@"csv"];
    
    
    _InkThinnerListCSV = [NSArray arrayWithContentsOfCSVFile:DefaultCSVPath options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
    
    if (_InkThinnerList == nil) {
        
        _InkThinnerList = [[NSMutableArray alloc] init];
    }
    
    [_InkThinnerList removeAllObjects];
    
    for (int i = 1; i < [_InkThinnerListCSV count]; i++) {
        
        NSArray *thinnerArray = [_InkThinnerListCSV objectAtIndex:i];
        
        [self AddInkThinner:[thinnerArray objectAtIndex:0]];
        
    }
    
    [self SaveToPList];
}

- (NSArray *)GetInkThinners {
    
    return [_InkThinnerList copy];
}

- (void)AddInkThinner:(NSString *)Thinner {
    
    NSInteger index = [_InkThinnerList indexOfObjectIdenticalTo:Thinner];
    
    if (index == NSNotFound) {
        
        [_InkThinnerList addObject:Thinner];
    }
}

- (void)RemoveInkThinner:(NSString *)Thinner {
    
    NSInteger index = [_InkThinnerList indexOfObjectIdenticalTo:Thinner];
    
    if (index != NSNotFound) {
        
        [_InkThinnerList removeObjectAtIndex:index];
    }
}

- (void)RemoveAll {
    
    [_InkThinnerList removeAllObjects];
}

@end
