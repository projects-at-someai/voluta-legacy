//
//  LTRPendingUploader.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 12/23/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "LTRPendingUploader.h"

@implementation LTRPendingUploader

@synthesize delegate;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)UploadPendingTreatmentRecords:(NSArray *)PendingTreatmentRecordList {
    
    _LTRCoreDataManager = [delegate GetLTRCoreDataManager];
    
    _LTRPDFGenerator = [[LTRPDFGenerator alloc] initWithDelegate:self withDatasource:self];
    
    _CloudServiceManager = [delegate GetCloudServiceManager];
    _CloudServiceManager.uploadDelegate = self;
    
    _PendingList = [[NSMutableArray alloc] initWithArray:PendingTreatmentRecordList];
    
    _CurrentFormNum = 0;
    _TotalToUpload = [_PendingList count];
    
    [self ProcessNextPendingForm];
    
}

- (void)ProcessNextPendingForm {
    
    _CurrentFormNum++;
    
    if ([_PendingList count] > 0) {
        
        NSDictionary *pendingtr = [_PendingList objectAtIndex:0];
        
        NSString *FirstName = [pendingtr objectForKey:@"First Name"];
        NSString *LastName = [pendingtr objectForKey:@"Last Name"];
        NSString *DateOfBirth = [pendingtr objectForKey:@"Date of Birth"];
        
        if (FirstName == nil || LastName == nil || DateOfBirth == nil) {
            
            //Record not found - unknown error, just remove from pending queue
            [self FileUploadComplete:YES];
        }
        else {
            
            [_LTRCoreDataManager LoadTreatmentRecord:FirstName
                                        withLastName:LastName
                                        withDoB:DateOfBirth];
            
            NSString *TempPath = [delegate GetTempPath];
            
            NSString *TRPDFName = [NSString stringWithFormat:@"Treatment Record - %@,%@ %@.pdf",
                                   LastName,
                                   FirstName,
                                   DateOfBirth];
            
            [_LTRPDFGenerator GeneratePDF:TRPDFName
                                 withPath:TempPath
                            withFirstName:FirstName
                             withLastName:LastName
                             withDoB:DateOfBirth];
        }
        
    }
    else {
        
        if (delegate) {
            [delegate PendingTreatmentRecordUploadComplete:YES];
        }
    }
}

#pragma mark - LTRPDFGeneratorDelegate
- (void)LTRPDFGeneratorComplete:(NSString *)PDFFilename {
    
    [_CloudServiceManager UploadFileAndReplace:PDFFilename withFilepath:[delegate GetTempPath]];
}

#pragma mark - LTRPDFGeneratorDatasource
- (NSArray *)TreatmentRecordItems {
    
    return [[_LTRCoreDataManager GetTreatmentRecord] copy];
}

#pragma mark - CloudServiceUploadDelegate
- (void)FileUploadComplete:(bool)UploadSuccessful {
    
    [_PendingList removeObjectAtIndex:0];

    if (delegate) {
        [delegate PendingTreatmentRecordUploadProgress:_CurrentFormNum withTotal:_TotalToUpload];
    }
    
    [self ProcessNextPendingForm];
    
}

@end
