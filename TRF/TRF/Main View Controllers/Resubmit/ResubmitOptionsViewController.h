//
//  ResubmitOptionsViewController.h
//  TRF
//
//  Created by Francis Bowen on 6/27/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaPopoverViewController.h"
#import "BodyPlacementTableCell.h"
#import "SessionFinancialsTableCell.h"
#import "EditTreatmentRecordsTableCell.h"
#import "FormDataManager.h"

#define RESUMBITOPTIONS_WIDTH  400.0f
#define RESUMBITOPTIONS_HEIGHT 385.0f

#define RESUMBITOPTIONS_PORTRAIT      CGRectMake(184.0f, 387.0f, RESUMBITOPTIONS_WIDTH, RESUMBITOPTIONS_HEIGHT)
#define RESUMBITOPTIONS_LANDSCAPE     CGRectMake(312.0f, 259.0f, RESUMBITOPTIONS_WIDTH, RESUMBITOPTIONS_HEIGHT)

@protocol ResubmitOptionsPopupDelegate
@required
- (void)ResubmitOptionsComplete:(NSString *)txt withIndex:(NSUInteger)index;
- (void)ResubmitOptionsCanceled;

- (void)SessionsFinancialsComplete:(SessionFinancialsTableCell *)cell withFinancialsData:(NSDictionary *)financials;

- (NSDictionary *)GetInitialData;

- (FormDataManager *)GetFormDataManager;

@end

@interface ResubmitOptionsViewController : VolutaPopoverViewController <
    UITableViewDataSource,
    UITableViewDelegate,
    PickerPopupTableCellDelegate,
    SessionFinancialsTableCellDelegate,
    EditTreatmentRecordsTableCellDelegate
>
{
    BodyPlacementPickerTableCell *_BodyPlacementCell;
    SessionFinancialsTableCell *_SessionsFinancialsCell;
    FormDataManager *_FormDataManager;
}

@property (nonatomic, weak) id<ResubmitOptionsPopupDelegate> delegate;
@property (retain) UIButton *CancelButton;
@property (retain) UITableView *OptionsTable;

@end
