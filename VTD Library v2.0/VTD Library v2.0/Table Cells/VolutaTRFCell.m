//
//  VolutaTRFCell.m
//  TRF
//
//  Created by Francis Bowen on 7/27/13.
//  Copyright (c) 2013 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaTRFCell.h"

@implementation VolutaTRFCell

@synthesize parentVC;
@synthesize childVC;
@synthesize TableCellValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        currentVCOrientation = UIDeviceOrientationFaceDown;
        
        self.textLabel.font = [UIFont fontWithName:VTD_FONT size:24.0f];
        self.detailTextLabel.font = [UIFont fontWithName:VTD_FONT size:22.0f];
        self.detailTextLabel.textColor = [UIColor blueColor];
        
        _CellHeight = 56.0f;
        
        TableCellValue = @"";
        _DataKey = @"";
        _CellType = @"";
        _CellDescription = @"";
        _isShowingVC = NO;
        _isRequired = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)ShowViewController:(UIDeviceOrientation)orientation {
    
    if (_isShowingVC) {
        return;
    }
    
    [self DisableParentTableView];
    
    [parentVC addChildViewController:childVC];
    [parentVC.view addSubview:childVC.view];
    
    childVC.view.alpha = 0;
    [childVC didMoveToParentViewController:parentVC];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        childVC.view.alpha = 1; }
                     completion:nil];
    
    [parentVC.view bringSubviewToFront:childVC.view];
    
    _isShowingVC = YES;
    
}

- (void)DismissViewController {
    
    [self EnableParentTableView];
    
    [childVC didMoveToParentViewController:nil];
    [childVC removeFromParentViewController];
    [childVC.view removeFromSuperview];
    
    _isShowingVC = NO;
}

- (void)EnableParentTableView {
    
    UIView *tview = self.superview;
    while (![tview isKindOfClass:[UITableView class]]) {
        tview = [tview superview];
    }
    
    [tview setUserInteractionEnabled:YES];
}

- (void)DisableParentTableView {
    
    UIView *tview = self.superview;
    while (![tview isKindOfClass:[UITableView class]]) {
        tview = [tview superview];
    }
    
    [tview setUserInteractionEnabled:NO];
}

- (NSString *)GetTableCellValue {
    
    return TableCellValue;
}

- (void)SetDataKey:(NSString *)Key {
    
    _DataKey = Key;
}

- (NSString *)GetDataKey {
    
    return _DataKey;
}

- (void)SetCellHeight:(CGFloat)Height {
    
    _CellHeight = Height;
}

- (CGFloat)GetCellHeight {
    
    return _CellHeight;
}

- (void)SetType:(NSString *)Type {
    
    _CellType = Type;
    
}

- (NSString *)GetType {
    
    return _CellType;
}

- (void)SetDescription:(NSString *)Description {
    
    _CellDescription = Description;
}

- (NSString *)GetDescription {
    
    return _CellDescription;
}

- (void)SetRequired:(bool)required {

    _isRequired = required;
}

- (bool)GetRequired {
    
    return _isRequired;
}

@end
