//
//  ConnectionView.m
//  The Big Picture
//
//  Created by Taylan Pince on 15/07/09.
//  Copyright 2009 Hippo Foundry. All rights reserved.
//

#import "ConnectionView.h"


@implementation ConnectionView

@synthesize loadingIndicator, label;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85]];
		
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		
		loadingIndicator.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
		loadingIndicator.hidesWhenStopped = YES;
		
		[loadingIndicator startAnimating];
		[self addSubview:loadingIndicator];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, loadingIndicator.frame.origin.y + loadingIndicator.frame.size.height + 15.0, frame.size.width - 80.0, 25.0)];
		
		[label setTextColor:[UIColor whiteColor]];
		[label setTextAlignment:UITextAlignmentCenter];
		[label setFont:[UIFont boldSystemFontOfSize:18.0]];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setText:@"Establishing Connection"];
		
		[self addSubview:label];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
}

- (void)removeView {
	[self removeFromSuperview];
}

- (void)stopAnimating {
	[UIView beginAnimations:@"fadeOut" context:NULL];
	[UIView setAnimationDuration:0.5];
	[self setAlpha:0.0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeView)];
	[UIView commitAnimations];
}

- (void)dealloc {
	[label release];
	[loadingIndicator release];
    [super dealloc];
}

@end
