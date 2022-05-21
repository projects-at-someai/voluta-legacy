//
//  CompressionUtil.m
//  TRF
//
//  Created by Francis Bowen on 10/5/13.
//  Copyright (c) 2013 Voluta Tattoo Digital. All rights reserved.
//

#import "CompressionUtil.h"

@implementation CompressionUtil

@synthesize compressionDelegate;

- (void)CompressDocumentsFolder:(NSString *)fileName
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    BOOL isDir=NO;
    NSArray *subpaths;
    NSString *exportPath = docDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:exportPath isDirectory:&isDir] && isDir){
        subpaths = [fileManager subpathsAtPath:exportPath];
    }
    
    NSString *archivePath = [docDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    NSMutableArray *filesToZip = [[NSMutableArray alloc] init];
    
    for(NSString *path in subpaths)
    {
        NSString *longPath = [exportPath stringByAppendingPathComponent:path];
        if([fileManager fileExistsAtPath:longPath isDirectory:&isDir] && !isDir)
        {
            [filesToZip addObject:longPath];
        }
    }
    
    [self CompressFilesFromArrayList:archivePath withFileList:filesToZip];
    
    if (compressionDelegate) {
        [compressionDelegate CompressionComplete];
    }
}

- (void)CompressFilesFromArrayList:(NSString *)zipFileName withFileList:(NSMutableArray *)fileList {
    
    NSUInteger fcount = [fileList count];
    NSUInteger counter = 0;
    
    if ([[zipFileName pathExtension] isEqualToString:SETTINGS_EXTENSION]) {
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        for (NSMutableDictionary *filenameAndPath in fileList) {
            
            NSString *filename = [filenameAndPath objectForKey:@"FileName"];
            NSString *path = [filenameAndPath objectForKey:@"Path"];
            
            NSString *longpath = [NSString stringWithFormat:@"%@/%@",path,filename];
            
            if ([fileManager fileExistsAtPath:longpath]){
                
                [files addObject:longpath];
                
                counter++;
                
                if (compressionDelegate) {
                    [compressionDelegate CompressionStatus:((float)counter / (float)fcount)];
                }
            }
            
        }
        
        [SSZipArchive createZipFileAtPath:zipFileName withFilesAtPaths:[files copy]];
        
    }
    else {
        
        [SSZipArchive createZipFileAtPath:zipFileName withFilesAtPaths:[fileList copy]];
    }
    
    
}

- (bool)ExtractFiles:(NSString *)fileName toPath:(NSString *)destPath
{
    
    [SSZipArchive unzipFileAtPath:fileName toDestination:destPath];
    
    return TRUE;

}

- (bool)ExtractFilesLegacyDB:(NSString *)fileName toPath:(NSString *)destPath
{

    NSError *error;
    NSString *FileExtension = [fileName pathExtension];
    
    if ([FileExtension isEqualToString:@"backup"]) {
        
        [SSZipArchive unzipFileAtPath:fileName toDestination:destPath overwrite:YES password:@"r2y12a20l13s" error:&error];
        
        return (error == nil);
    }
    else if ([FileExtension isEqualToString:@"backup_v2"]) {
        
        //Decrypt then unzip
        [SSZipArchive unzipFileAtPath:fileName toDestination:destPath];
        
        return TRUE;
    }
    
    return FALSE;
    
}

@end
