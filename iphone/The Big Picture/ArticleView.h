//
//  ArticleView.h
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//


@interface ArticleView : UIScrollView {
	NSString *article;
	UILabel *label;
}

@property (nonatomic, retain) NSString *article;
@property (nonatomic, retain) UILabel *label;

@end
