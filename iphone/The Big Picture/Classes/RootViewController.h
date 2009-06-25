//
//  RootViewController.h
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright Taylan Pince 2009. All rights reserved.
//

#import "AboutViewController.h"

@interface RootViewController : UITableViewController <AboutViewControllerDelegate> {
	NSMutableArray *articleList;
	NSMutableString *activeContent;
	NSDateFormatter *dateFormatter;
	
	UIActivityIndicatorView *loadingIndicator;
}

@property (nonatomic, retain) NSMutableArray *articleList;
@property (nonatomic, retain) NSMutableString *activeContent;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;

@end
