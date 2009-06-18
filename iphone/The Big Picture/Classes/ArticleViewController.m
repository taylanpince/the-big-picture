//
//  ArticleViewController.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "RegexKitLite.h"
#import "URLCacheConnection.h"
#import "TheBigPictureAppDelegate.h"
#import "ArticleViewController.h"
#import "ArticleView.h"
#import "PhotoView.h"
#import "LoadingView.h"
#import "Article.h"
#import "Photo.h"


static NSString *const RE_FIRST_PHOTO = @"<div class=\"bpImageTop\"><a name=\"photo1\"></a><a href=\".*?\"><img src=\"(.*?)\" class=\"bpImage\" style=\".*?\" /></a><br/><div class=\"bpCaption\">(.*?)<div";
static NSString *const RE_PHOTO = @"<div class=\"bpBoth\"><a name=\"photo[0-9]+\"></a><img src=\"(.*?)\" class=\"bpImage\" style=\".*?\" /><br/><div onclick=\"this.style.display='none'\" class=\"(.*?)\" style=\".*?\"></div><div class=\"bpCaption\"><div class=\"photoNum\"><a href=\"#photo[0-9]+\">[0-9]+</a></div>(.*?)<a href";
static NSString *const RE_HTML = @"<[a-zA-Z\\/][^>]*>";


@implementation ArticleViewController

@synthesize article, loadingIndicator, imageList, imageViewsList, hideTimer, activeConnection;
@synthesize zooming, rotating, activeIndex, activeOrientation;


- (void)loadView {
	self.title = article.title;
	self.wantsFullScreenLayout = YES;
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	
	scrollView.delegate = self;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.pagingEnabled = YES;
	scrollView.scrollsToTop = NO;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.directionalLockEnabled = YES;
	
	self.view = scrollView;
	
	imageList = [[NSMutableArray alloc] init];
	imageViewsList = [[NSMutableArray alloc] init];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)viewDidAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	
	[self.view.superview setFrame:screenBounds];
	[self.view setFrame:CGRectMake(0.0, 0.0, screenBounds.size.width + 15.0, screenBounds.size.height + 15.0)];
	
	[super viewDidAppear:animated];
	
	UIScrollView *scrollView = (UIScrollView *)[self view];
	
	[scrollView setContentOffset:CGPointZero];
	[scrollView setContentInset:UIEdgeInsetsZero];
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width - 15.0, scrollView.frame.size.height - 15.0)];
	
	ArticleView *articleView = [[ArticleView alloc] initWithFrame:CGRectMake(0.0, 0.0, scrollView.frame.size.width - 15.0, scrollView.frame.size.height - 15.0)];
	
	articleView.alpha = 0.0;
	articleView.tag = 0;
	articleView.backgroundColor = [UIColor blackColor];
	articleView.article = article.description;
	articleView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + 30.0, 0.0, 0.0, 0.0);
	
	[scrollView addSubview:articleView];
	
	[UIView beginAnimations:@"fadeIn" context:NULL];
	[UIView setAnimationDuration:0.5];
	[articleView setAlpha:1.0];
	[UIView commitAnimations];
	
	[articleView release];
	
	activeIndex = 0;
	
	if ([[(TheBigPictureAppDelegate *)[[UIApplication sharedApplication] delegate] articleData] objectForKey:article.guid] == nil) {
		[[(TheBigPictureAppDelegate *)[[UIApplication sharedApplication] delegate] articleData] setObject:[NSNumber numberWithInt:0] forKey:article.guid];
		
		NSInteger unreadCount = [[UIApplication sharedApplication] applicationIconBadgeNumber];
		
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount - 1];
	}
	
	loadingIndicator = [[LoadingView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width - 15.0, self.view.frame.size.height - 15.0)];
	
	[loadingIndicator setAlpha:0.0];
	[self.view addSubview:loadingIndicator];
	
	[UIView beginAnimations:@"fadeIn" context:NULL];
	[UIView setAnimationDuration:0.5];
	[loadingIndicator setAlpha:1.0];
	[UIView commitAnimations];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	activeConnection = [[URLCacheConnection alloc] initWithURL:article.url delegate:self];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (hideTimer != nil) {
		[hideTimer invalidate];
		
		hideTimer = nil;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


- (void)hideInterface {
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];

	[UIView beginAnimations:@"fadeOut" context:NULL];
	[UIView setAnimationDuration:0.5];
	[self.navigationController.navigationBar setAlpha:0.0];
	[UIView commitAnimations];
	
	hideTimer = nil;
}


