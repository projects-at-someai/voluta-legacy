//
//  ResubmitOptionsViewController.m
//  TRF
//
//  Created by Francis Bowen on 6/27/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "ResubmitOptionsViewController.h"

@interface ResubmitOptionsViewController ()

@end

@implementation ResubmitOptionsViewController

@synthesize delegate;
@synthesize CancelButton;
@synthesize OptionsTable;

__strong NSMutableArray *resubmitoptions = nil;

+(void)initialize {

    resubmitoptions = [[NSMutableArray alloc] initWithObjects:
                       @"Go back and make changes to waiver",
                       @"Go to Artist Notes",
                       @"Update session financials",
                       @"Start a new waiver",
                       nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.DialogView setBackgroundColor:[UIColor darkGrayColor]];
    self.DialogView.layer.cornerRadius = 10.0f;
    self.DialogView.layer.borderWidth = 1.5f;
    self.DialogView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, RESUMBITOPTIONS_WIDTH, 50.0f)];
    Title.text = @"Resubmit Options";
    Title.textAlignment = NSTextAlignmentCenter;
    Title.font = [UIFont fontWithName:VTD_FONT size:36.0f];
    Title.backgroundColor = [UIColor darkGrayColor];
    Title.textColor = [UIColor blackColor];
    [self.DialogView addSubview:Title];
    
    OptionsTable = [[UITableView alloc] initWithFrame:CGRectMake(20.0f,
                                                                 60.0f,
                                                                 RESUMBITOPTIONS_WIDTH - 40.0f,
                                                                 RESUMBITOPTIONS_HEIGHT - 60.0f - 60.0f)
                                                style:UITableViewStylePlain];
    OptionsTable.opaque = NO;
    OptionsTable.backgroundColor = [UIColor lightGrayColor];
    OptionsTable.separatorColor = [UIColor grayColor];
    OptionsTable.delegate = self;
    OptionsTable.dataSource = self;
    [self.DialogView addSubview:OptionsTable];
    
    CancelButton = [[UIButton alloc] initWithFrame:CGRectMake(RESUMBITOPTIONS_WIDTH / 2.0f - 100.0f / 2.0f,
                                                              RESUMBITOPTIONS_HEIGHT - 50.0f,
                                                              100.0f,
                                                              40.0f)];
    
    [CancelButton setBackgroundColor:[UIColor darkGrayColor]];
    [CancelButton.titleLabel setFont:[UIFont fontWithName:VTD_FONT size:30.0f]];
    [CancelButton setTitle:@"Done" forState:UIControlStateNormal];
    [CancelButton setTitleColor:VTD_LIGHT_BLUE forState:UIControlStateNormal];
    [CancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [CancelButton addTarget:self
                     action:@selector(CancelButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.DialogView addSubview:CancelButton];
    
    /*
    _BodyPlacementCell = [[BodyPlacementPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Body Placement" withParentViewController:self];
    _BodyPlacementCell.delegate = self;
     */
     
    _SessionsFinancialsCell = [[SessionFinancialsTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Session financials" withParentViewController:self withInitialData:nil];
    _SessionsFinancialsCell.delegate = self;

    self.LandscapeFrame = RESUMBITOPTIONS_LANDSCAPE;
    self.PortraitFrame = RESUMBITOPTIONS_PORTRAIT;
    
    [self setupFrame];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)CancelButtonTapped:(id)sender
{
    
    if (delegate) {
        [delegate ResubmitOptionsCanceled];
    }
}

#pragma mark - UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VolutaTRFCell *cell = [[VolutaTRFCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"Cell"];
    
    cell.textLabel.text = [resubmitoptions objectAtIndex:indexPath.row];
    
    switch (indexPath.row) {
            
        case 2:
            cell = _SessionsFinancialsCell;
            break;

            
        default: cell.textLabel.text = @"";
            break;
    }
    
    cell.textLabel.text = [resubmitoptions objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:VTD_FONT size:24.0f];
    
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *SelectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (delegate && (indexPath.row != 2)) {
        
        [delegate ResubmitOptionsComplete:SelectedCell.textLabel.text withIndex:indexPath.row];
    }
    
}

#pragma mark - PickerPopupTableCellDelegate
- (void)PickerComplete:(PickerPopupTableCell *)cell withValue:(NSString *)value {
    
    /*
    NSString *UpdatedBodyPlacment = [NSString stringWithFormat:@"%@",value];
    
    NSIndexPath *indexPath = [OptionsTable indexPathForCell:cell];
    
    if (delegate) {
        [delegate ResubmitOptionsComplete:UpdatedBodyPlacment withIndex:indexPath.row];
    }
    */
}

- (UIDeviceOrientation)getDeviceOrientation {
    
    return [self.RotationDelegate getDeviceOrientation];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
    
    [self.RotationDelegate setDeviceOrientation:orientation];
}

- (NSString *)getTitle {
    
    return @"Treatment Area";
}

#pragma mark - SessionFinancialsTableCellDelegate
- (void)SessionsFinancialsComplete:(SessionFinancialsTableCell *)cell
                withFinancialsData:(NSDictionary *)financials {
    
    if (delegate) {
        [delegate SessionsFinancialsComplete:cell withFinancialsData:financials];
    }
}

- (NSDictionary *)GetInitialData {
    
    return [delegate GetInitialData];
}

@end
