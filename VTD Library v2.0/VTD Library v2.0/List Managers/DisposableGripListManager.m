//
//  DisposableGripListManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "DisposableGripListManager.h"

@implementation DisposableGripListManager

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
    
    if (![self CheckForPList:[NSString stringWithFormat:@"%@.plist",DGRIPLIST_PLIST]]) {
        
        [self RestoreDefaults];
        
    }
    else {
        
        _DisposableGripList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,DGRIPLIST_PLIST]];
    }
}

- (void)SaveToPList {
    
    [_DisposableGripList writeToFile:
     [NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,DGRIPLIST_PLIST] atomically:NO];
}

- (void)RestoreDefaults {
    
    NSLog(@"Loading default disposable grips list");
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:TRFLISTBUNDLE ofType:@"bundle"];
    
    NSString *DefaultCSVPath = [[NSBundle bundleWithPath:bundlePath]
                                pathForResource:DEFAULTDGRIPLIST
                                ofType:@"csv"];
    
    
    _DisposableGripListCSV = [NSArray arrayWithContentsOfCSVFile:DefaultCSVPath options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
    
    if (_DisposableGripList == nil) {
        
        _DisposableGripList = [[NSMutableArray alloc] init];
    }
    
    [_DisposableGripList removeAllObjects];
    
    for (int i = 1; i < [_DisposableGripListCSV count]; i++) {
        
        NSArray *gripArray = [_DisposableGripListCSV objectAtIndex:i];
        
        [self AddDisposableGrip:[gripArray objectAtIndex:0]];
        
    }
    
    [self SaveToPList];
}

- (NSArray *)GetDisposableGrips {
    
    return [_DisposableGripList copy];
}

- (void)AddDisposableGrip:(NSString *)Grip {
    
    NSInteger index = [_DisposableGripList indexOfObjectIdenticalTo:Grip];
    
    if (index == NSNotFound) {
        
        [_DisposableGripList addObject:Grip];
    }
}

- (void)RemoveDisposableGrip:(NSString *)Grip {
    
    NSInteger index = [_DisposableGripList indexOfObjectIdenticalTo:Grip];
    
    if (index != NSNotFound) {
        
        [_DisposableGripList removeObjectAtIndex:index];
    }
}

- (void)RemoveAll {
    
    [_DisposableGripList removeAllObjects];
}

@end
