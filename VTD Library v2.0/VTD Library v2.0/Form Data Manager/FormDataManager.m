//
//  FormDataManager.m
//  LRF
//
//  Created by Francis Bowen on 6/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "FormDataManager.h"

@implementation FormDataManager

@synthesize PDFDelegates;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _FormData = [[NSMutableDictionary alloc] init];
        _FormImages = [[NSMutableDictionary alloc] init];
        _SupportingDocuments = [[NSMutableArray alloc] init];
        _SupportingDocumentsImages = [[NSMutableArray alloc] init];
        _SessionFinancials = [[NSMutableDictionary alloc] init];
        _SpecialistData = [[NSMutableDictionary alloc] init];

        //_IsResubmitting = NO;
    }
    
    return self;
}


- (NSDictionary *)GetFormData {
    
    return _FormData;
}

- (void)SetFormData:(NSDictionary *)FD {
    
    _FormData = [[NSMutableDictionary alloc] initWithDictionary:FD copyItems:YES];
}

- (NSDictionary *)GetFormImages {
    
    return _FormImages;
}

- (void)SetFormImages:(NSDictionary *)FI {
    
    _FormImages = [[NSMutableDictionary alloc] initWithDictionary:FI copyItems:YES];
}

- (NSMutableArray *)GetSupportingDocuments {
    
    return _SupportingDocuments;
}

- (NSMutableDictionary *)GetIndexedSupportingDocumentsImages {

    NSMutableDictionary *sdocimages = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [_SupportingDocuments count]; i++) {
        
        if (i < [_SupportingDocumentsImages count]) {
            
            NSMutableDictionary *sdoc = [_SupportingDocuments objectAtIndex:i];
            
            NSString *doctype = [sdoc objectForKey:@"DocumentName"];
            
            if (doctype != nil) {
                
                [sdocimages setObject:[_SupportingDocumentsImages objectAtIndex:i] forKey:doctype];
            }
            
        }
    }
    
    return sdocimages;
}

- (void)SetSupportingDocuments:(NSArray *)SDocs {
    
    _SupportingDocuments = [[NSMutableArray alloc] initWithArray:SDocs copyItems:YES];
}

- (void)SetSupportingDocumentsImages:(NSArray *)SDocsImages {
    
    _SupportingDocumentsImages = [[NSMutableArray alloc] initWithArray:SDocsImages copyItems:YES];
}

- (NSDictionary *)GetSessionFinancials {
    
    return _SessionFinancials;
}

- (void)SetSessionFinancials:(NSDictionary *)SF {
    
    _SessionFinancials = [[NSMutableDictionary alloc] initWithDictionary:SF copyItems:YES];
}

- (NSDictionary *)GetSpecialistData {
    
    return _SpecialistData;
}

- (void)SetSpecialistData:(NSDictionary *)SD {
    
    _SpecialistData = [[NSMutableDictionary alloc] initWithDictionary:SD copyItems:YES];
}

- (NSDictionary *)GetExtraData {
    
    return _ExtraData;
}

- (void)SetExtraData:(NSDictionary *)ED {
    
    _ExtraData = [[NSMutableDictionary alloc] initWithDictionary:ED copyItems:YES];
}

- (void)SetFormDataValue:(NSString *)Value withKey:(NSString *)Key {

    [_FormData setObject:Value forKey:Key];
}

- (NSString *)GetFormDataValue:(NSString *)Key {
    
    return [_FormData objectForKey:Key];
}

- (void)SetFinancialSessionDataValue:(id)Value withKey:(NSString *)Key {
    
    [_SessionFinancials setObject:Value forKey:Key];
}

- (id)GetFinancialSessionDataValue:(NSString *)Key {
    
    return [_SessionFinancials objectForKey:Key];
}

- (void)SetSpecialistDataValue:(NSString *)Value withKey:(NSString *)Key {
    
    [_SpecialistData setObject:Value forKey:Key];
}

- (NSString *)GetSpecialistDataValue:(NSString *)Key {
    
    return [_SpecialistData objectForKey:Key];
}

- (void)SetSpecialistDataArray:(NSMutableArray *)Values withKey:(NSString *)Key {
    
    [_SpecialistData setObject:Values forKey:Key];
}

- (NSMutableArray *)GetSpecialistDataArray:(NSString *)Key {
    
    return [_SpecialistData objectForKey:Key];
}

- (void)SetSpecialistDataDict:(NSMutableDictionary *)ValDict withKey:(NSString *)Key {
    
    [_SpecialistData setObject:ValDict forKey:Key];
}
- (NSMutableDictionary *)GetSpecialistDataDict:(NSString *)Key {
    
    return [_SpecialistData objectForKey:Key];
}

- (void)SetFormImagesValue:(UIImage *)Image withKey:(NSString *)Key {
    
    if (!Image) {
        NSLog(@"Trying to store nil image in FormDataManager for %@. Creating dummy white image to store in its place", Key);
        
        //create dummy white image
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(10, 10), YES, 0.0);
        
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, 10, 10));
        Image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    [_FormImages setObject:UIImagePNGRepresentation(Image) forKey:Key];
}

