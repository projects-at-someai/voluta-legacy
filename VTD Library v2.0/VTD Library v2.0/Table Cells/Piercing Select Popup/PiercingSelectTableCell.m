//
//  PiercingSelectTableCell.m
//  PRF
//
//  Created by Francis Bowen on 5/16/14.
//  Copyright (c) 2014 Voluta Tattoo Digital. All rights reserved.
//

#import "PiercingSelectTableCell.h"

@implementation PiercingSelectTableCell

@synthesize PiercingSelectVC;
@synthesize piercingSelectDelegate;
@synthesize cellDisplayValue;

- (void)initalizeInputView {
    
    self.PiercingSelectVC = [[PiercingSelectViewController alloc] init];
    self.PiercingSelectVC.delegate = self;
    self.PiercingSelectVC.RotationDelegate = self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withParentViewController:(UIViewController *)parentViewController
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initalizeInputView];
        
        piercingSelectDelegate = parentViewController;
        
        self.childVC = PiercingSelectVC;
        self.parentVC = parentViewController;
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initalizeInputView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self initalizeInputView];
    }
    return self;
}


- (void)setValue:(NSString *)v {
	cellDisplayValue = v;
	self.detailTextLabel.text = cellDisplayValue;
}

- (UIView *)inputView {
	return nil;
}

/*
 - (UIView *)inputAccessoryView {
 return nil;
 }
 */

- (void)done:(id)sender {
	[self resignFirstResponder];
}


- (BOOL)becomeFirstResponder {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        // resign the current first responder
        for (UIView *subview in self.superview.subviews) {
            if ([subview isFirstResponder]) {
                [subview resignFirstResponder];
                
            }
        }
        
        [self ShowViewController:currentVCOrientation];
        
        return NO;
    }
    return [super becomeFirstResponder];
}


- (BOOL)resignFirstResponder {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	
    //UITableView *tableView = (UITableView *)self.superview;
	//[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
	
    return [super resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	if (selected) {
		[self becomeFirstResponder];
	}
}

- (void)deviceDidRotate:(NSNotification*)notification {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// we should only get this call if the popover is visible
	}
}

#pragma mark -
#pragma mark Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)canResignFirstResponder {
    return YES;
}

#pragma mark -
#pragma TextfieldPopupViewController Protocol Method
- (void)PiercingSelectComplete:(NSString *)SelectedPiercing
{
    [self setValue:SelectedPiercing];
    
    [self DismissViewController];
    
    [self resignFirstResponder];
    
    if (piercingSelectDelegate) {
        
        self.TableCellValue = SelectedPiercing;
        [piercingSelectDelegate PiercingSelectionComplete:self didEndEditingWithValue:SelectedPiercing];
    }
}

- (void)setInitialValue:(NSString *)initialValue
{
    [self setValue:initialValue];
}

- (UIDeviceOrientation)getDeviceOrientation {
    
    return [piercingSelectDelegate getDeviceOrientation];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
    
    [piercingSelectDelegate setDeviceOrientation:orientation];
}

#pragma mark -
#pragma VolutaPopoverViewController delegate
- (void)RotationDetected:(UIDeviceOrientation)orientation
{
    if (orientation != currentVCOrientation) {
        
        [self DismissViewController];
        [self resignFirstResponder];
        currentVCOrientation = orientation;
        [self ShowViewController:currentVCOrientation];
        
    }
    
}


@end