- (void)showInterface {
	if ([[UIApplication sharedApplication] isStatusBarHidden] == YES) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];

		[UIView beginAnimations:@"fadeIn" context:NULL];
		[UIView setAnimationDuration:0.5];
		[self.navigationController.navigationBar setAlpha:1.0];
		[UIView commitAnimations];
		
		if (activeIndex > 0) {
			hideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideInterface) userInfo:nil repeats:NO];
		} else {
			hideTimer = nil;
		}
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)didRotate {
	rotating = NO;
	
	UIView *subView = [self.view viewWithTag:activeIndex];
	
	if ([subView isKindOfClass:[PhotoView class]]) {
		[[(PhotoView *)subView infoButton] setHidden:NO];
		[[(PhotoView *)subView label] setHidden:NO];
		[(PhotoView *)subView setOrientation:activeOrientation];
		[(PhotoView *)subView resetScale];
	}
}


- (void)willRotate {
	activeOrientation = [[UIDevice currentDevice] orientation];
	
	if (activeOrientation == UIDeviceOrientationPortraitUpsideDown || activeOrientation == UIDeviceOrientationUnknown || activeOrientation == UIDeviceOrientationFaceUp || activeOrientation == UIDeviceOrientationFaceDown) return;
	
	rotating = YES;

	UIScrollView *scrollView = (UIScrollView *)[self view];

	if (activeOrientation == UIDeviceOrientationPortrait) {
		[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * ([imageList count] + 1), scrollView.frame.size.height)];
		[scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * activeIndex, 0.0)];
	} else {
		[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height * ([imageList count] + 1))];
		
		if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
			[scrollView setContentOffset:CGPointMake(0.0, scrollView.frame.size.height * activeIndex)];
		} else {
			[scrollView setContentOffset:CGPointMake(0.0, scrollView.frame.size.height * ([imageList count] - 1 - activeIndex))];
		}
	}

	if (zooming) {
		zooming = NO;
		
		scrollView.pagingEnabled = YES;
		scrollView.directionalLockEnabled = YES;
	}
	
	CGFloat angle;
	
	if (activeOrientation == UIDeviceOrientationPortrait) {
		angle = 0.0;
	} else if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
		angle = M_PI / 2.0;
	} else if (activeOrientation == UIDeviceOrientationLandscapeRight) {
		angle = -M_PI / 2.0;
	}
	
	for (UIView *subView in scrollView.subviews) {
		if ([subView isKindOfClass:[PhotoView class]]) {
			if (subView.tag == activeIndex) {
				if (activeOrientation == UIDeviceOrientationPortrait) {
					subView.center = CGPointMake(subView.tag * scrollView.frame.size.width + subView.frame.size.width / 2, subView.frame.size.height / 2);
				} else if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
					subView.center = CGPointMake(subView.frame.size.width / 2, subView.tag * scrollView.frame.size.height + subView.frame.size.height / 2);
				} else if (activeOrientation == UIDeviceOrientationLandscapeRight) {
					subView.center = CGPointMake(subView.frame.size.width / 2, ([imageList count] - 1 - subView.tag) * scrollView.frame.size.height + subView.frame.size.height / 2);
				}
				
				[UIView beginAnimations:@"rotateActiveView" context:NULL];
				[UIView setAnimationDuration:0.5];
			}
			
			subView.transform = CGAffineTransformMakeRotation(angle);
			
			CGPoint position;
			
			if (activeOrientation == UIDeviceOrientationPortrait) {
				position = CGPointMake(subView.tag * scrollView.frame.size.width, 0.0);
			} else if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
				position = CGPointMake(0.0, subView.tag * scrollView.frame.size.height);
			} else if (activeOrientation == UIDeviceOrientationLandscapeRight) {
				position = CGPointMake(0.0, ([imageList count] - 1 - subView.tag) * scrollView.frame.size.height);
			}

			subView.frame = CGRectMake(position.x, position.y, (scrollView.frame.size.width - 15.0), scrollView.frame.size.height - 15.0);

			if (subView.tag == activeIndex) {
				[[(PhotoView *)subView label] setHidden:YES];
				[[(PhotoView *)subView infoButton] setHidden:YES];
			} else {
				[(PhotoView *)subView setOrientation:activeOrientation];
				[(PhotoView *)subView resetScale];
			}
			
			if (subView.tag == activeIndex) {
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(didRotate)];
				[UIView commitAnimations];
			}
		} else if ([subView isKindOfClass:[ArticleView class]]) {
			if (activeOrientation == UIDeviceOrientationPortrait) {
				[subView setFrame:CGRectMake(0.0, 0.0, subView.frame.size.width, subView.frame.size.height)];
			} else if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
				[subView setFrame:CGRectMake(0.0, 0.0, subView.frame.size.width, subView.frame.size.height)];
			} else if (activeOrientation == UIDeviceOrientationLandscapeRight) {
				[subView setFrame:CGRectMake(0.0, ([imageList count] - 1) * scrollView.frame.size.height, subView.frame.size.width, subView.frame.size.height)];
			}
		}
	}
	
	if (activeIndex == 0) {
		[self didRotate];
	} else {
		[self hideInterface];
	}
}