- (UIImage *)GetFormImagesValue:(NSString *)Key {
    
    return [UIImage imageWithData:[_FormImages objectForKey:Key]];
}

- (void)SetSupportingDocumentsImagesValue:(UIImage *)Image withIndex:(NSUInteger)Index {
    
    if (!Image) {
        NSLog(@"Trying to store nil supporting document image in FormDataManager. Creating dummy white image to store in its place");
        
        //create dummy white image
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(10, 10), YES, 0.0);
        
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, 10, 10));
        Image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    [_SupportingDocumentsImages setObject:UIImagePNGRepresentation(Image) atIndexedSubscript:Index];
}

- (UIImage *)GetSupportingDocumentsImageFromIndex:(NSUInteger)Index {
    
    if (Index >= 0 && Index < [_SupportingDocumentsImages count]) {
        
        return [_SupportingDocumentsImages objectAtIndex:Index];
    }
    
    NSLog(@"Supporting document image not found");
    
    return nil;
}

- (void)LoadLocalImages {
    
    if (!_VTDCrypto) {
        _VTDCrypto = [[VTDCrypto alloc] init];
    }
    
    @autoreleasepool {
        
        NSString *datakey = [Utilities CreateClientKey:_FormData];
        
        NSString *datakeyhex = [Utilities StringToHex:datakey];
        
        NSString *ImgsPath = [Utilities GetImagesPath];
        
        //client ID
        NSString *fn = [NSString stringWithFormat:@"%@/%@-CID",ImgsPath,datakeyhex];
        NSData *dataenc = [NSData dataWithContentsOfFile:fn];
        NSData *datadec = [_VTDCrypto Decrypt:dataenc withPassword:datakey];
        [self SetFormImagesValue:[UIImage imageWithData:datadec] withKey:CLIENT_ID_IMAGE];
        
        //client signature
        fn = [NSString stringWithFormat:@"%@/%@-CSIG",ImgsPath,datakeyhex];
        dataenc = [NSData dataWithContentsOfFile:fn];
        datadec = [_VTDCrypto Decrypt:dataenc withPassword:datakey];
        [self SetFormImagesValue:[UIImage imageWithData:datadec] withKey:CLIENT_SIGNATURE_IMAGE];
        
        //employee signature
        fn = [NSString stringWithFormat:@"%@/%@-ESIG",ImgsPath,datakeyhex];
        dataenc = [NSData dataWithContentsOfFile:fn];
        datadec = [_VTDCrypto Decrypt:dataenc withPassword:datakey];
        [self SetFormImagesValue:[UIImage imageWithData:datadec] withKey:EMPLOYEE_SIGNATURE_IMAGE];
        
        //check for supporting documents
        NSFileManager *fm = [[NSFileManager alloc] init];
        
        //Remove .backup_v2 files from documents directory
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:ImgsPath error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@ && CONTAINS '-SDOC'", datakeyhex];
        
        NSArray *sdocs = [dirContents filteredArrayUsingPredicate:fltr];
        for (NSString *file in sdocs) {
            
            NSLog(@"adding sdoc: %@", file);
            
            fn = [ImgsPath stringByAppendingPathComponent:file];
            dataenc = [NSData dataWithContentsOfFile:fn];
            datadec = [_VTDCrypto Decrypt:dataenc withPassword:datakey];
            
            //Get sdoc index
            NSRange indexloc = [file rangeOfString:@"-SDOC"];
            
            if (indexloc.location != NSNotFound) {
                
                NSString *index = [file substringFromIndex:(indexloc.location + 5)];
                
                int indexint = [index intValue];
                
                if (indexint >= 0 && indexint < [_SupportingDocuments count]) {
                    
                    [self SetSupportingDocumentsImagesValue:[UIImage imageWithData:datadec] withIndex:indexint];

                }
                else {
                    
                    NSLog(@"Invalid sdoc index: %d", indexint);
                }
                
            }

        }
        
    }
    

}

- (void)AddSupportingDocument:(NSDictionary *)SupportingDocument {
    
    NSMutableDictionary *sdoc = [SupportingDocument mutableCopy];
    
    UIImage *sdocimg = [sdoc objectForKey:@"DocumentImage"];
    
    if (sdocimg) {

        [_SupportingDocumentsImages addObject:sdocimg];
        [sdoc removeObjectForKey:@"DocumentImage"];
        
        [_SupportingDocuments addObject:[sdoc copy]];
        
    }
    else {
        
        NSLog(@"Supporting document image nil, sdoc not added");
    }
    
    sdoc = nil;
    sdocimg = nil;

}

- (void)RemoveSupportingDocument:(NSUInteger)Index {
    
    [_SupportingDocuments removeObjectAtIndex:Index];
    [_SupportingDocumentsImages removeObjectAtIndex:Index];
}

