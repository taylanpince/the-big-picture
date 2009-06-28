//
//  PhotoView.m
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "URLCacheConnection.h"
#import "PhotoView.h"
#import "CaptionView.h"
#import "Photo.h"


@implementation PhotoView

@synthesize photo, label, infoButton, loadingIndicator, activeConnection;
@synthesize initialDistance, maximumZoomScale, currentZoomScale, orientation, delegate;


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		currentZoomScale = 1.0;
		
		label = [[CaptionView alloc] initWithFrame:CGRectZero];
		
		[self addSubview:label];
		
		infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
		
		[infoButton setAlpha:0.0];
		[infoButton setFrame:CGRectMake(frame.size.width - 16.0, frame.size.height - 16.0, 16.0, 16.0)];
		[infoButton setShowsTouchWhenHighlighted:YES];
		[infoButton addTarget:self action:@selector(toggleCaption) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:infoButton];
		
		loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		
		loadingIndicator.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
		loadingIndicator.hidesWhenStopped = YES;
		
		[self addSubview:loadingIndicator];
    }
    return self;
}


- (void)toggleCaption {
	if (label.alpha > 0.0) {
		[UIView beginAnimations:@"captionFadeOut" context:NULL];
		[UIView setAnimationDuration:0.5];
		[label setAlpha:0.0];
		[UIView commitAnimations];
	} else {
		[UIView beginAnimations:@"captionFadeIn" context:NULL];
		[UIView setAnimationDuration:0.5];
		[label setAlpha:1.0];
		[UIView commitAnimations];
	}
}


- (void)resetScale {
	currentZoomScale = 1.0;
	
	if (orientation == UIDeviceOrientationPortrait || orientation == 0) {
		if (self.image.size.width > self.image.size.height) {
			maximumZoomScale = self.image.size.width / self.frame.size.width;
		} else {
			maximumZoomScale = self.image.size.height / self.frame.size.height;
		}

		[label setOrientation:orientation];
		[label setFrame:CGRectMake(0.0, self.frame.size.height, self.frame.size.width, 0.0)];
		[infoButton setCenter:CGPointMake(self.frame.size.width - 16.0, self.frame.size.height - 16.0)];
	} else {
		if (self.image.size.width > self.image.size.height) {
			maximumZoomScale = self.image.size.width / self.frame.size.height;
		} else {
			maximumZoomScale = self.image.size.height / self.frame.size.width;
		}

		[label setOrientation:orientation];
		[label setFrame:CGRectMake(0.0, self.frame.size.width, self.frame.size.height, 0.0)];
		[infoButton setCenter:CGPointMake(self.frame.size.height - 16.0, self.frame.size.width - 16.0)];
	}
}


- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	if (orientation == UIDeviceOrientationPortrait || orientation == 0) {
		loadingIndicator.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
	} else {
		loadingIndicator.center = CGPointMake(frame.size.height / 2, frame.size.width / 2);
	}
}


- (void)setImage:(UIImage *)image {
	[self setAlpha:0.0];
	[super setImage:image];
	[loadingIndicator stopAnimating];
	
	[self resetScale];
	
	[infoButton setAlpha:0.50];
	
	[UIView beginAnimations:@"fadeIn" context:NULL];
	[UIView setAnimationDuration:0.5];
	[self setAlpha:1.0];
	[UIView commitAnimations];
}


- (void)setPhoto:(Photo *)newPhoto {
	if (photo != newPhoto) {
		[photo release];
		
		photo = [newPhoto retain];
		
		label.alpha = 0.0;
		label.caption = newPhoto.caption;
		
		[loadingIndicator setHidden:NO];
		[loadingIndicator startAnimating];

		activeConnection = [[URLCacheConnection alloc] initWithURL:newPhoto.url delegate:self];
	}
}


- (CGFloat)distanceBetweenTwoPoints:(CGPoint)firstPoint toPoint:(CGPoint)secondPoint {
	float x = secondPoint.x - firstPoint.x;
	float y = secondPoint.y - firstPoint.y;
	
	return sqrt((x * x) + (y * y));
}