- (void)addPhoto:(NSUInteger)indexNum {
	Photo *photo = [imageList objectAtIndex:indexNum];
	PhotoView *imageView = [[PhotoView alloc] initWithFrame:CGRectZero];

	imageView.photo = photo;
	imageView.tag = indexNum + 1;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.userInteractionEnabled = YES;
	imageView.delegate = self;
	imageView.orientation = activeOrientation;
	imageView.backgroundColor = [UIColor blackColor];
	
	if (activeOrientation == UIDeviceOrientationPortrait || activeOrientation == 0) {
		imageView.frame = CGRectMake((indexNum + 1) * self.view.frame.size.width, 0.0, (self.view.frame.size.width - 15.0), (self.view.frame.size.height - 15.0));
	} else if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
		imageView.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
		imageView.frame = CGRectMake(0.0, (indexNum + 1) * self.view.frame.size.height, (self.view.frame.size.width - 15.0), (self.view.frame.size.height - 15.0));
	} else if (activeOrientation == UIDeviceOrientationLandscapeRight) {
		imageView.transform = CGAffineTransformMakeRotation(-M_PI / 2.0);
		imageView.frame = CGRectMake(0.0, ([imageList count] - 1 - (indexNum + 1)) * self.view.frame.size.height, (self.view.frame.size.width - 15.0), (self.view.frame.size.height - 15.0));
	}
	
	[self.view addSubview:imageView];
	[imageViewsList replaceObjectAtIndex:indexNum withObject:imageView];
	
	[imageView release];
}


- (void)doneLoadingPage:(NSString *)htmlData {
	NSArray *firstPhotoMatch = [htmlData captureComponentsMatchedByRegex:RE_FIRST_PHOTO];
	
	if (firstPhotoMatch != nil) {
		Photo *photo = [[Photo alloc] init];
		
		photo.url = [NSURL URLWithString:[firstPhotoMatch objectAtIndex:1]];
		photo.caption = [[firstPhotoMatch objectAtIndex:2] stringByReplacingOccurrencesOfRegex:RE_HTML withString:@""];
		
		[imageList addObject:photo];
		[imageViewsList addObject:[NSNull null]];
		
		[photo release];
	}
	
	NSArray *photoMatches = [htmlData arrayOfCaptureComponentsMatchedByRegex:RE_PHOTO];
	
	for (NSArray *photoMatch in photoMatches) {
		Photo *photo = [[Photo alloc] init];
		
		photo.url = [NSURL URLWithString:[photoMatch objectAtIndex:1]];
		photo.caption = [[photoMatch objectAtIndex:3] stringByReplacingOccurrencesOfRegex:RE_HTML withString:@""];
		photo.graphic = [[photoMatch objectAtIndex:2] isEqualToString:@"imghide"];
		
		[imageList addObject:photo];
		[imageViewsList addObject:[NSNull null]];
		
		[photo release];
	}
	
	UIScrollView *scrollView = (UIScrollView *)[self view];
	
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * ([imageList count] + 1), scrollView.contentSize.height)];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[loadingIndicator stopAnimating];
	
	if ([imageList count] > 0) [self addPhoto:0];
	if ([imageList count] > 1) [self addPhoto:1];
}


