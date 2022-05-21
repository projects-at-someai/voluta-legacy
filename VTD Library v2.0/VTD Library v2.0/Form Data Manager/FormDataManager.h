//
//  FormDataManager.h
//  LRF
//
//  Created by Francis Bowen on 6/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFGenerator.h"
#import "VTDCrypto.h"
#import <UIKit/UIKit.h>

@protocol FormDataManagerPDFDelegates <NSObject>
@optional
- (void)PDFGeneratorComplete:(NSString *)PDFFilename;
- (void)PartialPDFComplete:(NSString *)PDFFilename;

- (NSArray *)GetAllergies;
- (NSArray *)GetDiseases;
- (NSArray *)GetHealthConditions;
- (NSDictionary *)HealthAnswers;

- (NSArray *)LegalItems;
- (NSArray *)RulesItems;
@end

@interface FormDataManager : NSObject <
    PDFGeneratorDatasource,
    PDFGeneratorDelegate
>
{
    NSMutableDictionary *_FormData;
    NSMutableDictionary *_FormImages;
    NSMutableArray *_SupportingDocuments;
    NSMutableArray *_SupportingDocumentsImages;
    NSMutableDictionary *_SessionFinancials;
    NSMutableDictionary *_SpecialistData;
    NSMutableDictionary *_ExtraData;
    
    PDFGenerator *_PDFGenerator;
    
    VTDCrypto *_VTDCrypto;
    
    //HealthItemsManager *_HealthItemsManager;
    //LegalClausesManager *_LegalClauseManager;
    
    //bool _IsResubmitting;
}

@property (weak) id <FormDataManagerPDFDelegates> PDFDelegates;

//- (void)InitManagers;

- (NSDictionary *)GetFormData;
- (NSDictionary *)GetFormImages;
- (NSMutableArray *)GetSupportingDocuments;
- (NSMutableDictionary *)GetIndexedSupportingDocumentsImages;
- (NSDictionary *)GetSessionFinancials;
- (NSDictionary *)GetSpecialistData;
- (NSDictionary *)GetExtraData;

- (void)SetFormData:(NSDictionary *)FD;
- (void)SetFormImages:(NSDictionary *)FI;
- (void)SetSupportingDocuments:(NSArray *)SDocs;
- (void)SetSupportingDocumentsImages:(NSArray *)SDocsImages;
- (void)SetSessionFinancials:(NSDictionary *)SF;
- (void)SetSpecialistData:(NSDictionary *)SD;
- (void)SetExtraData:(NSDictionary *)ED;

- (void)SetFormDataValue:(NSString *)Value withKey:(NSString *)Key;
- (NSString *)GetFormDataValue:(NSString *)Key;

- (void)SetFinancialSessionDataValue:(id)Value withKey:(NSString *)Key;
- (id)GetFinancialSessionDataValue:(NSString *)Key;

- (void)SetSpecialistDataValue:(NSString *)Value withKey:(NSString *)Key;
- (NSString *)GetSpecialistDataValue:(NSString *)Key;

- (void)SetSpecialistDataArray:(NSMutableArray *)Values withKey:(NSString *)Key;
- (NSMutableArray *)GetSpecialistDataArray:(NSString *)Key;

- (void)SetSpecialistDataDict:(NSMutableDictionary *)ValDict withKey:(NSString *)Key;
- (NSMutableDictionary *)GetSpecialistDataDict:(NSString *)Key;

- (void)SetFormImagesValue:(UIImage *)Image withKey:(NSString *)Key;
- (UIImage *)GetFormImagesValue:(NSString *)Key;

- (void)AddSupportingDocument:(NSDictionary *)SupportingDocument;
- (void)RemoveSupportingDocument:(NSUInteger)Index;
- (NSMutableDictionary *)GetSupportingDocument:(NSUInteger)Index;
- (NSUInteger)GetNumSupportingDocuments;
- (void)UpdateSupportingDocumentAtIndex:(NSUInteger)index withDoc:(NSDictionary *)sdoc;

- (NSArray *)GetFormDataNames;
- (NSArray *)GetFormImagesNames;

//- (void)SetIsResubmitting:(BOOL)resubmitting;
//- (BOOL)GetIsResubmitting;

//- (void)SetDestViewController:(NSString *)DVC;
//- (NSString *)GetDestViewController;

//Form Utilities
- (void)ClearAll;

- (void)GeneratePDF:(NSString *)Filename atPath:(NSString *)FilePath;

- (void)LoadLocalImages;

/*
//Health and Legal Items Managers
- (void)LoadHealthItems;
- (NSArray *)GetAllergies;
- (NSArray *)GetDiseases;
- (NSArray *)GetHealthConditions;
- (NSMutableDictionary *)GetRequiredHealthItems;
- (void)LoadHealthItemsFromPList;
- (void)SaveRequiredHealthItems;
- (void)ReloadRequiredHealthItems;

- (NSArray *)LegalItems;
*/

@end
