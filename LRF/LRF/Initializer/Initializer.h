//
//  Initializer.h
//  LRF
//
//  Created by Francis Bowen on 11/13/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "KeychainWrapper.h"

@interface Initializer : NSObject
{
    BOOL _VersionHasChanged;
    BOOL _RegionHasChanged;
    NSString *_DocumentsDir;
}

- (void)InitializeDefaults;

@end
