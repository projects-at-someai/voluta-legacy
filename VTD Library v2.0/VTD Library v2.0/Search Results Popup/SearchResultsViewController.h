//
//  SearchResultsViewController.h
//  LRF
//
//  Created by Francis Bowen on 6/24/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define SEARCHRESULTS_WIDTH  400.0f
#define SEARCHRESULTS_HEIGHT 600.0f

#define SEARCHRESULTS_PORTRAIT      CGRectMake(184.0f, 212.0f, SEARCHRESULTS_WIDTH, SEARCHRESULTS_HEIGHT)
#define SEARCHRESULTS_LANDSCAPE     CGRectMake(312.0f, 84.0f, SEARCHRESULTS_WIDTH, SEARCHRESULTS_HEIGHT)

@protocol SearchResultsPopupDelegate
@required
- (void)SearchResultsComplete:(NSString *)txt
                    withIndex:(NSUInteger)index
               isSaveForLater:(BOOL)saveForLaterFlag;
- (void)SearchResultsCanceled;
@end

@interface SearchResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    //Note: _SearchResults is an array of NSDictionary objects with a "Search Result" entry
    NSArray *_SearchResults;
    NSArray *_SaveForLater;
    UIView *_View;
}

@property (nonatomic, weak) id<SearchResultsPopupDelegate> delegate;
@property (retain) UIButton *CancelButton;
@property (retain) UITableView *SearchResultsTable;

- (id)initWithSearchResults:(NSArray *)SearchResults;
- (void)DoRotation:(UIDeviceOrientation)Orientation;
- (void)SetSaveForLater:(NSArray *)saveforlater;

@end
