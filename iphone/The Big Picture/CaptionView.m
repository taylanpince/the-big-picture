//
//  CaptionView.m
//  The Big Picture
//
//  Created by Taylan Pince on 13/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "CaptionView.h"


@implementation CaptionView

@synthesize label, caption;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
		
        label = [[UILabel alloc] initWithFrame:CGRectZero];
		
		label.font = [UIFont systemFontOfSize:14.0];
		label.opaque = NO;
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor whiteColor];
		label.numberOfLines = 0;
		label.lineBreakMode = UILineBreakModeWordWrap;
		
		[self addSubview:label];
    }
    return self;
}


- (void)setCaption:(NSString *)newCaption {
	if (caption != newCaption) {
		[caption release];
		
		caption = [newCaption retain];
		
		[self setNeedsLayout];
	}
}


- (void)layoutSubviews {
	CGSize textSize = [caption sizeWithFont:label.font constrainedToSize:CGSizeMake(self.frame.size.width - 30.0, 2000.0) lineBreakMode:UILineBreakModeWordWrap];
	
	[label setText:caption];
	[label setFrame:CGRectMake(15.0, 10.0, textSize.width, textSize.height)];
	[self setFrame:CGRectMake(0.0, self.superview.frame.size.height - textSize.height - 20.0, self.frame.size.width, textSize.height + 20.0)];
}


- (void)dealloc {
	[label release];
	[caption release];
    [super dealloc];
}


@end
