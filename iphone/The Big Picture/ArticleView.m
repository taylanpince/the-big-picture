//
//  ArticleView.m
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "ArticleView.h"


@implementation ArticleView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
    }
    return self;
}


- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
	
	
	return YES;
}


- (void)dealloc {
    [super dealloc];
}


@end
