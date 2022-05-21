//
//  VolutaTRFCell.h
//  TRF
//
//  Created by Francis Bowen on 7/27/13.
//  Copyright (c) 2013 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VolutaTRFCell : UITableViewCell
{
    UIDeviceOrientation currentVCOrientation;
    
    NSString *_DataKey;
    NSString *_CellType;
    CGFloat _CellHeight;
    NSString *_CellDescription;
    bool _isShowingVC;
    bool _isRequired;
}

@property (retain) UIViewController *parentVC;
@property (retain) UIViewController *childVC;
@property (retain) NSString *TableCellValue;

- (void)ShowViewController:(UIDeviceOrientation)orientation;
- (void)DismissViewController;
- (void)EnableParentTableView;
- (void)DisableParentTableView;

- (NSString *)GetTableCellValue;

- (void)SetDataKey:(NSString *)Key;
- (NSString *)GetDataKey;

- (void)SetType:(NSString *)Type;
- (NSString *)GetType;

- (void)SetDescription:(NSString *)Description;
- (NSString *)GetDescription;

- (void)SetCellHeight:(CGFloat)Height;
- (CGFloat)GetCellHeight;

- (void)SetRequired:(bool)required;
- (bool)GetRequired;

@end
