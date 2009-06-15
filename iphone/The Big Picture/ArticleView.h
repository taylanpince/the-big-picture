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
	
	UIDeviceOrientation orientation;
}

@property (nonatomic, retain) NSString *article;
@property (nonatomic, retain) UILabel *label;

@property (nonatomic, assign) UIDeviceOrientation orientation;

@end
