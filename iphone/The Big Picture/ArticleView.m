//
//  ArticleView.m
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "ArticleView.h"


@implementation ArticleView

@synthesize article, label, orientation;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.font = [UIFont systemFontOfSize:16.0];
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor blackColor];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		
		[self addSubview:label];
    }
    return self;
}


- (void)setArticle:(NSString *)newArticle {
	if (article != newArticle) {
		[article release];

		article = [newArticle retain];
		
		[self setNeedsLayout];
	}
}


- (void)layoutSubviews {
	CGSize textSize;
	
	if (orientation == UIDeviceOrientationPortrait || orientation == 0) {
		textSize = [article sizeWithFont:label.font constrainedToSize:CGSizeMake(self.frame.size.width - 30.0, 2000.0) lineBreakMode:UILineBreakModeWordWrap];
	} else {
		textSize = [article sizeWithFont:label.font constrainedToSize:CGSizeMake(self.frame.size.height - 30.0, 2000.0) lineBreakMode:UILineBreakModeWordWrap];
	}
	
	label.text = article;
	label.frame = CGRectMake(15.0, 0.0, textSize.width, textSize.height);
	
	self.contentSize = CGSizeMake(textSize.width, textSize.height + 15.0);
}


- (void)dealloc {
	[article release];
	[label release];
    [super dealloc];
}


@end
