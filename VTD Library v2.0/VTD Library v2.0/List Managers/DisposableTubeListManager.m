//
//  DisposableTubeListManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "DisposableTubeListManager.h"

@implementation DisposableTubeListManager

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
    
    if (![self CheckForPList:[NSString stringWithFormat:@"%@.plist",DTUBELIST_PLIST]]) {
        
        [self RestoreDefaults];
        
    }
    else {
        
        _DisposableTubeList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,DTUBELIST_PLIST]];
    }
}

- (void)SaveToPList {
    
    [_DisposableTubeList writeToFile:
     [NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,DTUBELIST_PLIST] atomically:NO];
}

- (void)RestoreDefaults {
    
    NSLog(@"Loading default disposable tube list");
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:TRFLISTBUNDLE ofType:@"bundle"];
    
    NSString *DefaultCSVPath = [[NSBundle bundleWithPath:bundlePath]
                                pathForResource:DEFAULTDTUBELIST
                                ofType:@"csv"];
    
    
    _DisposableTubeListCSV = [NSArray arrayWithContentsOfCSVFile:DefaultCSVPath options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
    
    if (_DisposableTubeList == nil) {
        
        _DisposableTubeList = [[NSMutableArray alloc] init];
    }
    
    [_DisposableTubeList removeAllObjects];
    
    for (int i = 1; i < [_DisposableTubeListCSV count]; i++) {
        
        NSArray *tubeArray = [_DisposableTubeListCSV objectAtIndex:i];
        
        [self AddDisposableTube:[tubeArray objectAtIndex:0]];
        
    }
    
    [self SaveToPList];
}

- (NSArray *)GetDisposableTubes {
    
    return [_DisposableTubeList copy];
}

- (void)AddDisposableTube:(NSString *)Tube {
    
    NSInteger index = [_DisposableTubeList indexOfObjectIdenticalTo:Tube];
    
    if (index == NSNotFound) {
        
        [_DisposableTubeList addObject:Tube];
    }
}

- (void)RemoveDisposableTube:(NSString *)Tube {
    
    NSInteger index = [_DisposableTubeList indexOfObjectIdenticalTo:Tube];
    
    if (index != NSNotFound) {
        
        [_DisposableTubeList removeObjectAtIndex:index];
    }
}

- (void)RemoveAll {
    
    [_DisposableTubeList removeAllObjects];
}

@end
