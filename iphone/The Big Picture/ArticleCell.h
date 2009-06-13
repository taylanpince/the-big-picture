//
//  ArticleCell.h
//  The Big Picture
//
//  Created by Taylan Pince on 13/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//


@interface ArticleCell : UITableViewCell {
	NSString *mainTitle;
	NSString *subTitle;
	
	BOOL unread;
	
	UIView *contentView;
}

@property (nonatomic, retain) NSString *mainTitle;
@property (nonatomic, retain) NSString *subTitle;

@property (nonatomic, assign) BOOL unread;

- (void)drawContentView:(CGRect)rect;

@end
