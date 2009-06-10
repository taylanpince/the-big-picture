//
//  PhotoView.m
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "PhotoView.h"


@implementation PhotoView

@synthesize initialDistance, delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}


- (CGFloat)distanceBetweenTwoPoints:(CGPoint)firstPoint toPoint:(CGPoint)secondPoint {
	float x = secondPoint.x - firstPoint.x;
	float y = secondPoint.y - firstPoint.y;
	
	return sqrt((x * x) + (y * y));
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	switch ([[event allTouches] count]) {
		case 2: {
			UITouch *firstTouch = [[[event allTouches] allObjects] objectAtIndex:0];
			UITouch *secondTouch = [[[event allTouches] allObjects] objectAtIndex:1];
			
			initialDistance = [self distanceBetweenTwoPoints:[firstTouch locationInView:self] toPoint:[secondTouch locationInView:self]];
			
			[delegate didBeginZoomingOnView:self];
			
			break;
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	switch ([[event allTouches] count]) {
		case 1: {
			UITouch *touch = [[[event allTouches] allObjects] objectAtIndex:0];
			
			switch ([touch tapCount]) {
				case 1:
					[delegate didSingleTapOnView:self];
					break;
				case 2:
					[delegate didDoubleTapOnView:self];
					break;
			}
			
			break;
		}
		case 2: {
			[delegate didEndZoomingOnView:self];
			
			break;
		}
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	switch ([[event allTouches] count]) {
		case 2: {
			UITouch *firstTouch = [[[event allTouches] allObjects] objectAtIndex:0];
			UITouch *secondTouch = [[[event allTouches] allObjects] objectAtIndex:1];
			
			CGFloat finalDistance = [self distanceBetweenTwoPoints:[firstTouch locationInView:self] toPoint:[secondTouch locationInView:self]];
			
			if (initialDistance > finalDistance) {
				NSLog(@"Zooming Out");
			} else {
				NSLog(@"Zooming In");
			}
			
			break;
		}
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