- (void)prepNeighbours {
	if (zooming || rotating || activeIndex < 1 || [imageList count] == 0) return;
	
	if ((NSNull *)[imageViewsList objectAtIndex:activeIndex - 1] == [NSNull null]) {
		[self addPhoto:activeIndex - 1];
	}
	
	if (activeIndex > 2) {
		UIView *previousView = [imageViewsList objectAtIndex:activeIndex - 3];

		if ((NSNull *)previousView != [NSNull null]) {
			[previousView removeFromSuperview];
			
			[imageViewsList replaceObjectAtIndex:activeIndex - 3 withObject:[NSNull null]];
		}
	}
	
	if (activeIndex < [imageList count] - 4) {
		UIView *nextView = [imageViewsList objectAtIndex:activeIndex + 1];

		if ((NSNull *)nextView != [NSNull null]) {
			[nextView removeFromSuperview];
			
			[imageViewsList replaceObjectAtIndex:activeIndex + 1 withObject:[NSNull null]];
		}
	}
	
	if (activeIndex < [imageList count] && (NSNull *)[imageViewsList objectAtIndex:activeIndex] == [NSNull null]) {
		[self addPhoto:activeIndex];
	}
	
	if (activeIndex > 1 && (NSNull *)[imageViewsList objectAtIndex:activeIndex - 2] == [NSNull null]) {
		[self addPhoto:activeIndex - 2];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (zooming || rotating) return;

	if (activeOrientation == UIDeviceOrientationPortrait || activeOrientation == 0) {
		activeIndex = (scrollView.contentOffset.x < 0.0) ? 0 : floor(scrollView.contentOffset.x / scrollView.frame.size.width);
	} else if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
		activeIndex = (scrollView.contentOffset.y < 0.0) ? 0 : floor(scrollView.contentOffset.y / scrollView.frame.size.height);
	} else if (activeOrientation == UIDeviceOrientationLandscapeRight) {
		activeIndex = (scrollView.contentOffset.y < 0.0) ? 0 : [imageList count] - 1 - floor(scrollView.contentOffset.y / scrollView.frame.size.height);
	}

	if (activeIndex == 0) {
		if (hideTimer != nil) {
			[hideTimer invalidate];
			
			hideTimer = nil;
		}
		
		if (self.navigationController.navigationBar.alpha == 0.0) [self showInterface];
	} else {
		if (self.navigationController.navigationBar.alpha > 0.0 && hideTimer == nil) {
			hideTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideInterface) userInfo:nil repeats:NO];
		}
	}
	
	[self prepNeighbours];
}


- (void)didBeginZoomingOnView:(PhotoView *)view {
	[(UIScrollView *)[self view] setScrollEnabled:NO];
}


