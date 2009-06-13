//
//  ArticleView.m
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "ArticleView.h"


@implementation ArticleView

@synthesize article, label;


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
	CGSize textSize = [article sizeWithFont:label.font constrainedToSize:CGSizeMake(self.frame.size.width - 30.0, 2000.0) lineBreakMode:UILineBreakModeWordWrap];
	
	label.text = article;
	label.frame = CGRectMake(15.0, 0.0, textSize.width, textSize.height);
	
	self.contentSize = CGSizeMake(textSize.width, textSize.height + 15.0);
}


//- (void)drawRect:(CGRect)rect {
//	NSLog(@"Rect: %f, %f", rect.origin.x, rect.origin.y);
//	UIColor *mainColor = [UIColor whiteColor];
//	
//	[mainColor set];
//	
//	CGSize articleSize = [article drawInRect:CGRectMake(15.0, 10.0, rect.size.width - 30.0, 1000.0) withFont:mainFont lineBreakMode:UILineBreakModeWordWrap];
//
//	self.contentSize = articleSize;
//}


- (void)dealloc {
	[article release];
	[label release];
    [super dealloc];
}


@end
