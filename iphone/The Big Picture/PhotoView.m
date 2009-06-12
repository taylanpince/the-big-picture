//
//  PhotoView.m
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "PhotoView.h"
#import "Photo.h"


@implementation PhotoView

@synthesize photo, loadingIndicator, initialDistance, maximumZoomScale, currentZoomScale, delegate;


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		currentZoomScale = 1.0;
    }
    return self;
}


- (void)setImage:(UIImage *)image {
	self.alpha = 0.0;
	
	[super setImage:image];
	[loadingIndicator stopAnimating];
	
	if (image.size.width > image.size.height) {
		maximumZoomScale = image.size.width / self.frame.size.width;
	} else {
		maximumZoomScale = image.size.height / self.frame.size.height;
	}
	
	[UIView beginAnimations:@"fadeIn" context:NULL];
	[UIView setAnimationDuration:0.5];
	[self setAlpha:1.0];
	[UIView commitAnimations];
}


- (void)setPhoto:(Photo *)newPhoto {
	if (loadingIndicator != nil) {
		[loadingIndicator setHidden:NO];
		[loadingIndicator startAnimating];
	} else {
		loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		
		loadingIndicator.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
		loadingIndicator.hidesWhenStopped = YES;
		
		[loadingIndicator startAnimating];
		[self addSubview:loadingIndicator];
	}
	
	[self performSelectorInBackground:@selector(loadImage:) withObject:newPhoto.url];
}


- (void)loadImage:(NSURL *)url {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
	
	[self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
	
	[pool release];
}


- (CGFloat)distanceBetweenTwoPoints:(CGPoint)firstPoint toPoint:(CGPoint)secondPoint {
	float x = secondPoint.x - firstPoint.x;
	float y = secondPoint.y - firstPoint.y;
	
	return sqrt((x * x) + (y * y));
}


- (void)zoomToScale:(CGFloat)scale withCenterPoint:(CGPoint)center {
	if (scale >= 1.0 && scale <= maximumZoomScale) {
		currentZoomScale = scale;
		
		CGFloat scaledWidth = scale * self.image.size.width / maximumZoomScale;
		CGFloat scaledHeight = scale * self.image.size.height / maximumZoomScale;
		
		self.bounds = CGRectMake(0.0, 0.0, scaledWidth, scaledHeight);
	} else if (scale < 1.0) {
		currentZoomScale = 1.0;
		
		CGFloat scaledWidth = currentZoomScale * self.image.size.width / maximumZoomScale;
		CGFloat scaledHeight = currentZoomScale * self.image.size.height / maximumZoomScale;
		
		self.bounds = CGRectMake(0.0, 0.0, scaledWidth, scaledHeight);
	} else if (scale > maximumZoomScale) {
		currentZoomScale = maximumZoomScale;
		
		self.bounds = CGRectMake(0.0, 0.0, self.image.size.width, self.image.size.height);
	}
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
					if (currentZoomScale > 1.0) {
						[self zoomToScale:1.0 withCenterPoint:[touch locationInView:self]];
					} else {
						[self zoomToScale:maximumZoomScale withCenterPoint:[touch locationInView:self]];
					}
					
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
			
			[self zoomToScale:currentZoomScale + ((finalDistance - initialDistance) / 200.0) withCenterPoint:[firstTouch locationInView:self]];
			
			initialDistance = finalDistance;
			
			break;
		}
	}
}


- (void)dealloc {
	[photo release];
	[loadingIndicator release];
    [super dealloc];
}


@end
