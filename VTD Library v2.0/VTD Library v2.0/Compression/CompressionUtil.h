//
//  CompressionUtil.h
//  TRF
//
//  Created by Francis Bowen on 10/5/13.
//  Copyright (c) 2013 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"

@protocol CompressionDelegate <NSObject>
@optional
- (void)CompressionStatus:(float)status;

- (void)CompressionComplete;

@end

@interface CompressionUtil : NSObject
{

}

@property (weak) id <CompressionDelegate> compressionDelegate;

- (void)CompressDocumentsFolder:(NSString *)fileName;
- (bool)ExtractFiles:(NSString *)fileName toPath:(NSString *)destPath;
- (bool)ExtractFilesLegacyDB:(NSString *)fileName toPath:(NSString *)destPath;
- (void)CompressFilesFromArrayList:(NSString *)zipFileName withFileList:(NSMutableArray *)fileList;

@end
