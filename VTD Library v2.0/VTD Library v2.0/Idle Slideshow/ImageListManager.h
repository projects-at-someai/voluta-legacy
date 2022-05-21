//
//  ImageListManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 10/2/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageListManager : NSObject
{
    
}

@property (retain) NSMutableArray *ImageList;
@property (retain) NSMutableArray *AlbumList;

- (NSMutableArray *)getImageList;

@end
