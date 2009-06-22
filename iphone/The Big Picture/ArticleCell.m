//
//  ArticleCellView.m
//  The Big Picture
//
//  Created by Taylan Pince on 13/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "ArticleCell.h"


@interface ArticleCellView : UIView

@end


@implementation ArticleCellView

- (void)drawRect:(CGRect)rect {
	[(ArticleCell *)[self superview] drawContentView:rect];
}

@end


@implementation ArticleCell

@synthesize mainTitle, subTitle, unread;

static UIFont *mainFont = nil;
static UIFont *subFont = nil;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		contentView = [[ArticleCellView alloc] initWithFrame:CGRectZero];
		contentView.opaque = YES;
		contentView.backgroundColor = [UIColor whiteColor];
		
		[self addSubview:contentView];
		
		[contentView release];
		
		mainFont = [UIFont boldSystemFontOfSize:18.0];
		subFont = [UIFont systemFontOfSize:12.0];
    }
    return self;
}


- (void)dealloc {
	[mainTitle release];
	[subTitle release];
	[super dealloc];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (self.selected != selected) {
		[self setNeedsDisplay];
	}
	
	[super setSelected:selected animated:animated];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	if (self.highlighted != highlighted) {
		[self setNeedsDisplay];
	}
	
	[super setSelected:highlighted animated:animated];
}


- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	CGRect bounds = [self bounds];
	
	bounds.size.height -= 1;
	
	[contentView setFrame:bounds];
}


- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];
}


- (void)setSubTitle:(NSString *)newSubTitle {
	if (subTitle != newSubTitle) {
		[subTitle release];

		subTitle = [newSubTitle retain];
		
		[self setNeedsDisplay];
	}
}


- (void)drawContentView:(CGRect)rect {
	UIColor *mainColour = [UIColor blackColor];
	UIColor *subColour = [UIColor lightGrayColor];
	
	if (self.selected || self.highlighted) {
		mainColour = [UIColor whiteColor];
		subColour = [UIColor whiteColor];
	}
	
	CGPoint top = CGPointMake(40.0, 4.0);
	
	[mainColour set];
	
	CGSize textSize = [mainTitle drawInRect:CGRectMake(top.x, top.y, rect.size.width - 65.0, 600.0f) withFont:mainFont lineBreakMode:UILineBreakModeWordWrap];
	
	top.y += textSize.height;
	
	[subColour set];
	
	CGSize subTextSize = [subTitle drawInRect:CGRectMake(top.x, top.y, rect.size.width - 65.0, 600.0f) withFont:subFont lineBreakMode:UILineBreakModeTailTruncation];
	
	top.y += subTextSize.height + 4.0;
	
	if (unread) {
		UIImage *unreadDot = [UIImage imageNamed:@"dot.png"];
		[unreadDot drawAtPoint:CGPointMake(20.0 - unreadDot.size.width / 2, top.y / 2 - unreadDot.size.height / 2)];
	}
}

@end