- (void)zoomToScale:(CGFloat)scale animated:(BOOL)animated {
	if (!animated) {
		infoButton.hidden = (scale > 1.0);
		label.hidden = (scale > 1.0);
	}

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


- (void)autoZoomDone {
	if (orientation == UIDeviceOrientationPortrait || orientation == 0) {
		[delegate didEndZoomingOnView:self withCenterPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
	} else {
		[delegate didEndZoomingOnView:self withCenterPoint:CGPointMake(self.frame.size.height / 2, self.frame.size.width / 2)];
	}
	
	if (currentZoomScale == 1.0) {
		[self resetScale];
		
		infoButton.hidden = NO;
		label.hidden = NO;
	}
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.image) return;

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
					if (self.image) [self autoZoomDone];
					
					[delegate didSingleTapOnView:self withPoint:[touch locationInView:self]];
					break;
				case 2:
					if (!self.image) return;

					infoButton.hidden = YES;
					label.hidden = YES;
					
					[UIView beginAnimations:@"zoomIn" context:NULL];
					[UIView setAnimationDuration:0.5];
					
					if (currentZoomScale > 1.0) {
						[self zoomToScale:1.0 animated:YES];
					} else {
						[self zoomToScale:maximumZoomScale animated:YES];
					}
					
					[UIView setAnimationDelegate:self];
					[UIView setAnimationDidStopSelector:@selector(autoZoomDone)];
					[UIView commitAnimations];
					
					[delegate didDoubleTapOnView:self withPoint:[touch locationInView:self]];
					break;
				default: {
					CGPoint centerPoint;
					
					if (orientation == UIDeviceOrientationPortrait || orientation == 0) {
						centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
					} else {
						centerPoint = CGPointMake(self.frame.size.height / 2, self.frame.size.width / 2);
					}
					
					[delegate didEndZoomingOnView:self withCenterPoint:centerPoint];
					break;
				}
			}
			
			break;
		}
		case 2: {
			if (!self.image) return;
			
			UITouch *firstTouch = [[[event allTouches] allObjects] objectAtIndex:0];
			UITouch *secondTouch = [[[event allTouches] allObjects] objectAtIndex:1];
			CGPoint firstTouchLocation = [firstTouch locationInView:self];
			CGPoint secondTouchLocation = [secondTouch locationInView:self];
			
			CGPoint centerPoint = CGPointMake(
				MIN(secondTouchLocation.x, firstTouchLocation.x) + abs(secondTouchLocation.x - firstTouchLocation.x) / 2, 
				MIN(secondTouchLocation.y, firstTouchLocation.y) + abs(secondTouchLocation.y - firstTouchLocation.y) / 2
			);

			if (currentZoomScale <= 1.10) {
				infoButton.hidden = YES;
				label.hidden = YES;
				
				[UIView beginAnimations:@"zoomIn" context:NULL];
				[UIView setAnimationDuration:0.5];
				[self zoomToScale:1.0 animated:YES];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(autoZoomDone)];
				[UIView commitAnimations];
			} else {
				[delegate didEndZoomingOnView:self withCenterPoint:centerPoint];
			}
			
			break;
		}
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.image) return;

	switch ([[event allTouches] count]) {
		case 2: {
			UITouch *firstTouch = [[[event allTouches] allObjects] objectAtIndex:0];
			UITouch *secondTouch = [[[event allTouches] allObjects] objectAtIndex:1];
			
			CGFloat finalDistance = [self distanceBetweenTwoPoints:[firstTouch locationInView:self] toPoint:[secondTouch locationInView:self]];
			
			[self zoomToScale:currentZoomScale + ((finalDistance - initialDistance) / 200.0) animated:NO];
			
			initialDistance = finalDistance;
			
			break;
		}
	}
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}


- (void)connectionDidFail:(URLCacheConnection *)theConnection {
	[activeConnection release];
	activeConnection = nil;
}


- (void)connectionDidFinish:(URLCacheConnection *)theConnection {
	[self setImage:[UIImage imageWithData:theConnection.receivedData]];
	[activeConnection release];
	activeConnection = nil;
}


- (void)cancelConnection {
	if (activeConnection) {
		[activeConnection cancelConnection];
		[activeConnection release];
		activeConnection = nil;
	}
}


- (void)dealloc {
	[photo release];
	[label release];
	[loadingIndicator release];
	
	if (activeConnection) {
		[activeConnection cancelConnection];
		[activeConnection release];
		activeConnection = nil;
	}
	
    [super dealloc];
}


@end
