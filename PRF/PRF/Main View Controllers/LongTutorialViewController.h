//
//  LongTutorialViewController.h
//  PRF
//
//  Created by Francis Bowen on 5/20/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "VolutaBaseViewController.h"

#define NUM_WELCOME_PANELS  4

@interface LongTutorialViewController : VolutaBaseViewController <
    BaseViewControllerDelegate,
    BaseViewControllerBackgroundDelegate,
    UIScrollViewDelegate
>
{
    
}

@property (retain) UIButton *BeginButton;
@property (retain) UIScrollView *ScrollView;
//@property (retain) UIPageControl *pageControl;
@property (retain) UILabel *PanelNumberLabel;

@end
