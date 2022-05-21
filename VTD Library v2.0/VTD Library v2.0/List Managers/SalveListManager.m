//
//  SalveListManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 3/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "SalveListManager.h"

@implementation SalveListManager

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
    
    if (![self CheckForPList:[NSString stringWithFormat:@"%@.plist",SALVELIST_PLIST]]) {
        
        [self RestoreDefaults];
        
    }
    else {
        
        _SalveList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,SALVELIST_PLIST]];
    }
}

- (void)SaveToPList {
    
    [_SalveList writeToFile:
     [NSString stringWithFormat:@"%@/%@.plist",_DocumentsDir,SALVELIST_PLIST] atomically:NO];
}

- (void)RestoreDefaults {
    
    NSLog(@"Loading default salves list");
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:TRFLISTBUNDLE ofType:@"bundle"];
    
    NSString *DefaultCSVPath = [[NSBundle bundleWithPath:bundlePath]
                                pathForResource:DEFAULTDSALVELIST
                                ofType:@"csv"];
    
    
    _SalveListCSV = [NSArray arrayWithContentsOfCSVFile:DefaultCSVPath options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
    
    if (_SalveList == nil) {
        
        _SalveList = [[NSMutableArray alloc] init];
    }
    
    [_SalveList removeAllObjects];
    
    for (int i = 1; i < [_SalveListCSV count]; i++) {
        
        NSArray *salveArray = [_SalveListCSV objectAtIndex:i];
        
        [self AddSalve:[salveArray objectAtIndex:0]];
        
    }
    
    [self SaveToPList];
}

- (NSArray *)GetSalves {
    
    return [_SalveList copy];
}

- (void)AddSalve:(NSString *)Salve {
    
    NSInteger index = [_SalveList indexOfObjectIdenticalTo:Salve];
    
    if (index == NSNotFound) {
        
        [_SalveList addObject:Salve];
    }
}

- (void)RemoveSalve:(NSString *)Salve {
    
    NSInteger index = [_SalveList indexOfObjectIdenticalTo:Salve];
    
    if (index != NSNotFound) {
        
        [_SalveList removeObjectAtIndex:index];
    }
}

- (void)RemoveAll {
    
    [_SalveList removeAllObjects];
}

@end