- (NSDictionary *)GetSupportingDocument:(NSUInteger)Index {
    
    NSMutableDictionary *sdoc = [_SupportingDocuments objectAtIndex:Index];
    [sdoc setObject:[_SupportingDocumentsImages objectAtIndex:Index] forKey:@"DocumentImage"];
    
    return [sdoc copy];
}

- (NSUInteger)GetNumSupportingDocuments {
    
    return [_SupportingDocuments count];
}

- (void)UpdateSupportingDocumentAtIndex:(NSUInteger)index withDoc:(NSDictionary *)sdoc {
    
    //[_SupportingDocuments setObject:sdoc atIndexedSubscript:index];
    
    NSMutableDictionary *sdocmut = [sdoc mutableCopy];
    
    UIImage *sdocimg = [sdocmut objectForKey:@"DocumentImage"];
    
    if (sdocimg) {
        
        [_SupportingDocumentsImages setObject:sdocimg atIndexedSubscript:index];
        [sdocmut removeObjectForKey:@"DocumentImage"];
        
        [_SupportingDocuments setObject:[sdocmut copy] atIndexedSubscript:index];
        
    }
    else {
        
        NSLog(@"Supporting document image nil, sdoc not added");
    }
    
    sdocmut = nil;
    sdocimg = nil;
}

- (NSArray *)GetFormDataNames {

    return [_FormData allKeys];
}

- (NSArray *)GetFormImagesNames {
    
    return [_FormImages allKeys];
}

/*
- (void)SetIsResubmitting:(BOOL)resubmitting {
    
    _IsResubmitting = resubmitting;
}

- (BOOL)GetIsResubmitting {
    
    return _IsResubmitting;
}
*/


#pragma mark - Form Utilities

- (void)ClearAll {
    
    if (_FormData != nil) {
        
        [_FormData removeAllObjects];
    }
    
    if (_FormImages != nil) {
        
        [_FormImages removeAllObjects];
    }
    
    if (_SupportingDocuments != nil) {
        
        [_SupportingDocuments removeAllObjects];
    }
    
    if (_SupportingDocumentsImages != nil) {
        
        [_SupportingDocumentsImages removeAllObjects];
    }
    
    if (_SessionFinancials != nil) {
        
        [_SessionFinancials removeAllObjects];
    }
    
    if (_SpecialistData != nil) {
        
        [_SpecialistData removeAllObjects];
    }
}


- (void)GeneratePDF:(NSString *)Filename atPath:(NSString *)FilePath {
    
    //create pdf
    if (_PDFGenerator == nil) {
        
        _PDFGenerator = [[PDFGenerator alloc] init];
    }
    
    _PDFGenerator.delegate = self;
    _PDFGenerator.datasource = self;
    
    NSString *Name = [NSString stringWithFormat:@"%@ %@",
                      [_FormData objectForKey:@"First Name"],
                      [_FormData objectForKey:@"Last Name"]];
    
    [_FormData setObject:Name forKey:@"Name"];
    
    
    [_PDFGenerator GeneratePDF:Filename
                      withPath:FilePath];
}

#pragma mark - PDFGeneratorDelegate
- (void)PDFGeneratorComplete:(NSString *)PDFFilename {
    
    if (PDFDelegates && [PDFDelegates respondsToSelector:@selector(PDFGeneratorComplete:)]) {
        [PDFDelegates PDFGeneratorComplete:PDFFilename];
    }
 
}

- (void)PartialPDFComplete:(NSString *)PDFFilename {
    
    if (PDFDelegates && [PDFDelegates respondsToSelector:@selector(PartialPDFComplete:)]) {
        [PDFDelegates PartialPDFComplete:PDFFilename];
    }
}

#pragma mark - PDFGeneratorDatasource
- (NSMutableArray *)SupportingDocuments {
    
    return _SupportingDocuments;
}

- (NSMutableArray *)SupportingDocumentsImages {
    
    return _SupportingDocumentsImages;
}

- (NSDictionary *)ClientInfo {
    
    return _FormData;
}

- (NSDictionary *)ClientImages {
    
    return _FormImages;
}

- (NSDictionary *)SpecialistInfo {
    
    return _SpecialistData;
}

- (NSDictionary *)SessionFinancials {
    
    return _SessionFinancials;
}

- (NSDictionary *)HealthAnswers {
    
    return _FormData;
}

- (NSArray *)GetAllergies {
    
    return [PDFDelegates GetAllergies];
}

- (NSArray *)GetDiseases {
    
    return [PDFDelegates GetDiseases];
}

- (NSArray *)GetHealthConditions {

    return [PDFDelegates GetHealthConditions];
}

- (NSArray *)LegalItems {
    
    return [PDFDelegates LegalItems];
}

- (NSArray *)RulesItems {

    return [PDFDelegates RulesItems];
}

@end