- (void)didEndZoomingOnView:(PhotoView *)view withCenterPoint:(CGPoint)centerPoint {
	UIScrollView *scrollView = (UIScrollView *)[self view];
	CGFloat viewHeight = (view.frame.size.height < scrollView.frame.size.height - 15.0) ? scrollView.frame.size.height - 15.0 : view.frame.size.height;
	CGFloat viewWidth = (view.frame.size.width < scrollView.frame.size.width - 15.0) ? scrollView.frame.size.width - 15.0 : view.frame.size.width;
	
	scrollView.scrollEnabled = YES;

	if (view.currentZoomScale <= 1.0) {
		zooming = NO;
		
		scrollView.pagingEnabled = YES;
		scrollView.directionalLockEnabled = YES;
		scrollView.contentInset = UIEdgeInsetsZero;
		
		if (activeOrientation == UIDeviceOrientationPortrait || activeOrientation == 0) {
			view.frame = CGRectMake(scrollView.frame.size.width * view.tag, 0.0, viewWidth, viewHeight);
			
			[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * ([imageList count] + 1), scrollView.frame.size.height)];
			[scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * view.tag, 0.0)];
		} else {
			[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height * ([imageList count] + 1))];
			
			if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
				view.frame = CGRectMake(0.0, scrollView.frame.size.height * view.tag, viewWidth, viewHeight);
				[scrollView setContentOffset:CGPointMake(0.0, scrollView.frame.size.height * view.tag)];
			} else {
				view.frame = CGRectMake(0.0, scrollView.frame.size.height * ([imageList count] - 1 - view.tag), viewWidth, viewHeight);
				[scrollView setContentOffset:CGPointMake(0.0, scrollView.frame.size.height * ([imageList count] - 1 - view.tag))];
			}
		}
	} else {
		zooming = YES;
		
		CGFloat centerX = (view.frame.size.width < scrollView.frame.size.width - 15.0) ? 0.0 : centerPoint.x + 8.0 - scrollView.frame.size.width / 2;
		CGFloat centerY = (view.frame.size.height < scrollView.frame.size.height - 15.0) ? 0.0 : centerPoint.y - scrollView.frame.size.height / 2;
		
		view.frame = CGRectMake(0.0, 0.0, viewWidth, viewHeight);
		
		scrollView.pagingEnabled = NO;
		scrollView.directionalLockEnabled = NO;
		scrollView.contentInset = UIEdgeInsetsZero;
		scrollView.contentSize = view.frame.size;
		
		if (centerX + scrollView.frame.size.width > scrollView.contentSize.width) centerX = scrollView.contentSize.width - scrollView.frame.size.width;

		scrollView.contentOffset = CGPointMake(MAX(centerX, 0.0), MAX(centerY, 0.0));
	}

	for (UIView *subView in scrollView.subviews) {
		if ([subView isKindOfClass:[ArticleView class]] || ([subView isKindOfClass:[PhotoView class]] && subView.tag != view.tag)) {
			if (activeOrientation == UIDeviceOrientationPortrait || activeOrientation == 0) {
				CGFloat x;
				
				if (subView.tag < view.tag) {
					x = view.frame.origin.x - (view.tag - subView.tag) * scrollView.frame.size.width;
				} else if (subView.tag > view.tag) {
					x = view.frame.origin.x + view.frame.size.width + 15.0 + (subView.tag - view.tag - 1) * scrollView.frame.size.width;
				}
				
				subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
			} else {
				CGFloat y;
				CGFloat x = (zooming) ? (view.frame.size.width - subView.frame.size.width) / 2: 0.0;
				
				if (activeOrientation == UIDeviceOrientationLandscapeLeft) {
					if (subView.tag < view.tag) {
						y = view.frame.origin.y - (view.tag - subView.tag) * scrollView.frame.size.height;
					} else if (subView.tag > view.tag) {
						y = view.frame.origin.y + view.frame.size.height + 15.0 + (subView.tag - view.tag - 1) * scrollView.frame.size.height;
					}
				} else {
					if (subView.tag < view.tag) {
						y = view.frame.origin.y + view.frame.size.height + 15.0 + (view.tag - subView.tag - 1) * scrollView.frame.size.height;
					} else if (subView.tag > view.tag) {
						y = view.frame.origin.y - (subView.tag - view.tag) * scrollView.frame.size.height;
					}
				}
				
				subView.frame = CGRectMake(x, y, subView.frame.size.width, subView.frame.size.height);
			}
		}
	}
}


- (void)didSingleTapOnView:(PhotoView *)view withPoint:(CGPoint)point {
	hideTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(showInterface) userInfo:nil repeats:NO];
}


- (void)didDoubleTapOnView:(PhotoView *)view withPoint:(CGPoint)point {
	if (hideTimer != nil) {
		[hideTimer invalidate];
		
		hideTimer = nil;
	}
	
	[self didEndZoomingOnView:view withCenterPoint:point];
}


- (void)connectionDidFail:(URLCacheConnection *)theConnection {
	[activeConnection release];
	activeConnection = nil;
}


- (void)connectionDidFinish:(URLCacheConnection *)theConnection {
	NSString *htmlData = [[NSString alloc] initWithData:theConnection.receivedData encoding:NSASCIIStringEncoding];

	[self doneLoadingPage:htmlData];
	
	[htmlData release];
	[activeConnection release];
	activeConnection = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[article release];
	[loadingIndicator release];
	[imageList release];
	[imageViewsList release];
	
	if (activeConnection) {
		[activeConnection cancelConnection];
		[activeConnection release];
	}
	
    [super dealloc];
}

@end
