//
//  SearchResultsViewController.m
//  LRF
//
//  Created by Francis Bowen on 6/24/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "SearchResultsViewController.h"

@interface SearchResultsViewController ()

@end

@implementation SearchResultsViewController

@synthesize delegate;
@synthesize SearchResultsTable;
@synthesize CancelButton;

- (id)initWithSearchResults:(NSArray *)SearchResults {
    
    self = [super init];
    
    if (self) {
        
        _View = [[UIView alloc] init];
        _SearchResults = SearchResults;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [_View setBackgroundColor:[UIColor darkGrayColor]];
    _View.layer.cornerRadius = 10.0f;
    _View.layer.borderWidth = 1.5f;
    _View.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    if (_SearchResults == nil) {
        
        _SearchResults = [[NSArray alloc] init];
    }
    
    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SEARCHRESULTS_WIDTH, 50.0f)];
    Title.text = @"Search Results";
    Title.textAlignment = NSTextAlignmentCenter;
    Title.font = [UIFont fontWithName:VTD_FONT size:36.0f];
    Title.backgroundColor = [UIColor darkGrayColor];
    Title.textColor = [UIColor whiteColor];
    [_View addSubview:Title];
    
    SearchResultsTable = [[UITableView alloc] initWithFrame:CGRectMake(20.0f,
                                                                       60.0f,
                                                                       SEARCHRESULTS_WIDTH - 40.0f,
                                                                       SEARCHRESULTS_HEIGHT - 60.0f - 60.0f)
                                                      style:UITableViewStylePlain];
    SearchResultsTable.opaque = NO;
    SearchResultsTable.backgroundColor = [UIColor lightGrayColor];
    SearchResultsTable.separatorColor = [UIColor grayColor];
    SearchResultsTable.delegate = self;
    SearchResultsTable.dataSource = self;
    [_View addSubview:SearchResultsTable];
    
    CancelButton = [[UIButton alloc] initWithFrame:CGRectMake(SEARCHRESULTS_WIDTH / 2.0f - 100.0f / 2.0f,
                                                              SEARCHRESULTS_HEIGHT - 50.0f,
                                                              100.0f,
                                                              40.0f)];
    
    [CancelButton setBackgroundColor:[UIColor darkGrayColor]];
    [CancelButton.titleLabel setFont:[UIFont fontWithName:VTD_FONT size:30.0f]];
    [CancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [CancelButton setTitleColor:VTD_LIGHT_BLUE forState:UIControlStateNormal];
    [CancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [CancelButton addTarget:self
                     action:@selector(CancelButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    [_View addSubview:CancelButton];
    
    [self.view addSubview:_View];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)CancelButtonTapped:(id)sender
{
    if (delegate) {
        [delegate SearchResultsCanceled];
    }
}

- (void)DoRotation:(UIDeviceOrientation)Orientation {
    
    if (UIDeviceOrientationIsLandscape(Orientation)) {
        
        [_View setFrame:SEARCHRESULTS_LANDSCAPE];
    }
    else {
        
        [_View setFrame:SEARCHRESULTS_PORTRAIT];
    }
}

- (void)SetSaveForLater:(NSArray *)saveforlater {

    _SaveForLater = saveforlater;

    [SearchResultsTable reloadData];
}

#pragma mark - UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSUInteger numsections = 1;

    if ((_SaveForLater != nil) && ([_SaveForLater count] > 0)) {
        numsections = 2;
    }

    return numsections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSUInteger numrows = [_SearchResults count];

    if ((_SaveForLater != nil) && ([_SaveForLater count] > 0)) {

        if (section == 0) {

            numrows = [_SaveForLater count];
        }
        else {
            numrows = [_SearchResults count];
        }
    }

    return numrows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *SearchResultDict = nil;

    if ((_SaveForLater != nil) && ([_SaveForLater count] > 0) && (indexPath.section == 0)) {

        SearchResultDict = [_SaveForLater objectAtIndex:indexPath.row];
    }
    else {

        SearchResultDict = [_SearchResults objectAtIndex:indexPath.row];
    }

    NSString *SearchResult = [SearchResultDict objectForKey:@"Search Result"];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"Cell"];
    
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = SearchResult;
    cell.textLabel.font = [UIFont fontWithName:VTD_FONT size:24.0f];
    
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (delegate) {

        NSDictionary *SearchResultDict = nil;
        BOOL isSaveForLater = NO;

        if ((_SaveForLater != nil) && ([_SaveForLater count] > 0) && (indexPath.section == 0)) {

            SearchResultDict = [_SaveForLater objectAtIndex:indexPath.row];
            isSaveForLater = YES;
        }
        else {

            SearchResultDict = [_SearchResults objectAtIndex:indexPath.row];

        }

        NSString *SearchResult = [SearchResultDict objectForKey:@"Search Result"];
        
        [delegate SearchResultsComplete:SearchResult withIndex:indexPath.row isSaveForLater:isSaveForLater];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 55.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Name of section
    NSString *header = [self tableView:tableView titleForHeaderInSection:section];

    UIView *view;
    UILabel *label;

    // Label for secton header
    label = [[UILabel alloc] init];

    label.frame = CGRectMake(5, 5.0, 230, 45);

    label.textColor = VTD_LIGHT_BLUE;
    label.font = [UIFont fontWithName:VTD_FONT size:28.0f];
    label.text = header;
    label.backgroundColor = [UIColor clearColor];

    // View to contain label
    view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 230, 55)];
    view.backgroundColor = [UIColor darkGrayColor];
    [view addSubview:label];

    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Uploaded Waivers";

    if ((_SaveForLater != nil) && ([_SaveForLater count] > 0) && (section == 0)) {

        title = @"Forms Saved for Later";
    }

    return title;
}


@end
