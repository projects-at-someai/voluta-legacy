//
//  TableCellManager.h
//  LRF
//
//  Created by Francis Bowen on 5/28/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VolutaTRFCell.h"
#import "Utilities.h"

#import "TextInputTableCell.h"

#import "AlbumPickerTableCell.h"
#import "ArtistPickerTableCell.h"
#import "AustralianStatePickerTableCell.h"
#import "BodyPlacementTableCell.h"
#import "CanadianProvincePickerTableCell.h"
#import "HourTableCell.h"
#import "OrientationPickerTableCell.h"
#import "PiercerPickerTableCell.h"
#import "SlideshowDelayPickerTableCell.h"
#import "StatePickerTableCell.h"
#import "TimeoutPickerTableCell.h"
#import "EmployeePickerTableCell.h"

#import "PhoneNumberTableCell.h"
#import "SetPasswordTableCell.h"
#import "ZipCodeTableCell.h"

#import "GenderSegmentedTableCell.h"
#import "GeneralSegmentedTableCell.h"
#import "IDSegmentedTableCell.h"
#import "MedicationsSegmentedTableCell.h"
#import "PromotionsSegmentedTableCell.h"
#import "YesNoSegmentedTableCell.h"

#import "TextfieldPopupTableCell.h"

#import "SignaturePopupTableCell.h"

#import "LegalPopupTableCell.h"

#import "DatePickerPopupTableCell.h"

#import "GeneralCell.h"

#import "SwitchTableCell.h"

#import "SupportingDocumentsListTableCell.h"

#import "SessionFinancialsTableCell.h"

#import "EditTreatmentRecordsTableCell.h"

#import "DatabaseViewerTableCell.h"

#import "EmailCredentialsTableCell.h"

#import "HealthListEditorTableCell.h"
#import "LegalListEditorTableCell.h"

#import "ReferralPickerTableCell.h"

#import "FinancialsReportGeneratorTableCell.h"

#import "DatabaseExporterTableCell.h"

#import "EmployeeListPopupTableCell.h"

#import "ImageSelectorTableCell.h"

#import "SlideshowSetupTableCell.h"

#import "OrientationPickerTableCell.h"

#import "AdditionalFormSetupTableCell.h"

#import "DatabaseBackupTableCell.h"
#import "DatabaseRestoreTableCell.h"

#import "DatabaseSyncOptionsTableCell.h"

#import "SettingsBackupTableCell.h"
#import "SettingsRestoreTableCell.h"

#import "PrivacyViewerTableCell.h"

#import "LaserTreatmentRecordEditorTableCell.h"

#import "SubscriptionRestoreTableCell.h"

#import "InkListTableCell.h"
#import "NeedleListTableCell.h"
#import "InkThinnersListTableCell.h"
#import "DisposableTubesListTableCell.h"
#import "DisposableGripsListTableCell.h"
#import "SalvesListTableCell.h"
#import "BladeListTableCell.h"

#import "InkListEditorTableCell.h"
#import "InkThinnerListEditorTableCell.h"
#import "NeedleListEditorTableCell.h"
#import "DisposableTubesListEditorTableCell.h"
#import "DisposableGripsListEditorTableCell.h"
#import "SalvesListEditorTableCell.h"
#import "BladeListEditorTableCell.h"

//#import "DBTransferManagerCell.h"

#import "PiercingSelectTableCell.h"
#import "ClientPiercingPickerTableCell.h"
#import "PiercingJewelryListTableCell.h"
#import "JewelryListEditorTableCell.h"

#import "DataLogOptionsTableCell.h"

#import "VIPLoginTableCell.h"

#import "LogoSelectorTableCell.h"

#import "CosmeticLocationTableCell.h"
#import "ServiceSelectTableCell.h"

#import "RulesPopupTableCell.h"
#import "RulesListEditorTableCell.h"

#import "GeneralCSVPickerTableCell.h"
#import "GeneralCSVListEditorTableCell.h"

#import "ORFDestinationPickerTableCell.h"

@protocol TableCellManagerDatasource <NSObject>

@optional
- (NSArray *)GetAllergies;
- (NSArray *)GetDiseases;
- (NSArray *)GetHealthConditions;
- (NSMutableDictionary *)RequiredHealthItems;
- (BOOL)IsResubmitting;

@end

@interface TableCellManager : NSObject
{
    NSMutableArray *_HealthItemTypes;
    NSMutableArray *_HealthItemNames;
}

@property (assign) id<TableCellManagerDatasource> Datasource;

- (VolutaTRFCell *)CreateCell:(UIViewController *)ParentViewController
                 withCellType:(NSString *)CellType
          withCellDescription:(NSString *)CellDescription
                withCellTitle:(NSString *)TitleText
               withDetailText:(NSString *)DetailText
           withIsResubmitting:(bool)IsResubmitting
            withResubmitValue:(NSString *)ResubmitValue
                  withDataKey:(NSString *)DataKey;

- (NSMutableArray *)CreateHealthItemsCells:(UIViewController *)ParentViewController;

@end
