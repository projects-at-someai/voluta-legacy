//
//  AdditionalFormSetupTableCell.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 10/7/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaTRFCell.h"
#import "AdditionalFormSetupViewController.h"

@protocol AdditionalFormSetupTableCellDelegate <NSObject>
@optional
- (void)AdditionalFormSetupComplete:(VolutaTRFCell *)cell;

@required
- (UIDeviceOrientation)getDeviceOrientation;
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation;

- (CloudServiceManager *)GetCloudServiceManager;
- (NSString *)GetAppFolderName;

@end

@interface AdditionalFormSetupTableCell : VolutaTRFCell <AdditionalFormSetupPopupDelegate, PopoverRotationDelegate> {
    
    NSString *cellDisplayValue;
    
}

@property (nonatomic, retain) AdditionalFormSetupViewController *AdditionalFormSetupVC;
@property (weak) id <AdditionalFormSetupTableCellDelegate> delegate;
@property (nonatomic, strong) NSString *cellDisplayValue;

- (void)setInitialValue:(NSString *)initialValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withParentViewController:(UIViewController *)parentViewController;


@end
