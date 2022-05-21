//
//  ImageListManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 10/2/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "ImageListManager.h"

@implementation ImageListManager

@synthesize ImageList;
@synthesize AlbumList;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        ImageList = [[NSMutableArray alloc] init];
        [self acquireImageList];
        
    }
    
    return self;
}

- (void)acquireImageList
{
    [ImageList removeAllObjects];
    
    [self fetchAssetsLibraryPhotosURLWithCompletionBlock:^{
        
        NSLog(@"Image list acquired");
        
    }];
}

- (NSMutableArray *)getImageList
{
    return ImageList;
}

- (void)fetchAssetsLibraryPhotosURLWithCompletionBlock:(void(^)())completionBlock {
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryGroupsEnumerationResultsBlock libGroupEnumerationResult;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *album = [defaults objectForKey:SLIDESHOW_ALBUM_KEY];
    
    if (![album isEqualToString:@"Camera Roll"]) {
        
        libGroupEnumerationResult = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                NSUInteger numAssets = group.numberOfAssets;
                NSString *AlbumName = [group valueForProperty:ALAssetsGroupPropertyName];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *SelectedAlbum = [defaults objectForKey:SLIDESHOW_ALBUM_KEY];
                
                if (SelectedAlbum == nil || ([AlbumName isEqualToString:SelectedAlbum])) {
                    
                    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *innerstop) {
                        if (asset) {
                            ALAssetRepresentation *rep = [asset defaultRepresentation];
                            NSURL *imageURL = [rep url];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [ImageList addObject:imageURL];
                                
                                if (index + 1 == numAssets) {
                                    completionBlock();
                                }
                            });
                        }
                    }];
                }
                
            }
        };
        
        [assetLibrary enumerateGroupsWithTypes:(ALAssetsGroupAlbum)
                                    usingBlock:libGroupEnumerationResult
                                  failureBlock:^(NSError *error) {
                                      NSLog(@"failure: %@", [error localizedDescription]);
                                  }];
    }
    else
    {
        libGroupEnumerationResult = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                NSUInteger numAssets = group.numberOfAssets;
                
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *innerstop) {
                    if (asset) {
                        ALAssetRepresentation *rep = [asset defaultRepresentation];
                        NSURL *imageURL = [rep url];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ImageList addObject:imageURL];
                            
                            if (index + 1 == numAssets) {
                                completionBlock();
                            }
                        });
                    }
                }];
                
            }
        };
        
        [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                    usingBlock:libGroupEnumerationResult
                                  failureBlock:^(NSError *error) {
                                      NSLog(@"failure: %@", [error localizedDescription]);
                                  }];
    }
    
    
}

@end
