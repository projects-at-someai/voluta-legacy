//
//  PiercingSelectTableCell.h
//  PRF
//
//  Created by Francis Bowen on 5/16/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaTRFCell.h"
#import "PiercingSelectViewController.h"

@protocol PiercingSelectTableCellDelegate <NSObject>
@optional
- (void)PiercingSelectionComplete:(VolutaTRFCell *)cell didEndEditingWithValue:(NSString *)piercing;

@required
- (UIDeviceOrientation)getDeviceOrientation;
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation;

@end

@interface PiercingSelectTableCell : VolutaTRFCell <UITableViewDelegate, PiercingSelectViewControllerDelegate, PopoverRotationDelegate> {
    
    NSString *cellDisplayValue;
    
}

@property (nonatomic, retain) PiercingSelectViewController *PiercingSelectVC;
@property (weak) id <PiercingSelectTableCellDelegate> piercingSelectDelegate;
@property (nonatomic, strong) NSString *cellDisplayValue;

- (void)setInitialValue:(NSString *)initialValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withParentViewController:(UIViewController *)parentViewController;

@end
