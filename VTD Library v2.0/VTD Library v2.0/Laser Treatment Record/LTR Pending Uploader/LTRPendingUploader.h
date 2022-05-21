//
//  LTRPendingUploader.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 12/23/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "LTRPDFGenerator.h"
#import "LTRCoreDataManager.h"
#import "CloudServiceManager.h"

@protocol PendingTreatmentRecordUploaderDelegate
@optional
- (void)PendingTreatmentRecordUploadComplete:(bool)UploadSuccessful;
- (void)PendingTreatmentRecordUploadProgress:(NSUInteger)NumUploaded withTotal:(NSUInteger)TotalToUpload;

- (LTRCoreDataManager *)GetLTRCoreDataManager;
- (CloudServiceManager *)GetCloudServiceManager;
- (NSString *)GetTempPath;

@end

@interface LTRPendingUploader : NSObject <
    LTRPDFGeneratorDelegate,
    LTRPDFGeneratorDatasource,
    CloudServiceUploadDelegate
>
{
    LTRCoreDataManager *_LTRCoreDataManager;
    LTRPDFGenerator *_LTRPDFGenerator;
    CloudServiceManager *_CloudServiceManager;
    NSMutableArray *_PendingList;
    
    NSUInteger _CurrentFormNum;
    NSUInteger _TotalToUpload;
}

@property (weak) id <PendingTreatmentRecordUploaderDelegate> delegate;

- (void)UploadPendingTreatmentRecords:(NSArray *)PendingTreatmentRecordList;

@end
